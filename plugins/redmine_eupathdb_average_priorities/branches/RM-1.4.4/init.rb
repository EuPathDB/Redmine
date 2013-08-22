require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare :redmine_eupathdb do
	require_dependency 'issue' 
	unless Issue.included_modules.include? RedmineEupathdb::IssuePatch
		Issue.send(:include, RedmineEupathdb::IssuePatch)
	end
end

RAILS_DEFAULT_LOGGER.info 'Starting Redmine Eupathdb Average Priorities plugin'

Redmine::Plugin.register :redmine_eupathdb_average_priorities do
  name 'Redmine Eupathdb Average Priorities plugin'
  author 'EuPathDB'
  description 'This is a plugin for Redmine that adds the capability to average PI priorities'
  version '0.0.1'
  url 'http://eupathdb.org'
  author_url 'http://eupathdb.org'
end
