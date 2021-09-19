local Tools = require "tools"
--local BusNodeClass = require "bus_node"
local NodeStorage = require "node_storage"


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
    }

    local modData = modData
    local tools = Tools(modData)
    local nodeStorage = NodeStorage(modData)


    function self.AddTitleBarToEntityGui(parent, dragTarget)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = self.guiElementNames.closeButton, sprite = "utility/close_white", style = "frame_action_button"}
      end
      
      
     function self.AddBusAndChannelSelectorToEntityGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.BusLabel"}}
        tools.CreateAndRememberGuiElement("entity", flow, {type = "drop-down", name = self.guiElementNames.busOfEntityDropdown, items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)})
        flow.add{type = "label", caption = {"EntityGui.ChannelLabel"}}
        tools.CreateAndRememberGuiElement("entity", flow, {type = "drop-down", name = self.guiElementNames.channelOfEntityDropdown, items = {}})

        self.UpdateBusOfEntityDropdown()
        self.UpdateChannelOfEntityDropdown()
      end
      
      
      function self.AddSendReceiveSelectorToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.DirectionLabel"}}
        tools.CreateAndRememberGuiElement("entity", flow, {type = "drop-down", name = self.guiElementNames.directionDropdown, items = {}})
        
        self.UpdateDirectionDropdown()
      
      end
      
      
      function self.AddOkButtonToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "button", name = self.guiElementNames.okButton, caption = {"EntityGui.Ok"}}

      end


      function self.GetNodeForEditedEntity()

        local uniqueEntityId = modData.persisted.editedEntity.unit_number
        return nodeStorage.GetNode(uniqueEntityId)
      end


      function self.GetBusOfEditedEntity()

        local node = self.GetNodeForEditedEntity()
        if (node and node.settings) then
          return node.settings.busName
        end

        return ""
      end


      function self.GetChannelSetByBusName(busName)

        local bus = modData.persisted.busses[busName]
        if (bus == nil) then
            return nil
        end

        return bus.channelSet

      end


    function self.UpdateBusOfEntityDropdown()

        local dropDown = tools.RetrieveGuiElement("entity", self.guiElementNames.busOfEntityDropdown)
        dropDown.items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)
        local busOfEntity = self.GetBusOfEditedEntity()
        if (busOfEntity:len() > 0) then
          dropDown.selected_index = tools.GetIndexOfDropdownItem(dropDown.items, busOfEntity, tools.KeyFromDisplayString)
        else
          dropDown.selected_index = 0
        end

    end


    function self.UpdateDirectionDropdown()

      local directionDropdown = tools.RetrieveGuiElement("entity", self.guiElementNames.directionDropdown)
      directionDropdown.items = { "Send", "Receive"}
      
      local busNodeSettings = self.GetNodeForEditedEntity().settings
      if (busNodeSettings and busNodeSettings.direction == modData.constants.nodeDirection.send) then
        directionDropdown.selected_index = 1
      else
        directionDropdown.selected_index = 2
      end

    end


    function self.UpdateChannelOfEntityDropdown()

          local channelDropDown = tools.RetrieveGuiElement("entity", self.guiElementNames.channelOfEntityDropdown)
          local busDropDown = tools.RetrieveGuiElement("entity", self.guiElementNames.busOfEntityDropdown)

          local channelSet = nil
          if (busDropDown.selected_index == 0) then
            -- local busOfEntity = self.GetBusOfEditedEntity()
            -- if (busOfEntity:len() > 0) then
            --   local bus = modData.persisted.busses[busOfEntity]
            --   if (bus) then
            --     channelSet = modData.persisted.channelSets[bus.channelSet]
            --   end
            -- end
          else
            channelSet = self.GetChannelSetByBusName(tools.KeyFromDisplayString(busDropDown.items[busDropDown.selected_index]))
          end

          if (channelSet == nil) then
            channelDropDown.items = {}
          else
            channelDropDown.items = tools.ChannelsAsLocalizedStringList(channelSet.channels)
            local nodeSettings = self.GetNodeForEditedEntity().settings
            channelDropDown.selected_index = nodeSettings and tools.GetIndexOfDropdownItem(channelDropDown.items, nodeSettings.channelName) or 0
          end
      end

      
      function self.Close(playerId)

        local frame = tools.RetrieveGuiElement("entity", self.guiElementNames.gui)
        if (not frame) then
          return
        end

        tools.SaveGuiPosition(frame.location, playerId, "entity")

        modData.persisted.editedEntity = nil
        tools.ForgetGuiElements("entity")
        frame.destroy()

      end


      function self.HandleCloseButton(event)

        if (event.element.name ~= self.guiElementNames.closeButton) then
            return false
        end

        self.Close(event.player_index)

        return true
      end


      function self.HandleBusDropDownSelectionChanged(event)

        if (event.element.name ~= self.guiElementNames.busOfEntityDropdown) then
          return
        end

        self.UpdateChannelOfEntityDropdown()

      end
      

      function ApplySelectedBus(node)

        local busDropdown = tools.RetrieveGuiElement("entity", self.guiElementNames.busOfEntityDropdown)
        local selectedBusIndex = busDropdown.selected_index

        local selectedBus = ""
        if (selectedBusIndex ~= 0) then
          selectedBus = tools.KeyFromDisplayString(busDropdown.items[selectedBusIndex])
        end

        node.settings.busName = selectedBus

      end


      function ApplySelectedChannel(busNode)

        local channelDropDown = tools.RetrieveGuiElement("entity", self.guiElementNames.channelOfEntityDropdown)

        if (channelDropDown.selected_index ~= 0) then
          busNode.settings.channelName = channelDropDown.items[channelDropDown.selected_index]
        end

      end


      function ApplySendReceiveStats(busNode)
     
        local directionDropdown = tools.RetrieveGuiElement("entity", self.guiElementNames.directionDropdown)

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

        nodeStorage.SortNodeIntoStorageAccourdingToItsSettings(busNode)
      
        self.Close(event.player_index)

        return true

      end
      

      function self.Show(player, entity)

        self.Close(player.index) -- in case another entity is already open

        modData.persisted.editedEntity = entity

        local frame = tools.CreateAndRememberGuiElement("entity", player.gui.screen, {type = "frame", name = self.guiElementNames.gui, direction = "vertical"})
        local verticalFlow = frame.add{type = "flow", direction = "vertical"}

        self.AddTitleBarToEntityGui(verticalFlow, frame)
        self.AddBusAndChannelSelectorToEntityGui(verticalFlow)
        self.AddSendReceiveSelectorToEntityGui(verticalFlow)
        self.AddOkButtonToEntityGui(verticalFlow)

        frame.location = tools.GetGuiPosition(player.index, "entity")

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