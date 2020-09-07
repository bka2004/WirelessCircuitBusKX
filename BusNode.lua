local function BusNode()
    local self =
    {
        Bus = nil,
        Channel = nil,
        Send = true,
        Receive = true
    }


    function ShowEntityGui()
        player.gui.top.add{type="label", name="greeting", caption="Hi"}
        player.gui.top.greeting.caption = "Hello there!"
      
    end


    return self

end

