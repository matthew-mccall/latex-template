local utils = require("scripts.embed_utils")

local function kicad_to_svg(sch, _, _dir, _base, out_dir)
    return utils.run(string.format(
        'kicad-cli sch export svg --exclude-drawing-sheet --black-and-white --output %q %q',
        out_dir,
        sch
    ))
end

return {
    build = utils.make_builder{
        input_ext = ".kicad_sch",
        input_label = "KiCad schematic",
        to_svg = kicad_to_svg,
    }
}
