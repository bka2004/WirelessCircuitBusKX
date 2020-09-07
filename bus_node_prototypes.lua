


local CreateBusNodeEntity = function()

    local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])

    entity.name = "bus-node"
    entity.icons =
    {
        {
            icon = entity.icon,
            tint = { r = 1, g = 0, b = 0, a = 0.3 }
        },
    }

    return entity
end


local CreateBusNodeItem = function()

    local item = table.deepcopy(data.raw["item"]["constant-combinator"])

    item.name = "bus-node"
    item.place_result = "bus-node"
    item.icons =
    {
        {
            icon = item.icon,
            tint = { r = 1, g = 0, b = 0, a = 0.3 }
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
    recipe.icon_size = 32
    recipe.icons =
    {
        {
            icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png"
        },        
    }

    return recipe
end



data:extend{CreateBusNodeEntity(), CreateBusNodeItem(), CreateBusNodeRecipe()}
