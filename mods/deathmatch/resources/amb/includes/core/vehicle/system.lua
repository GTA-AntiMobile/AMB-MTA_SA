-- ============================================
-- /car command giống SA-MP (Engine, Lights, Trunk, Hood, Fuel, Windows, Status, Lock)
-- ============================================
-- Hàm tìm xe gần nhất trong phạm vi
function getClosestVehicle(player, radius)
    local px, py, pz = getElementPosition(player)
    local nearestVeh, minDist = nil, radius or 5
    for _, veh in ipairs(getElementsByType("vehicle")) do
        local vx, vy, vz = getElementPosition(veh)
        local dist = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
        if dist < minDist then
            nearestVeh, minDist = veh, dist
        end
    end
    return nearestVeh
end

-- ==========================
-- MAIN COMMAND
-- ==========================
addCommandHandler("car", function(player, _, subcmd)
    if not subcmd or subcmd == "" then
        outputChatBox("📌 Sử dụng: /car [engine|lights|hood|trunk|fuel|status|windows|lock]", player, 255, 255, 0)
        return
    end

    subcmd = string.lower(subcmd)
    local vehicle = getPedOccupiedVehicle(player)

    -- ==========================
    -- ENGINE
    -- ==========================
    if subcmd == "engine" then
        if not vehicle then
            return outputChatBox("❌ Bạn không ở trong xe.", player, 255, 100, 100)
        end
        if getVehicleOccupant(vehicle, 0) ~= player then
            return outputChatBox("❌ Bạn không phải tài xế.", player, 255, 100, 100)
        end

        local state = getVehicleEngineState(vehicle)
        setVehicleEngineState(vehicle, not state)
        if state then
            outputChatBox("🔴 Đã tắt động cơ.", player, 255, 100, 100)
        else
            outputChatBox("🟢 Đã bật động cơ.", player, 0, 255, 0)
        end

        -- ==========================
        -- LIGHTS
        -- ==========================
    elseif subcmd == "lights" then
        if not vehicle then
            return outputChatBox("❌ Bạn không ở trong xe.", player, 255, 100, 100)
        end
        if getVehicleOccupant(vehicle, 0) ~= player then
            return outputChatBox("❌ Bạn không phải tài xế.", player, 255, 100, 100)
        end

        local current = getVehicleOverrideLights(vehicle)
        if current == 2 then
            setVehicleOverrideLights(vehicle, 1) -- bật đèn
            outputChatBox("💡 Đã bật đèn xe.", player, 255, 255, 100)
        else
            setVehicleOverrideLights(vehicle, 2) -- tắt đèn
            outputChatBox("🔴 Đã tắt đèn xe.", player, 255, 100, 100)
        end

        -- ==========================
        -- HOOD (Nắp capo)
        -- ==========================
    elseif subcmd == "hood" then
        local targetVeh = vehicle
        if not targetVeh then
            targetVeh = getClosestVehicle(player, 5)
        end
        if not targetVeh then
            return outputChatBox("❌ Không có xe nào gần đây.", player, 255, 100, 100)
        end

        local state = getVehicleDoorOpenRatio(targetVeh, 0)
        if state == 0 then
            setVehicleDoorOpenRatio(targetVeh, 0, 1, 1000)
            outputChatBox("🔧 Đã mở nắp capo.", player, 255, 255, 100)
        else
            setVehicleDoorOpenRatio(targetVeh, 0, 0, 1000)
            outputChatBox("🔧 Đã đóng nắp capo.", player, 255, 255, 100)
        end

        -- ==========================
        -- TRUNK (Cốp xe)
        -- ==========================
    elseif subcmd == "trunk" then
        local targetVeh = vehicle
        if not targetVeh then
            targetVeh = getClosestVehicle(player, 5)
        end
        if not targetVeh then
            return outputChatBox("❌ Không có xe nào gần đây.", player, 255, 100, 100)
        end

        local state = getVehicleDoorOpenRatio(targetVeh, 1)
        if state == 0 then
            setVehicleDoorOpenRatio(targetVeh, 1, 1, 1000)
            outputChatBox("📦 Đã mở cốp xe.", player, 255, 255, 100)
        else
            setVehicleDoorOpenRatio(targetVeh, 1, 0, 1000)
            outputChatBox("📦 Đã đóng cốp xe.", player, 255, 255, 100)
        end

        -- ==========================
        -- LOCK (Khóa/Mở khóa xe)
        -- ==========================
    elseif subcmd == "lock" then
        local targetVeh = vehicle
        if not targetVeh then
            targetVeh = getClosestVehicle(player, 5)
        end
        if not targetVeh then
            return outputChatBox("❌ Không có xe nào gần đây để khóa.", player, 255, 100, 100)
        end

        local locked = isVehicleLocked(targetVeh)
        if locked then
            setVehicleLocked(targetVeh, false)
            outputChatBox("🔓 Bạn đã mở khóa xe.", player, 0, 255, 0)
            triggerClientEvent(root, "playLockSound", player, targetVeh, false)
        else
            setVehicleLocked(targetVeh, true)
            outputChatBox("🔒 Bạn đã khóa xe.", player, 255, 100, 100)
            triggerClientEvent(root, "playLockSound", player, targetVeh, true)
        end

        -- ==========================
        -- FUEL (Xăng)
        -- ==========================
    elseif subcmd == "fuel" then
        if not vehicle then
            return outputChatBox("❌ Bạn không ở trong xe.", player, 255, 100, 100)
        end
        local fuel = getElementData(vehicle, "fuel") or 100
        outputChatBox("⛽ Mức xăng hiện tại: " .. fuel .. "%", player, 0, 255, 0)

        -- ==========================
        -- STATUS (Thông tin tổng quan)
        -- ==========================
    elseif subcmd == "status" then
        if not vehicle then
            return outputChatBox("❌ Bạn không ở trong xe.", player, 255, 100, 100)
        end
        local engine = getVehicleEngineState(vehicle) and "ON" or "OFF"
        local lights = (getVehicleOverrideLights(vehicle) == 2) and "OFF" or "ON"
        local fuel = getElementData(vehicle, "fuel") or 100
        local windows = getElementData(vehicle, "windows") == 1 and "Down" or "Up"
        local locked = isVehicleLocked(vehicle) and "Locked" or "Unlocked"

        outputChatBox("🚗 Engine: " .. engine .. " | Lights: " .. lights .. " | Fuel: " .. fuel .. "%" ..
                          " | Windows: " .. windows .. " | Lock: " .. locked, player, 255, 255, 255)

        -- ==========================
        -- WINDOWS (Cửa kính)
        -- ==========================
    elseif subcmd == "windows" then
        if not vehicle then
            return outputChatBox("❌ Bạn phải ở trong xe.", player, 255, 100, 100)
        end
        if getVehicleType(vehicle) == "Bike" or getVehicleType(vehicle) == "Boat" then
            return outputChatBox("❌ Xe này không có cửa kính.", player, 255, 100, 100)
        end

        local winState = getElementData(vehicle, "windows") or 0
        if winState == 0 then
            setElementData(vehicle, "windows", 1)
            outputChatBox("🔻 Đã hạ cửa kính xuống.", player, 255, 255, 100)
        else
            setElementData(vehicle, "windows", 0)
            outputChatBox("🔺 Đã kéo cửa kính lên.", player, 255, 255, 100)
        end

        -- ==========================
        -- SAI THAM SỐ
        -- ==========================
    else
        outputChatBox(
            "❌ Lệnh không hợp lệ! Sử dụng: /car [engine|lights|hood|trunk|fuel|status|windows|lock]",
            player, 255, 100, 100)
    end
end)

