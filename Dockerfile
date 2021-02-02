FROM alpine:latest

LABEL version="1.0.0"

ENV GLIBC_VER=2.31-r0

# install glibc compatibility for alpine
RUN apk --no-cache add \
        bash \
    && apk add --update npm \
    && apk add --update nodejs \
    && apk add --update openssh

RUN npm install pm2@latest -g 
ADD entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]