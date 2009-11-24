
module ImageButtonTo
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
    
    #tag(:input, html_options.merge(:type => 'image', :source => source, :onclick => onclick))
    image_submit_tag(source, html_options.merge(:onclick => onclick))
  end
end

ActionController::Base.class_eval do
  helper ImageButtonTo
end