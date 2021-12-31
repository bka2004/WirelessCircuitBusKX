require "mod-gui"
local BusNode = require "bus_node"
local Tools = require "tools"
local Gui = require "gui"
local Ghosts = require "ghosts"
local Bus = require "bus"
local SelectionTool = require "selection_tool"
local Factories = require "factories"
local NodeStorage = require "node_storage"




string.starts_with = function (self, substring)
  return self:sub(1, substring:len()) == substring
end

string.ends_with = function (self, substring)
  return self:sub(-1 * substring:len()) == substring
end

local persistedDefault = 
{
  channelSets = {},
  busses = {},
  nodesById = {},
  playerSettings = {},
  guiElements = { config = {}, entity = {}, channelSet = {}, busses = {}, busAssign = {}},
  editedEntity = nil,
  pendingGhosts = {}
}

local modData =
{
  constants = 
  {  
    modPrefix = "WLCBKX_",
    nodeDirection = {send = 1, receive = 2},
    guiElementNames = {}
  },
  persisted = persistedDefault,
  minedEntityCache = {}
}



local tools = Tools(modData)
local factories = Factories(modData)
local nodeStorage = NodeStorage(modData)

-- modData.tools =
-- {
--   registerNode = function (entityId, entity)

--     modData.persisted.nodes[entityId] = factories.CreateBusNodeData(entity)
  
--   end
-- }
  
-- modData.tools.registerNodeWithSettings = function(entityId, entity, settings)

--   modData.persisted.nodes[entityId] = factories.CreateBusNodeDataWithSettings(entity, settings)

-- end

-- modData.tools.getBusNode = function(nodeId)

--   return modData.persisted.nodes[nodeId]

-- end

-- modData.tools.getOrCreatePlayerSettings = function(playerId)

--   local playerSettings = modData.persisted.playerSettings[playerId]
--   if (playerSettings) then
--     return playerSettings
--   end

--   modData.persisted.playerSettings[playerId] = factories.CreatePlayerData(playerId)

--   return modData.persisted.playerSettings[playerId]

-- end

  -- modData.tools.getNodeSettings = function(nodeId)
  --   local node = modData.persisted.nodes[nodeId]

  --   if (not node) then
  --     return nil
  --   end

  --   return tools.deepTableCopy(node.settings)

  -- end

  -- modData.tools.setNodeSettings = function(nodeId, settings)
  --   local node = modData.persisted.nodes[nodeId]

  --   if (not node) then
  --     return
  --   end

  --   modData.persisted.nodes[nodeId].settings = settings

  -- end






local ghosts = Ghosts(modData)
local gui = Gui(modData, ghosts)
local bus = Bus(modData)
local selectionTool = SelectionTool(modData, gui)
local dataMigrated = false



local function AddPersistentDefaultValues(persisted)

  for key, value in pairs(persistedDefault) do
    persisted[key] = value
  end
end


local function OnInit()
  AddPersistentDefaultValues(modData.persisted)
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

  -- TEMP
  -- if (not dataMigrated) then
  --   for _, bus in pairs(modData.persisted.busses) do
  --     for _, channel in pairs(bus.channels) do
  --       if (channel.nodes) then
  --         for _, node in pairs(channel.nodes) do
  --           if (node.settings.direction == modData.constants.nodeDirection.send) then
  --             channel.senderNodes = channel.senderNodes or {}
  --             channel.senderNodes[node.id] = node
  --           else
  --             channel.receiverNodes = channel.receiverNodes or {}
  --             channel.receiverNodes[node.id] = node
  --           end
  --         end
  
  --         channel.nodes = {}
  --       end
  --     end
  --   end
  

  --   dataMigrated = true
  -- end
  -- END_TEMP


  -- <MO_DATA_RESET> activate this block if mod data shall be reset (when data structures changed) => ALL PREVIOUS DATA LOST
  -- for key, _ in pairs (global.wireless_circuit_bus_data) do
  --   global.wireless_circuit_bus_data[key] = nil
  -- end
  -- AddPersistentDefaultValues(modData.persisted)
  -- </MOD_DATA_RESET>

  local tick = event.tick

  if (tick % 60 == 0) then
    ghosts.CheckPendingGhostsForRevival()
  end

  local l_busses = modData.persisted.busses

  if (not l_busses) then
    return
  end

  local busCount = 0
  for _, curBus in pairs(l_busses) do
    busCount = busCount + 1
    if (busCount % 60 == tick % 60) then
      bus.Update(curBus)
    end
  end

end


