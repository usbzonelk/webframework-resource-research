FROM debian:12.8 as builder

ENV GO_VERSION=1.23.4
ENV GIN_VERSION=1.10.0

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    gcc \
    g++ \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz \
    && rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

COPY . .

RUN go mod tidy

RUN go build -o main .

FROM debian:12.8

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/main /app/

EXPOSE 55031

CMD ["./main"]
