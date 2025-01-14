FROM debian:12.8

ENV ELIXIR_VERSION 1.18.1
ENV ERLANG_VERSION 27.0.3

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://packages.erlang.org/erlang-solutions_2.0_all.deb -o /tmp/erlang.deb \
    && dpkg -i /tmp/erlang.deb \
    && apt-get update \
    && apt-get install -y esl-erlang=${ERLANG_VERSION} \
    && rm -rf /tmp/erlang.deb \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/elixir-${ELIXIR_VERSION}-otp-${ERLANG_VERSION}.zip -o /tmp/elixir.zip \
    && unzip /tmp/elixir.zip -d /opt/ \
    && rm /tmp/elixir.zip \
    && ln -s /opt/elixir-${ELIXIR_VERSION}/bin/elixir /usr/local/bin/elixir \
    && ln -s /opt/elixir-${ELIXIR_VERSION}/bin/mix /usr/local/bin/mix \
    && ln -s /opt/elixir-${ELIXIR_VERSION}/bin/iex /usr/local/bin/iex

WORKDIR /app

COPY . .

RUN mix deps.get

RUN mix compile

EXPOSE 55041

CMD mix phx.server
