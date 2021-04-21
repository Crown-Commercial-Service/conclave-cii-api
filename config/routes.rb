Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'home#index'
  get '/identities/schemes/organisation', to: 'api/v1/organisations#search_organisation'
  get '/identities/schemes/identifiers', to: 'api/v1/organisations#search_organisation'
  post '/identities/schemes/organisation', to: 'api/v1/create_organisations#index'
  get '/identities/schemes', to: 'api/v1/schemes#schemes'
  delete '/identities/schemes/organisation', to: 'api/v1/remove_organisations_additional_identifier#delete_additional_identifier'
  delete '/identities/organisation', to: 'api/v1/remove_organisations#delete_organisation'
  put '/identities/schemes/organisation', to: 'api/v1/update_organisations#index'
  get '/identities/schemes/manageidentifiers', to: 'api/v1/manage_organisations#search_organisation'
  get '/identities/schemes/organisations', to: 'api/v1/registered_organisations_schemes#search_organisation'
  get '/identities/schemes/organisations/all', to: 'api/v1/all_registered_organisations_schemes#search_organisation'
  
  # these are testing endpoint will be removed on live
  namespace :api do
    namespace :v1 do
      namespace :testing do
        delete '/identities/schemes/organisation', to: 'crud_testing#remove_orginisation'
        get '/search/identities/schemes/organisation', to: 'crud_testing#search_org'
      end
    end
  end
  # these are Mock testing endpoint will be removed on live
  # namespace :api do
  #   namespace :v1 do
  #     namespace :mock do
  #       get '/identities/schemes/organisation', to: 'organisations_mock#search_organisation'
  #       get '/identities/schemes/identifiers', to: 'organisations_mock#search_organisation'
  #       post '/identities/schemes/organisation', to: 'create_organisations_mock#index'
  #       get '/identities/schemes', to: 'schemes_mock#schemes'
  #       delete '/identities/schemes/organisation', to: 'remove_organisations_additional_identifier_mock#delete_additional_identifier'
  #       delete '/identities/organisation', to: 'remove_organisations_mock#delete_organisation'
  #       put '/identities/schemes/organisation', to: 'update_organisations_mock#index'
  #       get '/identities/schemes/manageidentifiers', to: 'manage_organisations_mock#search_organisation'
  #       get '/identities/schemes/organisations', to: 'registered_organisations_schemes_mock#search_organisation'
  #       get '/identities/schemes/organisations/all', to: 'all_registered_organisations_schemes_mock#search_organisation'
  #     end
  #   end
  # end
end
