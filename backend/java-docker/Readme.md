# java-docker 

Example java application in docker.


## Building and running the docker image

```bash
$ docker build -t godocker .
$ docker run -p 8080:8080 godocker
```

Curl response
```bash
$ curl http://localhost:8080/backend/go/
```