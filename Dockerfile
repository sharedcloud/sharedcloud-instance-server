FROM python:3.7.0-alpine3.8

ADD requirements.txt /requirements.txt

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
    && pyvenv /venv \
    && /venv/bin/pip install -U pip \
    && LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "/venv/bin/pip install --no-cache-dir -r /requirements.txt" \
    && runDeps="$( \
            scanelf --needed --nobanner --recursive /venv \
                    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                    | sort -u \
                    | xargs -r apk info --installed \
                    | sort -u \
    )" \
    && apk add --virtual .python-rundeps $runDeps \
    && apk del .build-deps

# Install code
RUN mkdir /code/
WORKDIR /code/
ADD . /code/

EXPOSE 4005

CMD ["/venv/bin/python3", "instance-server.py"]