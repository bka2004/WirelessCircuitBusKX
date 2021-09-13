local Tools = require "tools"

local function BussesGui(modData)
    local self =
    {
        guiElementNames =
        {
          busAddButton = modData.constants.modPrefix .. "BusAddButton",
          busRemoveButton = modData.constants.modPrefix .. "BusRemoveButton",
          newBusTextfield = modData.constants.modPrefix .. "NewBusTextfield",
          chooseChannelSetDropDown = modData.constants.modPrefix .. "ChooseChannelSetDropDown",
          busListBox = modData.constants.modPrefix .. "BusListBox"

        },
    }

    local modData = modData
    local tools = Tools(modData)


    function self.HandleBusAddButton(event)
        if (event.element.name ~= self.guiElementNames.busAddButton) then
          return false
        end
      
        local busTextfield = tools.RetrieveGuiElement("busses", self.guiElementNames.newBusTextfield)
        local busName = busTextfield.text
        if (busName:len() == 0) then
          return true
        end
      
        local channelSetDropDown = tools.RetrieveGuiElement("busses", self.guiElementNames.chooseChannelSetDropDown)
        local selectedIndex = channelSetDropDown.selected_index
        if (selectedIndex == 0) then
          return true
        end
      
        local channelSetName = channelSetDropDown.get_item(selectedIndex)
        modData.persisted.busses[busName] = { name = busName, channelSet = channelSetName, nodes = {} }
        busTextfield.text = ""
      
        self.UpdateBusList()
      
        return true
      end
      

      function self.HandleBusRemoveButton(event)
        if (event.element.name ~= self.guiElementNames.busRemoveButton) then
          return false
        end
      
        local busListBox = tools.RetrieveGuiElement("busses", self.guiElementNames.busListBox)       
        local busToRemove = tools.KeyFromDisplayString(busListBox.items[busListBox.selected_index])

        modData.persisted.busses[busToRemove] = nil
     
        self.UpdateBusList()
      
        return true
      end
      

    function self.UpdateBusList()
        local busList = tools.RetrieveGuiElement("busses", self.guiElementNames.busListBox)
        busList.items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)
    end 

      
    function self.AddBusSelectorToBussesGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.BusNameLabel"}}
        tools.CreateAndRememberGuiElement("busses", flow, {type = "textfield", name = self.guiElementNames.newBusTextfield})
        flow.add{type = "label", caption = {"ConfigGui.ChannelSetLabel"}}
        tools.CreateAndRememberGuiElement("busses", flow, {type = "drop-down", name = self.guiElementNames.chooseChannelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)})
        tools.CreateAndRememberGuiElement("busses", flow, {type = "button", name = self.guiElementNames.busAddButton, caption = {"ConfigGui.Add"}})

    end
      
      
    function self.AddBusListToBussesGui(parent)

        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        tools.CreateAndRememberGuiElement("busses", outerFlow, {type = "list-box", name = self.guiElementNames.busListBox, items = tools.BussesAsLocalizedStringList(modData.persisted.busses, modData.persisted.channelSets)})
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = self.guiElementNames.busRemoveButton, caption = {"ConfigGui.Remove"}}

    end
      

    function self.Update()

        tools.RetrieveGuiElement("busses", self.guiElementNames.chooseChannelSetDropDown).items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)
        self.UpdateBusList()
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
            self.HandleBusAddButton,
            self.HandleBusRemoveButton
        })
        
    end


    return self
      
end


return BussesGui