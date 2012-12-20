SendboxRails::Application.routes.draw do
  match "/get_auth_token_handler" => 'home#get_auth_token_handler'

  match "/sendbox_app/" => redirect("/sendbox_app/0")
  match "/sendbox_app/:folder_id" => 'home#sendbox_app'

  match "/sendbox_processor" => 'home#sendbox_processor'

  match "/logout" => 'home#logout'

  match "/guide" => 'home#guide'

  root :to => 'home#index'
end
