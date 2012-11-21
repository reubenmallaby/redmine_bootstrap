require_dependency 'application_helper'

module ApplicationHelper
  alias_method :pagination_links_full_without_bootstrap, :pagination_links_full
  alias_method :per_page_links_without_bootstrap, :per_page_links
  
  def pagination_links_full(paginator, count=nil, options={})
    page_param = options.delete(:page_param) || :page
    per_page_links = options.delete(:per_page_links)
    options[:link_to_current_page] = true
    url_param = params.dup

    html = '<div class="pagination"><ul>'
    if paginator.current.previous
      html << "<li>#{link_to_content_update(l(:label_previous), url_param.merge(page_param => paginator.current.previous))}</li>"
    end

    html << (pagination_links_each(paginator, options) do |n|      
      "<li>#{link_to_content_update(n.to_s, url_param.merge(page_param => n))}</li>"
    end || '')

    if paginator.current.next
      html << "<li>#{link_to_content_update(l(:label_next), url_param.merge(page_param => paginator.current.next))}</li>"
    end

    unless count.nil?
      html << "<li><span>(#{paginator.current.first_item}-#{paginator.current.last_item}/#{count})</span></li>"
      if per_page_links != false && links = per_page_links(paginator.items_per_page, count)
        html << "#{links}"
      end
    end
    html << "</ul></div>"
    html.html_safe
  end
  
  def per_page_links(selected=10, item_count=nil)
    values = Setting.per_page_options_array
    if item_count && values.any?
      if item_count > values.first
        max = values.detect {|value| value >= item_count} || item_count
      else
        max = item_count
      end
      values = values.select {|value| value <= max || value == selected}
    end
    if values.empty? || (values.size == 1 && values.first == selected)
      return nil
    end
    links = values.collect do |n|
      n == selected ? "<li><span>#{n}</span></li>" : "<li>#{link_to_content_update(n, params.merge(:per_page => n))}</li>"
    end
    "<li><span>#{l(:label_display_per_page, links.join(''))}</span></li>"
    
  end
  
end

