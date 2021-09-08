Rails.application.routes.draw do
  # Admin constraint
  admin_constraint = lambda do |request|
    request.env['warden'].authenticate? && request.env['warden'].user.admin?
  end
  non_admin_constraint = lambda do |request|
    request.env['warden'].authenticate? && !request.env['warden'].user.admin?
  end
  authenticated_constraint = lambda do |request|
    request.env['warden'].authenticate?
  end

  # This needs to be firt, but *before* admin and user contrained routes are configured
  devise_for :users

  constraints admin_constraint do
    root to: 'hyrax/dashboard#show'

    concern :exportable, Blacklight::Routes::Exportable.new
    concern :searchable, Blacklight::Routes::Searchable.new

    # Only admin users should be able to search
    resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
      concerns :searchable
    end
    mount BlacklightAdvancedSearch::Engine => '/'

    # Mount sidekiq web ui and require authentication by an admin user
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'

    resources :batches, controller: 'hyrax/batches', only: [:index, :show, :create]
    resources :eads, only: [:index]
    resources :metadata_exports,
              controller: 'hyrax/metadata_exports',
              only: [:create]
    resources :metadata_imports,
              controller: 'hyrax/metadata_imports',
              only: [:new, :create]
    resources :xml_imports,
              controller: 'hyrax/xml_imports',
              only: [:show, :create, :new, :edit, :update]
    resources :templates,
              controller: 'hyrax/templates',
              only: [:index, :destroy, :edit, :update, :new]
    resources :template_updates,
              controller: 'hyrax/template_updates',
              only: [:index, :new, :create]

    get '/metadata_exports/:id/download', to: 'hyrax/metadata_exports#download'

    # Routes for managing drafts
    post '/draft/save_draft/:id', to: 'tufts/draft#save_draft'
    post '/draft/delete_draft/:id', to: 'tufts/draft#delete_draft'
    get '/draft/draft_saved/:id', to: 'tufts/draft#draft_saved'

    # Routes for managing QR status
    resources :qr_statuses, controller: 'tufts/qr_status', only: [:set_status, :status] do
      member do
        post 'set_status'
        get 'status'
      end
    end

    # Routes for managing publication status
    resources :publication_statuses, controller: 'tufts/publication_status', only: [:publish, :unpublish, :status] do
      member do
        post 'publish'
        post 'unpublish'
        get 'status'
      end
    end

    resources :deposit_types do
      get 'export', on: :collection
    end

    # Routes for managing QR status

    get '/handle/log/', to: 'tufts/handle_log#index'
  end # end admin constraint

  constraints non_admin_constraint do
    root to: 'contribute#redirect'
    get '/dashboard', to: 'contribute#redirect'
  end

  constraints authenticated_constraint do
    resources :users
    # Mount Engines
    mount Blacklight::Engine => '/'
    mount Hydra::RoleManagement::Engine => '/'
    mount Qa::Engine => '/authorities'
    mount Hyrax::Engine, at: '/'

    # Home page for non-authenticated users
    resources :welcome, only: 'index'
    root 'hyrax/homepage#index'

    curation_concerns_basic_routes

    resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
      concerns :exportable
    end

    resources :bookmarks do
      concerns :exportable

      collection do
        delete 'clear'
      end
    end
  end

  # Unauthenticated users should only be able to reach the /contribute controller and the log in page
  deployed_as_dark_archive = ActiveModel::Type::Boolean.new.cast(ENV['DEPLOY_AS_DARK_ARCHIVE'])
  unless deployed_as_dark_archive
    resources :contribute, as: 'contributions', controller: :contribute, only: [:index, :new, :create, :redirect] do
      collection do
        get 'license'
      end
    end
  end

  if deployed_as_dark_archive
    devise_scope :user do
      root to: "devise/sessions#new"
    end
  else
    root to: 'contribute#redirect'
    get '*path' => redirect { 'contribute#redirect' }
  end
end
