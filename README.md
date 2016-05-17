# Lesson 8 - Automate Your Development
Automating development workflow with gulp task runner module for Node.js

## Hello World API
Request for `localhost:8080/anything` will response `Hi anything`

## Start and Restart for server
In command line from lesson08 directory `gulp start` will run the api server and also restart it for every change in `.coffee` files from  project directory

## Build from source files
In command line from lesson08 diretory `gulp build` will compile `.coffee` files in `lesson08/src` to `.js` in `lesson08/build`

# Lesson 9 - A complete API set
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


