data:extend
{
    {
        type = "selection-tool",
        name = "bus-assigner",
        subgroup = "circuit-network",
        icon_size = 32,
        icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png",
        flags = {},
        order = "a",
        stack_size = 1,
        selection_color = {r = 0, g = 1, b = 0},
        alt_selection_color = {r = 1, g = 0, b = 0},
        selection_mode = {"any-entity"},
        alt_selection_mode = { "nothing"},
        selection_cursor_box_type = "entity",
        alt_selection_cursor_box_type = "not-allowed",
        entity_filter_mode = "whitelist",
        entity_filters = { "bus-node" }
    },
    {
        type = "recipe",
        name = "bus-assigner-recipe",
        ingredients = {},
        result = "bus-assigner",
        enabled = true
    }
}