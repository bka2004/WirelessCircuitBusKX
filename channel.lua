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


    function self.StringKeyFromSignalSpec(signalSpec)

        return signalSpec.type .. signalSpec.name

    end


    function self.GetDelimitedCount(count)
        return math.min(2147483647, math.max(-2147483647, count))
    end


    function self.MergeSignals(firstSet, secondSet)

        if (not secondSet or #secondSet == 0) then
            return
        end

        local countsBySignalId = {}

        for _, signal in pairs(firstSet) do
            local signalSpec = signal.signal
            countsBySignalId[self.StringKeyFromSignalSpec(signalSpec)] = { count = signal.count, signalSpec = signalSpec }
        end

        for _, signal in pairs(secondSet) do
            
            local signalSpec = signal.signal
            local signalKey = self.StringKeyFromSignalSpec(signalSpec)
            if (countsBySignalId[signalKey] ~= nil) then
                countsBySignalId[signalKey].count = self.GetDelimitedCount(countsBySignalId[signalKey].count  + signal.count)
            else
                countsBySignalId[signalKey] = { count = signal.count, signalSpec = signalSpec }
            end
        end

        for i, signal in ipairs(firstSet) do

            local signalSpec = signal.signal
            local signalKey = self.StringKeyFromSignalSpec(signalSpec)
            signal.count = countsBySignalId[signalKey].count
            countsBySignalId[signalKey] = nil
        end

        for signalKeyString, signalInfo in pairs(countsBySignalId) do
            firstSet[#firstSet+1] = { signal = signalInfo.signalSpec, count = signalInfo.count }
        end
    end


    function self.GetConstantCombinatorParametersFromSignals(signals)

        local constantCombinatorParameters = {}

        for i, signal in ipairs(signals) do
            constantCombinatorParameters[#constantCombinatorParameters+1] = { signal = signal.signal, count = signal.count, index = #constantCombinatorParameters+1 }
        end

        return constantCombinatorParameters
    end


    function self.SetOutputOnReceivers(signals, channel)

        for _, node in pairs(channel.nodes) do
            local nodeSettings = node.settings
            if (nodeSettings.direction == modData.constants.nodeDirection.receive) then

                -- -- substract the signals seen at the receiver, because they will get added to the output
                -- local network = node.worldEntity.get_circuit_network(defines.wire_type.red)
                -- if (network) then
                --     self.MergeSignals(signals, network.signals, modData.constants.signalMergeMode.substract)
                -- end
                -- network = node.worldEntity.get_circuit_network(defines.wire_type.green)
                -- if (network) then
                --     self.MergeSignals(signals, network.signals, modData.constants.signalMergeMode.substract)
                -- end

                if (node.worldEntity.valid) then
                    node.worldEntity.get_or_create_control_behavior().parameters = self.GetConstantCombinatorParametersFromSignals(signals)
                end
            end
        end

    end


    function self.GetSignalsFromWire(wire, channel)

        local signals = {}

        for _, node in pairs(channel.nodes) do
            local nodeSettings = node.settings
            if (nodeSettings.direction == modData.constants.nodeDirection.send) then
                
                local nodeCircuitNetwork = node.worldEntity.valid and node.worldEntity.get_circuit_network(wire) or nil

                if (nodeCircuitNetwork) then
                    self.MergeSignals(signals, nodeCircuitNetwork.signals)
                end
            end
        end

        return signals
    end


    function self.Update(channel)

        local signals = {}

        self.MergeSignals(signals, self.GetSignalsFromWire(defines.wire_type.red, channel))
        self.MergeSignals(signals, self.GetSignalsFromWire(defines.wire_type.green, channel))

        self.SetOutputOnReceivers(signals, channel)

    end


    return self
end


return Channel