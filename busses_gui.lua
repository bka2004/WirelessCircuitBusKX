local Tools = require "tools"

local function BussesGui(constants, persistedModData, volatileModData)
    local self =
    {

    }

    local constants = constants
    local persistedModData = persistedModData
    local volatileModData = volatileModData
    local tools = Tools()


    function self.HandleBusAddButton(event)
        if (event.element.name ~= constants.busAddButtonName) then
          return false
        end
      
        local busTextfield = volatileModData.guiElements[constants.newBusTextfieldName]
        local busName = busTextfield.text
        if (busName:len() == 0) then
          return true
        end
      
        local channelSetDropDown = volatileModData.guiElements[constants.chooseChannelSetDropDown]
        local selectedIndex = channelSetDropDown.selected_index
        if (selectedIndex == 0) then
          return true
        end
      
        local channelSetName = channelSetDropDown.get_item(selectedIndex)[2]
        persistedModData.busses[busName] = { name = busName, channelSet = channelSetName, nodes = {} }
        busTextfield.text = ""
      
        local busList = volatileModData.guiElements[constants.busListBoxName]
        busList.items = tools.BussesAsLocalizedStringList(persistedModData.busses, persistedModData.channelSets)
      
        return true
      end
      
      
    function self.AddBusSelectorToBussesGui(parent)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.BusNameLabel"}}
        volatileModData.guiElements[constants.newBusTextfieldName] = flow.add{type = "textfield", name = constants.newBusTextfieldName}
        flow.add{type = "label", caption = {"ConfigGui.ChannelSetLabel"}}
        volatileModData.guiElements[constants.chooseChannelSetDropDown] = flow.add{type = "drop-down", name = constants.chooseChannelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(persistedModData.channelSets)}
        volatileModData.guiElements[constants.busAddButtonName] = flow.add{type = "button", name = constants.busAddButtonName, caption = {"ConfigGui.Add"}}
    end
      
      
    function self.AddBusListToBussesGui(parent)
        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        volatileModData.guiElements[constants.busListBoxName] = outerFlow.add{type = "list-box", name = constants.busListBoxName, items = tools.BussesAsLocalizedStringList(persistedModData.busses)}
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = constants.removeChannelButtonName, caption = {"ConfigGui.Remove"}}
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