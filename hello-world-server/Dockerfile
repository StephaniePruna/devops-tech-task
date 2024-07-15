FROM rust:1.79.0
COPY ./ ./
RUN cargo build --release
# Expose the port that the application listens on.
EXPOSE 80
CMD ["./target/release/hello-world-server"]