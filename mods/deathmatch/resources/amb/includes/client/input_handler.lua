-- ===============================
-- MTA WASD + Unikey Fix Script
-- ===============================

-- Global variables để track chat state
local chatInputActive = false

-- Function để check chat state từ nhiều sources
local function isChatActive()
    -- Check MTA built-in chat
    if isChatBoxInputActive() then
        return true
    end
    
    -- Check custom chatbox state
    if _G.chatInputActive then
        return true
    end
    
    -- Check if any GUI input is active
    if guiGetInputEnabled() then
        return true
    end
    
    return false
end

-- Hàm di chuyển player
local function movePlayer()
    local ped = getLocalPlayer()
    
    -- Chỉ di chuyển khi KHÔNG có chat input nào active
    if not isChatActive() then
        if getKeyState("w") then
            setPedControlState(ped, "forwards", true)
        else
            setPedControlState(ped, "forwards", false)
        end

        if getKeyState("s") then
            setPedControlState(ped, "backwards", true)
        else
            setPedControlState(ped, "backwards", false)
        end

        if getKeyState("a") then
            setPedControlState(ped, "left", true)
        else
            setPedControlState(ped, "left", false)
        end

        if getKeyState("d") then
            setPedControlState(ped, "right", true)
        else
            setPedControlState(ped, "right", false)
        end
    else
        -- Khi chat active, FORCE disable tất cả movement
        setPedControlState(ped, "forwards", false)
        setPedControlState(ped, "backwards", false)
        setPedControlState(ped, "left", false)
        setPedControlState(ped, "right", false)
    end
end

-- Timer kiểm tra trạng thái phím 30ms/lần (faster response)
setTimer(movePlayer, 30, 0)

-- Event handlers để track chat state changes
addEventHandler("onClientGUIChanged", root, function()
    -- Update chat state when GUI changes
    chatInputActive = guiGetInputEnabled()
end)

-- Monitor custom chatbox state
setTimer(function()
    if _G.chatInputActive ~= chatInputActive then
        chatInputActive = _G.chatInputActive or false
        if chatInputActive then
            -- Force stop movement when chat opens
            local ped = getLocalPlayer()
            setPedControlState(ped, "forwards", false)
            setPedControlState(ped, "backwards", false)
            setPedControlState(ped, "left", false)
            setPedControlState(ped, "right", false)
        end
    end
end, 50, 0)
