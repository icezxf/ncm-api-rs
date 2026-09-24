# 构建阶段：alpine + musl 编译
FROM rust:1.85-alpine AS builder

RUN apk add --no-cache musl-dev

WORKDIR /src
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && \
    cargo build --release --features server && \
    rm -rf src

COPY src ./src
RUN touch src/main.rs && \
    cargo build --release --features server

# 运行阶段：alpine
FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app
COPY --from=builder /src/target/release/ncm-server /app/ncm-server
RUN chmod +x /app/ncm-server

EXPOSE 3000
ENTRYPOINT ["/app/ncm-server"]
CMD ["--port", "3000", "--bind", "0.0.0.0"]
