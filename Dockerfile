FROM alpine:edge

RUN apk add -U --no-cache \
    git \
    && rm -rf /var/cache/apk/*

RUN mkdir /app

COPY semantic-version.sh /app/semantic-version.sh