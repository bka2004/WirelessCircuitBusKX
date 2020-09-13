local Tools = require "tools"


local function EntityGui(modData)

    local self =
    {

    }

    local modData = modData
    local tools = Tools()


    function self.AddTitleBarToEntityGui(parent, dragTarget)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = modData.constants.guiElementNames.entityGuiCloseButton, sprite = "utility/close_white", style = "frame_action_button"}
      end
      
      
     function self.AddBusAndChannelSelectorToEntityGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.BusLabel"}}
        modData.volatile.guiElements[modData.constants.guiElementNames.busOfEntityDropdown] = flow.add{type = "drop-down", name = modData.constants.guiElementNames.busOfEntityDropdown, items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)}
        flow.add{type = "label", caption = {"EntityGui.ChannelLabel"}}
        modData.volatile.guiElements[modData.constants.guiElementNames.channelOfEntityDropdown] = flow.add{type = "drop-down", name = modData.constants.guiElementNames.channelOfEntityDropdown, items = {}}

        self.UpdateBusOfEntityDropdown()
        self.UpdateChannelOfEntityDropdown()
      end
      
      
      function self.AddSendReceiveSelectorToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        modData.volatile.guiElements[modData.constants.guiElementNames.sendCheckbox] = flow.add{type = "checkbox", name = modData.constants.guiElementNames.sendCheckbox, state = true}
        flow.add{type = "label", caption = {"EntityGui.SendLabel"}}
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        modData.volatile.guiElements[modData.constants.guiElementNames.receiveCheckbox] = flow.add{type = "checkbox", name = modData.constants.guiElementNames.receiveCheckbox, state = true}
        flow.add{type = "label", caption = {"EntityGui.ReceiveLabel"}}

        self.UpdateSendReceiveCheckboxes()
      
      end
      
      
      function self.AddOkButtonToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        modData.volatile.guiElements[modData.constants.guiElementNames.entityGuiOkButton] = flow.add{type = "button", name = modData.constants.guiElementNames.entityGuiOkButton, caption = {"EntityGui.Ok"}}
      
      end


      function self.GetNodeForEditedEntity()

        local uniqueEntityId = modData.volatile.editedEntity.unit_number
        return modData.persisted.nodes[uniqueEntityId]

      end


      function self.GetBusOfEditedEntity()

        return self.GetNodeForEditedEntity().bus

      end


      function self.GetChannelSetByBusName(busName)

        local bus = modData.persisted.busses[busName]
        if (bus == nil) then
            return nil
        end

        return modData.persisted.channelSets[bus.channelSet]

      end


    function self.UpdateBusOfEntityDropdown()

        local dropDown = modData.volatile.guiElements[modData.constants.guiElementNames.busOfEntityDropdown]
        dropDown.items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)
        local busOfEntity = self.GetBusOfEditedEntity()
        dropDown.selected_index = tools.GetIndexOfDropdownItem(dropDown.items, busOfEntity.name, tools.BusNameFromBusDisplayString)

    end


    function self.UpdateSendReceiveCheckboxes()

      local busNode = self.GetNodeForEditedEntity()

      local sendCheckbox = modData.volatile.guiElements[modData.constants.guiElementNames.sendCheckbox]
      sendCheckbox.state = busNode.send

      local receiveCheckbox = modData.volatile.guiElements[modData.constants.guiElementNames.receiveCheckbox]
      receiveCheckbox.state = busNode.receive

  end


    function self.UpdateChannelOfEntityDropdown()
          local channelDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.channelOfEntityDropdown]
          local busDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.busOfEntityDropdown]

          local channelSet = nil
          if (busDropDown.selected_index == 0) then
            local busOfEntity = self.GetBusOfEditedEntity()
            if (busOfEntity ~= nil) then
              channelSet = modData.persisted.channelSets[busOfEntity.channelSet]
            end
          else
            channelSet = self.GetChannelSetByBusName(tools.BusNameFromBusDisplayString(busDropDown.items[busDropDown.selected_index]))
          end

          if (channelSet == nil) then
            channelDropDown.items = {}
          else
            channelDropDown.items = tools.ChannelsAsLocalizedStringList(channelSet.channels)
            channelDropDown.selected_index = tools.GetIndexOfDropdownItem(channelDropDown.items, self.GetNodeForEditedEntity().channel)
          end
      end

      
      function self.Close()
        local frame = modData.volatile.guiElements[modData.constants.guiElementNames.entityGui]
        modData.volatile.editedEntity = nil
      
        modData.volatile.guiElements = {}
        frame.destroy()
      end


      function self.HandleCloseButton(event)

        if (event.element.name ~= modData.constants.guiElementNames.entityGuiCloseButton) then
            return false
        end

        self.Close()

        return true
      end

      
      function self.HandleBusDropDownSelectionChanged(event)
        if (event.element.name ~= modData.constants.guiElementNames.busOfEntityDropdown) then
          return
        end

        self.UpdateChannelOfEntityDropdown()

      end
      

      function ApplySelectedBus(busNode)
        local busDropdown = modData.volatile.guiElements[modData.constants.guiElementNames.busOfEntityDropdown]
        local selectedBusIndex = busDropdown.selected_index
        if (selectedBusIndex == 0) then
          if (busNode.bus ~= nil) then
            busNode.bus.nodes[busNode.entityId] = nil
            busNode.bus = nil
          end
        else
          local selectedBus = modData.persisted.busses[tools.BusNameFromBusDisplayString(busDropdown.items[selectedBusIndex])]
          busNode.bus = selectedBus
          selectedBus.nodes[busNode.entityId] = busNode
        end
      end


      function ApplySelectedChannel(busNode)

        local channelDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.channelOfEntityDropdown]

        if (channelDropDown.selected_index ~= 0) then
          busNode.channel = channelDropDown.items[channelDropDown.selected_index]
        end

      end


      function ApplySendReceiveStats(busNode)
     
        local sendCheckbox = modData.volatile.guiElements[modData.constants.guiElementNames.sendCheckbox]
        local receiveCheckbox = modData.volatile.guiElements[modData.constants.guiElementNames.receiveCheckbox]

        busNode.send = sendCheckbox.state
        busNode.receive = receiveCheckbox.state

      end


      function self.HandleEntityOkButton(event)

        if (event.element.name ~= modData.constants.guiElementNames.entityGuiOkButton) then
          return false
        end
      
        local busNode = self.GetNodeForEditedEntity()
      
        ApplySelectedBus(busNode)
        ApplySelectedChannel(busNode)
        ApplySendReceiveStats(busNode)
      
        self.Close()

        return true

      end
      

      function self.Show(player, entity)

        modData.volatile.editedEntity = entity

        local frame = player.gui.screen.add{type = "frame", name = modData.constants.guiElementNames.entityGui, direction = "vertical"}
        modData.volatile.guiElements[modData.constants.guiElementNames.entityGui] = frame
        local verticalFlow = frame.add{type = "flow", direction = "vertical"}
        self.AddTitleBarToEntityGui(verticalFlow, frame)
      
        self.AddBusAndChannelSelectorToEntityGui(verticalFlow)
        self.AddSendReceiveSelectorToEntityGui(verticalFlow)
        self.AddOkButtonToEntityGui(verticalFlow)
      
        player.opened = frame
      end


      function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
            self.HandleBusDropDownSelectionChanged
        })

    end


      function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            self.HandleEntityOkButton,
            self.HandleCloseButton
        })

      end

      
    return self

end


return EntityGui