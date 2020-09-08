require "mod-gui"
local ChannelSet = require "channel_set"

local constants =
{
  modPrefix = "WLCBKX_",
  closeButtonPostfix = "CloseButton"
}
constants.modGuiButtonName = constants.modPrefix .. "WirelessCircuitBusConfigButton"
constants.channelSetGuiCloseButtonName = constants.modPrefix .. "ChannelSetGui" .. constants.closeButtonPostfix
constants.channelSetGui = constants.modPrefix .. "ChannelSetGui"
constants.channelSetDropDown = constants.modPrefix .. "ChannelSetDropDown"
constants.channelSetCreateButtonName = constants.modPrefix .. "ChannelSetCreateButton"
constants.channelSetAddButtonName = constants.modPrefix .. "ChannelSetAddButton"
constants.channelSetCreateTextfield = constants.modPrefix .. "ChannelSetCreateTextfield"

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



local ChannelSetsAsLocalizedStringList = function(channelSets)
  local localizeStringList = {}
  for name,_ in pairs(channelSets) do
    localizeStringList[#localizeStringList+1] = {"", name}
  end

  return localizeStringList
end


local function PlayerGuiInit (player)
  mod_gui.get_button_flow(player).add{ type = "sprite-button", name = constants.modGuiButtonName, sprite = "entity/small-biter", style = mod_gui.button_style}
    
end


local function AddTitleBarToChannelSetGui(parent, dragTarget)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"ChannelSet.Title"}, style = "frame_title"}
  flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
  flow.add{type = "sprite-button", name = constants.channelSetGuiCloseButtonName, sprite = "utility/close_white", style = "frame_action_button"}
end


local function AddChannelSetSelectorToChannelSetGui(parent)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"ChannelSet.Label"}}
  flow.add{type = "drop-down", name = constants.channelSetDropDown, items=ChannelSetsAsLocalizedStringList(modData.channelSets)}
  flow.add{type = "textfield", name = constants.channelSetCreateTextfield}
  flow.add{type = "button", name = constants.channelSetCreateButtonName, caption = {"ChannelSet.Create"}}
end


local function AddChannelSelectorToChannelSetGui(parent)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"ChannelSet.Channels"}}
  flow.add{type = "textfield"}
  flow.add{type = "button", name = constants.channelAddCreateButtonName, caption = {"ChannelSet.Add"}}
end


local function ShowChannelSetGui(player)
  
  local frame = player.gui.screen.add{type = "frame", name = constants.channelSetGui, direction = "vertical"}
  local verticalFlow = frame.add{type = "flow", direction = "vertical"}
  AddTitleBarToChannelSetGui(verticalFlow, frame)
  AddChannelSetSelectorToChannelSetGui(verticalFlow)
  AddChannelSelectorToChannelSetGui(verticalFlow)
  player.opened = frame
end


local function OnInit()
  global.wireless_circuit_bus_data = modData

  for _, player in pairs(game.players) do
      PlayerGuiInit(player)
  end
end


local function OnLoad()
  modData = global.wireless_circuit_bus_data
end


local function OnPlayerCreated(event)

  local player = game.players[event.player_index]
  PlayerGuiInit(player)
end


local function OnTick(event)
  local tick = event.tick;

  if (tick % 60 == 0) then
  end
end


local function OnGuiOpened(event)

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


local function HandleModGuiButton(event)
  if (event.element.name ~= constants.modGuiButtonName) then
    return false
  end

  local player = game.players[event.player_index]

  ShowChannelSetGui(player)

  return true
end


local function HandleCloseButton(event)
  if (not event.element.name:starts_with(constants.modPrefix)) then
    return false
  end

  if (not event.element.name:ends_with(constants.closeButtonPostfix)) then
    return false
  end

  local frame = event.element.parent.parent.parent

  frame.destroy()

  return true
end


local function HandleChannelSetCreate(event)
  if (event.element.name ~= constants.channelSetCreateButtonName) then
    return false
  end

  local textfield = event.element.parent[constants.channelSetCreateTextfield]
  local newChannelSetName = textfield.text
  modData.channelSets[newChannelSetName] = ChannelSet(newChannelSetName)

  textfield.text = ""

  local dropdown = event.element.parent[constants.channelSetDropDown]
  dropdown.items = ChannelSetsAsLocalizedStringList(modData.channelSets)
  dropdown.selected_index = #dropdown.items

  return true
end


local function OnGuiClick(event)

  local handled = false

  for _,handleFunction  in pairs(
    {
      HandleModGuiButton,
      HandleCloseButton,
      HandleChannelSetCreate
    }) do
      if (not handled) then
        handled = handleFunction(event)
      end

  end
end



script.on_init(OnInit)
script.on_load(OnLoad)
script.on_event(defines.events.on_player_created, OnPlayerCreated)
script.on_event(defines.events.on_tick, OnTick)
script.on_event(defines.events.on_gui_opened, OnGuiOpened)
script.on_event(defines.events.on_gui_click, OnGuiClick)