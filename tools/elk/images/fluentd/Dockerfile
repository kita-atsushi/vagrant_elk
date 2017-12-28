# fluentd/Dockerfile
FROM fluent/fluentd:v0.12-debian

ARG proxy
ENV http_proxy="${proxy}" \
    https_proxy="${proxy}" \
    HTTP_PROXY="${proxy}" \
    HTTPS_PROXY="${proxy}" \
    NO_PROXY="localhost,127.0.0.1,elasticsearch"
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-rdoc", "--no-ri", "--version", "1.13.0"]

