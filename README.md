#SendBox (Rails)

A Sample Rails App integrating the Box.com and SendGrid API.
Also a port of the original SendBox (written in Django).

Check out the [demo](http://sendboxrails.herokuapp.com/)

##Requirements:

* [Rails](rubyonrails.org) - App Framework
* [Box](http://box.com)           - App API Key
* [SendGrid](http://sendgrid.com) - API User and API Password


##Quick Setup:

After cloning this repository, navigate to root folder and:

1. Run 'bundle install' to install the required gems.

2. Add in credentials to 'config/application.rb' (refer to inline comments)':
	```ruby
	....
	module SendboxRails
	  class Application < Rails::Application
	    #Box Config
	    $API_KEY = 'helloyouiama30characterapikey'

	    #SendGrid Config
	    $SENDGRID_API_URL = "https://sendgrid.com/api/mail.send.json"
	    $SENDGRID_API_USER = "api_user"
	    $SENDGRID_API_KEY = "api_user_password"
	    $DEFAULT_EMAIL_SUBJECT = "I've shared a file to you from Box.com!"
	...
	```

2. You're good to go! Run this app with:
	```
	rails server
	```