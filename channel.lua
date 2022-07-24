local function Channel(modData)

    local self = {}

    local modData = modData


    function self.GetDelimitedCount(count)
        return math.min(2147483647, math.max(-2147483647, count))
    end


    function self.MergeSignal(signals, signal)
        local existingSignal = signals[signal.signal.name]
        if (not existingSignal) then
            signals[signal.signal.name] = { signal = signal.signal, count = signal.count }
        else
            existingSignal.count = self.GetDelimitedCount(existingSignal.count + signal.count)
        end
    end


    function self.WriteSignalsIntoConstantCombinatorControlBehavior(controlBehavior, signals)

        local behaviorParameters = {}

        local count = 0
        for signalName, signal in pairs(signals) do
            count = count + 1
            behaviorParameters[count] = { signal = signal.signal, count = signal.count, index = count }
        end

        controlBehavior.parameters = behaviorParameters
    end


    function self.SetOutputOnReceivers(signals, channel)

        -- TEMP
        if (not channel.receiverNodes) then
            return
        end
        -- END_TEMP
        for _, node in pairs(channel.receiverNodes) do

            if (node.worldEntity.valid) then
                if (not node.controlBehavior or not node.controlBehavior.valid) then
                    node.controlBehavior = node.worldEntity.get_or_create_control_behavior()
                end
                self.WriteSignalsIntoConstantCombinatorControlBehavior(node.controlBehavior, signals)
            end
        end

    end




    function self.MergeSignalsOfWire(signals, wire, channel)

        -- TEMP
        if (not channel.senderNodes) then
            return
        end
        -- END_TEMP

        for _, node in pairs(channel.senderNodes) do
            local nodeCircuitNetwork = node.worldEntity.valid and node.worldEntity.get_circuit_network(wire) or nil

            if (nodeCircuitNetwork) then
                local wireSignals = nodeCircuitNetwork.signals
                if (wireSignals) then
                    for i = 1, #wireSignals do
                        self.MergeSignal(signals, wireSignals[i])
                    end
                end
            end
        end

    end


    function self.Update(channel)

        local signalsByType = {}

        self.MergeSignalsOfWire(signalsByType, defines.wire_type.green, channel)
        self.MergeSignalsOfWire(signalsByType, defines.wire_type.red, channel)

        self.SetOutputOnReceivers(signalsByType, channel)

    end


    return self
end


return Channel