FROM alpine:edge

RUN apk add -U --no-cache \
    git \
    bash \
    && rm -rf /var/cache/apk/*

RUN mkdir /app

COPY semantic-version.sh /app/semantic-version.sh

RUN chmod +x /app/semantic-version.sh

CMD ["sh", "/app/semantic-version.sh"]