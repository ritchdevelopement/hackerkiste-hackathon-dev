# go-docker 

Example golang application in docker

## Running the app locally

```bash
$ go build
$ ./go-docker
2019/02/03 11:38:11 Starting Server
```

```bash
$ curl http://localhost:8080/backend/go/
```

## Building and running the docker image

```bash
$ docker build -t godocker .
$ docker run -p 8080:8080 godocker
```