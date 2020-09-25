local ChannelSet = require "channel_set"
local Tools = require "tools"


local function ChannelSetGui(modData)
    local self =
    {
        guiElementNames =
        {
          removeChannelButton = modData.constants.modPrefix .. "ChannelRemoveButton",
          channelSetDropDown = modData.constants.modPrefix .. "ChannelSetDropDown",
          channelSetCreateButton = modData.constants.modPrefix .. "ChannelSetCreateButton",
          channelSetCreateTextfield = modData.constants.modPrefix .. "ChannelSetCreateTextfield",
          newChannelTextfield = modData.constants.modPrefix .. "NewChannelTextfield",
          channelAddButton = modData.constants.modPrefix .. "ChannelAddButton",
          channelListBox = modData.constants.modPrefix .. "ChannelListBox",
          removeBusButton = modData.constants.modPrefix .. "BusRemoveButton",
          moveChannelUpButton = modData.constants.modPrefix .. "MoveChannelUpButton",
          moveChannelDownButton = modData.constants.modPrefix .. "MoveChannelDownButton"          
        },
        guiElements = {}
    }

    local modData = modData
    local tools = Tools()

    function self.AddChannelSetSelectorToChannelSetGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Label"}}
        self.guiElements[self.guiElementNames.channelSetDropDown] = flow.add{type = "drop-down", name = self.guiElementNames.channelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)}
        flow.add{type = "textfield", name = self.guiElementNames.channelSetCreateTextfield}
        flow.add{type = "button", name = self.guiElementNames.channelSetCreateButton, caption = {"ConfigGui.Create"}}

    end
      
      
    function self.AddChannelSelectorToChannelSetGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Channels"}}
        self.guiElements[self.guiElementNames.newChannelTextfield] = flow.add{type = "textfield", name = self.guiElementNames.newChannelTextfield}
        self.guiElements[self.guiElementNames.channelAddButton] = flow.add{type = "button", name = self.guiElementNames.channelAddButton, caption = {"ConfigGui.Add"}}

    end
      
      
    function self.AddChannelListToChannelSetGui(parent)

        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        self.guiElements[self.guiElementNames.channelListBox] = outerFlow.add{type = "list-box", name = self.guiElementNames.channelListBox, items = {}}
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = self.guiElementNames.removeChannelButton, caption = {"ConfigGui.Remove"}}
        innerFlow.add{type = "button", name = self.guiElementNames.moveChannelUpButton, caption = {"ConfigGui.Up"}}
        innerFlow.add{type = "button", name = self.guiElementNames.moveChannelDownButton, caption = {"ConfigGui.Down"}}

    end


    function self.HandleChannelSetDropDownChanged(event)

        if (event.element.name ~= self.guiElementNames.channelSetDropDown) then
          return false
        end
      
        local channelSetDropDown = event.element
        local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)
        local channelsOfSelectedChannelSet = modData.persisted.channelSets[channelSetName].channels
      
        local channelList = self.guiElements[self.guiElementNames.channelListBox]
        channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)
      
        return true

      end
      

    function self.AddChannelSetGui(parent)
  
        self.AddChannelSetSelectorToChannelSetGui(parent)
        self.AddChannelSelectorToChannelSetGui(parent)
        self.AddChannelListToChannelSetGui(parent)

    end

    function self.HandleChannelAddButton(event)
        if (event.element.name ~= self.guiElementNames.channelAddButton) then
          return false
        end
      
        local channelTextfield = self.guiElements[self.guiElementNames.newChannelTextfield]
        local channelSetDropDown = self.guiElements[self.guiElementNames.channelSetDropDown]
        local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)
        local channelsOfSelectedChannelSet = modData.persisted.channelSets[channelSetName].channels
        table.insert(channelsOfSelectedChannelSet, channelTextfield.text)
        channelTextfield.text = ""
      
        local channelList = self.guiElements[self.guiElementNames.channelListBox]
        channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)
      
        return true
      end
      
            
      function self.HandleChannelSetCreateButton(event)
        if (event.element.name ~= self.guiElementNames.channelSetCreateButton) then
          return false
        end
      
        local textfield = event.element.parent[self.guiElementNames.channelSetCreateTextfield]
        local newChannelSetName = textfield.text
        modData.persisted.channelSets[newChannelSetName] = ChannelSet(newChannelSetName)
      
        textfield.text = ""
      
        local dropdown = event.element.parent[self.guiElementNames.channelSetDropDown]
        dropdown.items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)
        dropdown.selected_index = #dropdown.items
      
        return true
      end

      
    function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
            self.HandleChannelSetDropDownChanged
        })

    end

    function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            self.HandleChannelSetCreateButton,
            self.HandleChannelAddButton
        })
        
    end


    return self
    
end


return ChannelSetGui