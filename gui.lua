local Tools = require "tools"
local ConfigGui = require "config_gui"
local EntityGui = require "entity_gui"


local function Gui(constants, persistedModData, volatileModData)

    local self =
    {

    }

    local constants = constants
    local persistedModData = persistedModData
    local volatileModData = volatileModData
    local tools = Tools()
    local configGui = ConfigGui(constants, persistedModData, volatileModData)
    local entityGui = EntityGui(constants, persistedModData, volatileModData)


    function self.HandleModGuiButton(event)
        if (event.element.name ~= constants.modGuiButtonName) then
          return false
        end
      
        local player = game.players[event.player_index]
      
        configGui.Show(player)
      
        return true
    end


    function self.ShowEntityGui(player)

        entityGui.Show(player)

    end
    
    
    function self.HandleOnGuiSelectionStateChanged(event)

        tools.CallEventHandler(event, {
            configGui.HandleOnGuiSelectionStateChanged,
            entityGui.HandleOnGuiSelectionStateChanged
        })

    end


    function self.AddModGuiButton(player)
        mod_gui.get_button_flow(player).add{ type = "sprite-button", name = constants.modGuiButtonName, sprite = "entity/small-biter", style = mod_gui.button_style}
          
      end
      


    function self.HandleOnGuiClick(event)

        return tools.CallEventHandler(event, {
            self.HandleModGuiButton,
            configGui.HandleOnGuiClick,
            entityGui.HandleOnGuiClick
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
        
          volatileModData.editedEntity = clickedEntity
        
          local player = game.players[event.player_index]
        
          self.ShowEntityGui(player)
              
      end
      
      
    return self

end


return Gui