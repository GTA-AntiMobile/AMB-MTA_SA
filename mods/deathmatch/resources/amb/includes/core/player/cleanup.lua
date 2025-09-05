-- Auto cleanup player data on quit
addEventHandler("onPlayerQuit", root, function()
    setElementData(source, "loggedIn", false)
    setElementData(source, "username", nil)
    setElementData(source, "adminLevel", nil)
    setElementData(source, "level", nil)
    setElementData(source, "job", nil)
    setElementData(source, "playerMoney", nil)
    setElementData(source, "bankMoney", nil)
    -- Add/remove any other scoreboard-relevant data here
end)
