# rails5

gem 'devise'
gem 'ridgepole'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'license_finder'
end

group :development do
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

# rspec
generate 'rspec:install'

## binstubを使ってrspecの起動を早くする
run 'bundle exec spring binstub rspec'

create_file '.rspec', <<EOF, force: true
  --require spec_helper
  --format documentation
EOF


# redgepole
rakefile('ridgepole.rake') do
  <<-TASK
    namespace :ridgepole do
      desc 'Apply database schema (options: DRYRUN=false, VERBOSE=false)'
      task apply: :environment do
        options = ['--apply']
        options << '--dry-run' if ENV['DRYRUN']
        options << '--verbose' if ENV['VERBOSE']
        ridgepole(*options, "--file #{schema_file}")
      end

      desc 'Export database schema'
      task export: :environment do
        options = ['--export']
        ridgepole(*options, "--split --output #{schema_file}" )
      end

      private

      def schema_file
        Rails.root.join('db', 'schemas', 'Schemafile')
      end

      def config_file
        Rails.root.join('config', 'database.yml')
      end

      def ridgepole(*options)
        command = ['bundle exec ridgepole', "--config #{config_file} --env #{Rails.env}"]
        system [command + options].join(' ')
      end
    end
  TASK
end

# devise
generate 'devise:install'
