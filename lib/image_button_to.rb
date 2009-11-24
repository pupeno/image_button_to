# Copyright (c) 2009 José Pablo Fernández Silva. See LICENSE for details.

module ImageButtonTo

  # Generates a form containing a single image button that submits to the URL
  # created by the set of +options+. This is the safest method to ensure links
  # that cause changes to your data are not triggered by search bots or
  # accelerators.
  #
  # The generated form element has a class name of <tt>image-button-to</tt> to
  # allow styling of the form itself and its children. You can control the
  # form submission and input element behavior using +html_options+. This
  # method accepts the <tt>:method</tt> and <tt>:confirm</tt> modifiers
  # described in the +link_to+ documentation. If no <tt>:method</tt> modifier
  # is given, it will default to performing a POST operation. You can also
  # disable the button by passing <tt>:disabled => true</tt> in
  # +html_options+. If you are using RESTful routes, you can pass the
  # <tt>:method</tt> to change the HTTP verb used to submit the form.
  #
  # ==== Options
  # The +options+ hash accepts the same options as url_for.
  #
  # There are a few special +html_options+:
  # * <tt>:method</tt> - Specifies the anchor name to be appended to the path.
  # * <tt>:disabled</tt> - Specifies the anchor name to be appended to the
  #   path.
  # * <tt>:confirm</tt> - This will add a JavaScript confirm prompt with the
  #   question specified. If the user accepts, the link is processed normally,
  #   otherwise no action is taken.
  #
  # ==== Examples
  #   <%= button_to "new.png", :action => "new" %>
  #   # => "<form method="post" action="/controller/new" class="image-button-to">
  #   #      <div><input src="/images/new.png?1257839010" type="image" /></div>
  #   #    </form>"
  #
  #   button_to "delete.png", { :action => "delete", :id => @image.id },
  #             :confirm => "Are you sure?", :method => :delete
  #   # => "<form method="post" action="/images/delete/1" class="image-button-to">
  #   #      <div>
  #   #        <input type="hidden" name="_method" value="delete" />
  #   #        <input onclick="return confirm('Are you sure?');"
  #   #              src="/images/new.png?1257839010" type="image" />
  #   #      </div>
  #   #    </form>"
  def image_button_to(source, options = {}, html_options = {})
    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))
    
    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end
    
    form_method = method.to_s == 'get' ? 'get' : 'post'
    
    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end
    
    if confirm = html_options.delete("confirm")
      html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
    end
    
    url = options.is_a?(String) ? options : self.url_for(options)
    
    "<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button-to\"><div>" +
    method_tag + image_submit_tag(source, html_options) + request_token_tag + "</div></form>"
  end
  
  def image_button_to_remote(source, options = {}, html_options = {})
    image_button_to_function(source, remote_function(options), html_options)
  end
  
  def image_button_to_function(source, *args, &block)
    html_options = args.extract_options!.symbolize_keys
    
    function = block_given? ? update_page(&block) : args[0] || ''
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function};"
    
    image_submit_tag(source, html_options.merge(:onclick => onclick))
  end
end

ActionController::Base.class_eval do
  helper ImageButtonTo
end