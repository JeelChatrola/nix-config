---
name: cpp-standards
description: Enforce C++ best practices for formatting, static analysis, CMake, and modern C++ patterns. Use when writing, reviewing, or refactoring C++ code.
---

# C++ Standards

## Toolchain

| Tool | Purpose | Command |
|---|---|---|
| clang-format | Code formatting | `clang-format -i file.cpp` |
| clang-tidy | Static analysis + linting | `clang-tidy file.cpp` |
| clangd | LSP (IDE intelligence) | Auto via editor |
| cmake | Build system | `cmake -B build -G Ninja` |
| ninja | Fast builds | `ninja -C build` |
| bear | Generate compile_commands.json from make | `bear -- make` |
| ccache | Compiler cache | Set via `CMAKE_CXX_COMPILER_LAUNCHER` |
| gdb / lldb | Debugging | `gdb ./build/bin/target` |

These are installed via home-manager. Prefer them over alternatives.

## Code Rules

### Modern C++ (prefer C++17, use C++20 where supported)
- Use `auto` for complex types, explicit types for clarity at interfaces.
- Prefer `std::unique_ptr` / `std::shared_ptr` over raw `new`/`delete`.
- Use structured bindings: `auto [key, value] = pair;`
- Prefer `std::optional`, `std::variant`, `std::string_view` where appropriate.
- Use `constexpr` for compile-time computation.
- Range-based for loops over index loops when index isn't needed.

### Memory & Safety
- RAII for all resource management.
- No manual `new`/`delete` outside of factory functions.
- Prefer stack allocation over heap when lifetime is clear.
- Use `std::span` for non-owning array views (C++20).
- Mark single-arg constructors `explicit`.

### Headers
- Use `#pragma once` (or include guards matching `PROJECT_PATH_FILE_H_`).
- Forward-declare in headers, include in source.
- Minimal includes in headers.

### Naming (Google-style unless project has existing conventions)
- Types: `PascalCase`
- Functions/methods: `camelCase` or `snake_case` (match project)
- Constants: `kConstantName` or `ALL_CAPS`
- Member variables: `member_` (trailing underscore)

### CMake
- Minimum version 3.16+.
- Use targets (`target_link_libraries`) over global commands (`link_libraries`).
- Set `CMAKE_EXPORT_COMPILE_COMMANDS ON` for clangd.
- Use `FetchContent` or `find_package` for dependencies.

### Error Handling
- Use exceptions for exceptional conditions, return codes for expected failures.
- In ROS/real-time code: avoid exceptions, use `std::expected` or error codes.
- Never catch `(...)` silently.

## When Reviewing

Flag these as issues:
- Raw `new`/`delete` without RAII wrapper
- Missing virtual destructor on base classes with virtual methods
- Implicit single-arg constructors
- `using namespace std;` in headers
- Missing `override` on virtual method overrides
- C-style casts (use `static_cast`, `reinterpret_cast`)
- Uninitialized variables
- Missing `compile_commands.json` (clangd won't work)
