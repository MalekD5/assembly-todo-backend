# Assembly Todo Backend

A minimal Todo backend written in **C and x86 Assembly (NASM)**.  
This project explores low-level systems programming by implementing a simple HTTP server, routing, and JSON-based CRUD operations without relying on high-level frameworks.

## Overview

Unlike typical implementations (Node.js, Spring, etc.), this backend is built close to the metal using:

- C for core logic and orchestration  
- x86 Assembly (NASM) for low-level operations  
- Raw sockets / system APIs for networking  
- Manual JSON parsing and serialization  

## Features

- Basic HTTP server
- REST-style routing
- JSON request/response handling
- CRUD operations for todos:
  - Create todo
  - Read all todos
  - Update todo
  - Delete todo
- Minimal dependencies
- Built from scratch (no frameworks)

## Tech Stack

- **Language:** C + x86 Assembly (NASM)
- **Build Tools:** Makefile, MinGW64
- **Platform:** Windows (Win32 APIs / Winsock)

## Getting Started

### Prerequisites

- NASM (Netwide Assembler)
- MinGW64 (or compatible GCC toolchain)
- Make

### Build

    make

### Run

    ./dist/backend-win64.exe

The server will start on a predefined port (e.g., localhost:8080).

## API Endpoints

### Get all todos

    GET /todos

Example Response
```
 [
      {
        "id": 1,
        "title": "Learn Assembly",
        "completed": false
      }
]
```

### Create todo

    POST /todos
    Content-Type: application/json
    
     {
        "todo": "Learn Assembly"
     }
    

### Update todo

    POST /todos/:id

    {
      "id": "gdt2552q"
      "todo": "Learn Assembly"
    }

---

### Delete todo

    DELETE /todos/:id

## Why This Project?

Most backend systems abstract away:

- Memory management
- Networking internals
- Request parsing

This project intentionally avoids those abstractions to:

- Understand how HTTP servers work at a low level  
- Explore interoperability between C and Assembly  
- Build intuition around performance and system design  

## Limitations

- No persistence (in-memory only unless extended)
- Basic routing
- Minimal error handling
- Works in windows 64 bit only

## License

MIT License
