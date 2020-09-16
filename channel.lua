local function Channel(modData)

    local self = {}

    local modData = modData


    -- function self.MergeSignals(firstSet, secondSet, signalMergeMode)

    --     if (not secondSet or #secondSet == 0) then
    --         return
    --     end

    --     local countsBySignalId = {}

    --     for _, signal in pairs(firstSet) do
    --         countsBySignalId[signal.signal] = signal.count
    --     end

    --     for _, signal in pairs(secondSet) do
    --         if (signalMergeMode == modData.constants.signalMergeMode.add) then
    --             countsBySignalId[signal.signal] = (countsBySignalId[signal.signal] or 0) + signal.count
    --         elseif (signalMergeMode == modData.constants.signalMergeMode.substract) then
    --             countsBySignalId[signal.signal] = (countsBySignalId[signal.signal] or 0) - signal.count
    --         end
    --     end

    --     for i, signal in ipairs(firstSet) do

    --         signal.count = countsBySignalId[signal.signal]
    --         countsBySignalId[signal.signal] = nil
    --     end

    --     for signal, count in pairs(countsBySignalId) do
    --         firstSet[#firstSet+1] = { signal = signal, count = count }
    --     end
    -- end


    -- function self.SetOutputOnReceivers(signals, bus, channelName)

    --     for _, node in pairs(bus.nodes) do
    --         local nodeSettings = node.settings
    --         if (nodeSettings.channel == channelName and nodeSettings.receive) then

    --             -- substract the signals seen at the receiver, because they will get added to the output
    --             local network = node.worldEntity.get_circuit_network(defines.wire_type.red)
    --             if (network) then
    --                 self.MergeSignals(signals, network.signals, modData.constants.signalMergeMode.substract)
    --             end
    --             network = node.worldEntity.get_circuit_network(defines.wire_type.green)
    --             if (network) then
    --                 self.MergeSignals(signals, network.signals, modData.constants.signalMergeMode.substract)
    --             end

    --             node.worldEntity.get_or_create_control_behavior().parameters = { parameters = self.GetConstantCombinatorParametersFromSignals(signals) }
    --         end
    --     end

    -- end


    -- function self.GetSignalsFromWire(wire, bus, channelName)

    --     local signals = {}

    --     for _, node in pairs(bus.nodes) do
    --         local nodeSettings = node.settings
    --         if (nodeSettings.channel == channelName and nodeSettings.send) then
                
    --             local nodeCircuitNetwork = node.worldEntity.get_circuit_network(wire)

    --             if (nodeCircuitNetwork) then
    --                 self.MergeSignals(signals, nodeCircuitNetwork.signals, modData.constants.signalMergeMode.add)
    --             end
    --         end
    --     end

    --     return signals
    -- end


    -- function self.Update(bus, channelName)

    --     local signals = {}

    --     self.MergeSignals(signals, self.GetSignalsFromWire(defines.wire_type.red, bus, channelName), modData.constants.signalMergeMode.add)
    --     self.MergeSignals(signals, self.GetSignalsFromWire(defines.wire_type.green, bus, channelName), modData.constants.signalMergeMode.add)

    --     self.SetOutputOnReceivers(signals, bus, channelName)

    -- end


    return self
end


return Channel