FROM ghcr.io/cloudnative-pg/postgresql:18.3-bookworm

USER root

RUN apt update \
 && apt upgrade -y \
 && apt install -y postgresql-18-age postgresql-18-cron postgresql-18-pgtap postgresql-18-pgvector \
 && rm -rf /var/lib/apt/lists/*

USER 26
