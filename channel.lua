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


    -- function self.StringKeyFromSignalSpec(signalSpec)

    --     return signalSpec.type .. signalSpec.name

    -- end


    function self.GetDelimitedCount(count)
        return math.min(2147483647, math.max(-2147483647, count))
    end


    function self.MergeSignal(signals, signal)
        local existingSignal = signals[signal.signal.name]
        if (not existingSignal) then
            signals[signal.signal.name] = { signal = signal.signal, count = signal.count }
        else
            existingSignal.count = self.GetDelimitedCount(existingSignal.count + signal.count)
            --signals[signal.signal.name ] = { signal = signal, count = self.GetDelimitedCount(existingSignal.count + signal.count)}
        end
    end

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


    -- function self.GetConstantCombinatorParametersFromSignals(signals)

    --     local constantCombinatorParameters = {}

    --     for signal, signalCount in pairs(signals) do
    --         constantCombinatorParameters[#constantCombinatorParameters+1] = { signal = signal, count = signalCount, index = #constantCombinatorParameters+1 }
    --     end

    --     return constantCombinatorParameters
    -- end


    function self.WriteSignalsIntoConstantCombinatorControlBehavior(controlBehavior, signals)

        local behaviorParameters = {}

        local count = 0
        for signalName, signal in pairs(signals) do
            count = count + 1
            behaviorParameters[count] = { signal = signal.signal, count = signal.count, index = count }
        end

        controlBehavior.parameters = behaviorParameters

        -- if (count > 1) then
        --     local x = 0
        -- end

        -- while (#parameters > count) do
        --     table.remove(parameters, count + 1)
        -- end
    end

    -- function self.SetSignalsAtConstantCombinator(controlBehavior, signals)

    --     --local constantCombinatorParameters = {}

    --     local count = 0
    --     for signal, signalCount in pairs(signals) do
    --         count = count + 1
    --         controlBehavior.set_signal(count, {signal = signal, count = signalCount})
    --         --parameters[count] = { signal = signal, count = signalCount, index = count }
    --     end

    --     -- if (count > 1) then
    --     --     local x = 0
    --     -- end

    --     -- while (#parameters > count) do
    --     --     table.remove(parameters, count + 1)
    --     -- end
    -- end

    function self.SetOutputOnReceivers(signals, channel)

        -- TEMP
        if (not channel.receiverNodes) then
            return
        end
        -- END_TEMP
        for _, node in pairs(channel.receiverNodes) do
            --local nodeSettings = node.settings

            -- -- substract the signals seen at the receiver, because they will get added to the output
            -- local network = node.worldEntity.get_circuit_network(defines.wire_type.red)
            -- if (network) then
            --     self.MergeSignals(signals, network.signals, modData.constants.signalMergeMode.substract)
            -- end
            -- network = node.worldEntity.get_circuit_network(defines.wire_type.green)
            -- if (network) then
            --     self.MergeSignals(signals, network.signals, modData.constants.signalMergeMode.substract)
            -- end

            -- local sigCount = 0
            -- for key, value in pairs(signals) do
            --     sigCount = sigCount + 1
            -- end
            -- if (sigCount > 1) then
            --     local x = 0
            -- end

            if (node.worldEntity.valid) then
                if (not node.controlBehavior or not node.controlBehavior.valid) then
                    node.controlBehavior = node.worldEntity.get_or_create_control_behavior()
                end
                --node.worldEntity.get_or_create_control_behavior().parameters = {}
                --local combinatorParams = {}
                self.WriteSignalsIntoConstantCombinatorControlBehavior(node.controlBehavior, signals)
                --node.controlBehavior.parameters = combinatorParams
                --self.SetSignalsAtConstantCombinator(node.controlBehavior, signals)
                --node.worldEntity.get_or_create_control_behavior().parameters = self.GetConstantCombinatorParametersFromSignals(signals)
                -- local xx = combinatorParams
                -- local yy = node.worldEntity.get_or_create_control_behavior()
                -- local zz = yy.parameters
                -- local bla = 0
            end
        end

    end


    -- function self.GetSignalsFromWire(wire, channel)

    --     local signals = {}

    --     for _, node in pairs(channel.nodes) do
    --         local nodeSettings = node.settings
    --         if (nodeSettings.direction == modData.constants.nodeDirection.send) then
                
    --             local nodeCircuitNetwork = node.worldEntity.valid and node.worldEntity.get_circuit_network(wire) or nil

    --             if (nodeCircuitNetwork) then
    --                 self.MergeSignals(signals, nodeCircuitNetwork.signals)
    --             end
    --         end
    --     end

    --     return signals
    -- end


    function self.MergeSignalsOfWire(signals, wire, channel)

        --local signals = {}

        -- TEMP
        if (not channel.senderNodes) then
            return
        end
        -- END_TEMP

        for _, node in pairs(channel.senderNodes) do
--            local nodeSettings = node.settings
            local nodeCircuitNetwork = node.worldEntity.valid and node.worldEntity.get_circuit_network(wire) or nil

            if (nodeCircuitNetwork) then
                --self.MergeSignals(signals, nodeCircuitNetwork.signals)
                local wireSignals = nodeCircuitNetwork.signals
                if (wireSignals) then
                    for i = 1, #wireSignals do

                        -- if (wireSignals[i].signal.name == "signal-Z") then
                        --     local x = 0
                        -- end

                        self.MergeSignal(signals, wireSignals[i])
                    end
                end
            end
        end

        --return signals
    end


    function self.Update(channel)

        --local signals = {}
        local signalsByType = {}

        self.MergeSignalsOfWire(signalsByType, defines.wire_type.green, channel)
        self.MergeSignalsOfWire(signalsByType, defines.wire_type.red, channel)

        -- self.MergeSignals(signals, self.GetSignalsFromWire(defines.wire_type.red, channel))
        -- self.MergeSignals(signals, self.GetSignalsFromWire(defines.wire_type.green, channel))

        self.SetOutputOnReceivers(signalsByType, channel)

    end


    return self
end


return Channel