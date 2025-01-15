FROM ubuntu:jammy

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    git \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    lsb-release \
    python3-launchpadlib \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:rabbitmq/rabbitmq-erlang

RUN apt-get update --allow-unauthenticated

RUN apt-get install -y \
    erlang=1:26.2.5.3-1rmq1ppa1~ubuntu22.04.1 \
    elixir=1.17.3-1rmq1ppa1~ubuntu22.04.1

RUN mix local.hex --force

RUN mix local.rebar --force

WORKDIR /app

COPY . .

RUN mix deps.get

RUN mix compile

EXPOSE 55041

CMD mix phx.server
