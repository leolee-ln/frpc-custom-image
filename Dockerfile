FROM alpine:latest
ARG FRP_VERSION
COPY frpc /usr/local/bin/frpc
RUN chmod +x /usr/local/bin/frpc
ENTRYPOINT ["/usr/local/bin/frpc"]
