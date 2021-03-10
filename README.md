# CONCLAVE CII API
This is the Conclave Central Identity Index (CII) API service.

## Nomenclature

- **OrganisationSchemeIdentifier**: identifier used for an organisation with a scheme
- **Scheme**: 
- **SchemeRegister**: 

## Technical documentation

This is a Ruby on Rails application that .... It's only presented as an internal API and doesn't face public users.

### Setup instructions
#### For OSX/macOS version 10.9 or higher

##### 1. Install command line tools on terminal

`xcode-select --install`

##### 2. Install Hombrew

`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

##### 3. Install rbenv

`brew update`
`brew install rbenv`
`echo 'eval "$(rbenv init -)"' >> ~/.bash_profile`
`source ~/.bash_profile`

##### 4. Build ruby 2.7.2 with rbenv

`rbenv install 2.7.2`
`rbenv global 2.7.2`

##### 5. Install rails 6.0.3
`gem install rails -v 6.0.3`

##### 6. Download and install Postgresql 10
Go to https://www.postgresql.org/ and download the installer

##### 7. Run bundle install
`bundle install`

If you get the following error: 
`pg_connection.c:2411:4: error: implicit declaration of function 'gettimeofday' is invalid in C99 [-Werror,-Wimplicit-function-declaration] gettimeofday(&currtime, NULL);`

Then run the pg installation as below, before running bundle install again:
`gem install pg -v '0.18.4' -- --with-cflags="-Wno-error=implicit-function-declaration"`

##### 8. Create, migrate and seed the database
Before you run the db commands, you need to make sure you have your .env.local file in your projects folder.
Then run:
`rake db:create && rake db:migrate && rake db:seed`

### Running the application

From your console run the rails server:
`rails s`

### Running the test suite

To run the specs, from your console do:
`rspec spec`
