FROM rust:1.90-alpine AS builder

RUN apk add --no-cache musl-dev

WORKDIR /src
COPY . .

RUN cargo build --release --features server

FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app
COPY --from=builder /src/target/release/ncm-server /app/ncm-server
RUN chmod +x /app/ncm-server

EXPOSE 3000
ENTRYPOINT ["/app/ncm-server"]
CMD ["--port", "3000", "--bind", "0.0.0.0"]
