local Job = require('plenary.job')

local default_config = {
    tmp_dir = '/tmp/plantuml_nvim'
}

local M = {}

M._config = default_config

local webserver_job = nil

local index_html = [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="refresh" content="5" >
    <title>PlantUML viewer</title>
  </head>
  <body>
      <img src="./output.png">
  </body>
</html>
]]

local function stop_webserver()
    if webserver_job ~= nil then
        local handle = io.popen("kill " .. webserver_job.pid)
        if handle ~= nil then
            handle:close()
        end
        webserver_job = nil
    end
end

local function start_webserver()
    webserver_job = Job:new({
        command = "python3",
        args = {"-m", "http.server"},
        cwd = M._config.tmp_dir,
    })

    webserver_job:start()
end

local function setup_tmp_dir()
    local mkdir_job = vim.fn.jobstart(string.format('[[ ! -d %s ]] && mkdir %s', M._config.tmp_dir, M._config.tmp_dir))
    vim.fn.jobwait({mkdir_job}, 1000)
    vim.fn.writefile(vim.split(index_html, '\n'), string.format('%s/index.html', M._config.tmp_dir))
end

local function generate_diagram()
    if webserver_job == nil then
        return
    end

    local filepath = vim.fn.expand('%:p')
    local command = string.format('cat %s | docker run --rm -i ghcr.io/zapling/plantuml-docker:latest > %s/output.png', filepath, M._config.tmp_dir)

    vim.fn.jobstart(command)
end

local function entrypoint(opts)
    if opts.args == "" or opts.args == "start" then
        setup_tmp_dir()
        start_webserver()
        return
    end

    if opts.args == "stop" then
        stop_webserver()
        return
    end
end

function M.setup(cfg)
    M._config = vim.tbl_deep_extend("force", M._config, cfg or {})

    vim.api.nvim_create_user_command(
        "Plantuml",
        function(opts) entrypoint(opts) end,
        {nargs = "?"}
    )
    vim.api.nvim_create_autocmd("VimLeavePre", { callback = stop_webserver })
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = {"*.puml"},
        callback = generate_diagram,
    })
end

return M
