local function Tools()

    local self = {}

    function self.ChannelSetsAsLocalizedStringList(channelSets)
        local localizeStringList = {}
        for name,_ in pairs(channelSets) do
          localizeStringList[#localizeStringList + 1] = name --{"", name}
        end
      
        return localizeStringList
    end
      
      
    function self.ChannelsAsLocalizedStringList(channels)
        local localizeStringList = {}
        for _, name in pairs(channels) do
          localizeStringList[#localizeStringList + 1] = name -- {"", name}
        end
      
        return localizeStringList
    end
      
      
    function self.BussesAsLocalizedStringList(busses, channelSets)
        local localizeStringList = {}
        for name, bus in pairs(busses) do
          localizeStringList[#localizeStringList + 1] = name .. " - " .. channelSets[bus.channelSet].name -- {"", name .. " - " .. channelSets[bus.channelSet].name}
        end
      
        return localizeStringList
    end


    function self.BusNameFromBusDisplayString(busDisplayString)
        return busDisplayString:sub(1, busDisplayString:find(" - ") - 1)
    end

    
    function self.GetIndexOfDropdownItem(items, item, dropdownItemModifier)

        for i, name in pairs(items) do
            if (dropdownItemModifier ~= nil) then
                name = dropdownItemModifier(name)
            end
            if (name == item) then
                return i
            end
        end

        return 0

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


    function self.deepTableCopy(orig, copies)
        copies = copies or {}
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            if copies[orig] then
                copy = copies[orig]
            else
                copy = {}
                copies[orig] = copy
                for orig_key, orig_value in next, orig, nil do
                    copy[self.deepTableCopy(orig_key, copies)] = self.deepTableCopy(orig_value, copies)
                end
                setmetatable(copy, self.deepTableCopy(getmetatable(orig), copies))
            end
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end


    return self
      
end


return Tools