local ChannelSet = require "channel_set"
local Tools = require "tools"
local Factories = require "factories"


local function ChannelSetGui(modData)
    local self =
    {
        guiElementNames =
        {
          removeChannelButton = modData.constants.modPrefix .. "ChannelRemoveButton",
          channelSetDropDown = modData.constants.modPrefix .. "ChannelSetDropDown",
          channelSetCreateButton = modData.constants.modPrefix .. "ChannelSetCreateButton",
          channelSetRenameButton = modData.constants.modPrefix .. "ChannelSetRenameButton",
          channelSetDeleteButton = modData.constants.modPrefix .. "ChannelSetDeleteButton",
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
    local factories = Factories(modData)

    function self.AddChannelSetSelectorToChannelSetGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Label"}}
        tools.CreateAndRememberGuiElement("channelSet", flow, {type = "drop-down", name = self.guiElementNames.channelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)})
        tools.CreateAndRememberGuiElement("channelSet", flow, {type = "textfield", name = self.guiElementNames.channelSetCreateTextfield})
        flow.add{type = "button", name = self.guiElementNames.channelSetCreateButton, caption = {"ConfigGui.Create"}}
        flow.add{type = "button", name = self.guiElementNames.channelSetRenameButton, caption = {"ConfigGui.Rename"}}
        flow.add{type = "button", name = self.guiElementNames.channelSetDeleteButton, caption = {"ConfigGui.Delete"}}

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

        self.UpdateChannelSetNameField(channelSetName)

        self.UpdateChannelList(channelSetName)
      
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
          game.show_message_dialog{text = "name already in use"}
          return true
        end

        modData.persisted.channelSets[newChannelSetName] = factories.CreateChannelSet(newChannelSetName)
      
        self.UpdateChannelSets()
      
        return true
      end


      function self.ChannelSetIsInUseByBusses(channelSet)

        for _, bus in pairs(modData.persisted.busses) do
          if (bus.channelSet == channelSet) then
            return true
          end
        end

        return false
      end

      
      function self.HandleChannelSetDeleteButton(event)
        if (event.element.name ~= self.guiElementNames.channelSetDeleteButton) then
          return false
        end

        local dropdown = event.element.parent[self.guiElementNames.channelSetDropDown]
        local channelSetToDelete = dropdown.items[dropdown.selected_index]
        local existingChannelSet = modData.persisted.channelSets[channelSetToDelete]
        if (self.ChannelSetIsInUseByBusses(existingChannelSet)) then
          game.show_message_dialog{text = "channel set still in use"}
          return true
        end
        
        modData.persisted.channelSets[channelSetToDelete] = nil

        for _, bus in pairs(modData.persisted.busses) do
          if (bus.channelSet == channelSetToDelete) then
            bus.channelSet = "<unassigned>"
          end
        end

        self.UpdateChannelSets()
      
        return true
      end

      function self.UpdateChannelSets()
        local channelSetDropdown = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelSetDropDown)
        channelSetDropdown.items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)
        channelSetDropdown.selected_index = #channelSetDropdown.items
        self.UpdateChannelList(channelSetDropdown.items[channelSetDropdown.selected_index])
        self.UpdateChannelSetNameField(channelSetDropdown.items[channelSetDropdown.selected_index])
      end

      function self.UpdateChannelList(channelSet)

        local channelList = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelListBox)

        if (not channelSet) then
          channelList.items = {}
        else
          local channelsOfChannelSet = modData.persisted.channelSets[channelSet].channels
          channelList.items = tools.ChannelsAsLocalizedStringList(channelsOfChannelSet)
          end
      end


      function self.UpdateChannelSetNameField(channelSetName)
        local channelSetNameTextField = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelSetCreateTextfield)
        channelSetNameTextField.text = channelSetName or ""
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

      
      function self.HandleChannelRemoveButton(event)
        if (event.element.name ~= self.guiElementNames.removeChannelButton) then
          return false
        end
      
        local channelList = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelListBox)
        if (channelList.selected_index == 0) then
          return
        end

        local channelSetDropDown = tools.RetrieveGuiElement("channelSet", self.guiElementNames.channelSetDropDown)
        local editedChannelSetName = channelSetDropDown.items[channelSetDropDown.selected_index]

        modData.persisted.channelSets[editedChannelSetName].channels[channelList.selected_index] = nil

        self.UpdateChannelList(editedChannelSetName)

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
            self.HandleChannelSetDeleteButton,
            self.HandleChannelRemoveButton,
            self.HandleChannelAddButton
        })
        
    end


    return self
    
end


return ChannelSetGui