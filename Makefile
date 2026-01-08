.PHONY: build check test clean fmt clippy release

build:
	cargo build

check:
	cargo check

test:
	cargo test

clean:
	cargo clean

fmt:
	cargo fmt

clippy:
	cargo clippy -- -D warnings

release:
	cargo build --release

all: fmt clippy test build
