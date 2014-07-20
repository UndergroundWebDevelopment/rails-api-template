################
## Middleware ##
################

gem 'rack-cors', require: 'rack/cors'

###################
## Rails helpers ##
###################

gem 'bcrypt-ruby', '~> 3.1.2'

###################
## Database Gems ##
###################

gem 'pg' # Postgres.
gem 'activerecord-postgis-adapter'
gem 'rgeo' # Geo-data, for use with postgres

gem 'paranoia', '~> 2.0' # Paranoid delete
gem 'acts-as-taggable-on' # Models can be taggable.
gem 'annotate' # Annotates models with db schema.
gem 'paperclip', '~> 4.1' # Attachment handling (images).
gem 'kaminari' # Pagnination gem

####################################
## Authentication / Authorization ##
####################################

gem 'devise' # Authentication
gem 'devise-token_authenticatable' # Token auth.
gem "pundit" # Authorization

###################
## API Interface ##
###################

# gem 'associates', github: "phildionne/associates"
gem 'associates', github: "undergroundwebdesigns/associates" # Meta-models
gem 'roar-rails' # Representer library

##############
## Frontend ##
##############

gem 'requirejs-rails', github: 'jwhitley/requirejs-rails'
gem 'haml'
gem 'i18n-js' # I18n for JS files.

gem 'unicorn' # Rails server.

############
## Assets ##
############

gem_group :assets do
  gem 'bootstrap-sass', '~> 3.2.0'
  gem 'autoprefixer-rails'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'haml_coffee_assets', github: 'netzpirat/haml_coffee_assets'
  gem 'uglifier'
end

###########################
## 12 Factored Apps help ##
###########################

gem_group :production do
    gem 'rails_12factor'
end

######################
## Development Gems ##
######################

gem_group :development do
  gem 'coffee-rails-source-maps'
  gem 'thor'

  # Guard watches for file changes and automatically re-runs
  # tests. Brakeman watches for potential security issues.
  gem 'guard'
  gem 'guard-ctags-bundler'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'guard-coffeescript'
  gem 'brakeman', :require => false
  gem 'guard-brakeman'

  # Byebug is a debugger
  gem 'byebug'
end

######################
## Test Environment ##
######################

gem_group :test, :development do
  gem 'rspec'
  gem 'rspec-rails', '~> 2.0'
  gem 'spring-commands-rspec'

  # Provides a DSL for combination acceptance
  # tests + API documentation generators.
  gem 'rspec_api_documentation'

  gem 'factory_girl_rails', "~> 4.0"
  gem 'faker'

  gem "codeclimate-test-reporter", require: nil
  
  # Dotenv loads env variables from a .env file when the
  # environment is bootstraped.
  gem 'dotenv-deployment'
end

###################
## Documentation ##
###################

gem_group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

run "bundle install"


#######################
## Install and Setup ##
#######################

# Helper Methods
def copy_from_repo(filename, destination)
  repo = 'https://raw.github.com/UndergroundWebDevelopment/rails-api-template/master/files/'
  get repo + filename, destination
end

def generate_secret
  rake 'secret'
end

# Configure rails generators:
application <<-GENERATORS
config.generators do |g|
  g.views false
  g.helpers false
end
GENERATORS

# Setup rspec:
generate rspec:install

# Setup devise:
generate "devise:install"
model_name = ask("What would you like the user model to be called? [user]")
model_name = "user" if model_name.blank?
generate "devise", model_name

# Setup rails admin:
if yes?("Would you like to setup Rails Admin?")
  gem_group :admin, :development do
    gem 'rails_admin'
    gem "rails_admin_pundit", :github => "sudosu/rails_admin_pundit"
    gem "rails_admin_map_field", :github => "sudosu/rails_admin_map_field"
  end
  generate "rails_admin:install"
end

# Generates a config file for Kaminari:
generate "kaminari:config"

# Install annotate, so that it will auto-run on migrate:
generate "annotate:install"

# Copy config file for require-js into place:
if yes?("Generate chaplin frontend app?")
  file "Bowerfile", <<-CODE
  # Puts to ./vendor/assets/bower_components
  asset "backbone"
  asset "backbone-modelbinder"
  asset "backbone-validation"

  asset "bootstrap"
  asset "chaplin"
  asset "jquery"
  asset "lodash"
  CODE

  initializer "bower_rails.rb", <<-CODE
  BowerRails.configure do |bower_rails|
    # Invokes rake bower:install before precompilation. Defaults to false
    bower_rails.install_before_precompile = true
  end
  CODE

  copy_from_repo "rails_app_templates/config/requirejs.yml", "config/requirejs.yml"
  copy_from_repo "chaplin_app_template", "app/assets/javascripts"
end

# Copy base view:
copy_from_repo "rails_app_templates/views/application.html.haml", "app/views/application.html.haml"

# Copy DB config:
copy_from_repo 'rails_app_templates/config/database.yml', 'config/database.yml'
copy_from_repo 'rails_app_templates/config/secrets.yml', 'config/secrets.yml'
copy_from_repo 'rails_app_templates/env', '.env'
copy_from_repo 'rails_app_templates/Procfile', 'Procfile'

# Generate a postgres DB for this app and initialize it:
if run('which initdb') && $? == 0
  db_path = "vendor/postgresql"
  empty_directory db_path
  append_to_file ".gitignore", db_path
  run "initdb #{db_path}"
else
  say "initdb binary not found, not instantiating a project DB."
end

#########################
## Initialize Git Repo ##
#########################

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
