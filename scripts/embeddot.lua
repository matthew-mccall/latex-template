local utils = require("scripts.embed_utils")

local M = {}

local function out_dir_for(dir)
    return (dir == "." or dir == "") and "out" or ("out/" .. dir)
end

function M.build(basename)
    local dir = basename:match("^(.*)/") or "."
    if dir == "" then dir = "." end
    local base = basename:match("([^/]+)$") or basename

    local dot = (dir == ".") and (base .. ".dot") or (dir .. "/" .. base .. ".dot")
    local out_dir = out_dir_for(dir)
    local svg = out_dir .. "/" .. base .. ".svg"
    local pdf = out_dir .. "/" .. base .. ".pdf"

    if not utils.file_exists(dot) then
        tex.error("DOT file not found: " .. dot)
        return nil
    end

    local ok, err = utils.ensure_dir(out_dir)
    if not ok then
        tex.error("Failed to create output dir: " .. tostring(err))
        return nil
    end

    if utils.file_newer(dot, svg) then
        local rc, emsg = utils.run(string.format('dot -Tsvg %q -o %q', dot, svg))
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
