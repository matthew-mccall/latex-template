local lfs = require("lfs")

local M = {}

local function out_dir_for(dir)
    return (dir == "." or dir == "") and "out" or ("out/" .. dir)
end

M.out_dir_for = out_dir_for

local function split_path(path)
    local parts = {}
    for seg in path:gmatch("[^/]+") do
        parts[#parts + 1] = seg
    end
    return parts
end

function M.log(msg)
    texio.write_nl("[embed] " .. msg)
end

function M.file_exists(path)
    local a = lfs.attributes(path)
    return a and a.mode == "file"
end

function M.file_newer(src, dest)
    local s = lfs.attributes(src, "modification")
    if not s then return false end
    local d = lfs.attributes(dest, "modification")
    if not d then return true end
    return s > d
end

function M.ensure_dir(path)
    if not path or path == "" or path == "." then
        return true
    end
    local built = ""
    for _, seg in ipairs(split_path(path)) do
        if seg ~= "." then
            built = (built == "") and seg or (built .. "/" .. seg)
            local attr = lfs.attributes(built)
            if not attr then
                local ok, err = lfs.mkdir(built)
                if not ok then
                    return nil, err or ("mkdir failed for " .. built)
                end
            elseif attr.mode ~= "directory" then
                return nil, built .. " exists and is not a directory"
            end
        end
    end
    return true
end

function M.run(cmd)
    local ok, why, code = os.execute(cmd)
    if ok == true or ok == 0 then
        return true
    end
    return nil, string.format("command failed (%s %s): %s", tostring(why), tostring(code), cmd)
end

local function default_svg_to_pdf(svg, pdf)
    return M.run(string.format('inkscape %q --export-area-drawing --export-type=pdf --export-filename=%q', svg, pdf))
end

local function default_input_path(dir, base, ext)
    if dir == "." then
        return base .. ext
    end
    return dir .. "/" .. base .. ext
end

function M.make_builder(opts)
    assert(type(opts) == "table", "opts table is required")
    assert(type(opts.to_svg) == "function", "opts.to_svg function is required")
    assert(opts.input_path or opts.input_ext, "opts.input_ext or opts.input_path is required")

    local input_ext = opts.input_ext
    local input_label = opts.input_label or "Source file"
    local svg_to_pdf = opts.svg_to_pdf or default_svg_to_pdf
    local input_path_fn = opts.input_path

    return function(basename)
        local dir = basename:match("^(.*)/") or "."
        if dir == "" then dir = "." end
        local base = basename:match("([^/]+)$") or basename

        local input_path = input_path_fn and input_path_fn(dir, base) or default_input_path(dir, base, input_ext)
        local out_dir = out_dir_for(dir)
        local svg = out_dir .. "/" .. base .. ".svg"
        local pdf = out_dir .. "/" .. base .. ".pdf"

        if not M.file_exists(input_path) then
            tex.error(input_label .. " not found: " .. input_path)
            return nil
        end

        local ok, err = M.ensure_dir(out_dir)
        if not ok then
            tex.error("Failed to create output dir: " .. tostring(err))
            return nil
        end

        if M.file_newer(input_path, svg) then
            local ok_svg, emsg = opts.to_svg(input_path, svg, dir, base, out_dir)
            if not ok_svg then
                tex.error(emsg or ("Failed to build SVG for " .. input_path))
                return nil
            end
        end

        if M.file_newer(svg, pdf) then
            local ok_pdf, emsg = svg_to_pdf(svg, pdf, dir, base, out_dir)
            if not ok_pdf then
                tex.error(emsg or ("Failed to build PDF for " .. svg))
                return nil
            end
        end

        return pdf
    end
end

return M
