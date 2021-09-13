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
          channelSetRenameButton = modData.constants.modPrefix .. "ChannelSetRenameButton",
          channelSetCreateTextfield = modData.constants.modPrefix .. "ChannelSetCreateTextfield",
          newChannelTextfield = modData.constants.modPrefix .. "NewChannelTextfield",
          channelAddButton = modData.constants.modPrefix .. "ChannelAddButton",
          channelListBox = modData.constants.modPrefix .. "ChannelListBox",
          removeBusButton = modData.constants.modPrefix .. "BusRemoveButton",
          moveChannelUpButton = modData.constants.modPrefix .. "MoveChannelUpButton",
          moveChannelDownButton = modData.constants.modPrefix .. "MoveChannelDownButton"          
        },
    }

    local modData = modData
    local tools = Tools(modData)

    function self.AddChannelSetSelectorToChannelSetGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Label"}}
        tools.CreateAndRememberGuiElement("channelSet", flow, {type = "drop-down", name = self.guiElementNames.channelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)})

        flow.add{type = "textfield", name = self.guiElementNames.channelSetCreateTextfield}
        flow.add{type = "button", name = self.guiElementNames.channelSetCreateButton, caption = {"ConfigGui.Create"}}
        flow.add{type = "button", name = self.guiElementNames.channelSetRenameButton, caption = {"ConfigGui.Rename"}}

    end
      
      
    function self.AddChannelSelectorToChannelSetGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Channels"}}
        tools.CreateAndRememberGuiElement("channelSet", flow, {type = "textfield", name = self.guiElementNames.newChannelTextfield})
        tools.CreateAndRememberGuiElement("channelSet", flow, {type = "button", name = self.guiElementNames.channelAddButton, caption = {"ConfigGui.Add"}})

    end
      
      
    function self.AddChannelListToChannelSetGui(parent)

        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        tools.CreateAndRememberGuiElement("channelSet", outerFlow, {type = "list-box", name = self.guiElementNames.channelListBox, items = {}})
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
        local channelSetNameTextField = event.element.parent[self.guiElementNames.channelSetCreateTextfield]
        channelSetNameTextField.text = channelSetName

        local channelsOfSelectedChannelSet = modData.persisted.channelSets[channelSetName].channels
      
        local channelList = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelListBox)
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
      
        local channelTextfield = tools.RetrieveGuiElement("channelSet", self.guiElementNames.newChannelTextfield)
        local channelSetDropDown = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelSetDropDown)
        local channelSetName = channelSetDropDown.get_item(channelSetDropDown.selected_index)
        local channelsOfSelectedChannelSet = modData.persisted.channelSets[channelSetName].channels
        table.insert(channelsOfSelectedChannelSet, channelTextfield.text)
        channelTextfield.text = ""
      
        local channelList = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelListBox)
        channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfSelectedChannelSet)
      
        return true
      end
      
            
      function self.HandleChannelSetCreateButton(event)
        if (event.element.name ~= self.guiElementNames.channelSetCreateButton) then
          return false
        end
      
        local textfield = event.element.parent[self.guiElementNames.channelSetCreateTextfield]
        local newChannelSetName = textfield.text
        local existingChannselSet = modData.persisted.channelSets[newChannelSetName]
        if (existingChannselSet) then
          return true
        end

        modData.persisted.channelSets[newChannelSetName] = ChannelSet(newChannelSetName)
      
        textfield.text = ""
      
        local dropdown = event.element.parent[self.guiElementNames.channelSetDropDown]
        dropdown.items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)
        dropdown.selected_index = #dropdown.items
      
        return true
      end

      
      function self.HandleChannelSetRenameButton(event)
        if (event.element.name ~= self.guiElementNames.channelSetRenameButton) then
          return false
        end
      
        local textfield = event.element.parent[self.guiElementNames.channelSetCreateTextfield]
        local newChannelSetName = textfield.text
        local existingChannselSet = modData.persisted.channelSets[newChannelSetName]
        if (existingChannselSet) then
          game.show_message_dialog{text = "name already in use"}
          return true
        end

        local channelSetDropDown = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelSetDropDown)
        local curChannelSetName = channelSetDropDown.items[channelSetDropDown.selected_index]
        channelSetDropDown.set_item(channelSetDropDown.selected_index, newChannelSetName)

        modData.persisted.channelSets[newChannelSetName] = tools.deepTableCopy(modData.persisted.channelSets[curChannelSetName])
        modData.persisted.channelSets[curChannelSetName] = nil
      
        textfield.text = ""

        for _, bus in pairs(modData.persisted.busses) do
          if (bus.channelSet == curChannelSetName) then
            bus.channelSet = newChannelSetName
          end
        end
      
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
            self.HandleChannelSetRenameButton,
            self.HandleChannelAddButton
        })
        
    end


    return self
    
end


return ChannelSetGui