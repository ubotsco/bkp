ARG PGVERSION=17
FROM postgres:${PGVERSION}-alpine

RUN apk add --no-cache aws-cli

ADD bkp.sh /
WORKDIR /data

ENTRYPOINT ["/bin/bash", "/bkp.sh"]
CMD []
