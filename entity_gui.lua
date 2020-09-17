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
        flow.add{type = "label", caption = {"EntityGui.DirectionLabel"}}
        modData.volatile.guiElements[modData.constants.guiElementNames.directionDropdown] = flow.add{type = "drop-down", name = modData.constants.guiElementNames.directionDropdown, items = {}}
      
        self.UpdateDirectionDropdown()
      
      end
      
      
      function self.AddOkButtonToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        modData.volatile.guiElements[modData.constants.guiElementNames.entityGuiOkButton] = flow.add{type = "button", name = modData.constants.guiElementNames.entityGuiOkButton, caption = {"EntityGui.Ok"}}
      
      end


      function self.GetNodeForEditedEntity()

        local uniqueEntityId = modData.volatile.editedEntity.unit_number
        return modData.tools.getBusNode(uniqueEntityId)

      end


      function self.GetBusOfEditedEntity()

        return self.GetNodeForEditedEntity().settings.bus

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
        if (busOfEntity:len() > 0) then
          dropDown.selected_index = tools.GetIndexOfDropdownItem(dropDown.items, busOfEntity, tools.BusNameFromBusDisplayString)
        else
          dropDown.selected_index = 0
        end

    end


    function self.UpdateDirectionDropdown()

      local directionDropdown = modData.volatile.guiElements[modData.constants.guiElementNames.directionDropdown]
      directionDropdown.items = { "Send", "Receive"}
      
      local busNodeSettings = self.GetNodeForEditedEntity().settings
      if (busNodeSettings.direction == modData.constants.nodeDirection.send) then
        directionDropdown.selected_index = 1
      else
        directionDropdown.selected_index = 2
      end

    end


    function self.UpdateChannelOfEntityDropdown()
          local channelDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.channelOfEntityDropdown]
          local busDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.busOfEntityDropdown]

          local channelSet = nil
          if (busDropDown.selected_index == 0) then
            local busOfEntity = self.GetBusOfEditedEntity()
            if (busOfEntity:len() > 0) then
              channelSet = modData.persisted.channelSets[modData.persisted.busses[busOfEntity].channelSet]
            end
          else
            channelSet = self.GetChannelSetByBusName(tools.BusNameFromBusDisplayString(busDropDown.items[busDropDown.selected_index]))
          end

          if (channelSet == nil) then
            channelDropDown.items = {}
          else
            channelDropDown.items = tools.ChannelsAsLocalizedStringList(channelSet.channels)
            channelDropDown.selected_index = tools.GetIndexOfDropdownItem(channelDropDown.items, self.GetNodeForEditedEntity().settings.channel)
          end
      end

      
      function self.Close()
        local frame = modData.volatile.guiElements[modData.constants.guiElementNames.entityGui]
        if (not frame) then
          return
        end

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

        local busNodeSettings = busNode.settings
        local busDropdown = modData.volatile.guiElements[modData.constants.guiElementNames.busOfEntityDropdown]
        local selectedBusIndex = busDropdown.selected_index
        if (selectedBusIndex == 0) then
          if (busNodeSettings.bus:len() > 0) then
            modData.persisted.busses[busNodeSettings.bus].nodes[busNode.worldEntity.unit_number] = nil
            busNode.bus = ""
          end
        else
          local selectedBus = tools.BusNameFromBusDisplayString(busDropdown.items[selectedBusIndex])
          busNodeSettings.bus = selectedBus
          modData.persisted.busses[selectedBus].nodes[busNode.worldEntity.unit_number] = busNode
        end
      end


      function ApplySelectedChannel(busNode)

        local channelDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.channelOfEntityDropdown]

        if (channelDropDown.selected_index ~= 0) then
          busNode.settings.channel = channelDropDown.items[channelDropDown.selected_index]
        end

      end


      function ApplySendReceiveStats(busNode)
     
        local directionDropdown = modData.volatile.guiElements[modData.constants.guiElementNames.directionDropdown]

        if (directionDropdown.selected_index == 1) then
          busNode.settings.direction = modData.constants.nodeDirection.send
        else
          busNode.settings.direction = modData.constants.nodeDirection.receive
        end

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

        self.Close() -- in case another entity is already open

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