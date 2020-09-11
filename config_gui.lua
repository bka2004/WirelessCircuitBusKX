local ChannelSetGui = require "channel_set_gui"
local BussesGui = require "busses_gui"
local Tools = require "tools"


local function ConfigGui(constants, persistedModData, volatileModData)
    local self =
    {

    }

    local constants = constants
    local persistedModData = persistedModData
    local volatileModData = volatileModData

    local channelSetGui = ChannelSetGui(constants, persistedModData, volatileModData)
    local bussesGui = BussesGui(constants, persistedModData, volatileModData)
    local tools = Tools()


    function self.AddTitleBarToConfigGui(parent, dragTarget)
        local flow = parent.add{type = "flow", direction = "horizontal"}
        flow.add{type = "label", caption = {"ConfigGui.Title"}, style = "frame_title"}
        flow.add{type = "empty-widget", style = "wirelessdragwidget"}.drag_target = dragTarget
        flow.add{type = "sprite-button", name = constants.configGuiCloseButtonName, sprite = "utility/close_white", style = "frame_action_button"}
    end
      
      
    function self.Show(player)
  
        local frame = player.gui.screen.add{type = "frame", name = constants.configGui, direction = "vertical"}
        volatileModData.guiElements[constants.configGui] = frame
        local verticalFlow = frame.add{type = "flow", direction = "vertical"}
        self.AddTitleBarToConfigGui(verticalFlow, frame)
        
        local tabPane = verticalFlow.add{type = "tabbed-pane"}
        local bussesTab = tabPane.add{type = "tab", name = constants.bussesTab, caption={"ConfigGui.BussesTab"}}
        local bussesFlow = tabPane.add{type = "flow", direction = "vertical"}
        bussesGui.AddBussesGui(bussesFlow)
        tabPane.add_tab(bussesTab, bussesFlow)
        
        local channelSetTab = tabPane.add{type = "tab", caption={"ConfigGui.ChannelSetTab"}}
        local channelSetFlow = tabPane.add{type = "flow", direction = "vertical"}
        channelSetGui.AddChannelSetGui(channelSetFlow)
        tabPane.add_tab(channelSetTab, channelSetFlow)
      
        player.opened = frame
      end


      function self.HandleBussesTabActivated(event)

        if (event.element.name ~= constants.bussesTab) then
          return false
        end
      
        volatileModData.guiElements[constants.chooseChannelSetDropDown].items = tools.ChannelSetsAsLocalizedStringList(persistedModData.channelSets)
      
        return true

      end
      
      
      


      function OnGuiClick(event)

        tools.CallEventHandler(event, {
            channelSetGui.HandleOnGuiClick,
            bussesGui.HandleOnGuiClick,
            self.HandleBussesTabActivated
        })

      end
      
      

    return self
    
end


return ConfigGui