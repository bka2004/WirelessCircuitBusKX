


local CreateBusNodeEntity = function()

    local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])

    entity.name = "bus-node"
    entity.icons =
    {
        {
            icon = entity.icon,
        },
        {
            icon = "__WirelessCircuitBusKX__" .. "/icons/WirelessCircuitBusNode.png",
        },
    }
    entity.additional_pastable_entities = {"bus-node"}

    return entity
end


local CreateBusNodeItem = function()

    local item = table.deepcopy(data.raw["item"]["constant-combinator"])

    item.type = "item-with-tags"
    item.name = "bus-node"
    item.place_result = "bus-node"
    item.icons =
    {
        {
            icon = item.icon,
        },
        {
            icon = "__WirelessCircuitBusKX__" .. "/icons/WirelessCircuitBusNode.png",
        },
    }

    return item
end


local CreateBusNodeRecipe = function()

    local recipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])

    recipe.enabled = true
    recipe.name = "bus-node"
    recipe.ingredients = {{"constant-combinator", 1}, {"radar", 1}}
    recipe.result = "bus-node"
    recipe.icon_size = 64
    recipe.icons =
    {
        {
            icon = "__base__/graphics/icons/constant-combinator.png",
        },
        {
            icon = "__WirelessCircuitBusKX__" .. "/icons/WirelessCircuitBusNode.png",
        },
    }

    return recipe
end



data:extend{CreateBusNodeEntity(), CreateBusNodeItem(), CreateBusNodeRecipe()}
