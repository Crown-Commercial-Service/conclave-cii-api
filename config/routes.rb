Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'home#index'
  namespace :api do
    namespace :v1 do
      get '/identities/schemes/:scheme_id/organisation/page/:pageno/pagesize/:pagesize', to: 'identities_schemes_organisations#organisations'
      get '/identities/schemes/organisations/page/:page_no/pagesize/:pages_ize', to: 'identities_schemes_organisations#organisations'
      get '/identities/schemes/organisation', to: 'organisations#search_org'
      post '/identities/schemes/organisations', to: 'identities_schemes_organisations#organisations'
      get '/identities/schemes/organisations', to: 'identities_schemes_organisations#organisations'
      get '/identities/schemes', to: 'schemes#schemes'
      put '/identities/schemes/organisations', to: 'identities_schemes_organisations#organisations'
      delete '/identities/schemes/organisations', to: 'identities_schemes_organisations#organisations'
    end
  end
end
