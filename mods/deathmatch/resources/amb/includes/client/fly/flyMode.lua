-- client/fly_client.lua

local flySpeed = 1.0
local verticalSpeed = 0.7
local verticalOffset = 5.0
local isFlying = false

-- nhận trạng thái từ server
addEvent("flyMode:set", true)
addEventHandler("flyMode:set", localPlayer, function(enabled)
    isFlying = enabled
    toggleControl("jump", not enabled)
    toggleControl("sprint", not enabled)
    toggleControl("fire", not enabled)
    toggleControl("enter_exit", not enabled)
    -- setElementCollisionsEnabled(localPlayer, not enabled) -- nếu muốn xuyên tường
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

    if getKeyState("space") then moveZ = moveZ + verticalSpeed end
    if getKeyState("lctrl") then moveZ = moveZ - verticalSpeed end

    if moveX ~= 0 or moveY ~= 0 or moveZ ~= 0 then
        setElementPosition(localPlayer, x + moveX, y + moveY, z + moveZ)
    end

    local groundZ = getGroundPosition(x, y, z)
    if groundZ then
        z = math.max(z + moveZ, groundZ + verticalOffset)
    else
        z = z + moveZ
    end

    setElementVelocity(localPlayer, moveX, moveY, moveZ)
end)
