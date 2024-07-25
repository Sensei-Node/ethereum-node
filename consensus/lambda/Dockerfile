FROM --platform=linux/amd64 debian:bullseye-slim
WORKDIR /asdf
RUN apt-get update && apt-get install -y git curl cmake clang pkg-config libssl-dev build-essential
RUN git clone https://github.com/asdf-vm/asdf.git . --branch v0.12.0
RUN echo '. "/asdf/asdf.sh"' > ~/.bashrc
RUN echo '. "/asdf/completions/asdf.bash"' > ~/.bashrc
RUN source ~/.bashrc && asdf plugin add elixir && asdf plugin add erlang && asdf plugin add golang && asdf plugin add rust && asdf install
WORKDIR /lambda
RUN git clone https://github.com/lambdaclass/lambda_ethereum_consensus.git .
RUN make deps
ENTRYPOINT ["/scripts/init.sh"]
