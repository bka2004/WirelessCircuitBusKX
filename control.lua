require "mod-gui"


local modData =
{
  channelSets = {},
  busses = {}
}


local function PlayerGuiInit (player)
  mod_gui.get_button_flow(player).add{ type = "sprite-button", name = "WirelessCircuitBusConfig", sprite = "entity/small-biter", style = mod_gui.button_style}
    
end


script.on_init(
  function ()
      global.wireless_circuit_bus_data = modData

    for _, player in pairs(game.players) do
        PlayerGuiInit(player)
    end

  end
)


script.on_load(
  function ()
      modData = global.wireless_circuit_bus_data
  end
)


script.on_event(defines.events.on_player_created,
  function(event)

    local player = game.players[event.player_index]
    PlayerGuiInit(player)
  end
)


script.on_event(defines.events.on_tick,
  function(event)
    local tick = event.tick;

    if (tick % 60 == 0) then
    end
  end
)


script.on_event(defines.events.on_gui_opened,
  function(event)

    if (event.gui_type ~= defines.gui_type.entity) then
      return
    end

    local clickedEntity = event.entity;

    if (clickedEntity.prototype.name ~= "bus-node") then
      return
    end

    local player = game.players[event.player_index]

    showBusNodeGuid(player)

  end
)
