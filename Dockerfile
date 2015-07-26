FROM alpine:latest


COPY ./patch/prctl.h /tmp/prctl.h

RUN apk --update add python redis libxslt supervisor \
    && rm -rf /var/cache/apk/*

RUN echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk --update add --virtual build-dev build-base linux-headers python-dev py-pip libxslt-dev libxml2-dev libzip-dev libffi-dev openssl-dev ca-certificates \
    && cp -f /tmp/prctl.h /usr/include/linux/prctl.h \
    && pip install -U virtualenv \
    && virtualenv /www/sentry/ \
    && source /www/sentry/bin/activate \
    && pip install -U sentry \
    && mkdir -p /opt/sentry \
    && apk del --purge build-dev \
    && rm -rf /tmp/* /var/cache/apk/* /root/.cache/*

COPY ./sentry/sentry.conf.py /etc/sentry/sentry.conf.py
COPY ./sentry/sentry.init.py /etc/sentry/sentry.init.py
COPY ./redis/redis.conf /etc/redis.conf
COPY ./supervisord/supervisord.conf /etc/supervisord.conf

EXPOSE 9000

ENTRYPOINT redis-server /etc/redis.conf \
    && source /www/sentry/bin/activate \
    && SENTRY_CONF=/etc/sentry/sentry.conf.py sentry upgrade --noinput \
    && SENTRY_CONF=/etc/sentry/sentry.conf.py python /etc/sentry/sentry.init.py \
    && mv dsn /opt/sentry/dsn \
    && supervisord -c /etc/supervisord.conf