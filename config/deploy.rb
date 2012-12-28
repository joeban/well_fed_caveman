require 'bundler/capistrano'

#========================
# CONFIG
#========================
set :application, "well_fed_caveman"
 
set :scm, :git
set :git_enable_submodules, 1
set :repository, "git@github.com:joeban/well_fed_caveman"
set :branch, "master"
set :ssh_options, { :forward_agent => true }
 
set :stage, :production
set :user, "deploy"
set :use_sudo, false
set :runner, "deploy"
set :deploy_to, "/var/www/well_fed_caveman"
set :app_server, :passenger
set :domain, "wellfedcaveman.com"

set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

set :normalize_asset_timestamps, false

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

#========================
# ROLES
#========================
role :app, domain
role :web, domain
role :db, domain, :primary => true

#========================
# CUSTOM
#========================
 
namespace :deploy do
  desc "Start Application"
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
 
  desc "Stop Application"
  task :stop, :roles => :app do
    # Do nothing.
  end
 
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "precompile the assets"
  task :assets, :roles => :web, :except => { :no_release => true } do
    run "cd #{current_path}; rm -rf public/assets/*"
    run "cd #{current_path}; RAILS_ENV=production bundle exec rake assets:precompile"
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
