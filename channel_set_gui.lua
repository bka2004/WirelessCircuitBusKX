local Tools = require "tools"

local function ChannelSetGui(constants, persistedModData, volatileModData)
    local self =
    {

    }

    local constants = constants
    local persistedModData = persistedModData
    local volatileModData = volatileModData
    local tools = Tools()

    function self.AddChannelSetSelectorToChannelSetGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Label"}}
        volatileModData.guiElements[constants.channelSetDropDown] = flow.add{type = "drop-down", name = constants.channelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(persistedModData.channelSets)}
        flow.add{type = "textfield", name = constants.channelSetCreateTextfield}
        flow.add{type = "button", name = constants.channelSetCreateButtonName, caption = {"ConfigGui.Create"}}

    end
      
      
    function self.AddChannelSelectorToChannelSetGui(parent)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Channels"}}
        volatileModData.guiElements[constants.newChannelTextfieldName] = flow.add{type = "textfield", name = constants.newChannelTextfieldName}
        volatileModData.guiElements[constants.channelAddButtonName] = flow.add{type = "button", name = constants.channelAddButtonName, caption = {"ConfigGui.Add"}}
    end
      
      
    function self.AddChannelListToChannelSetGui(parent)
        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        volatileModData.guiElements[constants.channelListBoxName] = outerFlow.add{type = "list-box", name = constants.channelListBoxName, items = {}}
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = constants.removeChannelButtonName, caption = {"ConfigGui.Remove"}}
        innerFlow.add{type = "button", name = constants.moveChannelUpButtonName, caption = {"ConfigGui.Up"}}
        innerFlow.add{type = "button", name = constants.moveChannelDownButtonName, caption = {"ConfigGui.Down"}}
    end


    function self.AddChannelSetGui(parent)
  
        self.AddChannelSetSelectorToChannelSetGui(parent)
        self.AddChannelSelectorToChannelSetGui(parent)
        self.AddChannelListToChannelSetGui(parent)

    end

    function self.HandleChannelAddButton(event)
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
        channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)
      
        return true
      end
      
            
      function self.HandleChannelSetCreateButton(event)
        if (event.element.name ~= constants.channelSetCreateButtonName) then
          return false
        end
      
        local textfield = event.element.parent[constants.channelSetCreateTextfield]
        local newChannelSetName = textfield.text
        persistedModData.channelSets[newChannelSetName] = ChannelSet(newChannelSetName)
      
        textfield.text = ""
      
        local dropdown = event.element.parent[constants.channelSetDropDown]
        dropdown.items = tools.ChannelSetsAsLocalizedStringList(persistedModData.channelSets)
        dropdown.selected_index = #dropdown.items
      
        return true
      end
      
      
      function HandleOnGuiClick(event)

        tools.CallEventHandler(event, {
            self.HandleChannelSetCreateButton,
            self.HandleChannelAddButton
        })
        
    end


    return self
    
end


return ChannelSetGui