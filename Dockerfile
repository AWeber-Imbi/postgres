FROM postgres:18.3

ENV POSTGRES_USER=imbi \
    POSTGRES_DATABASE=imbi

RUN apt update \
 && apt upgrade -y \
 && apt install -y postgresql-18-age postgresql-18-cron postgresql-18-pgtap postgresql-18-pgvector \
 && rm -rf /var/lib/apt/lists/* \
 && cp  /usr/share/postgresql/postgresql.conf.sample /etc/postgresql/postgresql.conf \
 && echo "shared_preload_libraries = 'age, pg_cron'" >> /etc/postgresql/postgresql.conf
