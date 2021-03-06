FROM golang:alpine as builder


RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN mkdir /app
WORKDIR /app

# ENV GO111MODULE=on
ARG app_env
ARG app_port


ENV APP_ENV $app_env
ENV APP_PORT $app_port

COPY assets /app/assets
COPY main.go /app
COPY go.mod   /app


RUN go mod download
RUN go get
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o web-app-$app_env


# Run container
FROM alpine:latest
ARG app_env
ARG app_port

ENV APP_ENV $app_env
ENV APP_PORT $app_port

RUN apk --no-cache add ca-certificates

RUN mkdir /app
WORKDIR /app
COPY assets /app/assets

COPY --from=builder /app/web-app-$app_env .
COPY --from=builder /app/assets .


RUN ln -s /app/web-app-$app_env /app/docker_entrypoint.sh

CMD ["/app/docker_entrypoint.sh"]

EXPOSE $app_port
