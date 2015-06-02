# google-scraper
A sample application developed to scrap search result of google web search and return total number of adwords displayed. Api is feature is also added and secured using doorkeeper.
## Steps to setup app on local

* Clone the app.
* cd into the app and run bundle install and rake db:setup.
* After that run rake task rake reverse_ilike:run to add custom function to sql.
* Now run command rails s to start the server.

## For using doorkeeper oauth2 authentication
* Goto url http://google-scrap.herokuapp.com/oauth/applications.
* Login before going to it.
* Create an application and use client id and secret key to access the api.
