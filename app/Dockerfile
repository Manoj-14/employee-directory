FROM docker.io/library/python:3.12-alpine3.22 AS build-venv

RUN apk update && \
    apk add gcc g++ linux-headers

WORKDIR /app

COPY ./requirements.txt requirements.txt

RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install -r requirements.txt

FROM docker.io/library/python:3.12-alpine3.22

COPY --from=build-venv /opt/venv /opt/venv

WORKDIR /app

ENV PHOTOS_BUCKET=photo-bucket
ENV DYNAMO_MODE=on

COPY . .

CMD ["/opt/venv/bin/gunicorn", "application:application", "--workers", "4", "--bind", "0.0.0.0:8000"]