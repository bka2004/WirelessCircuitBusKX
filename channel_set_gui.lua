local ChannelSet = require "channel_set"
local Tools = require "tools"


local function ChannelSetGui(modData)
    local self =
    {

    }

    local modData = modData
    local tools = Tools()

    function self.AddChannelSetSelectorToChannelSetGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Label"}}
        modData.volatile.guiElements[modData.constants.guiElementNames.channelSetDropDown] = flow.add{type = "drop-down", name = modData.constants.guiElementNames.channelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)}
        flow.add{type = "textfield", name = modData.constants.guiElementNames.channelSetCreateTextfield}
        flow.add{type = "button", name = modData.constants.guiElementNames.channelSetCreateButton, caption = {"ConfigGui.Create"}}

    end
      
      
    function self.AddChannelSelectorToChannelSetGui(parent)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Channels"}}
        modData.volatile.guiElements[modData.constants.guiElementNames.newChannelTextfield] = flow.add{type = "textfield", name = modData.constants.guiElementNames.newChannelTextfield}
        modData.volatile.guiElements[modData.constants.guiElementNames.channelAddButton] = flow.add{type = "button", name = modData.constants.guiElementNames.channelAddButton, caption = {"ConfigGui.Add"}}
    end
      
      
    function self.AddChannelListToChannelSetGui(parent)
        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        modData.volatile.guiElements[modData.constants.guiElementNames.channelListBox] = outerFlow.add{type = "list-box", name = modData.constants.guiElementNames.channelListBox, items = {}}
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = modData.constants.guiElementNames.removeChannelButton, caption = {"ConfigGui.Remove"}}
        innerFlow.add{type = "button", name = modData.constants.guiElementNames.moveChannelUpButton, caption = {"ConfigGui.Up"}}
        innerFlow.add{type = "button", name = modData.constants.guiElementNames.moveChannelDownButton, caption = {"ConfigGui.Down"}}
    end


    function self.HandleChannelSetDropDownChanged(event)

        if (event.element.name ~= modData.constants.guiElementNames.channelSetDropDown) then
          return false
        end
      
        local channelSetDropDown = event.element
        local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)
        local channelsOfSelectedChannelSet = modData.persisted.channelSets[channelSetName].channels
      
        local channelList = modData.volatile.guiElements[modData.constants.guiElementNames.channelListBox]
        channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)
      
        return true

      end
      

    function self.AddChannelSetGui(parent)
  
        self.AddChannelSetSelectorToChannelSetGui(parent)
        self.AddChannelSelectorToChannelSetGui(parent)
        self.AddChannelListToChannelSetGui(parent)

    end

    function self.HandleChannelAddButton(event)
        if (event.element.name ~= modData.constants.guiElementNames.channelAddButton) then
          return false
        end
      
        local channelTextfield = modData.volatile.guiElements[modData.constants.guiElementNames.newChannelTextfield]
        local channelSetDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.channelSetDropDown]
        local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)
        local channelsOfSelectedChannelSet = modData.persisted.channelSets[channelSetName].channels
        table.insert(channelsOfSelectedChannelSet, channelTextfield.text)
        channelTextfield.text = ""
      
        local channelList = modData.volatile.guiElements[modData.constants.guiElementNames.channelListBox]
        channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)
      
        return true
      end
      
            
      function self.HandleChannelSetCreateButton(event)
        if (event.element.name ~= modData.constants.guiElementNames.channelSetCreateButton) then
          return false
        end
      
        local textfield = event.element.parent[modData.constants.guiElementNames.channelSetCreateTextfield]
        local newChannelSetName = textfield.text
        modData.persisted.channelSets[newChannelSetName] = ChannelSet(newChannelSetName)
      
        textfield.text = ""
      
        local dropdown = event.element.parent[modData.constants.guiElementNames.channelSetDropDown]
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