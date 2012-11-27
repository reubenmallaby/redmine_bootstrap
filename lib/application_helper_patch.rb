require_dependency 'application_helper'

module ApplicationHelper
  alias_method :pagination_links_full_without_bootstrap, :pagination_links_full
  alias_method :per_page_links_without_bootstrap, :per_page_links
  alias_method :progress_bar_without_bootstrap, :progress_bar
  alias_method :render_project_jump_box_without_bootstrap, :render_project_jump_box

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

  def progress_bar(pcts, options={})
    html = ""
    pcts = [pcts, pcts] unless pcts.is_a?(Array)
    pcts = pcts.collect(&:round)
    pcts[1] = pcts[1] - pcts[0]
    pcts << (100 - pcts[1] - pcts[0])
    legend = options[:legend] || ''
    html << "<div class='progress pourcent' title='#{legend} #{pcts[0]}%'>"
    html << "<div class='bar bar-success' style='width: #{pcts[0]}%;'></div>"
    html << "<div class='bar bar-warning' style='width: #{pcts[1]}%;'></div>"
    html << "<div class='bar bar-danger' style='width: #{pcts[2]}%;'></div>"
    html << "</div>"
    html.html_safe
  end

  def render_project_nested_lists(projects)
    s = ''
    if projects.any?
      ancestors = []
      original_project = @project
      projects.sort_by(&:lft).each do |project|
        # set the project environment to please macros.
        @project = project
        if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
          s << "<ul class='nolist projects #{ ancestors.empty? ? 'root' : nil}'>\n"
        else
          ancestors.pop
          s << "</li>"
          while (ancestors.any? && !project.is_descendant_of?(ancestors.last))
            ancestors.pop
            s << "</ul><br /><br /></li>\n"
          end
        end
        classes = (ancestors.empty? ? 'root' : 'child')
        s << "<li class='nolist #{classes}'><div class='#{classes}'>"
        s << h(block_given? ? yield(project) : project.name)
        s << "</div>\n"
        ancestors << project
      end
      s << ("</li></ul>\n" * ancestors.size)
      @project = original_project
    end
    s.html_safe
  end

      # modified from redmine_favourite_projects plugin
    def render_project_jump_box
      return unless User.current.logged?
      projects = User.current.memberships.collect(&:project).compact.uniq
      if projects.any?
        s = '<div class="btn-group">'
        s+= '<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">'
        s+= l(:label_jump_to_a_project)
        s+= '<span class="caret"></span>'
        s+= '</a>'
        s+= '<ul class="dropdown-menu">'
        projects.each do |project|
          s+= '<li>' + link_to(project.name, :controller => 'projects', :action => 'show', :id => project.id) + '</li>' 
        end
        s+= '</ul>'
        s+= '</div>'
        s.html_safe
      end
    end
  
end

