require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare :redmine_eupathdb do
	require_dependency 'issue' 
	unless Issue.included_modules.include? RedmineEupathdb::IssuePatch
		Issue.send(:include, RedmineEupathdb::IssuePatch)
	end
end

RAILS_DEFAULT_LOGGER.info 'Starting EuPathDB plugin'

Redmine::Plugin.register :redmine_eupathdb do
  name 'Redmine EuPathDB plugin'
  author 'EuPathDB'
  description 'This is a plugin for Redmine that adds functionality specific to the EuPathDB Redmine Instance'
  version '0.0.1'
  url 'http://eupathdb.org'
  author_url 'http://eupathdb.org'
end
