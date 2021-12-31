
require("bus_node_prototypes")
require("bus_assigner_prototypes")
require("sprites")

local s = data.raw["gui-style"].default

--Widgets
s["wirelessdragwidget"] =
{
    type = "empty_widget_style",
    parent = "draggable_space_header",
    horizontally_stretchable = "on",
    natural_height = 24,
    minimal_width = 24,
}
