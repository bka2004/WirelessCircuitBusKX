local ChannelSetGui = require "channel_set_gui"
local BussesGui = require "busses_gui"
local Tools = require "tools"


local function ConfigGui(modData)
    local self =
    {

    }

    local modData = modData
    local channelSetGui = ChannelSetGui(modData)
    local bussesGui = BussesGui(modData)
    local tools = Tools()


    function self.AddTitleBarToConfigGui(parent, dragTarget)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = modData.constants.guiElementNames.configGuiCloseButton, sprite = "utility/close_white", style = "frame_action_button"}
    end
      
      
    function self.Show(player)
  
        local frame = player.gui.screen.add{type = "frame", name = modData.constants.guiElementNames.configGui, direction = "vertical"}
        modData.volatile.guiElements[modData.constants.guiElementNames.configGui] = frame
        local verticalFlow = frame.add{type = "flow", direction = "vertical"}
        self.AddTitleBarToConfigGui(verticalFlow, frame)
        
        local tabPane = verticalFlow.add{type = "tabbed-pane"}
        local bussesTab = tabPane.add{type = "tab", name = modData.constants.guiElementNames.bussesTab, caption={"ConfigGui.BussesTab"}}
        local bussesFlow = tabPane.add{type = "flow", direction = "vertical"}
        bussesGui.AddBussesGui(bussesFlow)
        tabPane.add_tab(bussesTab, bussesFlow)
        
        local channelSetTab = tabPane.add{type = "tab", caption={"ConfigGui.ChannelSetTab"}}
        local channelSetFlow = tabPane.add{type = "flow", direction = "vertical"}
        channelSetGui.AddChannelSetGui(channelSetFlow)
        tabPane.add_tab(channelSetTab, channelSetFlow)
      
        player.opened = frame
      end


    function self.HandleCloseButton(event)
      
        local frame
        if (event.element.name ~= modData.constants.guiElementNames.configGuiCloseButton) then
            return false
        end

        local frame = modData.volatile.guiElements[modData.constants.guiElementNames.configGui]
      
        modData.volatile.guiElements = {}
        frame.destroy()
      
        return true
      end
      

      function self.HandleBussesTabActivated(event)

        if (event.element.name ~= modData.constants.guiElementNames.bussesTab) then
          return false
        end
      
        modData.volatile.guiElements[modData.constants.guiElementNames.chooseChannelSetDropDown].items = tools.ChannelSetsAsLocalizedStringList(modData.persisted.channelSets)
      
        return true

      end
      
      
      function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
            channelSetGui.HandleOnGuiSelectionStateChanged,
            bussesGui.HandleOnGuiSelectionStateChanged
        })

    end


    function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            channelSetGui.HandleOnGuiClick,
            bussesGui.HandleOnGuiClick,
            self.HandleBussesTabActivated,
            self.HandleCloseButton
        })

    end
      

    return self
    
end


return ConfigGui