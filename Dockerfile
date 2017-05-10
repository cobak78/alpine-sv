FROM alpine:edge

COPY semantic-version.sh ./app

WORKDIR /app

CMD ["sh", "/app/semantic-version.sh"]