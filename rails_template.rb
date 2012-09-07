## Rails App Template
## Run using $ rails new [appname] -d mysql -JTG -m template.rb

## Gems
gem "rake", "0.8.7" # http://twitter.com/#!/dhh/status/71966528744071169
gem "yajl-ruby"

# Haml & Sass
gem "haml", "~> 3.1.0"
gem 'haml-rails'
gem "compass", ">= 0.11.5"

# Forms
gem 'simple_form'

# Javascript
gem 'jquery-rails'
#gem 'barista'
#gem 'therubyracer', :require => nil

#gem 'mysql2'
#gem 'mysql2', '< 0.3'
#gem 'nifty-generators'
#gem 'capistrano'
#gem 'heroku_san', :group => :development


# Generators
#gem 'rails3-generators', :group => [:test, :cucumber]
gem 'rails3-generators', group: [:development, :test]
#gem 'rails3-generators', :git => 'git://github.com/maukoquiroga/rails3-generators.git', :group => [:development, :test]
#gem 'rails3-generators', :git => 'git://github.com/maukoquiroga/rails3-generators.git', :group => [:test]

# Auth
#gem 'devise'
#gem 'cancan'

# Versioning
#gem 'paper_trail'

# Testing
#gem "autotest", :group => [:test, :cucumber]
#gem "autotest-rails-pure", :group => [:test, :cucumber]
#gem "autotest-fsevent", :group => [:test, :cucumber]
#gem "autotest-growl", :group => [:test, :cucumber]
#gem 'rspec', :group => [:test, :cucumber]
gem 'rspec-rails',        group: [:development, :test]
#gem 'cucumber', :group => [:test, :cucumber]
#gem 'cucumber-rails', :group => [:test, :cucumber]
#gem 'gherkin', '2.3.2', :group => [:test, :cucumber]
gem 'capybara',           group: [:development, :test]
gem 'database_cleaner',   group: [:development, :test]
#gem 'factory_girl', :group => [:test, :cucumber]
gem 'factory_girl_rails', group: [:development, :test]
#gem 'launchy', :group => [:test, :cucumber]
gem 'spork',              group: [:development, :test]

#run 'bundle package'
run 'bundle install'
#run 'bundle check'

## Generators

inject_into_file('config/application.rb', :after => 'config.i18n.default_locale = :de') do
  %q{

    # Generator Settings
    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture_replacement => :factory_girl
    end

    # Global Sass Option
    Sass::Plugin.options[:template_location] = { 'app/stylesheets' => 'public/stylesheets' }
  }
end

#inject_into_file('config/application.rb', :after => 'config.i18n.default_locale = :de') do
#  %q{
#
#    # Generator Settings
#    config.generators do |g|
#      g.template_engine :haml
#    end
#
#    # Global Sass Option
#    Sass::Plugin.options[:template_location] = { 'app/stylesheets' => 'public/stylesheets' }
#  }
#end


## Run all the generators
generate 'rspec:install'
#generate 'cucumber:install --capybara --rspec --spork'
#generate 'cucumber:install --capybara --rspec'
generate 'jquery:install'
generate 'simple_form:install'
run 'spork --bootstrap'
#generate 'barista:install'

## Files
# Clear the default index
remove_file 'public/404.html'
remove_file 'public/422.html'
remove_file 'public/500.html'
remove_file 'public/index.html'
#remove_file 'public/favicon.ico'
remove_file 'public/images/rails.png'

# Make the SASS directory and base file
stylesheet = <<-STYLESHEET
@import blueprint/reset
@import partials/base
@import compass
@import compass/utilities
@import compass/layout
@import blueprint
@import partials/page

$background-color: #eee

body.two-columns
  background-color: $background-color

  #container
    +container

    #content
      +column($blueprint-grid-columns)
STYLESHEET

empty_directory 'app/stylesheets'
create_file 'app/stylesheets/application.sass', stylesheet
# Make the CofeeScript directory and base file
#empty_directory 'app/coffescripts'
#create_file 'app/coffescripts/application.coffee'

