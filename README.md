# Contents
* NodeJS
	* [Lesson 08 - Automate Your Development](#lesson-08---automate-your-development)
	* [Lesson 09 - A complete API set](#lesson-09---a-complete-api-set)
	* [Lesson 10 - Cookie Based Authentication](#lesson-10---cookie-based-authentication)
	* [Lesson 11 - JWT Based Authentication](#lesson-11---jwt-based-authentication)
	* [Lesson 12 -  Add Authentication and Authorization to Blog](#lesson-12---add-authentication-and-authorization-to-blog)
	* [Lesson 13 - Automated testing for lesson 12](#lesson-13---automated-testing-for-lesson-12)
* AngularJS
	* [Lesson 02 - Simplest Angular Sample](#lesson-02---simplest-angular-sample)

# Lesson 08 - Automate Your Development
Automating development workflow with gulp task runner module for Node.js

## Hello World API
Request for `localhost:8080/anything` will response `Hi anything`

## Start and Restart for server
In command line from lesson08 directory `gulp start` will run the api server and also restart it for every change in `.coffee` files from  project directory

## Build from source files
In command line from lesson08 diretory `gulp build` will compile `.coffee` files in `lesson08/src` to `.js` in `lesson08/build`

# Lesson 09 - A complete API set
lesson09 directory contains an API set for reply to `CRUD` actions

## Documentation of this API
 `GET localhost:8080/docs` will show the documentation

## Create, Read, Update and Delete post(s) 

### GET /posts/{post_key}
This is responsible for `R` and will show a post that have been stored in couchbase with an id as `post_randomID`

### POST /posts
This is responsible for `C` and will create a post that comes from clients like postman as a `JSON` format:
```
{
	"title" : "title of the  post",
	"body" : "body of the post",
	"author" : "body of the post",
	"created_at" : "creation date of post",
}
```

### GET /posts
This is responsible for `R` but this time will return all posts that are in couchbase

### DELETE /posts/{post_key}
This is responsible for `D` and will delete an specific post with `post_randomID` from couchbase

### PUT /posts/{post_key}
This is responsible for `U` and will update an specefic post with `post_randomID` from couchbase

# Lesson 10 - Cookie Based Authentication
In this lesson you learn cookie based authentication using [hapi-auth-cookie](https://www.npmjs.com/package/hapi-auth-cookie) plugin.

## Start the API
In lesson10 directory use `gulp` or `gulp start` to run this API.

## How it works
In your browser address bar write `localhost:8015' and hit Enter.

### Login
After showing the login page use `admin` for username and password.
this page contains a form with `post` method and `/login' action.

### Logout
After successful login you will face with wellcome message and logout button.
this page contains a form with `post` method and `/logout` action.

### Ping to API
If you enter `/ping` after main address while you are loged in
the API will reply `pong` and in case of logout will say `I will say pong if login`.

### Hello with name
You will have access to `/hello/arash` just if have been authenticated as `admin`.

# Lesson 11 - JWT Based Authentication

## How it works
From lesson11 directory use `gulp` to build and start the API or `gulp start` just to start.
For request to API use [postman](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop?hl=en)
or `curl` with base url of `localhost:8011`.

## Signup
To signup use `/signup` with `POST` method and body as follow:
```javascript
{
    "fullname" : "your name",
    "dob": "1989-06-12",
    "email" : "me@me.com",
    "password" : "password",
    "weight" : "74",
    "height": "172"
}
```
If your signup be successful the API will response `Your registeration was successful login to your account` and after that if you try to login again will respond `This email has been registered before` and if 
you forget to fill some fields it will respond `To signup you must fill all required fields`
## Login
To login your account use `/login` with `POST` method and your login credentials as follow:
```javascript
{
    "email" : "me@me.com",
    "password" : "password"
    
}
```
If your login be successful the API will respond `Your authorization was successful`

## Profile
To see your profile use `/me` with method `GET` 

## Feed
Useing `/feed` with method `GET` will respond  will respond `[ { card: ‘menu’ }, { card: ‘login’ } ]` if you were logged in and otherwise respond  `[ { card: ‘menu’ }, { card: ‘profile’, name: your_name } ]` 

## Logout
To logout use `/logout` with `POST` method. If you were logged in the API will respond `Your logout was successful`

# Lesson 12 - Add Authentication and Authorization to Blog
To start the api from `api` use `gulp start`.
To visit the blog use `localhost:8012` from your browser.

## Setup API
To setup api do these steps:
* From `api/` run `npm install` command.
* From `api/` run `gulp api:setup`.
* From `setup/elasticsearch.yml` copy configurations to `elasticsearch.yml` on your machine.
* In `lesson12` root directory do `curl -XPUT http://localhost:9200/_template/blog?pretty=true -d @setup/blog.template.json`
* Create an index `blog` in ***elastic***.
* Replicate bucket `default` in `couchbase` to elastic by creating new XDCR in couchbase.
##

## Prerequisite
Before of running the api add two documents to `default` bucket in couchbase as follow:

Id: `p_test`
```
{
  "title" : "Test for title",
  "body" : "Body of post for test, body of post for test...",
  "doc_type" : "post",
  "doc_key" : "p_test",
  "author_key" : "u_test",
  "no" : 1
}

Id: `u_test`
{
  "name" : "Arash Kay",
  "email" : "arash@me.com",
  "password" : "arash",
  "doc_type" : "user",
  "doc_key" : "u_test",
}
```
## Run API
* To run API, in `api/` run `gulp api:start`.


## Registration
Use `GET /register` 

## How to publish your post
After logging in to blog at the buttom of all posts page you can publish your blog with title and body fields

# Lesson 13 - Automated testing for lesson 12

# Lesson 02 - Simplest Angular Sample
## How to Setup
From lesson02 of AngularJS directory run `bower install` for installing dependencies.

## How to run
from command line on linux systems in lesson02 run `google-chrome index.html` or simply open index.html file with your desiered browser.

