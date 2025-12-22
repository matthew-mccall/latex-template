local utils = require("scripts.embed_utils")

local M = {}

local function out_dir_for(dir)
    return (dir == "." or dir == "") and "out" or ("out/" .. dir)
end

function M.build(basename)
    local dir = basename:match("^(.*)/") or "."
    if dir == "" then dir = "." end
    local base = basename:match("([^/]+)$") or basename

    local sch = (dir == ".") and (base .. ".kicad_sch") or (dir .. "/" .. base .. ".kicad_sch")
    local out_dir = out_dir_for(dir)
    local svg = out_dir .. "/" .. base .. ".svg"
    local pdf = out_dir .. "/" .. base .. ".pdf"

    if not utils.file_exists(sch) then
        tex.error("KiCad schematic not found: " .. sch)
        return nil
    end

    local ok, err = utils.ensure_dir(out_dir)
    if not ok then
        tex.error("Failed to create output dir: " .. tostring(err))
        return nil
    end

    if utils.file_newer(sch, svg) then
        local cmd = string.format('kicad-cli sch export svg --exclude-drawing-sheet --black-and-white --output %q %q', out_dir, sch)
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
