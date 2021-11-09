Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'home#index'
  get '/identities/schemes', to: 'api/v1/schemes#schemes'
  get '/identities/schemes/:scheme/identifiers/:id', to: 'api/v1/organisations#search_organisation'
  put '/identities/organisations/:organisationId/schemes/:scheme/identifiers/:id', to: 'api/v1/update_organisations#index'
  get '/identities/organisations/:organisationId/schemes/:scheme/identifiers/:id', to: 'api/v1/manage_organisations#search_organisation'
  get '/identities/organisations/:organisationId', to: 'api/v1/registered_organisations_schemes#search_organisation'
  get '/identities/organisations/:organisationId/all', to: 'api/v1/all_registered_organisations_schemes#search_organisation'
  delete '/identities/organisations/:organisationId/schemes/:scheme/identifiers/:id', to: 'api/v1/remove_organisations_additional_identifier#delete_additional_identifier'
  delete '/identities/organisations/:organisationId', to: 'api/v1/remove_organisations#delete_organisation'
  #get '/identities/organisations/sso/:organisationId/all', to: 'api/v1/utilities/all_registered_organisations_schemes#search_all_organisation'
  post '/identities/organisations/schemes/:account_id_type/identifiers/:account_id', to: 'api/v1/data_migration#create_org_profile'
  get '/identities/organisations/schemes/codes', to: 'api/v1/data_migration_schemes#dm_schemes_helper'
  post '/identities/organisations', to: 'api/v1/create_organisations#index'

  # these are testing endpoint will be removed on live
  namespace :api do
    namespace :v1 do
      namespace :testing do
        delete '/identities/schemes/organisation', to: 'crud_testing#remove_orginisation'
        get '/search/identities/schemes/organisation', to: 'crud_testing#search_org'
      end
    end
  end

  # Mock routes
  namespace :api do
    namespace :v1 do
      namespace :mock do
        get '/identities/schemes/:scheme/identifiers/:id', to: 'organisations_mock#search_organisation'
        post '/identities/organisations', to: 'create_organisations_mock#index'
        get '/identities/schemes', to: 'schemes_mock#schemes'
        delete '/identities/organisations/:organisationId/schemes/:scheme/identifiers/:id', to: 'remove_organisations_additional_identifier_mock#delete_additional_identifier'
        delete '/identities/organisations/:organisationId', to: 'remove_organisations_mock#delete_organisation'
        put '/identities/organisations/:organisationId/schemes/:scheme/identifiers/:id', to: 'update_organisations_mock#index'
        get '/identities/organisations/:organisationId/schemes/:scheme/identifiers/:id', to: 'manage_organisations_mock#search_organisation'
        get '/identities/organisations/:organisationId', to: 'registered_organisations_schemes_mock#search_organisation'
        get '/identities/organisations/:organisationId/all', to: 'all_registered_organisations_schemes_mock#search_organisation'
        post '/identities/organisations/schemes/:account_id_type/identifiers/:account_id', to: 'data_migration_mock#create_org_profile'
        get '/identities/organisations/schemes/codes', to: 'api/v1/data_migration_schemes_mock#dm_schemes_helper'
      end
    end
  end
end