-- Fill gas command
addCommandHandler("fillgas", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    -- Check if at gas station
    local px, py, pz = getElementPosition(player)
    local gasStations = {{1941.4, -1773.9, 13.4}, -- Los Santos
    {1004.0, -939.3, 42.2}, -- Los Santos 2
    {-90.5, -1169.4, 2.4}, -- Los Santos 3
    {2202.0, 2474.0, 10.8}, -- Las Venturas
    {614.9, 1694.2, 7.0}, -- Las Venturas 2
    {-1609.8, -2718.2, 48.5}, -- San Fierro
    {-2029.5, 156.7, 29.0} -- San Fierro 2
    }

    local atGasStation = false
    for _, station in ipairs(gasStations) do
        if getDistanceBetweenPoints3D(px, py, pz, station[1], station[2], station[3]) < 10 then
            atGasStation = true
            break
        end
    end

    if not atGasStation then
        outputChatBox("❌ Ban khong o gan tram xang.", player, 255, 100, 100)
        return
    end

    local playerData = getElementData(player, "playerData") or {}
    local fuelCost = 500 -- $500 for full tank

    if (playerData.money or 0) < fuelCost then
        outputChatBox("❌ Ban khong co du tien de do xang ($500).", player, 255, 100, 100)
        return
    end

    -- Fill gas
    playerData.money = (playerData.money or 0) - fuelCost
    setElementData(player, "playerData", playerData)
    setElementData(vehicle, "fuel", 100) -- Full tank

    outputChatBox("⛽ Da do day xang voi gia $500.", player, 0, 255, 0)
end)

