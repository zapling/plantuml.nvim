# plantuml.nvim

Neovim helper for working with PlantUML files.

# Features

- Generate `.puml` file on save and serve preview on `localhost:8000`

# Requirements

- Nvim (only tested on `0.8`)
- Python3
- Docker
- Docker img (`docker pull ghcr.io/zapling/plantuml-docker:latest`)

# Installation

```lua
-- packer.nvim
use {'zapling/plantuml.nvim', requires = {'nvim-lua/plenary.nvim'}}
```

# Usage

```lua
require('plantuml').setup()
```

`:Plantuml` to start the watcher, saving a `.puml` will now generate file and serve it

`:Plantuml stop` will stop the watcher
