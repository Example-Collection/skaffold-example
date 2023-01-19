FROM golang:1.19.5-buster

EXPOSE 8080

WORKDIR /app

COPY go.mod ./
RUN go mod download
COPY ./main.go ./main.go

RUN go build -o /go-hello-server

CMD ["go", "run", "main.go"]