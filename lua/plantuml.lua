local Job = require('plenary.job')

local M = {}

local webserver_job = nil
local tmp_dir = '/tmp/plantuml_nvim'

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
        cwd = tmp_dir,
    })

    webserver_job:start()
end

local function setup_tmp_dir()
    vim.fn.jobstart('[[ ! -d /tmp/plantuml_nvim ]] && mkdir /tmp/plantuml_nvim')
    vim.fn.writefile(vim.split(index_html, '\n'), '/tmp/plantuml_nvim/index.html')
end

local function generate_diagram()
    if webserver_job == nil then
        return
    end

    local filepath = vim.fn.expand('%:p')
    local command = 'cat ' .. filepath .. ' | docker run --rm -i ghcr.io/zapling/plantuml-docker:latest > /tmp/plantuml_nvim/output.png'

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

function M.setup()
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
