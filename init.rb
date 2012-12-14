require 'redmine'
require 'bootstrap_hooks'
require 'application_helper_patch'
require 'settings_helper_patch'

Redmine::Plugin.register :redmine_bootstrap do
  name 'Redmine Bootstrap theme plugin'
  author 'Reuben Mallaby'
  description 'This is a plugin modifying Redmine to use a Bootstrap theme'
  version '0.0.3'
  url 'http://mallaby.me/projects/redmine_bootstrap'
  author_url 'http://mallaby.me'
   
  requires_redmine :version_or_higher => '2.1.0'
end
