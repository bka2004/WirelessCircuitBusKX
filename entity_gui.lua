local Tools = require "tools"
local BusNodeClass = require "bus_node"


local function EntityGui(modData)

    local self =
    {
      guiElementNames = 
      {
        closeButton = modData.constants.modPrefix .. "EntityGuiCloseButton",
        okButton = modData.constants.modPrefix .. "EntityGuiOkButton",
        gui = modData.constants.modPrefix .. "EntityGui",
        busOfEntityDropdown = modData.constants.modPrefix .. "BusOfEntityDropDown",
        channelOfEntityDropdown = modData.constants.modPrefix .. "ChannelOfEntityDropDown",
        directionDropdown = modData.constants.modPrefix .. "DirectionDropdown"
      },
      guiElements = {},
      editedEntity = {}
    }

    local modData = modData
    local tools = Tools()


    function self.AddTitleBarToEntityGui(parent, dragTarget)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = self.guiElementNames.closeButton, sprite = "utility/close_white", style = "frame_action_button"}
      end
      
      
     function self.AddBusAndChannelSelectorToEntityGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.BusLabel"}}
        self.guiElements[self.guiElementNames.busOfEntityDropdown] = flow.add{type = "drop-down", name = self.guiElementNames.busOfEntityDropdown, items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)}
        flow.add{type = "label", caption = {"EntityGui.ChannelLabel"}}
        self.guiElements[self.guiElementNames.channelOfEntityDropdown] = flow.add{type = "drop-down", name = self.guiElementNames.channelOfEntityDropdown, items = {}}

        self.UpdateBusOfEntityDropdown()
        self.UpdateChannelOfEntityDropdown()
      end
      
      
      function self.AddSendReceiveSelectorToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.DirectionLabel"}}
        self.guiElements[self.guiElementNames.directionDropdown] = flow.add{type = "drop-down", name = self.guiElementNames.directionDropdown, items = {}}
      
        self.UpdateDirectionDropdown()
      
      end
      
      
      function self.AddOkButtonToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        self.guiElements[self.guiElementNames.okButton] = flow.add{type = "button", name = self.guiElementNames.okButton, caption = {"EntityGui.Ok"}}
      
      end


      function self.GetNodeForEditedEntity()

        local uniqueEntityId = self.editedEntity.unit_number
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

        local dropDown = self.guiElements[self.guiElementNames.busOfEntityDropdown]
        dropDown.items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)
        local busOfEntity = self.GetBusOfEditedEntity()
        if (busOfEntity:len() > 0) then
          dropDown.selected_index = tools.GetIndexOfDropdownItem(dropDown.items, busOfEntity, tools.KeyFromDisplayString)
        else
          dropDown.selected_index = 0
        end

    end


    function self.UpdateDirectionDropdown()

      local directionDropdown = self.guiElements[self.guiElementNames.directionDropdown]
      directionDropdown.items = { "Send", "Receive"}
      
      local busNodeSettings = self.GetNodeForEditedEntity().settings
      if (busNodeSettings.direction == modData.constants.nodeDirection.send) then
        directionDropdown.selected_index = 1
      else
        directionDropdown.selected_index = 2
      end

    end


    function self.UpdateChannelOfEntityDropdown()
          local channelDropDown = self.guiElements[self.guiElementNames.channelOfEntityDropdown]
          local busDropDown = self.guiElements[self.guiElementNames.busOfEntityDropdown]

          local channelSet = nil
          if (busDropDown.selected_index == 0) then
            local busOfEntity = self.GetBusOfEditedEntity()
            if (busOfEntity:len() > 0) then
              channelSet = modData.persisted.channelSets[modData.persisted.busses[busOfEntity].channelSet]
            end
          else
            channelSet = self.GetChannelSetByBusName(tools.KeyFromDisplayString(busDropDown.items[busDropDown.selected_index]))
          end

          if (channelSet == nil) then
            channelDropDown.items = {}
          else
            channelDropDown.items = tools.ChannelsAsLocalizedStringList(channelSet.channels)
            channelDropDown.selected_index = tools.GetIndexOfDropdownItem(channelDropDown.items, self.GetNodeForEditedEntity().settings.channel)
          end
      end

      
      function self.Close()
        local frame = self.guiElements[self.guiElementNames.gui]
        if (not frame) then
          return
        end

        self.editedEntity = nil
      
        self.guiElements = {}
        frame.destroy()
      end


      function self.HandleCloseButton(event)

        if (event.element.name ~= self.guiElementNames.closeButton) then
            return false
        end

        self.Close()

        return true
      end


      function self.HandleBusDropDownSelectionChanged(event)

        if (event.element.name ~= self.guiElementNames.busOfEntityDropdown) then
          return
        end

        self.UpdateChannelOfEntityDropdown()

      end
      

      function ApplySelectedBus(busNodeData)

        local busDropdown = self.guiElements[self.guiElementNames.busOfEntityDropdown]
        local selectedBusIndex = busDropdown.selected_index

        local selectedBus = ""
        if (selectedBusIndex ~= 0) then
          selectedBus = tools.KeyFromDisplayString(busDropdown.items[selectedBusIndex])
        end

        local busNode = BusNodeClass(modData)
        busNode.SetBus(busNodeData, selectedBus)

      end


      function ApplySelectedChannel(busNode)

        local channelDropDown = self.guiElements[self.guiElementNames.channelOfEntityDropdown]

        if (channelDropDown.selected_index ~= 0) then
          busNode.settings.channel = channelDropDown.items[channelDropDown.selected_index]
        end

      end


      function ApplySendReceiveStats(busNode)
     
        local directionDropdown = self.guiElements[self.guiElementNames.directionDropdown]

        if (directionDropdown.selected_index == 1) then
          busNode.settings.direction = modData.constants.nodeDirection.send
        else
          busNode.settings.direction = modData.constants.nodeDirection.receive
        end

      end


      function self.HandleEntityOkButton(event)

        if (event.element.name ~= self.guiElementNames.okButton) then
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

        self.editedEntity = entity

        local frame = player.gui.screen.add{type = "frame", name = self.guiElementNames.gui, direction = "vertical"}
        self.guiElements[self.guiElementNames.gui] = frame
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