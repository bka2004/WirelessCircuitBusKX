local Tools = require "tools"
local BusNodeClass = require "bus_node"
local Factories = require "factories"
local NodeStorage = require "node_storage"


local function BusAssignGui(modData)

    local self = 
    {
        guiElementNames = 
        {
            closeButton = modData.constants.modPrefix .. "BusAssignGuiCloseButton",
            gui = modData.constants.modPrefix .. "BusAssignGui",
            busMappingListBox = modData.constants.modPrefix .. "BusMappingListBox",
            assignBusButton = modData.constants.modPrefix .. "AssignBusButton",
            newRadioButton = modData.constants.modPrefix .. "NewRadioButton",
            existingRadioButton = modData.constants.modPrefix .. "ExistingRadioButton",
            existingBusDropdown = modData.constants.modPrefix .. "ExistingBusDropdown",
            newBusTextfield = modData.constants.modPrefix .. "NewBusTextfield",
            applyButton = modData.constants.modPrefix .. "ApplyButton",
        },
    }

    local modData = modData
    local localBusMappings = {}
    local localSelectedNodes
    local tools = Tools(modData)
    local factories = Factories(modData)
    local nodeStorage = NodeStorage(modData)


    function self.GetBusMappingsDisplayList()

        local displayList = {}

        for oldBus, newBusInfo in pairs(localBusMappings) do
            displayList[#displayList+1] = tools.GetBusNameDisplayString(oldBus) .. " -> " .. tools.GetBusNameDisplayString(newBusInfo.name) .. " [" .. newBusInfo.type .. "]"
        end

        return displayList
    end


    function self.AddAssignButton(parent)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "button", caption = { "BusAssignGui.Assign" }, name = self.guiElementNames.assignBusButton}

    end


    function self.AddEditMapping(parent)

        parent.add{type = "label", caption = {"BusAssignGui.MappingEditLabel"}}

        local existingBusFlow = parent.add{type = "flow", direction = "horizontal"}
        tools.CreateAndRememberGuiElement("busAssign", existingBusFlow, {type = "radiobutton", state = false, name = self.guiElementNames.existingRadioButton })
        existingBusFlow.add{type = "label", caption = {"BusAssignGui.ExistingBusLabel"}}
        tools.CreateAndRememberGuiElement("busAssign", existingBusFlow, {type = "drop-down", name = self.guiElementNames.existingBusDropdown})

        local newBusFlow = parent.add{type = "flow", direction = "horizontal"}
        tools.CreateAndRememberGuiElement("busAssign", newBusFlow, {type = "radiobutton", state = false, name = self.guiElementNames.newRadioButton })
        newBusFlow.add{type = "label", caption = {"BusAssignGui.NewBusLabel"}}
        tools.CreateAndRememberGuiElement("busAssign", newBusFlow, {type = "textfield", name = self.guiElementNames.newBusTextfield})
        newBusFlow.add{type = "button", caption = { "BusAssignGui.Apply"}, name = self.guiElementNames.applyButton}

    end


    function self.AddMappingList(parent)
    
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"BusAssignGui.MappingListLabel"}}
        tools.CreateAndRememberGuiElement("busAssign", flow, {type = "list-box", name = self.guiElementNames.busMappingListBox})

    end


    function self.AddTitleBar(parent, dragTarget)
    
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"BusAssignGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = self.guiElementNames.closeButton, sprite = "utility/close_white", style = "frame_action_button"}
    
    end


    function self.UpdateMappingList()

        local mappingListBox = tools.RetrieveGuiElement("busAssign", self.guiElementNames.busMappingListBox)
        mappingListBox.items = self.GetBusMappingsDisplayList()

    end


    function self.Close(playerId)

        local frame = tools.RetrieveGuiElement("busAssign", self.guiElementNames.gui)
        --local frame = self.guiElements[self.guiElementNames.gui]
        if (not frame) then
          return
        end

        tools.SaveGuiPosition(frame.location, playerId, "config")

        localBusMappings = {}
        localSelectedNodes = {}
        tools.ForgetGuiElements("busAssign")

        frame.destroy()

    end


    function self.Show(player, busMappings, selectedNodes)

        for oldBus, newBus in pairs(busMappings) do
            localBusMappings[oldBus] = { type = "new", name = newBus }
        end
        localSelectedNodes = selectedNodes

        local frame = tools.CreateAndRememberGuiElement("busAssign", player.gui.screen, {type = "frame", name = self.guiElementNames.gui, direction = "vertical"})
        local verticalFlow = frame.add{type = "flow", direction = "vertical"}

        self.AddTitleBar(verticalFlow, frame)
        self.AddMappingList(verticalFlow)
        self.AddEditMapping(verticalFlow)
        self.AddAssignButton(verticalFlow)

        self.UpdateMappingList()

        frame.location = tools.GetGuiPosition(player.index, "busAssign")

        player.opened = frame

    end


    function self.CreateNonExistingBusses()

        for oldBus, newBusInfo in pairs(localBusMappings) do
            if (newBusInfo.type == "new") then
                local channelSet = modData.persisted.busses[oldBus].channelSet
                modData.persisted.busses[newBusInfo.name] = factories.CreateBusWithChannelSet(newBusInfo.name, channelSet)
            end
        end

    end


    function self.AssignBusses()

        local busNodeClass = BusNodeClass(modData)

        for _, entity in pairs(localSelectedNodes) do
            local node = modData.persisted.nodesById[entity.unit_number]
            node.settings.busName = localBusMappings[node.settings.busName].name
            nodeStorage.SortNodeIntoStorageAccourdingToItsSettings(node)
        end
    end


    function self.GetBussesWithSameChannelSetAs(busName)

        local origBus = modData.persisted.busses[busName]
        if (not origBus) then
            return {}
        end

        local channetSetToMatch = origBus.channelSet

        local result = {}
        for busName, bus in pairs(modData.persisted.busses) do
            if (bus.channelSet == channetSetToMatch) then
                result[busName] = bus
            end
        end

        return result

    end


    function self.UpdateEditMapping(oldBusName, newBusInfo)

        local newRadioButton = tools.RetrieveGuiElement("busAssign", self.guiElementNames.newRadioButton)
        local existingRadioButton = tools.RetrieveGuiElement("busAssign", self.guiElementNames.existingRadioButton)
        local existingBusDropdown = tools.RetrieveGuiElement("busAssign", self.guiElementNames.existingBusDropdown)
        local newBusTextfield = tools.RetrieveGuiElement("busAssign", self.guiElementNames.newBusTextfield)

        newRadioButton.state = newBusInfo.type == "new"
        existingRadioButton.state = newBusInfo.type == "existing"
        existingBusDropdown.items = tools.BussesAsLocalizedStringList(self.GetBussesWithSameChannelSetAs(oldBusName), modData.persisted.channelSets)

        if (newRadioButton.state) then
            existingBusDropdown.selected_index = 0
            newBusTextfield.text = newBusInfo.name
        else
            existingBusDropdown.selected_index = tools.GetIndexOfDropdownItem(existingBusDropdown.items, newBusInfo.name, tools.KeyFromDisplayString)
            newBusTextfield.text = ""
        end
    end


    function self.HandleAssignBusButton(event)

        if (event.element.name ~= self.guiElementNames.assignBusButton) then
          return false
        end

        self.CreateNonExistingBusses()
        self.AssignBusses()
      
        self.Close(event.player_index)

        return true

    end


    function self.HandleCloseButton(event)

        if (event.element.name ~= self.guiElementNames.closeButton) then
            return false
        end

        self.Close(event.player_index)

        return true

    end


    function self.HandleBusMappingSelectionChanged(event)

        if (event.element.name ~= self.guiElementNames.busMappingListBox) then
            return false
        end

        local oldBusOfMapping = self.GetOldBusNameOfSelectedMapping()
        local newBusInfo = localBusMappings[oldBusOfMapping]
        self.UpdateEditMapping(oldBusOfMapping, newBusInfo)

        return true
    end


    function self.GetOldBusNameOfSelectedMapping()

        local mappingListBox = tools.RetrieveGuiElement("busAssign", self.guiElementNames.busMappingListBox)
        return tools.KeyFromDisplayString(mappingListBox.items[mappingListBox.selected_index])

    end


    function self.HandleRadioButton(event)

        if (event.element.name == self.guiElementNames.newRadioButton) then
            local existingRadioButton = tools.RetrieveGuiElement("busAssign", self.guiElementNames.existingRadioButton)
            existingRadioButton.state = false
            return true
        end

        if (event.element.name == self.guiElementNames.existingRadioButton) then
            local newRadioButton = tools.RetrieveGuiElement("busAssign", self.guiElementNames.newRadioButton)
            newRadioButton.state = false
            return true
        end

        return false
    end


    function self.HandleApplyButton(event)

        if (event.element.name ~= self.guiElementNames.applyButton) then
            return false
        end

        local newRadioButton = tools.RetrieveGuiElement("busAssign", self.guiElementNames.newRadioButton)
        local mappingType = "existing"
        if (newRadioButton.state) then
            mappingType = "new"
        end

        local newBusName
        if (newRadioButton.state) then
            local newBusTextfield = tools.RetrieveGuiElement("busAssign", self.guiElementNames.newBusTextfield)
            newBusName = newBusTextfield.text
        else
            local existingBusDropdown = tools.RetrieveGuiElement("busAssign", self.guiElementNames.existingBusDropdown)
            newBusName = tools.KeyFromDisplayString(existingBusDropdown.items[existingBusDropdown.selected_index])
        end

        local oldBusName = self.GetOldBusNameOfSelectedMapping()
        local newBusInfo = { type = mappingType, name = newBusName }

        localBusMappings[oldBusName] = newBusInfo

        self.UpdateMappingList()

    end


    function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            self.HandleEditMappingApplyButton,
            self.HandleCloseButton,
            self.HandleAssignBusButton,
            self.HandleRadioButton,
            self.HandleApplyButton,
        })

    end


    function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
            self.HandleBusMappingSelectionChanged,
        })

    end



    return self
end


return BusAssignGui