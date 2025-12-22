local lfs = require("lfs")

local M = {}

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

return M
