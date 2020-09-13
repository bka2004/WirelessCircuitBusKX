require "mod-gui"
local BusNode = require "bus_node"
local Tools = require "tools"
local Gui = require "gui"





string.starts_with = function (self, substring)
  return self:sub(1, substring:len()) == substring
end

string.ends_with = function (self, substring)
  return self:sub(-1 * substring:len()) == substring
end

local modData =
{
  constants = 
  {  
    modPrefix = "WLCBKX_",
    guiElementNames = {}
  },
  persisted = 
  {
    channelSets = {},
    busses = {},
    nodes = {}  
  },
  volatile = 
  {
    guiElements = {},
    editedEntity = nil
    }
}



modData.constants.guiElementNames["modGuiButton"]  = modData.constants.modPrefix .. "WirelessCircuitBusConfigButton"
modData.constants.guiElementNames["configGuiCloseButton"] = modData.constants.modPrefix .. "ChannelSetGuiCloseButton"
modData.constants.guiElementNames["entityGuiCloseButton"] = modData.constants.modPrefix .. "EntityGuiCloseButton"
modData.constants.guiElementNames["entityGuiOkButton"] = modData.constants.modPrefix .. "EntityGuiOkButton"
modData.constants.guiElementNames["configGui"] = modData.constants.modPrefix .. "ConfigtGui"
modData.constants.guiElementNames["entityGui"] = modData.constants.modPrefix .. "EntityGui"
modData.constants.guiElementNames["channelSetDropDown"] = modData.constants.modPrefix .. "ChannelSetDropDown"
modData.constants.guiElementNames["chooseChannelSetDropDown"] = modData.constants.modPrefix .. "ChooseChannelSetDropDown"
modData.constants.guiElementNames["busOfEntityDropdown"] = modData.constants.modPrefix .. "BusOfEntityDropDown"
modData.constants.guiElementNames["channelOfEntityDropdown"] = modData.constants.modPrefix .. "ChannelOfEntityDropDown"
modData.constants.guiElementNames["channelSetCreateButton"] = modData.constants.modPrefix .. "ChannelSetCreateButton"
modData.constants.guiElementNames["channelAddButton"] = modData.constants.modPrefix .. "ChannelAddButton"
modData.constants.guiElementNames["busAddButton"] = modData.constants.modPrefix .. "BusAddButton"
modData.constants.guiElementNames["channelSetCreateTextfield"] = modData.constants.modPrefix .. "ChannelSetCreateTextfield"
modData.constants.guiElementNames["channelListBox"] = modData.constants.modPrefix .. "ChannelListBox"
modData.constants.guiElementNames["busListBox"] = modData.constants.modPrefix .. "BusListBox"
modData.constants.guiElementNames["removeChannelButton"] = modData.constants.modPrefix .. "ChannelRemoveButton"
modData.constants.guiElementNames["removeBusButton"] = modData.constants.modPrefix .. "BusRemoveButton"
modData.constants.guiElementNames["moveChannelUpButton"] = modData.constants.modPrefix .. "MoveChannelUpButton"
modData.constants.guiElementNames["moveChannelDownButton"] = modData.constants.modPrefix .. "MoveChannelDownButton"
modData.constants.guiElementNames["newChannelTextfield"] = modData.constants.modPrefix .. "NewChannelTextfield"
modData.constants.guiElementNames["newBusTextfield"] = modData.constants.modPrefix .. "NewBusTextfield"
modData.constants.guiElementNames["sendCheckbox"] = modData.constants.modPrefix .. "SendCheckbox"
modData.constants.guiElementNames["receiveCheckbox"] = modData.constants.modPrefix .. "ReceiveCheckbox"
modData.constants.guiElementNames["bussesTab"] = modData.constants.modPrefix .. "BussesTab"




local tools = Tools()
local gui = Gui(modData)







local function OnInit()
  global.wireless_circuit_bus_data = modData.persisted

  for _, player in pairs(game.players) do
      gui.AddModGuiButton(player)
  end
end


local function OnLoad()
  modData.persisted = global.wireless_circuit_bus_data
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
  modData.persisted.nodes[uniqueEntityId] = { entityId = uniqueEntityId, bus = nil, channel = "", send = true, receive = true }

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

