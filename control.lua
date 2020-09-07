require "mod-gui"

local constants =
{
  modPrefix = "WLCBKX_"
}
constants.modGuiButtonName = constants.modPrefix .. "WirelessCircuitBusConfig"
constants.channelSetGuiCloseButtonName = constants.modPrefix .. "ChannelSetGuiClose"
constants.channelSetGui = constants.modPrefix .. "ChannelSetGui"

string.starts_with = function (self, substring)
  return self:sub(1, substring:len()) == substring
end

string.ends_with = function (self, substring)
  return self:sub(-1 * substring:len()) == substring
end

local modData =
{
  channelSets = {},
  busses = {}
}


local function PlayerGuiInit (player)
  mod_gui.get_button_flow(player).add{ type = "sprite-button", name = constants.modGuiButtonName, sprite = "entity/small-biter", style = mod_gui.button_style}
    
end


local function ShowChannelSetGui(player)
  
  local frame = player.gui.screen.add{type = "frame", name = constants.channelSetGui, direction = "vertical"}
  local titleflow = frame.add{type = "flow", direction = "horizontal"}
    titleflow.add{type = "label", caption = {"Wireless.Title"}, style = "frame_title"}
    titleflow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = frame
    titleflow.add{type = "sprite-button", name = constants.channelSetGuiCloseButtonName, sprite = "utility/close_white", style = "frame_action_button"}
  frame.add{type = "label", caption = {"ChannelSet.Title"}, style = "frame_title"}
  frame.add{type = "button", name = "WIRELESS_CLICK_04x", caption = {"Wireless.AddNetwork"}}
  player.opened = frame
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


local function HandleModGuiButton(event)
  if (event.element.name ~= constants.modGuiButtonName) then
    return
  end

  local player = game.players[event.player_index]

  ShowChannelSetGui(player)
end


local function HandleCloseButton(event)
  if (not event.element.name:starts_with(constants.modPrefix)) then
    return
  end

  if (not event.element.name:ends_with("Close")) then
    return
  end

  local player = game.players[event.player_index]

  player.opened.destroy()
  player.opened = nil
end


script.on_event(defines.events.on_gui_click,
  function(event)

    HandleModGuiButton(event)

    HandleCloseButton(event)


  end
)