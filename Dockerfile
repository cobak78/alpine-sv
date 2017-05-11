FROM alpine:edge

RUN apk add -U --no-cache \
    git \
    && rm -rf /var/cache/apk/*

COPY semantic-version.sh /semantic-version.sh