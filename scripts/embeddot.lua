local utils = require("scripts.embed_utils")

local function dot_to_svg(dot, svg)
    return utils.run(string.format('dot -Tsvg %q -o %q', dot, svg))
end

return {
    build = utils.make_builder{
        input_ext = ".dot",
        input_label = "DOT file",
        to_svg = dot_to_svg,
    }
}
