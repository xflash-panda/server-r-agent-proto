# server-r-agent-proto

Rust gRPC protocol definitions for server-agent communication. This is the Rust implementation of [server-agent-proto](https://github.com/xflash-panda/server-agent-proto).

## Generated Files

The protobuf files are compiled at build time by `build.rs`. Generated Rust code is placed in:

```
target/debug/build/server-r-agent-proto-*/out/agent.rs
```

You don't need to access this file directly - use the re-exported types from `src/lib.rs`.

## Usage

### Add Dependency

```toml
[dependencies]
server-r-agent-proto = { git = "https://github.com/xflash-panda/server-r-agent-proto" }
```

### Client Example

```rust
use server_r_agent_proto::{agent_client::AgentClient, ConfigRequest, NodeType};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = AgentClient::connect("http://[::1]:50051").await?;

    let request = tonic::Request::new(ConfigRequest {
        node_id: 1,
        node_type: NodeType::Shadowsocks as i32,
    });

    let response = client.config(request).await?;
    println!("Response: {:?}", response);

    Ok(())
}
```

### Server Example

```rust
use tonic::{transport::Server, Request, Response, Status};
use server_r_agent_proto::{
    agent_server::{Agent, AgentServer},
    ConfigRequest, ConfigResponse, HeartbeatRequest, HeartbeatResponse,
    RegisterRequest, RegisterResponse, UnregisterRequest, UnregisterResult,
    SubmitRequest, SubmitResponse, UsersRequest, UsersResponse,
    VerifyRequest, VerifyResponse,
};

#[derive(Debug, Default)]
pub struct MyAgent {}

#[tonic::async_trait]
impl Agent for MyAgent {
    async fn config(&self, request: Request<ConfigRequest>) -> Result<Response<ConfigResponse>, Status> {
        let reply = ConfigResponse {
            result: true,
            raw_data: vec![],
        };
        Ok(Response::new(reply))
    }

    async fn heartbeat(&self, request: Request<HeartbeatRequest>) -> Result<Response<HeartbeatResponse>, Status> {
        Ok(Response::new(HeartbeatResponse { result: true }))
    }

    async fn submit(&self, request: Request<SubmitRequest>) -> Result<Response<SubmitResponse>, Status> {
        Ok(Response::new(SubmitResponse { result: true }))
    }

    async fn users(&self, request: Request<UsersRequest>) -> Result<Response<UsersResponse>, Status> {
        Ok(Response::new(UsersResponse { raw_data: vec![] }))
    }

    async fn register(&self, request: Request<RegisterRequest>) -> Result<Response<RegisterResponse>, Status> {
        Ok(Response::new(RegisterResponse { register_id: "id".to_string() }))
    }

    async fn unregister(&self, request: Request<UnregisterRequest>) -> Result<Response<UnregisterResult>, Status> {
        Ok(Response::new(UnregisterResult { result: true }))
    }

    async fn verify(&self, request: Request<VerifyRequest>) -> Result<Response<VerifyResponse>, Status> {
        Ok(Response::new(VerifyResponse { result: true }))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50051".parse()?;
    let agent = MyAgent::default();

    Server::builder()
        .add_service(AgentServer::new(agent))
        .serve(addr)
        .await?;

    Ok(())
}
```

## Node Types

| Type | Value |
|------|-------|
| SHADOWSOCKS | 0 |
| TROJAN | 1 |
| VMESS | 2 |
| HYSTERIA | 3 |
| HYSTERIA2 | 4 |
| ANYTLS | 6 |
| TUIC | 7 |

## RPC Methods

| Method | Request | Response | Description |
|--------|---------|----------|-------------|
| Config | ConfigRequest | ConfigResponse | Get node configuration |
| Register | RegisterRequest | RegisterResponse | Register a node |
| Unregister | UnregisterRequest | UnregisterResult | Unregister a node |
| Heartbeat | HeartbeatRequest | HeartbeatResponse | Health check |
| Submit | SubmitRequest | SubmitResponse | Submit statistics |
| Users | UsersRequest | UsersResponse | Get user information |
| Verify | VerifyRequest | VerifyResponse | Verify request |

## License

GPL-3.0
