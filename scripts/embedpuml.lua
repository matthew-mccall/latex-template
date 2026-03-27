local utils = require("scripts.embed_utils")

local function plantuml_out_relative(dir, out_dir)
    if dir == "." or dir == "" then
        return out_dir
    end
    return "../" .. out_dir
end

local function plantuml_to_svg(puml, _svg, dir, _base, out_dir)
    local out_rel = plantuml_out_relative(dir, out_dir)
    return utils.run(string.format('plantuml -tsvg -o %q %q', out_rel, puml))
end

return {
    build = utils.make_builder{
        input_ext = ".puml",
        input_label = "PUML file",
        to_svg = plantuml_to_svg,
    }
}
