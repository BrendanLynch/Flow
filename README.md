# Flow

Do-not-disturb team status OS X menu app

![Flow](https://dl.dropbox.com/s/hpu63zme986dp8w/flow-app.png)

Server
---
* Flask microframework
* MongoDB

### Configuration

Replace `MONGO_URL_HERE` with the path to your MongoDB server or provider. Replace `DB_NAME_HERE` with database / deployment name. MongoEngine will automatically create a collection called 'flow' when you add users.

### Deploy to Heroku (example)
1. Create app in the [Heroku dashboard](https://dashboard.heroku.com/apps)
2. Init git repo

		git init
		heroku git:remote -a HEROKU_APP_NAME_HERE
		
3. Commit files

		git add .
		git commit -m "Flow server"
		
4. Deploy to Heroku

		git push heroku master

5. Use server location in OS X app configuration below

### Add users
##### POST /flow
*Parameters*  
`name` name of user  
`status` 0 or 1 (👋 or 🚫)

App
---
* Runs in the OS X menu bar
* Drag-and-drop target to Applications, right click > open to launch
* Add to Login Items to run on startup
* Click a name to toggle status

### Configuration

Replace `SERVER_URL_HERE` with the path to the deployed server url.

### Compile

Build the app with the live server configured. Copy / share target (Flow.app) with members of your team.
