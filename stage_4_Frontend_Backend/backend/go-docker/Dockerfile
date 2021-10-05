# builder image
FROM golang:1.13-alpine3.11 as builder
RUN mkdir /build
COPY . /build/
WORKDIR /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -o golang-example .


# generate clean, final image for end users
FROM alpine:3.11.3
COPY --from=builder /build/golang-example .

EXPOSE 8080

# executable
ENTRYPOINT [ "./golang-example" ]
# arguments that can be overridden
CMD [ "3", "300" ]