# plantuml.nvim

Neovim helper for working with PlantUML files.

# Features

- Generate `.puml` file on save and serve preview on `localhost:8000`

# Requirements

- Python3
- Docker

# Installation

```lua
-- packer.nvim
use {'zapling/plantuml.nvim'}
```

# Usage

```lua
require('plantuml').setup()
```

Run `:Plantuml` to start the watcher, running `:w` on a `.puml` file will now generate and serve.