## Layout
layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    = styleshhet_link_tag 'application.css', :media => 'screen'
    = javascript_include_tag :defaults, jquery.min, rails
    = csrf_meta_tag
  %body.bp.two-columns
    #container
      #content= yield
LAYOUT

#layout = <<-LAYOUT
#!!!
#%html
#  %head
#    %title #{app_name.humanize}
#    = styleshhet_link_tag 'application.css', :media => 'screen'
#    = javascript_include_tag :defaults, jquery.min, rails
#    = csrf_meta_tag
#  %body.bp.two-columns
#    #topbar= render '/shared/topbar'
#    #container
#      #header= render '/shared/header'
#      #sidebar= render '/shared/sidebar'
#      #content= yield
#      #footer= render '/shared/footer'
#LAYOUT

remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.haml', layout
#empty_directory 'app/views/shared'
#create_file 'app/views/shared/_topbar.html.haml'
#create_file 'app/views/shared/_header.html.haml'
#create_file 'app/views/shared/_sidebar.html.haml'
#create_file 'app/views/shared/_footer.html.haml'

# Setup Factory_Girl
empty_directory 'spec/support'
create_file 'spec/factories/factories.rb'

#Nifty-Layout
#generate 'nifty:layout --haml'

#Compass Blue/Print
run 'compass init rails . --using blueprint/semantic --syntax sass'
empty_directory 'app/stylesheets/blueprint'
#run 'compass init rails .'

# Compile Sass in tmp
inject_into_file('config/compass.rb', :after => 'http_path = "/"') do
  %q{
css_dir   = 'tmp/stylesheets'
sass_dir  = 'app/stylesheets'
  }
end

create_file 'config/initializers/compass.rb'

#inject_into_file('config/initializers/compass.rb') do
#  %q{
#    require 'fileutils'
#    FileUtils.mkdir_p(Rails.root.join('tmp', 'stylesheets')
#
#    Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
#        :urls => ['/stylesheets'],
#        :root => '#{Rails.root}/tmp')
#  }
#end

# Require all libs in lib directory
requires = <<-REQUIRES
Dir[File.join(Rails.root, 'lib', '*.rb')].each do |f|
  require f
end
REQUIRES

create_file 'config/initializers/requires.rb', requires

#Autotest
#autotest = <<-AUTOTEST
#require 'autotest/growl'
#require 'autotest/fsevent'
#AUTOTEST

#create_file 'config/autotest.rb', autotest

# Capistrano
#run 'capify .'

# Mysql
#run 'cp config/database.yml config/database.yml.example'

# Devise & CanCan
#generate 'devise:install'
#generate 'devise user'
#generate 'cancan:ability'

#inject_into_file('app/controllers/application_controller.rb', :before => 'end') do
#  %q{
#before_filter :authenticate_user! # devise authentication
#check_authorization # cancan authorizations

#rescue_from CanCan::AccessDenied do |e|
#  render "pages/access_denied"
#end
#  }
#end

# has_many and belongs_to
#generate 'migration add_role_id_to_users role_id:integer'
#generate 'model role name:string'

#inject_into_file('app/models/user.rb', :before => 'end') do
#  %q{
#  belongs_to :role
#  }
#end

#inject_into_file('app/models/role.rb', :before => 'end') do
#  %q{
#  has_many :users
#  }
#end

# Versioning with Paper Trail
#generate 'paper_trail:install'
#generate 'controller versions'

#inject_into_file('app/controllers/versions_controllers.rb', :before => 'end') do
#  %q{
#  def revert
#    @version = Version.find(params[:id])
 #   @version.reify.save!
#    redirect_to :back
#  end
#  }
#end

# Dashboard
#generate 'controller pages dashboard access_denied'

# Routes
#inject_into_file('app/controllers/versions_controllers.rb', :before => 'end') do
#  %q{
#  post "versions/:id/revert" => "versions#revert", :as => "revert_version"
#  root :to => "pages#dashboard"
#  }
#end
