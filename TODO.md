## URLs Mautic para LB

* form/submit
* mtc/event


## Enable PHP Extensions


### SSH2

https://serverpilot.io/docs/how-to-install-the-php-ssh2-extension/


### Tidy

No Dockerfile

```Dockerfile
RUN apt update && apt install -y libtidy-dev
RUN docker-php-ext-install tidy
```

### Brotli para testes

```Dockerfile
FROM wordpress:php8.2-apache as build_ext

WORKDIR /root

RUN apt update && apt install -y git
RUN git clone --recursive --depth=1 https://github.com/kjdev/php-ext-brotli.git && cd php-ext-brotli/ && \
	phpize && \
	./configure && \
	make

FROM wordpress:php8.2-apache

RUN apt update && apt install -y libtidy-dev
RUN docker-php-ext-install tidy


COPY --from=build_ext /root/php-ext-brotli/modules/brotli.so /usr/local/lib/php/extensions/no-debug-non-zts-20220829/

RUN echo "extension=brotli.so" > /usr/local/etc/php/conf.d/brotli.ini
```

### Enable mods apache2

```sh
LoadModule headers_module /usr/lib/apache2/modules/mod_headers.so
LoadModule ext_filter_module /usr/lib/apache2/modules/mod_ext_filter.so
LoadModule brotli_module /usr/lib/apache2/modules/mod_brotli.so
```

