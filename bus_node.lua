


local CreateBusNode = function()

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


local CreateBusNodeRecipe = function()

    local recipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])

    recipe.enabled = true
    recipe.name = "bus-node"
    recipe.ingredients = {{"constant-combinator", 1}, {"radar", 1}}

    return recipe
end



data:extend{CreateBusNode(), CreateBusNodeRecipe()}
