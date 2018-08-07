# rails5

# gems
gem_group :default do
  gem 'devise'
  gem 'ridgepole'
end

gem_group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'license_finder'
end

gem_group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  gem 'rubocop'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'rack-mini-profiler'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'rufo'
  gem 'annotate'
end

# bundle install
run 'bundle install --path vendor/bundle --jobs=4'

# locales
remove_file 'config/locales/en.yml'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml -P config/locales/'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'

# config/application.rb
application do
  %q{
    config.generators.system_tests = nil
    config.i18n.default_locale = :ja
    config.time_zone = 'Tokyo'
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.view_specs false
      g.controller_specs false
      g.routing_specs false
      g.helper_specs false
      g.request_specs true
      g.assets false
      g.helper false
    end
  }
end

# rspec
generate 'rspec:install'

## binstubを使ってrspecの起動を早くする
run 'bundle exec spring binstub rspec'

file '.rspec', <<EOF, force: true
  --require spec_helper
  --format documentation
EOF
#run 'bundle binstubs rspec-core'
# db create
run 'bin/rake db:create'

# redgepole

file 'db/schemas/Schemafile'

rakefile('ridgepole.rake') do
  <<-TASK
    namespace :ridgepole do
      desc 'Apply database schema (options: DRYRUN=false, VERBOSE=false)'
      task apply: :environment do
        options = ['--apply']
        options << '--dry-run' if ENV['DRYRUN']
        options << '--verbose' if ENV['VERBOSE']
        ridgepole(*options, "--file \#{schema_file}")
      end

      desc 'Export database schema'
      task export: :environment do
        options = ['--export']
        ridgepole(*options, "--split --output \#{schema_file}" )
      end

      private

      def schema_file
        Rails.root.join('db', 'schemas', 'Schemafile')
      end

      def config_file
        Rails.root.join('config', 'database.yml')
      end

      def ridgepole(*options)
        command = ['bundle exec ridgepole', "--config \#{config_file} --env \#{Rails.env}"]
        system [command + options].join(' ')
      end
    end
  TASK
end

run 'bin/rake ridgepole:export'

# devise
generate 'devise:install'
