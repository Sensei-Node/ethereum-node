FROM --platform=linux/amd64 debian:stable-slim

RUN apt update && apt install -y socat
ENTRYPOINT [ "/scripts/socat.sh" ]