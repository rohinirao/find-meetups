Rails.application.routes.draw do
  root :to => "meetups#index"

  resources(:meetups, only: %i[index]) do
    collection do
      get :search
      get :search_result
    end
  end
end
