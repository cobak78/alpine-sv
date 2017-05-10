FROM alpine:edge

RUN apk add -U --no-cache \
    git \
    && rm -rf /var/cache/apk/*

COPY semantic-version.sh ./app

WORKDIR /app

CMD ["sh", "/app/semantic-version.sh"]