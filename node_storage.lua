local Factories = require "factories"
local Tools = require "tools"

local function NodeStorage(modData)
    local self = {}

    local factories = Factories(modData)
    local tools = Tools(modData)
    local modData = modData
--    local unassigned = "{unassigned}"


    -- function self.GetUnassignedBus()
    --     local unassignedBus = modData.persisted.busses[unassigned]
    --     if (not unassignedBus) then
    --         unassignedBus = factories.CreateBus(unassigned)
    --         modData.persisted.busses[unassigned] = unassignedBus
    --     end

    --     return unassignedBus
    -- end


    -- function self.GetUnassignedChannelOf(busName)
    --     local bus = modData.persisted.busses[busName]
    --     return self.GetUnassignedChannelOf(bus)
    -- end


    -- function self.GetUnassignedChannelOf(bus)
    --     local unassignedChannel = bus.channels[unassigned]
    --     if (not unassignedChannel) then
    --         unassignedChannel = factories.CreateChannel(unassigned)
    --         bus.channels[unassigned] = unassignedChannel
    --     end

    --     return unassignedChannel
    -- end


    function self.GetNode(nodeId)

        return modData.persisted.nodesById[nodeId]
        
    end


    function self.StoreNewNode(node, id)
        self.StoreNewNodeWithSettings(node, id, {busName = "", channelName = "", direction = modData.constants.nodeDirection.send })
    end


    function self.StoreNewNodeWithSettings(node, id, settings)
        modData.persisted.nodesById[id] = node

        local targetChannel = self.GetAssignedChannel(settings.busName, settings.channelName)

        if (targetChannel) then
            if (settings.direction == modData.constants.nodeDirection.send) then
                targetChannel.senderNodes[id] = node
            else                
                targetChannel.receiverNodes[id] = node
            end
        end
        node.settings = settings
        node.currentlyAssignedChannelRef = targetChannel

    end


    function self.GetAssignedChannel(busName, channelName)

        if ((not busName or busName:len() == 0) or (not channelName or channelName:len() == 0)) then
            return nil
        end

        local assignedBus = modData.persisted.busses[busName]
        if (not assignedBus) then
            return nil
        end

        local assignedChannel = assignedBus.channels[channelName]
        if (not assignedChannel) then
            assignedBus.channels[channelName] = { receiverNodes = {}, senderNodes = {}}
            assignedChannel = assignedBus.channels[channelName]
        end

        return assignedChannel
    end


    function self.RemoveNode(nodeId)
        local nodeToRemove = modData.persisted.nodesById[nodeId]
        if (not nodeToRemove) then
            return
        end

        local assignedChannel = self.GetAssignedChannel(nodeToRemove.settings.busName, nodeToRemove.settings.channelName)

        if (assignedChannel) then
            if (nodeToRemove.settings.direction == modData.constants.nodeDirection.send) then
                assignedChannel.senderNodes[nodeId] = nil
            else                
                assignedChannel.receiverNodes[nodeId] = nil
            end
        end
        modData.persisted.nodesById[nodeId] = nil

    end


    function self.SortNodeIntoStorageAccourdingToItsSettings(node)
        local settings = node.settings
  
        local targetChannel = self.GetAssignedChannel(settings.busName, settings.channelName)

        if (targetChannel == node.currentlyAssignedChannelRef) then
            return
        end

        if (node.currentlyAssignedChannelRef) then
            if (settings.direction == modData.constants.nodeDirection.send) then
                node.currentlyAssignedChannelRef.senderNodes[node.id] = nil
            else
                node.currentlyAssignedChannelRef.receiverNodes[node.id] = nil
            end
        end
        if (targetChannel) then
            if (settings.direction == modData.constants.nodeDirection.send) then
                targetChannel.senderNodes[node.id] = node
            else                    
                targetChannel.receiverNodes[node.id] = node
            end
        end
        node.currentlyAssignedChannelRef = targetChannel

      end
  
  
      function self.GetCopyOfSettingsFor(nodeId)
        local node = modData.persisted.nodesById[nodeId]

        if (not node) then
            return nil
        end

        return tools.deepTableCopy(node.settings)
    end

    return self

end

return NodeStorage

