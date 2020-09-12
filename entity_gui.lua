local Tools = require "tools"


local function EntityGui(constants, persistedModData, volatileModData)

    local self =
    {

    }

    local constants = constants
    local persistedModData = persistedModData
    local volatileModData = volatileModData
    local tools = Tools()


    function self.AddTitleBarToEntityGui(parent, dragTarget)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = constants.entityGuiCloseButtonName, sprite = "utility/close_white", style = "frame_action_button"}
      end
      
      
     function self.AddBusAndChannelSelectorToEntityGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"EntityGui.BusLabel"}}
        volatileModData.guiElements[constants.busOfEntityDropdown] = flow.add{type = "drop-down", name = constants.busOfEntityDropdown, items = tools.BussesAsLocalizedStringList(persistedModData.busses, persistedModData.channelSets)}
        flow.add{type = "label", caption = {"EntityGui.ChannelLabel"}}
        flow.add{type = "drop-down", name = constants.channelOfEntityDropdown, items = {}}

      end
      
      
      function self.AddSendReceiveSelectorToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "checkbox", name = constants.sendCheckbox, state = true}
        flow.add{type = "label", caption = {"EntityGui.SendLabel"}}
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "checkbox", name = constants.receiveCheckbox, state = true}
        flow.add{type = "label", caption = {"EntityGui.ReceiveLabel"}}
      
      end
      
      
      function self.AddOkButtonToEntityGui(parent)
      
        local flow = parent.add{type = "flow", direction = "horizontal"}
        volatileModData.guiElements[constants.entityGuiOkButtonName] = flow.add{type = "button", name = constants.entityGuiOkButtonName, caption = {"EntityGui.Ok"}}
      
      end

      
      function self.HandleCloseButton(event)

        if (event.element.name ~= constants.entityGuiCloseButtonName) then
            return false
        end

        local frame = volatileModData.guiElements[constants.entityGui]
        volatileModData.editedEntity = nil
      
        volatileModData.guiElements = {}
        frame.destroy()
      
        return true
      end
      

      function self.HandleEntityOkButton(event)

        if (event.element.name ~= constants.entityGuiOkButtonName) then
          return false
        end
      
        local uniqueEntityId = volatileModData.editedEntity.unit_number
        local busNode = persistedModData.nodes[uniqueEntityId]
      
        local busDropdown = volatileModData.guiElements[constants.busOfEntityDropdown]
        local selectedBusIndex = busDropdown.selected_index
        if (selectedBusIndex == 0) then
          if (busNode.bus ~= nil) then
            busNode.bus.nodes[uniqueEntityId] = nil
            busNode.bus = nil
          end
        else
          local selectedBus = persistedModData.busses[tools.BusNameFromBusDisplayString(busDropdown.items[selectedBusIndex][2])]
          busNode.bus = selectedBus
          selectedBus.nodes[uniqueEntityId] = busNode
        end
      
        return true

      end
      

      function self.Show(player)

        local frame = player.gui.screen.add{type = "frame", name = constants.entityGui, direction = "vertical"}
        volatileModData.guiElements[constants.entityGui] = frame
        local verticalFlow = frame.add{type = "flow", direction = "vertical"}
        self.AddTitleBarToEntityGui(verticalFlow, frame)
      
        self.AddBusAndChannelSelectorToEntityGui(verticalFlow)
        self.AddSendReceiveSelectorToEntityGui(verticalFlow)
        self.AddOkButtonToEntityGui(verticalFlow)
      
        player.opened = frame
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