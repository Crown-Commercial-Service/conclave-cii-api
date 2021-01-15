Rails.application.routes.draw do
  apipie
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'home#index'
  get '/identities/schemes/organisation', to: 'api/v1/organisations#search_organisation'
  post '/identities/schemes/organisation', to: 'api/v1/create_organisations#index'
  get '/identities/schemes', to: 'api/v1/schemes#schemes'
  namespace :api do
    namespace :v1 do
      get '/identities/schemes/organisation', to: 'organisations#search_organisation'
      post '/identities/schemes/organisation', to: 'organisations#add_organisation'
      get '/identities/schemes', to: 'schemes#schemes'
    end
  end
end
