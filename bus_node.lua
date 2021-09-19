local function BusNodeClass(modData)

    local self =
    {
    }

    local modData = modData


    -- function self.StringKeyFromSignalSpec(signalSpec)

    --     return signalSpec.type .. signalSpec.name

    -- end


    -- function self.SetBus(node, busName)

    --     if (not node.settings) then
    --       node.settings = {}
    --     end
    --     local settings = node.settings
    --     if (busName == "") then
    --       if (settings.bus:len() > 0) then
    --         modData.persisted.busses[settings.bus].nodes[node.worldEntity.unit_number] = nil
    --         node.bus = ""
    --       end
    --     else
    --       settings.bus = busName
    --       modData.persisted.busses[busName].nodes[node.worldEntity.unit_number] = node
    --     end

    -- end

    -- function self.GetDelimitedCount(count)
    --     return math.min(2147483647, math.max(-2147483647, count))
    -- end


    -- function self.MergeSignals(firstSet, secondSet)

    --     if (not secondSet or #secondSet == 0) then
    --         return
    --     end

    --     local countsBySignalId = {}

    --     for _, signal in pairs(firstSet) do
    --         local signalSpec = signal.signal
    --         countsBySignalId[self.StringKeyFromSignalSpec(signalSpec)] = { count = signal.count, signalSpec = signalSpec }
    --     end

    --     for _, signal in pairs(secondSet) do
            
    --         local signalSpec = signal.signal
    --         local signalKey = self.StringKeyFromSignalSpec(signalSpec)
    --         if (countsBySignalId[signalKey] ~= nil) then
    --             countsBySignalId[signalKey].count = self.GetDelimitedCount(countsBySignalId[signalKey].count  + signal.count)
    --         else
    --             countsBySignalId[signalKey] = { count = signal.count, signalSpec = signalSpec }
    --         end
    --     end

    --     for i, signal in ipairs(firstSet) do

    --         local signalSpec = signal.signal
    --         local signalKey = self.StringKeyFromSignalSpec(signalSpec)
    --         signal.count = countsBySignalId[signalKey].count
    --         countsBySignalId[signalKey] = nil
    --     end

    --     for signalKeyString, signalInfo in pairs(countsBySignalId) do
    --         firstSet[#firstSet+1] = { signal = signalInfo.signalSpec, count = signalInfo.count }
    --     end
    -- end


    -- function self.GetConstantCombinatorParametersFromSignals(signals)

    --     local constantCombinatorParameters = {}

    --     for i, signal in ipairs(signals) do
    --         constantCombinatorParameters[#constantCombinatorParameters+1] = { signal = signal.signal, count = signal.count, index = #constantCombinatorParameters+1 }
    --     end

    --     return constantCombinatorParameters
    -- end


    -- function self.SetOutputSignals(node, signals)

    --     node.worldEntity.get_or_create_control_behavior().parameters = { parameters = self.GetConstantCombinatorParametersFromSignals(signals) }

    -- end


    -- function self.MergeWireSignals(signals, node, wire)
    --     local nodeCircuitNetwork = node.worldEntity.get_circuit_network(wire)
    --     if (nodeCircuitNetwork) then
    --         self.MergeSignals(signals, nodeCircuitNetwork.signals)
    --     end
    -- end


    -- function self.GetSignalsFromCorrespondingSenders(node, bus)

    --     local signals = {}

    --     for _, busNode in pairs(bus.nodes) do
    --         if (busNode.settings.send
    --             and node.worldEntity.unit_number ~= busNode.worldEntity.unit_number
    --             and node.settings.channel == busNode.settings.channel) then

    --                 self.MergeWireSignals(signals, busNode, defines.wire_type.green)
    --                 self.MergeWireSignals(signals, busNode, defines.wire_type.red)
    --         end
    --     end

    --     return signals
    -- end


    -- function self.Update(node, bus)
    --     local signals = self.GetSignalsFromCorrespondingSenders(node, bus)

    --     self.SetOutputSignals(node, signals)
    -- end


    return self

end


return BusNodeClass