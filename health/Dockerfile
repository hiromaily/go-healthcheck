FROM alpine:3.6

#RUN echo $GOPATH => /go

RUN apk update
RUN apk add \
        bash \
        vim \
        jq \
        wget \
        curl \
        socat \
        bzip2

#httpie
RUN apk add --update python py-pip ca-certificates
RUN pip install --upgrade pip
RUN pip install httpie httpie-unixsocket && rm -rf /var/cache/apk/*

#curl: Version 7.40 or higher is required to use --unix-socket option
#RUN mkdir -p /workspace/tmp
#WORKDIR /workspace/tmp
#RUN wget http://curl.haxx.se/download/curl-7.54.1.tar.bz2 && tar -xvjf curl-7.54.1.tar.bz2
#
#WORKDIR /workspace/tmp/curl-7.54.1
#RUN ./configure && make && make install
#RUN rm -rf /usr/lib/x86_64-linux-gnu/libcurl.so.4 && cp ./lib/.libs/libcurl.so.4 /usr/lib/x86_64-linux-gnu/

RUN mkdir -p /workspace/health
WORKDIR /workspace/health
COPY ./check.sh .

CMD ["bash"]
