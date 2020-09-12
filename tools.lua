local function Tools()

    local self = {}

    function self.ChannelSetsAsLocalizedStringList(channelSets)
        local localizeStringList = {}
        for name,_ in pairs(channelSets) do
          localizeStringList[#localizeStringList + 1] = {"", name}
        end
      
        return localizeStringList
    end
      
      
    function self.ChannelsAsLocalizedStringList(channels)
        local localizeStringList = {}
        for _, name in pairs(channels) do
          localizeStringList[#localizeStringList + 1] = {"", name}
        end
      
        return localizeStringList
    end
      
      
    function self.BussesAsLocalizedStringList(busses, channelSets)
        local localizeStringList = {}
        for name, bus in pairs(busses) do
          localizeStringList[#localizeStringList + 1] = {"", name .. " - " .. channelSets[bus.channelSet].name}
        end
      
        return localizeStringList
    end


    function self.BusNameFromBusDisplayString(busDisplayString)
        return busDisplayString:sub(1, busDisplayString:find(" - ") - 1)
    end


    function self.CallEventHandler(event, eventHandler)

        local handled = false
      
        for _,handleFunction  in pairs(eventHandler) do
            if (not handled) then
              handled = handleFunction(event)
            end      
        end

        return handled
    end


    return self
      
end


return Tools