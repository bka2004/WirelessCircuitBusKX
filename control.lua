require "mod-gui"
local BusNode = require "bus_node"
local Tools = require "tools"
local Gui = require "gui"


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
local gui = Gui(constants, persistedModData, volatileModData)







local function OnInit()
  global.wireless_circuit_bus_data = persistedModData

  for _, player in pairs(game.players) do
      gui.AddModGuiButton(player)
  end
end


local function OnLoad()
  persistedModData = global.wireless_circuit_bus_data
end


local function OnPlayerCreated(event)

  local player = game.players[event.player_index]
  gui.AddModGuiButton(player)
end


local function OnTick(event)
  local tick = event.tick;

  if (tick % 60 == 0) then
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
script.on_event(defines.events.on_gui_opened, gui.HandleOnGuiOpened)
script.on_event(defines.events.on_gui_click, gui.HandleOnGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, gui.HandleOnGuiSelectionStateChanged)
script.on_event(defines.events.on_entity_cloned, OnEntityCreated)
script.on_event(defines.events.on_built_entity, OnEntityCreated)

