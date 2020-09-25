local Tools = require "tools"
local ConfigGui = require "config_gui"
local EntityGui = require "entity_gui"
local BusAssignGui = require "bus_assign_gui"


local function Gui(modData)

    local self =
    {
        guiElementNames = 
        {
          modGuiButton = modData.constants.modPrefix .. "WirelessCircuitBusConfigButton"

        },
        guiElements = {}
    }

    local modData = modData
    local tools = Tools()
    local configGui = ConfigGui(modData)
    local entityGui = EntityGui(modData)
    local busAssignGui = BusAssignGui(modData)


    function self.GetBusAssignGui()

      return busAssignGui

    end


    function self.HandleModGuiButton(event)
        if (event.element.name ~= self.guiElementNames.modGuiButton) then
          return false
        end
      
        local player = game.players[event.player_index]
      
        configGui.Show(player)
      
        return true
    end


    function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
            configGui.HandleOnGuiSelectionStateChanged,
            entityGui.HandleOnGuiSelectionStateChanged,
            busAssignGui.HandleOnGuiSelectionStateChanged
        })

    end


    function self.AddModGuiButton(player)
        mod_gui.get_button_flow(player).add{ type = "sprite-button", name = self.guiElementNames.modGuiButton, sprite = "entity/small-biter", style = mod_gui.button_style}
          
      end
      


    function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            self.HandleModGuiButton,
            configGui.HandleOnGuiClick,
            entityGui.HandleOnGuiClick,
            busAssignGui.HandleOnGuiClick
        })
      
      end
      
      
      function self.HandleOnGuiOpened(event)

        if (event.gui_type ~= defines.gui_type.entity) then
            return
          end
        
          local clickedEntity = event.entity;
        
          if (clickedEntity.prototype.name ~= "bus-node") then
            return
          end
                
          local player = game.players[event.player_index]
        
          entityGui.Show(player, clickedEntity)
              
      end
      
      
    return self

end


return Gui