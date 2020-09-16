require "mod-gui"
local BusNode = require "bus_node"
local Tools = require "tools"
local Gui = require "gui"
local Ghosts = require "ghosts"



local tools = Tools()

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
    nodes = {},
  },
  volatile = 
  {
    guiElements = {},
    editedEntity = nil
  }
}

modData.tools =
{
  registerNode = function (entityId)

    modData.persisted.nodes[entityId] = { bus = "", channel = "", send = true, receive = true }
  
  end
}
  
modData.tools.registerNodeWithSettings = function(nodeId, settings)

  modData.persisted.nodes[nodeId] = settings

end

modData.tools.getBusNode = function(nodeId)
    local node = modData.persisted.nodes[nodeId]
    if (not node) then
      modData.persisted.nodes[nodeId] = modData.tools.registerNode(nodeId)
    end

    return node

  end

  modData.tools.getNodeSettings = function(nodeId)
    local node = modData.persisted.nodes[nodeId]

    if (not node) then
      return nil
    end

    return tools.deepTableCopy(node)

  end

  modData.tools.setNodeSettings = function(nodeId, settings)
    local node = modData.persisted.nodes[nodeId]

    if (not node) then
      return
    end

    modData.persisted.nodes[nodeId] = settings

  end



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




local gui = Gui(modData)
local ghosts = Ghosts(modData)







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
    ghosts.CheckPendingGhostsForRevival()
  end
end


local function OnBlueprintSetup(event)
  
  local player = game.players[event.player_index]

  local blueprint = player.blueprint_to_setup
  if (not blueprint or not blueprint.valid_for_read) then
    blueprint = player.cursor_stack
  end
  local bpe = blueprint.get_blueprint_entities()
  for _, entity in ipairs(bpe) do
    if (entity.name == "bus-node") then
      local orig = player.surface.find_entity("bus-node", entity.position)
      local origSettings = modData.tools.getNodeSettings(orig.unit_number)
      blueprint.set_blueprint_entity_tag(entity.entity_number, "sourceBusNodeSettings", origSettings)
      local x = "y"
    end
  end
  local x = "g"
end


local function OnEntityCreatedByPlacing(event)

  local createdEntity = event.created_entity

  -- if (event.stack.is_blueprint) then
  --   local x = event.stack.get_blueprint_entities()
  --   for i, bpe in pairs(x) do
  --     local orig = game.surfaces["nauvis"].find_entity("bus-node", bpe.position)
  --     local xx = "xx"
  --   end
  --   local bla ="fasel"
  -- end
  
  if (createdEntity.name == "entity-ghost" and createdEntity.ghost_name == "bus-node") then
    ghosts.AddPending(createdEntity)
  end

  if (createdEntity.name ~= "bus-node") then
    return
  end

  local uniqueIdOfNewEntity = event.created_entity.unit_number
  modData.tools.registerNode(uniqueIdOfNewEntity)

end


local function OnSettingsPasted(event)

  if (event.destination.name ~= "bus-node") then
    return
  end

  local sourceId = event.source.unit_number
  local destId = event.destination.unit_number

  modData.tools.setNodeSettings(destId, modData.tools.getNodeSettings(sourceId))

end


script.on_init(OnInit)
script.on_load(OnLoad)
script.on_event(defines.events.on_player_created, OnPlayerCreated)
script.on_event(defines.events.on_tick, OnTick)
script.on_event(defines.events.on_gui_opened, gui.HandleOnGuiOpened)
script.on_event(defines.events.on_gui_click, gui.HandleOnGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, gui.HandleOnGuiSelectionStateChanged)
script.on_event(defines.events.on_entity_cloned, OnEntityCreatedByPlacing)
script.on_event(defines.events.on_built_entity, OnEntityCreatedByPlacing)
script.on_event(defines.events.on_robot_built_entity, OnEntityCreatedByPlacing)
script.on_event(defines.events.on_entity_settings_pasted, OnSettingsPasted)
script.on_event(defines.events.on_player_setup_blueprint, OnBlueprintSetup)

