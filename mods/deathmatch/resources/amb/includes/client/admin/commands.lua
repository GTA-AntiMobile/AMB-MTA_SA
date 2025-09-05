-- ================================
-- AMB MTA:SA - Client Event Handlers
-- Client-side listeners for admin commands
-- ================================

-- Admin spectate client events
addEvent("onAdminSpectate", true)
addEventHandler("onAdminSpectate", root, function(targetPlayer, spectating)
    if spectating then
        -- Set camera to target
        setCameraTarget(targetPlayer)
        outputChatBox("👁️ Spectating mode ON", 255, 255, 100)
    else
        -- Return camera to self
        setCameraTarget(localPlayer)
        outputChatBox("👁️ Spectating mode OFF", 255, 255, 100)
    end
end)

-- Admin freeze client events
addEvent("onPlayerFreeze", true)
addEventHandler("onPlayerFreeze", root, function(frozen)
    if frozen then
        -- Freeze effect
        setPlayerHudComponentVisible("radar", false)
        outputChatBox("❄️ You have been frozen by an admin", 100, 200, 255)
    else
        -- Unfreeze effect
        setPlayerHudComponentVisible("radar", true)
        outputChatBox("✅ You have been unfrozen", 0, 255, 0)
    end
end)