# Desktop

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mgkuhn.github.io/Desktop.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mgkuhn.github.io/Desktop.jl/dev)
[![Build Status](https://github.com/mgkuhn/Desktop.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mgkuhn/Desktop.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This Julia package provides functions for basic GUI Desktop interactions:

* checking if the current process has access to a desktop environment
* opening a URL with a web browser
* opening a file with the desktop environment's default application

## Example

```julia
using Desktop
if hasdesktop()
   browse_url("https://julialang.org/")
else
   @info("No desktop environment available.")
end
```
