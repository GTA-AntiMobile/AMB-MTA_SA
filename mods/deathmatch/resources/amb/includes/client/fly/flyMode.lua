-- client/fly_client.lua

local flySpeed = 0.8
local verticalSpeed = 0.6
local verticalOffset = 5.0
local isFlying = false

-- nhận trạng thái từ server
addEvent("flyMode:set", true)
addEventHandler("flyMode:set", localPlayer, function(enabled)
    isFlying = enabled
    
    if enabled then
        -- Disable collision with world but keep collision with other players/vehicles
        setElementCollisionsEnabled(localPlayer, false)
        -- Disable physics
        setElementFrozen(localPlayer, true)
        -- Disable controls
        toggleControl("jump", false)
        toggleControl("sprint", false)
        toggleControl("fire", false)
        toggleControl("enter_exit", false)
        toggleControl("crouch", false)
        
        -- Set initial position safely above ground
        local x, y, z = getElementPosition(localPlayer)
        local groundZ = getGroundPosition(x, y, z + 1000)
        if groundZ then
            setElementPosition(localPlayer, x, y, math.max(z, groundZ + verticalOffset))
        end
    else
        -- Re-enable everything
        setElementCollisionsEnabled(localPlayer, true)
        setElementFrozen(localPlayer, false)
        toggleControl("jump", true)
        toggleControl("sprint", true)
        toggleControl("fire", true)
        toggleControl("enter_exit", true)
        toggleControl("crouch", true)
        
        -- Land safely
        local x, y, z = getElementPosition(localPlayer)
        local groundZ = getGroundPosition(x, y, z + 1000)
        if groundZ then
            setElementPosition(localPlayer, x, y, groundZ + 1.0)
        end
        setElementVelocity(localPlayer, 0, 0, 0)
    end
end)

-- bay mỗi frame
addEventHandler("onClientRender", root, function()
    if not isFlying then return end

    local x, y, z = getElementPosition(localPlayer)
    local cx, cy, cz, tx, ty, tz = getCameraMatrix()
    local dirX, dirY, dirZ = tx - cx, ty - cy, tz - cz

    local len = math.sqrt(dirX*dirX + dirY*dirY + dirZ*dirZ)
    if len > 0 then dirX, dirY, dirZ = dirX/len, dirY/len, dirZ/len end

    local moveX, moveY, moveZ = 0, 0, 0

    -- Movement controls
    if getKeyState("w") then
        moveX = moveX + dirX * flySpeed
        moveY = moveY + dirY * flySpeed
        moveZ = moveZ + dirZ * flySpeed
    end
    if getKeyState("s") then
        moveX = moveX - dirX * flySpeed
        moveY = moveY - dirY * flySpeed
        moveZ = moveZ - dirZ * flySpeed
    end

    local rightX, rightY = dirY, -dirX
    if getKeyState("a") then
        moveX = moveX - rightX * flySpeed
        moveY = moveY - rightY * flySpeed
    end
    if getKeyState("d") then
        moveX = moveX + rightX * flySpeed
        moveY = moveY + rightY * flySpeed
    end

    -- Vertical movement
    if getKeyState("space") then 
        moveZ = moveZ + verticalSpeed 
    end
    if getKeyState("lctrl") then 
        moveZ = moveZ - verticalSpeed 
    end

    -- Calculate new position
    local newX, newY, newZ = x + moveX, y + moveY, z + moveZ
    
    -- Ensure minimum height above ground
    local groundZ = getGroundPosition(newX, newY, newZ + 100)
    if groundZ then
        newZ = math.max(newZ, groundZ + verticalOffset)
    end
    
    -- Apply movement only if there's actual movement
    if moveX ~= 0 or moveY ~= 0 or moveZ ~= 0 then
        setElementPosition(localPlayer, newX, newY, newZ)
        -- Reset velocity to prevent physics interference
        setElementVelocity(localPlayer, 0, 0, 0)
    end
end)

-- Emergency landing on F12
addEventHandler("onClientKey", root, function(key, press)
    if key == "F12" and press and isFlying then
        outputChatBox("🚨 Emergency landing activated!", 255, 255, 0)
        triggerServerEvent("flyMode:emergencyLanding", localPlayer)
    end
end)

-- Prevent fall damage while flying
addEventHandler("onClientPlayerDamage", localPlayer, function()
    if isFlying then
        cancelEvent()
    end
end)

-- Auto-disable fly if player gets in vehicle
addEventHandler("onClientPlayerVehicleEnter", localPlayer, function()
    if isFlying then
        triggerServerEvent("flyMode:autoDisable", localPlayer)
    end
end)