local function OnBlueprintSetup(event)
  
  local player = game.players[event.player_index]

  local blueprint = player.blueprint_to_setup
  if (not blueprint or not blueprint.valid_for_read) then
    blueprint = player.cursor_stack
  end
  local bpe = blueprint.get_blueprint_entities()
  if (not bpe) then
    return
  end
  for _, entity in ipairs(bpe) do
    if (entity.name == "bus-node") then
      local orig = player.surface.find_entity("bus-node", entity.position)
      local origSettings = nodeStorage.GetCopyOfSettingsFor(orig.unit_number) -- modData.tools.getNodeSettings(orig.unit_number)
      blueprint.set_blueprint_entity_tag(entity.entity_number, "sourceBusNodeSettings", origSettings)
    end
  end

end


local function OnEntityCreatedByPlacing(event)

  local createdEntity = event.created_entity

  if (createdEntity.name == "entity-ghost" and createdEntity.ghost_name == "bus-node") then

    -- local player = game.players[event.player_index]
    -- for key, value in pairs(modData.minedEntityCache) do
    --   player.print("cache_x:" .. key.x)
    --   player.print("cache_y:" .. key.y)
    -- end

    -- player.print("created_x:" .. createdEntity.position.x)
    -- player.print("created_y:" .. createdEntity.position.y)

    local minedEntity = modData.minedEntityCache[createdEntity.position.x] and modData.minedEntityCache[createdEntity.position.x][createdEntity.position.y]
    if (minedEntity) then
      ghosts.AddPendingWithSettings(createdEntity, minedEntity.settings)
      modData.minedEntityCache[createdEntity.position] = nil
    else
      ghosts.AddPending(createdEntity)
    end

  end

  if (createdEntity.name ~= "bus-node") then
    return
  end

  local newNodeId = createdEntity.unit_number
  nodeStorage.StoreNewNode(factories.CreateNode(newNodeId, createdEntity), newNodeId)
  --modData.tools.registerNode(createdEntity.unit_number, createdEntity)

end


local function OnEntityRemoved(event)

  local removedEntity = event.entity
  
  if (removedEntity.name == "bus-node") then
    if (not modData.minedEntityCache[removedEntity.position.x]) then
      modData.minedEntityCache[removedEntity.position.x] = {}
    end
    modData.minedEntityCache[removedEntity.position.x][removedEntity.position.y] = modData.persisted.nodesById[removedEntity.unit_number]

    nodeStorage.RemoveNode(removedEntity.unit_number)

    --modData.persisted.nodes[removedEntity.unit_number] = nil
  end

end


local function OnSettingsPasted(event)

  if (event.destination.name ~= "bus-node") then
    return
  end

  local sourceId = event.source.unit_number
  local destId = event.destination.unit_number

  local destinationNode = nodeStorage.GetNode(destId)
  destinationNode.settings = nodeStorage.GetCopyOfSettingsFor(sourceId)
  --modData.tools.setNodeSettings(destId, modData.tools.getNodeSettings(sourceId))

end

local function EventTest(event)
  local x = "y"
end


script.on_init(OnInit)
script.on_load(OnLoad)
script.on_event(defines.events.on_player_created, OnPlayerCreated)
script.on_event(defines.events.on_tick, OnTick)
script.on_event(defines.events.on_gui_opened, gui.HandleOnGuiOpened)
script.on_event(defines.events.on_gui_click, gui.HandleOnGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, gui.HandleOnGuiSelectionStateChanged)
script.on_event(defines.events.on_gui_text_changed, gui.HandleOnGuiTextChanged)
script.on_event(defines.events.on_entity_cloned, OnEntityCreatedByPlacing)
script.on_event(defines.events.on_player_mined_entity, OnEntityRemoved)
script.on_event(defines.events.on_robot_mined_entity, OnEntityRemoved)
script.on_event(defines.events.on_built_entity, OnEntityCreatedByPlacing)
script.on_event(defines.events.on_robot_built_entity, OnEntityCreatedByPlacing)
script.on_event(defines.events.on_entity_settings_pasted, OnSettingsPasted)
script.on_event(defines.events.on_player_setup_blueprint, OnBlueprintSetup)
script.on_event(defines.events.on_player_selected_area, selectionTool.OnSelection)
script.on_event(defines.events.on_pre_player_removed, EventTest)
script.on_event(defines.events.on_pre_player_left_game, EventTest)
script.on_event(defines.events.on_player_removed, EventTest)
script.on_event(defines.events.on_player_left_game, EventTest)


