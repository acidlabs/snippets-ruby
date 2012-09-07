#Application
set :application, "application_name"

#Server
set :user,        "server_user_name"
set :server_path, "/path/to/public_html/"
set :port,        22 # SSH Port
set :use_sudo,    false

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true

#Git
set :scm,             :git
set :git_user,        "git_user_name"
set :scm_passphrase,  ""
set :repository,      "git@github.com:#{git_user}/#{application}.git"
set :branch,          "master" # change as fit your working branch

set :deploy_to, "#{server_path}#{application}"

role :app,  application
role :web,  application
role :db,   application , primary: true

set :deploy_via, :remote_cache # [ :remote_cache | :copy ]

set :database_username,     application
set :production_database,   application
set :development_database,  "#{application}_development"
set :test_database,         "#{application}_test"

#Tasks
namespace :db do
  desc "Create database yaml in shared path"
  task :configure do
    set :database_password do
      Capistrano::CLI.password_prompt "Database Password: "
    end

    db_config = <<-EOF
      development:
        adapter: mysql2
        encoding: utf8
        reconnect: false
        database: #{development_database}
        pool: 5
        username: #{database_username}
        password: #{database_password}
        socket: /var/run/mysqld/mysqld.sock

      test: &test
        adapter: mysql2
        encoding: utf8
        reconnect: false
        database: #{test_database}
        pool: 5
        username: #{database_username}
        password: #{database_password}
        socket: /var/run/mysqld/mysqld.sock

      production:
        adapter: mysql2
        encoding: utf8
        reconnect: false
        database: #{production_database}
        pool: 5
        username: #{database_username}
        password: #{database_password}
        socket: /var/run/mysqld/mysqld.sock

      cucumber:
        <<: *test
    EOF

    run "mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end

  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  desc "Create the database"
  task :create do
    run "cd #{latest_release} && rake RAILS_ENV=production db:create"
    run "cd #{latest_release} && rake RAILS_ENV=development db:create"
    run "cd #{latest_release} && rake RAILS_ENV=test db:create"
  end
end

#namespace :apache2 do
#  desc "Configure Virtual Host"
#  task :vhost do
#    vhost <<-EOF
#      <VirtualHost *:80>
#
#        ServerName  #{application}
#        ServerAlias *.#{application}
#
#        DocumentRoot #{current_path}/public
#
#        <Directory #{current_path}/public>
#              Options -MultiViews
#              AllowOverride All
#              Order allow,deny
#              Allow from all
#        </Directory>
#
#       CustomLog  "#{shared_path}/log/access_log" combined
#        ErrorLog   "#{shared_path}/log/error_log"
#
#      </VirtualHost>
#    EOF
#    put vhost, "~/src/#{application}"
#    sudo "mv ~/src/#{application} /etc/apache2/sites-available/#{application}"
#    sudo "a2ensite #{application}"
#  end

#  desc "Restart Apache2"
#  task :restart do
#    sudo "/etc/init.d/apache2 reload"
#  end
#end

#namespace :passenger do
#  desc "Reload Passenger"
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "touch #{current_path}/tmp/restart.txt"
#  end
#end

namespace :bundle do
  desc "Bundle Gemfile.lock"
  task :lock do
    run "cd #{latest_release} && bundle --without test"
  end

  desc "Bundle Install"
  task :install do
    run "cd #{latest_release} && bundle install"
  end
end

#namespace :deploy do
#  [:start, :stop, :restart].each do |t|
#    desc "#{t} task is a no-op with mod_rails"
#    task t, :roles => :app do
#      ;
#    end
#  end
#end

before "deploy:setup",      "db:configure"
before "deploy:cold",       "db:symlink"
before "deploy:cold",       "db:create"
after "deploy:cold",        "bundle:lock"
after "deploy:cold",        "apache:vhost"
after "deploy:cold",        "apache:restart"
# before "deploy",            "bundle:lock"
before "deploy",            "db:symlink"
# after "deploy",             "passenger:restart"
# after "deploy",             "deploy:cleanup"
before "deploy:migrations", "db:symlink"
# after "deploy:migrations",  "passenger:restart"
# after "deploy:migrations",  "deploy:cleanup"