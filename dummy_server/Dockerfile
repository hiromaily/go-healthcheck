FROM golang:1.8

RUN mkdir -p /go/src/github.com/hiromaily/go-healthcheck/dummy_server
WORKDIR /go/src/github.com/hiromaily/go-healthcheck/dummy_server

COPY ./main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -o /go/bin/dummy ./main.go

#EXPOSE 80
CMD ["/go/bin/dummy", "-p", "80"]
