FROM --platform=linux/amd64 rust:1.69.0 AS builder
WORKDIR /openexec
RUN apt-get update && apt-get install -y git cmake clang pkg-config libssl-dev build-essential
RUN git clone https://github.com/TennisBowling/openexecution-oe.git .
RUN cargo install --path .

FROM --platform=linux/amd64 debian:bullseye-slim AS runtime
COPY --from=builder /usr/local/cargo/bin/openexecution-oe /usr/local/bin/openexecution
RUN chmod +x /usr/local/bin/openexecution
ENTRYPOINT ["/scripts/init.sh"]