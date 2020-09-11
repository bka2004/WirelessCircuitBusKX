require "mod-gui"
local ChannelSet = require "channel_set"
local BusNode = require "bus_node"
local Tools = require "tools"
local ConfigGui = require "config_gui"


local constants =
{
  modPrefix = "WLCBKX_",
  closeButtonPostfix = "CloseButton"
}
constants.modGuiButtonName = constants.modPrefix .. "WirelessCircuitBusConfigButton"
constants.configGuiCloseButtonName = constants.modPrefix .. "ChannelSetGui" .. constants.closeButtonPostfix
constants.entityGuiCloseButtonName = constants.modPrefix .. "EntityGui" .. constants.closeButtonPostfix
constants.entityGuiOkButtonName = constants.modPrefix .. "EntityGuiOkButton"
constants.configGui = constants.modPrefix .. "ConfigtGui"
constants.entityGui = constants.modPrefix .. "EntityGui"
constants.channelSetDropDown = constants.modPrefix .. "ChannelSetDropDown"
constants.chooseChannelSetDropDown = constants.modPrefix .. "ChooseChannelSetDropDown"
constants.busOfEntityDropdown = constants.modPrefix .. "BusOfEntityDropDown"
constants.channelOfEntityDropdown = constants.modPrefix .. "ChannelOfEntityDropDown"
constants.channelSetCreateButtonName = constants.modPrefix .. "ChannelSetCreateButton"
constants.channelAddButtonName = constants.modPrefix .. "ChannelAddButton"
constants.busAddButtonName = constants.modPrefix .. "BusAddButton"
constants.channelSetCreateTextfield = constants.modPrefix .. "ChannelSetCreateTextfield"
constants.channelListBoxName = constants.modPrefix .. "ChannelListBox"
constants.busListBoxName = constants.modPrefix .. "BusListBox"
constants.removeChannelButtonName = constants.modPrefix .. "ChannelRemoveButton"
constants.removeBusButtonName = constants.modPrefix .. "BusRemoveButton"
constants.moveChannelUpButtonName = constants.modPrefix .. "MoveChannelUpButton"
constants.moveChannelDownButtonName = constants.modPrefix .. "MoveChannelDownButton"
constants.newChannelTextfieldName = constants.modPrefix .. "NewChannelTextfield"
constants.newBusTextfieldName = constants.modPrefix .. "NewBusTextfield"
constants.sendCheckbox = constants.modPrefix .. "SendCheckbox"
constants.receiveCheckbox = constants.modPrefix .. "ReceiveCheckbox"
constants.bussesTab = constants.modPrefix .. "BussesTab"




string.starts_with = function (self, substring)
  return self:sub(1, substring:len()) == substring
end

string.ends_with = function (self, substring)
  return self:sub(-1 * substring:len()) == substring
end

local persistedModData =
{
  channelSets = {},
  busses = {},
  nodes = {}
}

local volatileModData =
{
  guiElements = {},
  editedEntity = nil
}


local tools = Tools()
local configGui = ConfigGui(constants, persistedModData, volatileModData)





local function PlayerGuiInit (player)
  mod_gui.get_button_flow(player).add{ type = "sprite-button", name = constants.modGuiButtonName, sprite = "entity/small-biter", style = mod_gui.button_style}
    
end


local function AddTitleBarToEntityGui(parent, dragTarget)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"EntityGui.Title"}, style = "frame_title"}
  flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
  flow.add{type = "sprite-button", name = constants.entityGuiCloseButtonName, sprite = "utility/close_white", style = "frame_action_button"}
end


local function OnInit()
  global.wireless_circuit_bus_data = persistedModData

  for _, player in pairs(game.players) do
      PlayerGuiInit(player)
  end
end


local function OnLoad()
  persistedModData = global.wireless_circuit_bus_data
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


local function AddBusAndChannelSelectorToEntityGui(parent)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"EntityGui.BusLabel"}}
  volatileModData.guiElements[constants.busOfEntityDropdown] = flow.add{type = "drop-down", name = constants.busOfEntityDropdown, items = tools.BussesAsLocalizedStringList(persistedModData.busses)}
  flow.add{type = "label", caption = {"EntityGui.ChannelLabel"}}
  flow.add{type = "drop-down", name = constants.channelOfEntityDropdown, items = {}}
end


local function AddSendReceiveSelectorToEntityGui(parent)

  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "checkbox", name = constants.sendCheckbox, state = true}
  flow.add{type = "label", caption = {"EntityGui.SendLabel"}}

  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "checkbox", name = constants.receiveCheckbox, state = true}
  flow.add{type = "label", caption = {"EntityGui.ReceiveLabel"}}

