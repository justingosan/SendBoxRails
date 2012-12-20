require 'rest_client'
require 'nokogiri'
require 'json'

class HomeController < ApplicationController
    def index
        # Application Entry Point. Retrieves generated Box.com ticket upon construction.
        # Facilitates app authentication with user's Box account

        #Request for box ticket
        request = RestClient.get 'https://www.box.com/api/1.0/rest',
                        {:params => {'action' => 'get_ticket', 'api_key' => $API_KEY}}


        @ticket = Nokogiri.XML(request).xpath('/response/ticket').inner_text
        @auth_url = 'https://www.box.com/api/1.0/auth/' + @ticket
        
        if session[:auth_token]
            @auth_token = session[:auth_token]
        end

        render 'index'
    end

    def get_auth_token_handler
        # Receives: POST data 'ticket' OR GET request with parameters 'auth_token' and 'ticket' from Box.com
        # Pairs authenticated ticket with Box API Key to retreive Auth auth_token
        # needed for accessing user Box files and folders.

        # if auth_token is part of parameter, assign it to session and redirect to main application
        if params[:auth_token]
            session[:auth_token] = params[:auth_token]
            redirect_to :action => "sendbox_app" and return
        end

        # if auth_token exists, redirect to sendbox application page
        if session[:auth_token]
            redirect_to :action => "sendbox_app" and return

        # else if ticket exists, attempt to authenticate then redirect to main application
        elsif params[:ticket]
        #ticket number from POST
        ticket = params[:ticket]

        #request authentication
        request = RestClient.get 'https://www.box.com/api/1.0/rest',
                    {:params => {'action' => 'get_auth_token', 'api_key' => $API_KEY, 'ticket' => ticket}}

        # Assign auth_token to session variable
        session[:auth_token] = Nokogiri.XML(request).xpath('/response/auth_token').inner_text

        redirect_to :action => "sendbox_app" and return
        end

        # else redirect to home page
        redirect_to :action => "index"
    end

    def sendbox_app
        # Main Application View. Displays table of all files and folders on current 'folder_id'.
        # Allows simple folder navigation and provides 'share links' for files.

        if session[:auth_token]
            auth_headers = "BoxAuth api_key=" + $API_KEY + "&auth_token=" + session[:auth_token]
            request = RestClient.get 'https://api.box.com/2.0/folders/'+ params[:folder_id], {:Authorization => auth_headers}
            obj = JSON.parse(request)
            
            @folder = obj['name']
            @items = obj['item_collection']['entries']
            @parent = obj['parent']
            @subject = $DEFAULT_SUBJECT

            session[:user_email] = obj['owned_by']['login']

            render "home/sendbox" and return
        end

        #redirect to home page
        redirect_to :action => "index"
    end

    def sendbox_processor
        # Receives: POST value 'file_id', 'email', 'subject', 'message'
        # Generates Share Link based on file_id
        # Makes use of SendGrid API to send email

        if params[:file_id] and params[:email]
            # Generate shared link using Box API
            data = JSON.generate(['shared_link' => ['access' => 'Open']])
            auth_headers = "BoxAuth api_key=" + $API_KEY + "&auth_token=" + session[:auth_token]
            request = RestClient.put 'https://api.box.com/2.0/files/'+ params[:file_id], data, {:Authorization => auth_headers}
            obj = JSON.parse(request)

            #Extract JSON values
            filename = obj['name']
            shared_link = obj['shared_link']['url']

            # Finally, compose and send our email via SendGrid API
            subject = params[:subject] == "" ? $DEFAULT_SUBJECT : params[:subject]
            message = params[:message]+ "\n\n\nFile Name: " + filename + "\n\nBox Shared Link: " + shared_link
            emails  = params[:email]
            from_email = session[:user_email]

            # build GET parameters
            payload = {:api_user => $SENDGRID_API_USER,     
                        :api_key => $SENDGRID_API_KEY,
                          :to=> emails,
                            :subject => subject,
                              :text => message,
                                :from => from_email, }

            RestClient.get 'https://sendgrid.com/api/mail.send.json', {:params => payload}

            redirect_to :action => "sendbox_app", :folder_id => 0, :success => emails and return
        end

        redirect_to :action => "index"
    end

    def logout
        #Clears all sessions then redirects to home page
        reset_session
        redirect_to :action => "index"
    end

    def guide
        render "home/guide", :layout => false
    end
end