-- Car radio command
addCommandHandler("radio", function(player, cmd, station)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    if not station then
        outputChatBox("Su dung: /radio [1-12/off]", player, 255, 255, 255)
        outputChatBox("1=Playback FM, 2=K-Rose, 3=K-DST, 4=Bounce FM, 5=SF-UR", player, 255, 255, 255)
        outputChatBox("6=Radio Los Santos, 7=Radio X, 8=CSR 103.9, 9=K-JAH West", player, 255, 255, 255)
        outputChatBox("10=Master Sounds 98.3, 11=WCTR, 12=User Track Player", player, 255, 255, 255)
        return
    end

    if station == "off" then
        setVehicleRadio(vehicle, 0) -- Turn off radio
        outputChatBox("📻 Da tat radio.", player, 255, 255, 100)
        return
    end

    local stationID = tonumber(station)
    if not stationID or stationID < 1 or stationID > 12 then
        outputChatBox("❌ Station khong hop le (1-12).", player, 255, 100, 100)
        return
    end

    setVehicleRadio(vehicle, stationID)

    local stationNames = {
        [1] = "Playback FM",
        [2] = "K-Rose",
        [3] = "K-DST",
        [4] = "Bounce FM",
        [5] = "SF-UR",
        [6] = "Radio Los Santos",
        [7] = "Radio X",
        [8] = "CSR 103.9",
        [9] = "K-JAH West",
        [10] = "Master Sounds 98.3",
        [11] = "WCTR",
        [12] = "User Track Player"
    }

    outputChatBox(string.format("📻 Da chuyen sang %s.", stationNames[stationID]), player, 255, 255, 100)
end)

-- Park vehicle command
addCommandHandler("park", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    if getVehicleOccupant(vehicle, 0) ~= player then
        outputChatBox("❌ Ban khong phai la tai xe.", player, 255, 100, 100)
        return
    end

    -- Check if player owns the vehicle
    local vehicleOwner = getElementData(vehicle, "owner")
    if vehicleOwner ~= getPlayerName(player) then
        outputChatBox("❌ Day khong phai xe cua ban.", player, 255, 100, 100)
        return
    end

    -- Save parking position
    local x, y, z = getElementPosition(vehicle)
    local rx, ry, rz = getElementRotation(vehicle)

    setElementData(vehicle, "parkX", x)
    setElementData(vehicle, "parkY", y)
    setElementData(vehicle, "parkZ", z)
    setElementData(vehicle, "parkRX", rx)
    setElementData(vehicle, "parkRY", ry)
    setElementData(vehicle, "parkRZ", rz)

    outputChatBox("🅿️ Da luu vi tri park xe tai day.", player, 0, 255, 0)
end)

-- Flip vehicle command
addCommandHandler("flip", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    if getVehicleOccupant(vehicle, 0) ~= player then
        outputChatBox("❌ Ban khong phai la tai xe.", player, 255, 100, 100)
        return
    end

    -- Check if vehicle is upside down
    local rx, ry, rz = getElementRotation(vehicle)
    if math.abs(rx) < 90 and math.abs(ry) < 90 then
        outputChatBox("❌ Xe khong bi lat.", player, 255, 100, 100)
        return
    end

    -- Flip vehicle
    setElementRotation(vehicle, 0, 0, rz)
    outputChatBox("🔄 Da lat nguoc xe lai.", player, 0, 255, 0)
end)
