require "mod-gui"
local ChannelSet = require "channel_set"
local BusNode = require "bus_node"

local constants =
{
  modPrefix = "WLCBKX_",
  closeButtonPostfix = "CloseButton"
}
constants.modGuiButtonName = constants.modPrefix .. "WirelessCircuitBusConfigButton"
constants.channelSetGuiCloseButtonName = constants.modPrefix .. "ChannelSetGui" .. constants.closeButtonPostfix
constants.configGui = constants.modPrefix .. "ConfigtGui"
constants.channelSetDropDown = constants.modPrefix .. "ChannelSetDropDown"
constants.chooseChannelSetDropDown = constants.modPrefix .. "ChooseChannelSetDropDown"
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



string.starts_with = function (self, substring)
  return self:sub(1, substring:len()) == substring
end

string.ends_with = function (self, substring)
  return self:sub(-1 * substring:len()) == substring
end

local persistedModData =
{
  channelSets = {},
  busses = {}
}

local volatileModData =
{
  guiElements = {}
}


local ChannelSetsAsLocalizedStringList = function(channelSets)
  local localizeStringList = {}
  for name,_ in pairs(channelSets) do
    localizeStringList[#localizeStringList + 1] = {"", name}
  end

  return localizeStringList
end


local ChannelsAsLocalizedStringList = function(channels)
  local localizeStringList = {}
  for _, name in pairs(channels) do
    localizeStringList[#localizeStringList + 1] = {"", name}
  end

  return localizeStringList
end


local BussesAsLocalizedStringList = function(busses)
  local localizeStringList = {}
  for name, bus in pairs(busses) do
    localizeStringList[#localizeStringList + 1] = {"", name .. " - " .. persistedModData.channelSets[bus.channelSet].name}
  end

  return localizeStringList
end


local function PlayerGuiInit (player)
  mod_gui.get_button_flow(player).add{ type = "sprite-button", name = constants.modGuiButtonName, sprite = "entity/small-biter", style = mod_gui.button_style}
    
end


local function AddTitleBarToConfigGui(parent, dragTarget)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"ConfigGui.Title"}, style = "frame_title"}
  flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
  flow.add{type = "sprite-button", name = constants.channelSetGuiCloseButtonName, sprite = "utility/close_white", style = "frame_action_button"}
end


local function AddChannelSetSelectorToChannelSetGui(parent)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"ConfigGui.Label"}}
  volatileModData.guiElements[constants.channelSetDropDown] = flow.add{type = "drop-down", name = constants.channelSetDropDown, items = ChannelSetsAsLocalizedStringList(persistedModData.channelSets)}
  flow.add{type = "textfield", name = constants.channelSetCreateTextfield}
  flow.add{type = "button", name = constants.channelSetCreateButtonName, caption = {"ConfigGui.Create"}}
end


local function AddChannelSelectorToChannelSetGui(parent)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"ConfigGui.Channels"}}
  volatileModData.guiElements[constants.newChannelTextfieldName] = flow.add{type = "textfield", name = constants.newChannelTextfieldName}
  volatileModData.guiElements[constants.channelAddButtonName] = flow.add{type = "button", name = constants.channelAddButtonName, caption = {"ConfigGui.Add"}}
end


local function AddChannelListToChannelSetGui(parent)
  local outerFlow = parent.add{type = "flow", direction = "horizontal"}
  volatileModData.guiElements[constants.channelListBoxName] = outerFlow.add{type = "list-box", name = constants.channelListBoxName, items = {}}
  local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
  innerFlow.add{type = "button", name = constants.removeChannelButtonName, caption = {"ConfigGui.Remove"}}
  innerFlow.add{type = "button", name = constants.moveChannelUpButtonName, caption = {"ConfigGui.Up"}}
  innerFlow.add{type = "button", name = constants.moveChannelDownButtonName, caption = {"ConfigGui.Down"}}
end


local function AddChannelSetGui(parent)
  
  AddChannelSetSelectorToChannelSetGui(parent)
  AddChannelSelectorToChannelSetGui(parent)
  AddChannelListToChannelSetGui(parent)
end


local function AddBusSelectorToBussesGui(parent)
  local flow = parent.add{type = "flow", direction = "horizontal"}
  flow.add{type = "label", caption = {"ConfigGui.BusNameLabel"}}
  volatileModData.guiElements[constants.newBusTextfieldName] = flow.add{type = "textfield", name = constants.newBusTextfieldName}
  flow.add{type = "label", caption = {"ConfigGui.ChannelSetLabel"}}
  volatileModData.guiElements[constants.chooseChannelSetDropDown] = flow.add{type = "drop-down", name = constants.chooseChannelSetDropDown, items = ChannelSetsAsLocalizedStringList(persistedModData.channelSets)}
  volatileModData.guiElements[constants.busAddButtonName] = flow.add{type = "button", name = constants.busAddButtonName, caption = {"ConfigGui.Add"}}
end


