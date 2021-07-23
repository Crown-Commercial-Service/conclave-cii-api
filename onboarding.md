<br>
<div align="center">
  <div align="center"><h1>Conclave-CII Onboarding Documentation</h1>A guide for any new developer to begin developing on the conclave cii api project.</div>
  <div align="right">
    <br>
    <a href="https://github.com/Crown-Commercial-Service/conclave-cii-api/blob/main/README.md"><strong>Documentation »</strong></a>
    <br>
    <a href="https://github.com/Crown-Commercial-Service/conclave-cii-api/issues">Report Bug</a>
    ·
    <a href="https://github.com/Crown-Commercial-Service/conclave-cii-api/issues">Request Feature</a>
  </div>
</div>



<!-- TABLE OF CONTENTS -->
<details open="open" style="padding:4px;display:inline;border-width:1px;border-style:solid;">
  <summary><b style="display: inline-block"><u>Contents</u></b></summary>
    <ol>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#authorization">Authorization</a></li>
    </ol>
</details><hr><br>



<!-- #prerequisites -->
## Prerequisites
You must have the following technologies installed on your development machine, in order to get started. Specific instructions will depend on your system:

<br>

* [Ruby](https://www.ruby-lang.org/en/documentation/installation/)
* [Ruby-on-Rails](https://guides.rubyonrails.org/v5.0/index.html) - This project is written in ruby using the Rails framework.

Version: It is recommended you install a ruby version manager like [RVM](https://rvm.io/) or [RBENV](https://github.com/rbenv/rbenv), to manage your current ruby version to match the project's. [The ruby version can be found here.](Gemfile)<br>Ensure both ruby and rails are installed successfully by executing the following two commands:
```sh
    ruby -v && rails -v

    Output-> Rails x.x.x.x
    Output-> ruby x.x.x (xxxx-xx-xx revision xxxxxxxx) [...]
```

<br>

* [PostgreSQL](https://www.postgresql.org/) - The project is supported by a PSQL (and reddis) database, and in order to interact with user created records, PSQL should be installed on your system. It is not necessary to run the project, however, as rails handle the infrastructure.<br>
You can check whether PSQL is installed on your system with:
```sh
    psql --version

    Output-> psql (PostgreSQL) x.x (...)
```

<br>

* [Rollbar](https://rollbar.com/) - Error logging handled and reported by Rollbar. A request should be put in to Tech Ops or Internal IT, to request to be added to the 'crowncommercial' organisation, as well as the 'Conclave-CII-API' project inside the org.

<br>

* [Cloud Foundry Cli V7](https://github.com/cloudfoundry/cli/wiki/V7-CLI-Installation-Guide) - Command Line Interface for CF, required to manage the application's deployment environments.<br>
You can check CF Cli v7 successfully installed by executing the follwing:
```sh
    cf -v

    Output-> cf version x.x.x...
```

Cloud Foundry GOV.UK PaaS Login: In order to get access to the GOV.UK PaaS api, and any hosted apps, CF cli requires you to login with a username and password, in the following way:
```sh
    cf login -a api.london.cloud.service.gov.uk -u <USERNAME> -p <PASSWORD>
```
Ensure you have [GOV.UK PaaS account](https://docs.cloud.service.gov.uk/get_started.html#get-an-account), and also have access to the 'ccs-conclave-cii' organisation. If you do not yet have access to the organisation (i.e. it is not an option on the org selection screen immediately after loggin in), then make a request to Tech Ops or Internal IT, and ask for access to the organisation.<br>After successfully loggin in, if all is correct, you should be able to see:
```sh
    Select an org:
    n. ccs-conclave-cii

    Org (enter to skip):
```

<br><hr><br>



<!-- #installation -->
## Installation
If you do not have access to both the [Crown-Commercial-Service](https://github.com/Crown-Commercial-Service) organisation on github, or the [conclace-cii-api](https://github.com/Crown-Commercial-Service/conclave-cii-api) repository, then a request to Internal IT should be made, to gain access access.

[Download the project repository](https://github.com/Crown-Commercial-Service/conclave-cii-api.git) and unzip, or git clone it:
  ```sh
  git clone https://github.com/Crown-Commercial-Service/conclave-cii-api.git
  ```
Navigate to the newly downloaded repo:
  ```sh
  cd conclave-cii-api
  ```
<i>[Optional]</i> If you are using a ruby version manager, download and select the [matching version to the project](Gemfile):
  ```sh
  rvm install x.x.x
  rvm use x.x.x
  ```
Install application:
  ```sh
  bundle install
  ```
Initialise the user Database:
  ```sh
  RAILS_ENV=test bundle exec rake db:create
  RAILS_ENV=test bundle exec rake db:migrate
  RAILS_ENV=test bundle exec rake db:seed
  ```
Create an empty '.env.local file', or rename '.env.test', in the project's root folder, locally. Copy and paste the secrets available from another dev, or the the vault backing service, for the environment you are running in, which in this case is "dev" (development). If you do not have access to the vault, then Tech Ops can assist with this.<br>When ready, to start the project run:
  ```sh
  rails s
  ```

Once the project is successfully running, you may encounter a 401 authorization when attempting to make a request to any. This will occur any time the database is reset/dropped, and as such you will need to follow the steps just below, in [Authorization](#authorization) below, to re-authorize.

<br><hr><br>



<!-- #authorization -->
## Authorization
Whenever the project is deployed to a brand new environment in Cloud Foundry, or also a new local environment, you must authorize the app by the using the rails console with the following steps:
  ```sh
  bundle install
  cd conclave-cii-api/app
  rails c
  (main)> Client.create(name: "Dev team", description: "CCS CII API team testing for dev team", active: true)

  Output-> \#<Client id: x, name: "Dev team", description: "CCS CII API team...", api_key: "xxxxxxxxxxxxxxxxxxxxxx...", active: true, ...>

  (main)> quit
  ```
This "api_key" contained in that body of data is the 'x-api-key' request parameter, when making any calls to the cii api.

<br><hr><br>