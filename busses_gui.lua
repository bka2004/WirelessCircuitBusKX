local Tools = require "tools"

local function BussesGui(modData)
    local self =
    {

    }

    local modData = modData
    local tools = Tools()


    function self.HandleBusAddButton(event)
        if (event.element.name ~= modData.constants.guiElementNames.busAddButton) then
          return false
        end
      
        local busTextfield = modData.volatile.guiElements[modData.constants.guiElementNames.newBusTextfield]
        local busName = busTextfield.text
        if (busName:len() == 0) then
          return true
        end
      
        local channelSetDropDown = modData.volatile.guiElements[modData.constants.guiElementNames.chooseChannelSetDropDown]
        local selectedIndex = channelSetDropDown.selected_index
        if (selectedIndex == 0) then
          return true
        end
      
        local channelSetName = channelSetDropDown.get_item(selectedIndex)
        modData.persisted.busses[busName] = { name = busName, channelSet = channelSetName, nodes = {} }
        busTextfield.text = ""
      
        local busList = modData.volatile.guiElements[modData.constants.guiElementNames.busListBox]
        busList.items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)
      
        return true
      end
      
      
    function self.AddBusSelectorToBussesGui(parent)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.BusNameLabel"}}
        modData.volatile.guiElements[modData.constants.guiElementNames.newBusTextfield] = flow.add{type = "textfield", name = modData.constants.guiElementNames.newBusTextfield}
        flow.add{type = "label", caption = {"ConfigGui.ChannelSetLabel"}}
        modData.volatile.guiElements[modData.constants.guiElementNames.chooseChannelSetDropDown] = flow.add{type = "drop-down", name = modData.constants.guiElementNames.chooseChannelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)}
        modData.volatile.guiElements[modData.constants.guiElementNames.busAddButton] = flow.add{type = "button", name = modData.constants.guiElementNames.busAddButton, caption = {"ConfigGui.Add"}}
    end
      
      
    function self.AddBusListToBussesGui(parent)
        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        modData.volatile.guiElements[modData.constants.guiElementNames.busListBox] = outerFlow.add{type = "list-box", name = modData.constants.guiElementNames.busListBox, items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)}
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = modData.constants.guiElementNames.removeChannelButton, caption = {"ConfigGui.Remove"}}
    end
      
      
    function self.AddBussesGui(parent)
        
        self.AddBusSelectorToBussesGui(parent)
        self.AddBusListToBussesGui(parent)

    end


    function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
        })

    end


    function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            self.HandleBusAddButton
        })
        
    end


    return self
      
end


return BussesGui