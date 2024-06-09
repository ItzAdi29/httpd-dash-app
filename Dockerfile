FROM httpd:latest

# WORKDIR /app

RUN rm -rf /usr/local/apache2/htdocs/*

COPY . /usr/local/apache2/htdocs/