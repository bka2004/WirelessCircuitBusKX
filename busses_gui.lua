local Tools = require "tools"

local function BussesGui(modData)
    local self =
    {
        guiElementNames =
        {
          busAddButton = modData.constants.modPrefix .. "BusAddButton",
          newBusTextfield = modData.constants.modPrefix .. "NewBusTextfield",
          chooseChannelSetDropDown = modData.constants.modPrefix .. "ChooseChannelSetDropDown",
          busListBox = modData.constants.modPrefix .. "BusListBox"

        },
        guiElements = {}
    }

    local modData = modData
    local tools = Tools()


    function self.HandleBusAddButton(event)
        if (event.element.name ~= self.guiElementNames.busAddButton) then
          return false
        end
      
        local busTextfield = self.guiElements[self.guiElementNames.newBusTextfield]
        local busName = busTextfield.text
        if (busName:len() == 0) then
          return true
        end
      
        local channelSetDropDown = self.guiElements[self.guiElementNames.chooseChannelSetDropDown]
        local selectedIndex = channelSetDropDown.selected_index
        if (selectedIndex == 0) then
          return true
        end
      
        local channelSetName = channelSetDropDown.get_item(selectedIndex)
        modData.persisted.busses[busName] = { name = busName, channelSet = channelSetName, nodes = {} }
        busTextfield.text = ""
      
        local busList = self.guiElements[self.guiElementNames.busListBox]
        busList.items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)
      
        return true
      end
      
      
    function self.AddBusSelectorToBussesGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.BusNameLabel"}}
        self.guiElements[self.guiElementNames.newBusTextfield] = flow.add{type = "textfield", name = self.guiElementNames.newBusTextfield}
        flow.add{type = "label", caption = {"ConfigGui.ChannelSetLabel"}}
        self.guiElements[self.guiElementNames.chooseChannelSetDropDown] = flow.add{type = "drop-down", name = self.guiElementNames.chooseChannelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)}
        self.guiElements[self.guiElementNames.busAddButton] = flow.add{type = "button", name = self.guiElementNames.busAddButton, caption = {"ConfigGui.Add"}}

    end
      
      
    function self.AddBusListToBussesGui(parent)
        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        self.guiElements[self.guiElementNames.busListBox] = outerFlow.add{type = "list-box", name = self.guiElementNames.busListBox, items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)}
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = self.guiElementNames.removeBusButton, caption = {"ConfigGui.Remove"}}
    end
      

    function self.Update()

        self.guiElements[self.guiElementNames.chooseChannelSetDropDown].items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)

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