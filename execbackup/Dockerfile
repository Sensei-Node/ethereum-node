FROM --platform=linux/amd64 rust:bookworm AS chef
ARG EB_RELEASE_TAG
WORKDIR /ebu
RUN apt-get update && apt-get install -y git cmake clang pkg-config libssl-dev openssl build-essential
RUN git clone https://github.com/TennisBowling/executionbackup.git .
RUN if [[ "$EB_RELEASE_TAG" ]] ; then git checkout $EB_RELEASE_TAG ; fi
RUN cargo install --path .

FROM --platform=linux/amd64 debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y libssl-dev openssl
COPY --from=chef /usr/local/cargo/bin/executionbackup /usr/local/bin/executionbackup
RUN chmod +x /usr/local/bin/executionbackup
ENTRYPOINT ["/scripts/init.sh"]
