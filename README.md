# The largest heading
## The second largest heading
###### The smallest heading

**This is bold text**

*This text is italicized*

**This text is _extremely_ important**

In the words of Abraham Lincoln:
> Pardon my French

Use `git status` to list all new or modified files that haven't yet been committed.

Some basic Git commands are:
```
git status
git add
git commit
```

### Run Server commands is:
`server -grpc-port=9090 -http-port=8020`

### Run client-grpc commands is:
`client-grpc -server=localhost:9090`

### Run client-rest commands is:
`client-rest -server=http://localhost:8020`


### Create new access token
Run web_oauth commands under the web_oauth folder is:
`web_oauth`


### Create .pb.go file
Run protoc-gen commands is:
`third_party/protoc-gen.sh`


This site was built using [GitHub Pages](https://pages.github.com/).

You can add emoji to your writing by typing :EMOJICODE:.
@octocat :+1: This PR looks great - it's ready to merge! :shipit:


### Code tree:

#### 1. service and client:
	- api
		- proto
			- v1
				- todo-service.proto
		- swagger
			- v1
				- todo-service.swagger.json
	- cmd
		- client-grpc
			- client-grpc
			- main.go
			- user_token.json
		- client-rest
			- client-rest
			- main.go
			- user_token.json
		- server
			- main.go
			- server
	- pkg
		- api
			- v1
				todo-service.pb.go
				todo-service.pb.gw.go
		- aux
			- aux.go
		- cmd
			- server
				- server.go
		- protocol
			- grpc
				- server.go
			- rest
				- server.go
		- service
			- v1
				- heartrate-parser.go
				- helper-service.go
				- profile-parser.go
				- refresh_service.go
				- step_distance-parser.go
				- todo-service.go
	- third_party
		- google
			- api
				- annotations.proto
				- http.proto
			- protobuf
			- rpc
				- code.proto
				- error_details.proto
				- status.proto
		- protoc-gen-swagger
			- options
				- annotations.proto
				- openapiv2.proto
		- protoc-gen.sh
	


#### 2. web_oauth:
	- templates
		- oauth.html
	- helper.go
	- web-oauth.go
	- web_oauth*


jx-microservice/cmd/server

1. First list item
	- First nested list item
		- Second nested list item