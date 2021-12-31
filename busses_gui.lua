local Tools = require "tools"
local Factories = require "factories"


local function BussesGui(modData)
    local self =
    {
        guiElementNames =
        {
          busAddButton = modData.constants.modPrefix .. "BusAddButton",
          busRenameButton = modData.constants.modPrefix .. "BusRenameButton",
          busRemoveButton = modData.constants.modPrefix .. "BusRemoveButton",
          newBusTextfield = modData.constants.modPrefix .. "NewBusTextfield",
          chooseChannelSetDropDown = modData.constants.modPrefix .. "ChooseChannelSetDropDown",
          busListBox = modData.constants.modPrefix .. "BusListBox"

        },
    }

    local modData = modData
    local tools = Tools(modData)
    local factories = Factories(modData)


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
        local channelSet = modData.persisted.channelSets[channelSetName]
        modData.persisted.busses[busName] = factories.CreateBusWithChannelSet(busName, channelSet)
        busTextfield.text = ""
      
        self.UpdateBusList()
      
        return true
      end
 
      
      function self.HandleBusRenameButton(event)
        if (event.element.name ~= self.guiElementNames.busRenameButton) then
          return false
        end

        local busList = tools.RetrieveGuiElement("busses", self.guiElementNames.busListBox)
        local busTextfield = tools.RetrieveGuiElement("busses", self.guiElementNames.newBusTextfield)

        local oldBusName = tools.KeyFromDisplayString(busList.get_item(busList.selected_index))
        local newBusName = busTextfield.text

        self.RenameBus(oldBusName, newBusName)

        self.UpdateBusList()
      
        return true
      end


      function self.HandleBusSelected(event)
        if (event.element.name ~= self.guiElementNames.busListBox) then
          return false
        end

        local busList = tools.RetrieveGuiElement("busses", self.guiElementNames.busListBox)
        local busTextfield = tools.RetrieveGuiElement("busses", self.guiElementNames.newBusTextfield)

        busTextfield.text = tools.KeyFromDisplayString(busList.get_item(busList.selected_index))
     
        return true
      end


      function self.HandleBusRemoveButton(event)
        if (event.element.name ~= self.guiElementNames.busRemoveButton) then
          return false
        end
      
        local busListBox = tools.RetrieveGuiElement("busses", self.guiElementNames.busListBox)       
        if (busListBox.selected_index == 0) then
          return true
        end

        local busToRemove = tools.KeyFromDisplayString(busListBox.items[busListBox.selected_index])

        modData.persisted.busses[busToRemove] = nil
     
        self.UpdateBusList()
      
        return true
      end
      

    function self.UpdateBusList()
        local busList = tools.RetrieveGuiElement("busses", self.guiElementNames.busListBox)
        busList.items = tools.BussesAsLocalizedStringListSorted(modData.persisted.busses, modData.persisted.channelSets)
    end 

      
    function self.AddBusSelectorToBussesGui(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.BusNameLabel"}}
        tools.CreateAndRememberGuiElement("busses", flow, {type = "textfield", name = self.guiElementNames.newBusTextfield})
        flow.add{type = "label", caption = {"ConfigGui.ChannelSetLabel"}}
        tools.CreateAndRememberGuiElement("busses", flow, {type = "drop-down", name = self.guiElementNames.chooseChannelSetDropDown, items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)})
        tools.CreateAndRememberGuiElement("busses", flow, {type = "button", name = self.guiElementNames.busAddButton, caption = {"ConfigGui.Add"}})
        tools.CreateAndRememberGuiElement("busses", flow, {type = "button", name = self.guiElementNames.busRenameButton, caption = {"ConfigGui.Rename"}})

    end
      
      
    function self.AddBusListToBussesGui(parent)

        local outerFlow = parent.add{type = "flow", direction = "horizontal"}
        tools.CreateAndRememberGuiElement("busses", outerFlow, {type = "list-box", name = self.guiElementNames.busListBox })
        local innerFlow = outerFlow.add{type = "flow", direction = "vertical"}
        innerFlow.add{type = "button", name = self.guiElementNames.busRemoveButton, caption = {"ConfigGui.Remove"}}

        self.UpdateBusList()
    end
      

    function self.Update()

        tools.RetrieveGuiElement("busses", self.guiElementNames.chooseChannelSetDropDown).items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)
        self.UpdateBusList()
    end

      
    function self.AddBussesGui(parent)
        
        self.AddBusSelectorToBussesGui(parent)
        self.AddBusListToBussesGui(parent)

    end


    function self.RenameBus(oldName, newName)
      local bus = modData.persisted.busses[oldName]
      if not bus then
        return
      end

      bus.name = newName
      modData.persisted.busses[oldName] = nil
      modData.persisted.busses[newName] = bus

      self.UpdatedAffectedNodes(oldName, newName)
    end


    function self.UpdatedAffectedNodes(oldName, newName)

      for nodeId, node in pairs(modData.persisted.nodesById) do
        if (node.settings.busName == oldName) then
          node.settings.busName = newName
        end
      end

      
    end


    function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
          self.HandleBusSelected
        })

    end


    function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            self.HandleBusAddButton,
            self.HandleBusRenameButton,
            self.HandleBusRemoveButton
        })
        
    end


    return self
      
end


return BussesGui