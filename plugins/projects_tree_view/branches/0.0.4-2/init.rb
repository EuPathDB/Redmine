require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'
require 'projectstreeview_projects_helper_patch'
Dispatcher.to_prepare do
  ProjectsHelper.send(:include, ProjectstreeviewProjectsHelperPatch)
end

Redmine::Plugin.register :projects_tree_view do
  name 'Projects Tree and Priorities View plugin'
  author 'Chris Peterson - EuPathDB'
  description 'This is a Redmine plugin which will turn the projects page into a tree view; it also adds a tab called Priorities for a more detailed project view'
  version '0.0.4-1'

  menu :top_menu, :projectspis, { :controller => 'projectspis', :action => 'index' }, :caption => 'Devel/Infra Priorities'
  menu :top_menu, :datapis, { :controller => 'datapis', :action => 'index' }, :caption => 'Data Priorities'
end

class ProjectsTreeViewListener < Redmine::Hook::ViewListener

  # Adds javascript and stylesheet tags
  def view_layouts_base_html_head(context)
    javascript_include_tag('projects_tree_view', :plugin => :projects_tree_view) +
    stylesheet_link_tag('projects_tree_view', :plugin => :projects_tree_view)
  end
  
end


