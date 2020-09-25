local ChannelSetGui = require "channel_set_gui"
local BussesGui = require "busses_gui"
local Tools = require "tools"


local function ConfigGui(modData)
    local self =
    {
        guiElementNames =
        {
          closeButton = modData.constants.modPrefix .. "ChannelSetGuiCloseButton",
          gui = modData.constants.modPrefix .. "ConfigtGui",
          bussesTab = modData.constants.modPrefix .. "BussesTab",
        },
        guiElements = {}
    }

    local modData = modData
    local channelSetGui = ChannelSetGui(modData)
    local bussesGui = BussesGui(modData)
    local tools = Tools()


    function self.AddTitleBar(parent, dragTarget)

        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = self.guiElementNames.closeButton, sprite = "utility/close_white", style = "frame_action_button"}

    end
      
      
    function self.Show(player)
  
        local frame = player.gui.screen.add{type = "frame", name = self.guiElementNames.gui, direction = "vertical"}
        self.guiElements[self.guiElementNames.gui] = frame
        local verticalFlow = frame.add{type = "flow", direction = "vertical"}
        self.AddTitleBar(verticalFlow, frame)
        
        local tabPane = verticalFlow.add{type = "tabbed-pane"}
        local bussesTab = tabPane.add{type = "tab", name = self.guiElementNames.bussesTab, caption={"ConfigGui.BussesTab"}}
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
        if (event.element.name ~= self.guiElementNames.closeButton) then
            return false
        end

        local frame = self.guiElements[self.guiElementNames.gui]
      
        self.guiElements = {}
        frame.destroy()
      
        return true
      end
      

      function self.HandleBussesTabActivated(event)

        if (event.element.name ~= self.guiElementNames.bussesTab) then
          return false
        end
      
        bussesGui.Update()
      
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