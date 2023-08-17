FROM centos:centos7
LABEL maintainer="wnduq93@saltware.co.kr"

ENV NGINX_VERSION 1.17.5

RUN yum update -y && \
    yum install -y wget git patch gcc pcre-devel zlib-devel openssl-devel make && \
    yum clean all

WORKDIR /tmp

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar xf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    git clone https://github.com/chobits/ngx_http_proxy_connect_module && \
    patch -p1 < ./ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_101504.patch && \
    ./configure --add-module=./ngx_http_proxy_connect_module --sbin-path=/usr/sbin/nginx --with-http_ssl_module --with-http_v2_module && \
    make && \
    make install && \
    rm -rf /tmp/*

WORKDIR /
COPY ./nginx.conf /usr/local/nginx/conf/nginx.conf

# Forward Access, error logs to Docker log collector
RUN ln  -sf /dev/stdout /usr/local/nginx/logs/access.log \
 && ln -sf /dev/stderr /usr/local/nginx/logs/errors.log

EXPOSE 443
CMD nginx 
