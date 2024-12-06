# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'users', controllers: {
        registrations: 'api/v1/users/registrations',
        sessions: 'api/v1/users/sessions'
      }
      resources :users, only: %i[show] do
        resources :tweets, only: %i[index]
        resources :follows, only: %i[index create destroy]
      end

      resources :tweets, only: %i[index create show destroy] do
        resources :replies, only: %i[create]
        resources :retweets, only: %i[create destroy]
        resources :likes, only: %i[create destroy]
        resources :bookmarks, only: %i[create destroy]
      end
      resources :images, only: [:create]
      resources :profiles, only: %i[show update]
      resources :notices, only: [:index]
      resources :groups, only: %i[create index] do
        resources :messages, only: %i[index]
      end
      resources :bookmarks, only: %i[index]
    end
  end
end