local function AddBusListToBussesGui(parent)
  local outerFlow = parent.add{type = "flow", direction = "horizontal"}
  volatileModData.guiElements[constants.busListBoxName] = outerFlow.add{type = "list-box", name = constants.busListBoxName, items = BussesAsLocalizedStringList(persistedModData.busses)}
  local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
  innerFlow.add{type = "button", name = constants.removeChannelButtonName, caption = {"ConfigGui.Remove"}}
end


local function AddBussesGui(parent)
  
  AddBusSelectorToBussesGui(parent)
  AddBusListToBussesGui(parent)
end


local function ShowConfigGui(player)
  
  local frame = player.gui.screen.add{type = "frame", name = constants.configGui, direction = "vertical"}
  volatileModData.guiElements[constants.configGui] = frame
  local verticalFlow = frame.add{type = "flow", direction = "vertical"}
  AddTitleBarToConfigGui(verticalFlow, frame)
  
  local tabPane = verticalFlow.add{type = "tabbed-pane"}
  local bussesTab = tabPane.add{type = "tab", caption={"ConfigGui.BussesTab"}}
  local bussesFlow = tabPane.add{type = "flow", direction = "vertical"}
  AddBussesGui(bussesFlow)
  tabPane.add_tab(bussesTab, bussesFlow)
  
  local channelSetTab = tabPane.add{type = "tab", caption={"ConfigGui.ChannelSetTab"}}
  local channelSetFlow = tabPane.add{type = "flow", direction = "vertical"}
  AddChannelSetGui(channelSetFlow)
  tabPane.add_tab(channelSetTab, channelSetFlow)

  player.opened = frame
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

  ShowConfigGui(player)

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

  volatileModData.guiElements = {}
  frame.destroy()

  return true
end


local function HandleChannelSetCreateButton(event)
  if (event.element.name ~= constants.channelSetCreateButtonName) then
    return false
  end

  local textfield = event.element.parent[constants.channelSetCreateTextfield]
  local newChannelSetName = textfield.text
  persistedModData.channelSets[newChannelSetName] = ChannelSet(newChannelSetName)

  textfield.text = ""

  local dropdown = event.element.parent[constants.channelSetDropDown]
  dropdown.items = ChannelSetsAsLocalizedStringList(persistedModData.channelSets)
  dropdown.selected_index = #dropdown.items

  return true
end


local function HandleChannelAddButton(event)
  if (event.element.name ~= constants.channelAddButtonName) then
    return false
  end

  local channelTextfield = volatileModData.guiElements[constants.newChannelTextfieldName]
  local channelSetDropDown = volatileModData.guiElements[constants.channelSetDropDown]
  local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)[2]
  local channelsOfSelectedChannelSet = persistedModData.channelSets[channelSetName].channels
  table.insert(channelsOfSelectedChannelSet, channelTextfield.text)
  channelTextfield.text = ""

  local channelList = volatileModData.guiElements[constants.channelListBoxName]
  channelList.items = ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)

  return true
end


local function HandleBusAddButton(event)
  if (event.element.name ~= constants.busAddButtonName) then
    return false
  end

  local busTextfield = volatileModData.guiElements[constants.newBusTextfieldName]
  local busName = busTextfield.text
  if (busName:len() == 0) then
    return true
  end

  local channelSetDropDown = volatileModData.guiElements[constants.chooseChannelSetDropDown]
  local selectedIndex = channelSetDropDown.selected_index
  if (selectedIndex == 0) then
    return true
  end

  local channelSetName = channelSetDropDown.get_item(selectedIndex)[2]
  persistedModData.busses[busName] = { name = busName, channelSet = channelSetName }
  busTextfield.text = ""

  local busList = volatileModData.guiElements[constants.busListBoxName]
  busList.items = BussesAsLocalizedStringList(persistedModData.busses)

  return true
end


local function OnGuiClick(event)

  local handled = false

  for _,handleFunction  in pairs(
    {
      HandleModGuiButton,
      HandleCloseButton,
      HandleChannelSetCreateButton,
      HandleChannelAddButton,
      HandleBusAddButton
    }) do
      if (not handled) then
        handled = handleFunction(event)
      end

  end
end


local function HandleChannelSetDropDownChanged(event)
  if (event.element.name ~= constants.channelSetDropDown) then
    return false
  end

  local channelSetDropDown = event.element
  local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)[2]
  local channelsOfSelectedChannelSet = persistedModData.channelSets[channelSetName].channels

  local channelList = volatileModData.guiElements[constants.channelListBoxName]
  channelList.items = ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)

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


script.on_init(OnInit)
script.on_load(OnLoad)
script.on_event(defines.events.on_player_created, OnPlayerCreated)
script.on_event(defines.events.on_tick, OnTick)
script.on_event(defines.events.on_gui_opened, OnGuiOpened)
script.on_event(defines.events.on_gui_click, OnGuiClick)
script.on_event(defines.events.on_gui_selection_state_changed, OnGuiSelectionStateChanged)