end


local function AddOkButtonToEntityGui(parent)

  local flow = parent.add{type = "flow", direction = "horizontal"}
  volatileModData.guiElements[constants.entityGuiOkButtonName] = flow.add{type = "button", name = constants.entityGuiOkButtonName, caption = {"EntityGui.Ok"}}

end


local function ShowBusNodeGui(player)

  local frame = player.gui.screen.add{type = "frame", name = constants.entityGui, direction = "vertical"}
  volatileModData.guiElements[constants.entityGui] = frame
  local verticalFlow = frame.add{type = "flow", direction = "vertical"}
  AddTitleBarToEntityGui(verticalFlow, frame)

  AddBusAndChannelSelectorToEntityGui(verticalFlow)
  AddSendReceiveSelectorToEntityGui(verticalFlow)
  AddOkButtonToEntityGui(verticalFlow)

  player.opened = frame
end


local function OnGuiOpened(event)

  if (event.gui_type ~= defines.gui_type.entity) then
    return
  end

  local clickedEntity = event.entity;

  if (clickedEntity.prototype.name ~= "bus-node") then
    return
  end

  volatileModData.editedEntity = clickedEntity

  local player = game.players[event.player_index]

  ShowBusNodeGui(player)

end


local function HandleModGuiButton(event)
  if (event.element.name ~= constants.modGuiButtonName) then
    return false
  end

  local player = game.players[event.player_index]

  configGui.Show(player)

  return true
end


local function HandleCloseButton(event)
  if (not event.element.name:starts_with(constants.modPrefix)) then
    return false
  end

  if (not event.element.name:ends_with(constants.closeButtonPostfix)) then
    return false
  end

  local frame
  if (event.element.name == constants.entityGuiCloseButtonName) then
    frame = volatileModData.guiElements[constants.entityGui]
    volatileModData.editedEntity = nil
  elseif (event.element.name == constants.configGuiCloseButtonName) then
    frame = volatileModData.guiElements[constants.configGui]
  end

  if (frame == nil) then
    return true
  end

  volatileModData.guiElements = {}
  frame.destroy()

  return true
end


local function HandleEntityOkButton(event)
  if (event.element.name ~= constants.entityGuiOkButtonName) then
    return false
  end

  local uniqueEntityId = volatileModData.editedEntity.unit_number
  local busNode = persistedModData.nodes[uniqueEntityId]

  local busDropdown = volatileModData.guiElements[constants.busOfEntityDropdown]
  local selectedBusIndex = busDropdown.selected_index
  if (selectedBusIndex == 0) then
    if (busNode.bus ~= nil) then
      busNode.bus.nodes[uniqueEntityId] = nil
      busNode.bus = nil
    end
  else
    local selectedBus = persistedModData.busses[busDropdown.items[selectedBusIndex][2]]
    busNode.bus = selectedBus
    selectedBus.nodes[uniqueEntityId] = busNode
  end

  return true
end


local function OnGuiClick(event)

  tools.CallEventHandler(event, {
    HandleModGuiButton,
    configGui.HandleOnGuiClick
  })

end


local function HandleChannelSetDropDownChanged(event)
  if (event.element.name ~= constants.channelSetDropDown) then
    return false
  end

  local channelSetDropDown = event.element
  local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)[2]
  local channelsOfSelectedChannelSet = persistedModData.channelSets[channelSetName].channels

  local channelList = volatileModData.guiElements[constants.channelListBoxName]
  channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)

  return true
end


local function OnGuiSelectionStateChanged(event)

  local handled = false

  for _,handleFunction  in pairs(
    {
      HandleChannelSetDropDownChanged,
    }) do
      if (not handled) then
        handled = handleFunction(event)
      end

  end
end


local function OnEntityCreated(event)

  local createdEntity = event.created_entity

  if (createdEntity.name ~= "bus-node") then
    return
  end

  local uniqueEntityId = createdEntity.unit_number
  persistedModData.nodes[uniqueEntityId] = { send = true, receive = true }

end


script.on_init(OnInit)
script.on_load(OnLoad)
script.on_event(defines.events.on_player_created, OnPlayerCreated)
script.on_event(defines.events.on_tick, OnTick)
script.on_event(defines.events.on_gui_opened, OnGuiOpened)
script.on_event(defines.events.on_gui_click, OnGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, OnGuiSelectionStateChanged)
script.on_event(defines.events.on_entity_cloned, OnEntityCreated)
script.on_event(defines.events.on_built_entity, OnEntityCreated)

