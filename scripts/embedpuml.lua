local utils = require("scripts.embed_utils")

local M = {}

local function out_dir_for(dir)
    return (dir == "." or dir == "") and "out" or ("out/" .. dir)
end

local function plantuml_out_relative(dir)
    if dir == "." or dir == "" then
        return "out"
    end
    return "../out/" .. dir
end

function M.build(basename)
    local dir = basename:match("^(.*)/") or "."
    if dir == "" then dir = "." end
    local base = basename:match("([^/]+)$") or basename

    local puml = (dir == ".") and (base .. ".puml") or (dir .. "/" .. base .. ".puml")
    local out_dir = out_dir_for(dir)
    local svg = out_dir .. "/" .. base .. ".svg"
    local pdf = out_dir .. "/" .. base .. ".pdf"

    if not utils.file_exists(puml) then
        tex.error("PUML file not found: " .. puml)
        return nil
    end

    local ok, err = utils.ensure_dir(out_dir)
    if not ok then
        tex.error("Failed to create output dir: " .. tostring(err))
        return nil
    end

    if utils.file_newer(puml, svg) then
        local out_rel = plantuml_out_relative(dir)
        local cmd = string.format('plantuml -tsvg -o %q %q', out_rel, puml)
        local rc, emsg = utils.run(cmd)
        if not rc then
            tex.error(emsg)
            return nil
        end
    end

    if utils.file_newer(svg, pdf) then
        local rc, emsg = utils.run(string.format('inkscape %q --export-area-drawing --export-type=pdf --export-filename=%q', svg, pdf))
        if not rc then
            tex.error(emsg)
            return nil
        end
    end

    return pdf
end

return M
