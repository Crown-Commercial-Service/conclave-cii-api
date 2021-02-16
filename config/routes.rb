Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'home#index'
  get '/identities/schemes/organisation', to: 'api/v1/organisations#search_organisation'
  post '/identities/schemes/organisation', to: 'api/v1/create_organisations#index'
  get '/identities/schemes', to: 'api/v1/schemes#schemes'
  delete '/identities/schemes/organisation', to: 'api/v1/remove_organisations_aditional_identifier#delete_addtional_identifier'
  delete '/identities/organisation', to: 'api/v1/remove_organisations#delete_orginisation'
  put '/identities/schemes/organisation', to: 'api/v1/update_organisations#index'
  namespace :api do
    namespace :v1 do
      namespace :testing do
        delete '/identities/schemes/organisation', to: 'crud_testing#remove_orginisation'
        get '/search/identities/schemes/organisation', to: 'crud_testing#search_org'
      end
    end
  end
end