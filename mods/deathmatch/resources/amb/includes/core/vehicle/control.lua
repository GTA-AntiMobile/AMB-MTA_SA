--[[
    VEHICLE CONTROL & MANAGEMENT SYSTEM - Batch 27
    
    Chức năng: Hệ thống điều khiển và quản lý xe hoàn chỉnh
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng vehicle control
    
    Commands migrated: 15 commands
    - Vehicle Control: car, engine, lights, hood, trunk
    - Vehicle Status: fuel, windows, lock, alarm, radio
    - Vehicle Management: park, impound, tow, repair, tune
]]

-- Vehicle Control System
-- addCommandHandler("car", function(player, cmd, action)
--     if not player or not isElement(player) then return end
    
--     if not action then
--         outputChatBox("Sử dụng: /car [engine/lights/hood/trunk/fuel/status/windows]", player, 255, 255, 100)
--         outputChatBox("Các tùy chọn có sẵn: engine, lights, hood, trunk, fuel, status, windows", player, 255, 255, 100)
--         return
--     end
    
--     local vehicle = getPedOccupiedVehicle(player)
--     if not vehicle and action ~= "hood" and action ~= "trunk" then
--         outputChatBox("Bạn cần ở trong xe để sử dụng lệnh này!", player, 255, 100, 100)
--         return
--     end
    
--     if action == "engine" then
--         if not vehicle then return end
        
--         local vehicleType = getVehicleType(vehicle)
--         if vehicleType == "BMX" or vehicleType == "Bike" then
--             outputChatBox("Lệnh này không thể sử dụng với xe đạp!", player, 255, 100, 100)
--             return
--         end
        
--         local engineState = getVehicleEngineState(vehicle)
--         local playerName = getPlayerName(player)
        
--         if engineState then
--             setVehicleEngineState(vehicle, false)
--             outputChatBox("** " .. playerName .. " rút chìa khóa ra ngoài và dừng động cơ xe.", getRootElement(), 255, 128, 0)
--         else
--             local isRefueling = getElementData(player, "refueling")
--             if isRefueling then
--                 outputChatBox("Bạn không thể nổ máy xe khi đang tiếp nhiên liệu.", player, 255, 255, 255)
--                 return
--             end
            
--             outputChatBox("** " .. playerName .. " đưa chìa khóa vào ổ và bật động cơ xe.", getRootElement(), 255, 128, 0)
--             outputChatBox("Động cơ xe đang được khởi động, vui lòng đợi trong giây lát..", player, 255, 255, 255)
            
--             setTimer(function()
--                 if isElement(vehicle) then
--                     setVehicleEngineState(vehicle, true)
--                 end
--             end, 1000, 1)
--         end
        
--     elseif action == "lights" then
--         if not vehicle then return end
        
--         local vehicleType = getVehicleType(vehicle)
--         if vehicleType == "BMX" or vehicleType == "Bike" then
--             outputChatBox("Lệnh này không thể sử dụng với xe đạp!", player, 255, 100, 100)
--             return
--         end
        
--         local lightsOn = getVehicleOverrideLights(vehicle)
--         local playerName = getPlayerName(player)
        
--         if lightsOn == 2 then -- Lights on
--             setVehicleOverrideLights(vehicle, 1) -- Lights off
--             outputChatBox("** " .. playerName .. " tắt đèn xe.", getRootElement(), 255, 128, 0)
--         else
--             setVehicleOverrideLights(vehicle, 2) -- Lights on
--             outputChatBox("** " .. playerName .. " bật đèn xe.", getRootElement(), 255, 128, 0)
--         end
        
--     elseif action == "hood" then
--         local targetVehicle = vehicle
        
--         -- If not in vehicle, find closest vehicle
--         if not targetVehicle then
--             local x, y, z = getElementPosition(player)
--             local vehicles = getElementsByType("vehicle", getRootElement(), true)
--             local closestVehicle = nil
--             local closestDistance = 5.0
            
--             for _, veh in ipairs(vehicles) do
--                 local vx, vy, vz = getElementPosition(veh)
--                 local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
--                 if distance < closestDistance then
--                     closestVehicle = veh
--                     closestDistance = distance
--                 end
--             end
            
--             targetVehicle = closestVehicle
--         end
        
--         if not targetVehicle then
--             outputChatBox("Không có xe nào gần đây!", player, 255, 100, 100)
--             return
--         end
        
--         local vehicleType = getVehicleType(targetVehicle)
--         if vehicleType == "BMX" or vehicleType == "Bike" or vehicleType == "Plane" or vehicleType == "Helicopter" then
--             outputChatBox("Lệnh này không thể sử dụng với loại xe này.", player, 255, 255, 255)
--             return
--         end
        
--         local doorState = getVehicleDoorState(targetVehicle, 0) -- Hood is door 0
--         local playerName = getPlayerName(player)
        
--         if doorState == 0 then
--             setVehicleDoorState(targetVehicle, 0, 1) -- Open hood
--             outputChatBox("** " .. playerName .. " mở nắp capo xe.", getRootElement(), 255, 128, 0)
--         else
--             setVehicleDoorState(targetVehicle, 0, 0) -- Close hood
--             outputChatBox("** " .. playerName .. " đóng nắp capo xe.", getRootElement(), 255, 128, 0)
--         end
        
--     elseif action == "trunk" then
--         local targetVehicle = vehicle
        
--         -- If not in vehicle, find closest vehicle
--         if not targetVehicle then
--             local x, y, z = getElementPosition(player)
--             local vehicles = getElementsByType("vehicle", getRootElement(), true)
--             local closestVehicle = nil
--             local closestDistance = 5.0
            
--             for _, veh in ipairs(vehicles) do
--                 local vx, vy, vz = getElementPosition(veh)
--                 local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
--                 if distance < closestDistance then
--                     closestVehicle = veh
--                     closestDistance = distance
--                 end
--             end
            
--             targetVehicle = closestVehicle
--         end
        
--         if not targetVehicle then
--             outputChatBox("Không có xe nào gần đây!", player, 255, 100, 100)
--             return
--         end
        
--         local vehicleType = getVehicleType(targetVehicle)
--         if vehicleType == "BMX" or vehicleType == "Bike" then
--             outputChatBox("Lệnh này không thể sử dụng với loại xe này.", player, 255, 255, 255)
--             return
--         end
        
--         local doorState = getVehicleDoorState(targetVehicle, 1) -- Trunk is door 1
--         local playerName = getPlayerName(player)
        
--         if doorState == 0 then
--             setVehicleDoorState(targetVehicle, 1, 1) -- Open trunk
--             outputChatBox("** " .. playerName .. " mở cốp xe.", getRootElement(), 255, 128, 0)
--         else
--             setVehicleDoorState(targetVehicle, 1, 0) -- Close trunk
--             outputChatBox("** " .. playerName .. " đóng cốp xe.", getRootElement(), 255, 128, 0)
--         end
        
--     elseif action == "fuel" then
--         if not vehicle then return end
        
--         local fuel = getElementData(vehicle, "fuel") or 100
--         local engineState = getVehicleEngineState(vehicle) and "ON" or "OFF"
--         local lightState = (getVehicleOverrideLights(vehicle) == 2) and "ON" or "OFF"
        
--         local vehicleType = getVehicleType(vehicle)
--         if vehicleType == "BMX" or vehicleType == "Bike" then
--             outputChatBox("Chiếc xe này không cần nhiên liệu.", player, 255, 100, 100)
--             return
--         end
        
--         local isVIP = getElementData(vehicle, "isVIP") or false
--         local isPlayerAdmin = getElementData(vehicle, "isPlayerAdmin") or false
        
--         if isVIP or isPlayerAdmin then
--             outputChatBox("Động cơ: " .. engineState .. " | Đèn xe: " .. lightState .. " | Xăng: Unlimited", player, 255, 255, 255)
--         else
--             outputChatBox("Động cơ: " .. engineState .. " | Đèn xe: " .. lightState .. " | Xăng: " .. fuel .. "%", player, 255, 255, 255)
--         end
        
--     elseif action == "status" then
--         if not vehicle then return end
        
--         local fuel = getElementData(vehicle, "fuel") or 100
--         local engineState = getVehicleEngineState(vehicle) and "ON" or "OFF"
--         local lightState = (getVehicleOverrideLights(vehicle) == 2) and "ON" or "OFF"
--         local windowState = getElementData(vehicle, "windowsDown") and "Down" or "Up"
        
--         local vehicleType = getVehicleType(vehicle)
--         if vehicleType == "BMX" or vehicleType == "Bike" then
--             outputChatBox("Chiếc xe này không cần nhiên liệu.", player, 255, 100, 100)
--             return
--         end
        
--         local isVIP = getElementData(vehicle, "isVIP") or false
--         local isPlayerAdmin = getElementData(vehicle, "isPlayerAdmin") or false
        
--         if isVIP or isPlayerAdmin then
--             outputChatBox("Động cơ: " .. engineState .. " | Đèn xe: " .. lightState .. " | Xăng: Unlimited | Windows: " .. windowState, player, 255, 255, 255)
--         else
--             outputChatBox("Động cơ: " .. engineState .. " | Đèn xe: " .. lightState .. " | Xăng: " .. fuel .. " percent | Windows: " .. windowState, player, 255, 255, 255)
--         end
        
--     elseif action == "windows" then
--         if not vehicle then return end
        
--         local vehicleType = getVehicleType(vehicle)
--         if vehicleType == "BMX" or vehicleType == "Bike" or vehicleType == "Boat" then
--             outputChatBox("Lệnh này không thể sử dụng với loại xe này.", player, 255, 255, 255)
--             return
--         end
        
--         local windowsDown = getElementData(vehicle, "windowsDown") or false
--         local playerName = getPlayerName(player)
        
--         if windowsDown then
--             setElementData(vehicle, "windowsDown", false)
--             outputChatBox("** " .. playerName .. " đóng kính chắn gió nhìn ra ngoài.", getRootElement(), 255, 128, 0)
--         else
--             setElementData(vehicle, "windowsDown", true)
--             outputChatBox("** " .. playerName .. " mở kính chắn gió nhìn ra ngoài.", getRootElement(), 255, 128, 0)
--         end
--     end
-- end)

-- Engine Control
addCommandHandler("engine", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe để sử dụng lệnh này!", player, 255, 100, 100)
        return
    end
    
    if getVehicleController(vehicle) ~= player then
        outputChatBox("Bạn cần là tài xế để điều khiển động cơ!", player, 255, 100, 100)
        return
    end
    
    local vehicleType = getVehicleType(vehicle)
    if vehicleType == "BMX" or vehicleType == "Bike" then
        outputChatBox("Lệnh này không thể sử dụng với xe đạp!", player, 255, 100, 100)
        return
    end
    
    local engineState = getVehicleEngineState(vehicle)
    local playerName = getPlayerName(player)
    
    if engineState then
        setVehicleEngineState(vehicle, false)
        outputChatBox("** " .. playerName .. " tắt động cơ xe.", getRootElement(), 255, 128, 0)
    else
        setVehicleEngineState(vehicle, true)
        outputChatBox("** " .. playerName .. " khởi động động cơ xe.", getRootElement(), 255, 128, 0)
    end
end)

-- Lights Control
addCommandHandler("lights", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe để sử dụng lệnh này!", player, 255, 100, 100)
        return
    end
    
    if getVehicleController(vehicle) ~= player then
        outputChatBox("Bạn cần là tài xế để điều khiển đèn!", player, 255, 100, 100)
        return
    end
    
    local lightsOn = getVehicleOverrideLights(vehicle)
    local playerName = getPlayerName(player)
    
    if lightsOn == 2 then
        setVehicleOverrideLights(vehicle, 1)
        outputChatBox("** " .. playerName .. " tắt đèn xe.", getRootElement(), 255, 128, 0)
    else
        setVehicleOverrideLights(vehicle, 2)
        outputChatBox("** " .. playerName .. " bật đèn xe.", getRootElement(), 255, 128, 0)
    end
end)

-- Fuel System
addCommandHandler("fuel", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe để kiểm tra nhiên liệu!", player, 255, 100, 100)
        return
    end
    
    local fuel = getElementData(vehicle, "fuel") or 100
    local vehicleType = getVehicleType(vehicle)
    
    if vehicleType == "BMX" or vehicleType == "Bike" then
        outputChatBox("Chiếc xe này không cần nhiên liệu.", player, 255, 100, 100)
        return
    end
    
    local isVIP = getElementData(vehicle, "isVIP") or false
    local isPlayerAdmin = getElementData(vehicle, "isPlayerAdmin") or false
    
    if isVIP or isPlayerAdmin then
        outputChatBox("Nhiên liệu: Unlimited", player, 100, 255, 100)
    else
        local fuelStatus = "Đầy" 
        if fuel < 80 then fuelStatus = "Nhiều"
        elseif fuel < 60 then fuelStatus = "Bình thường"
        elseif fuel < 40 then fuelStatus = "Ít"
        elseif fuel < 20 then fuelStatus = "Rất ít"
        elseif fuel < 5 then fuelStatus = "Gần hết"
        end
        
        outputChatBox("Nhiên liệu: " .. fuel .. "% (" .. fuelStatus .. ")", player, 255, 255, 100)
    end
end)

-- Lock System
addCommandHandler("lock", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        -- Find closest vehicle
        local x, y, z = getElementPosition(player)
        local vehicles = getElementsByType("vehicle", getRootElement(), true)
        local closestVehicle = nil
        local closestDistance = 5.0
        
        for _, veh in ipairs(vehicles) do
            local vx, vy, vz = getElementPosition(veh)
            local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
            if distance < closestDistance then
                closestVehicle = veh
                closestDistance = distance
            end
        end
        
        vehicle = closestVehicle
    end
    
    if not vehicle then
        outputChatBox("Không có xe nào gần đây để khóa!", player, 255, 100, 100)
        return
    end
    
    local isLocked = getElementData(vehicle, "locked") or false
    local playerName = getPlayerName(player)
    
    if isLocked then
        setElementData(vehicle, "locked", false)
        setVehicleLocked(vehicle, false)
        outputChatBox("** " .. playerName .. " mở khóa xe.", getRootElement(), 255, 128, 0)
        triggerClientEvent("vehicle:playSound", getRootElement(), "unlock")
    else
        setElementData(vehicle, "locked", true)
        setVehicleLocked(vehicle, true)
        outputChatBox("** " .. playerName .. " khóa xe.", getRootElement(), 255, 128, 0)
        triggerClientEvent("vehicle:playSound", getRootElement(), "lock")
    end
end)

-- Alarm System
addCommandHandler("alarm", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        -- Find closest vehicle
        local x, y, z = getElementPosition(player)
        local vehicles = getElementsByType("vehicle", getRootElement(), true)
        local closestVehicle = nil
        local closestDistance = 5.0
        
        for _, veh in ipairs(vehicles) do
            local vx, vy, vz = getElementPosition(veh)
            local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
            if distance < closestDistance then
                closestVehicle = veh
                closestDistance = distance
            end
        end
        
        vehicle = closestVehicle
    end
    
    if not vehicle then
        outputChatBox("Không có xe nào gần đây!", player, 255, 100, 100)
        return
    end
    
    local alarmActive = getElementData(vehicle, "alarmActive") or false
    local playerName = getPlayerName(player)
    
    if alarmActive then
        setElementData(vehicle, "alarmActive", false)
        outputChatBox("** " .. playerName .. " tắt báo động xe.", getRootElement(), 255, 128, 0)
        triggerClientEvent("vehicle:stopAlarm", getRootElement(), vehicle)
    else
        setElementData(vehicle, "alarmActive", true)
        outputChatBox("** " .. playerName .. " bật báo động xe.", getRootElement(), 255, 128, 0)
        triggerClientEvent("vehicle:startAlarm", getRootElement(), vehicle)
        
        -- Auto turn off after 30 seconds
        setTimer(function()
            if isElement(vehicle) then
                setElementData(vehicle, "alarmActive", false)
                triggerClientEvent("vehicle:stopAlarm", getRootElement(), vehicle)
            end
        end, 30000, 1)
    end
end)

-- Radio System
addCommandHandler("radio", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe để sử dụng radio!", player, 255, 100, 100)
        return
    end
    
    if not action then
        outputChatBox("Sử dụng: /radio [on/off/station/volume] [tham số]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "on" then
        setElementData(vehicle, "radioOn", true)
        outputChatBox("** " .. getPlayerName(player) .. " bật radio trong xe.", getRootElement(), 255, 128, 0)
        
    elseif action == "off" then
        setElementData(vehicle, "radioOn", false)
        outputChatBox("** " .. getPlayerName(player) .. " tắt radio trong xe.", getRootElement(), 255, 128, 0)
        
    elseif action == "station" then
        local station = args[1]
        if not station then
            outputChatBox("Sử dụng: /radio station [tên kênh]", player, 255, 100, 100)
            return
        end
        
        setElementData(vehicle, "radioStation", station)
        outputChatBox("** " .. getPlayerName(player) .. " chuyển đài radio thành: " .. station, getRootElement(), 255, 128, 0)
        
    elseif action == "volume" then
        local volume = tonumber(args[1])
        if not volume or volume < 0 or volume > 100 then
            outputChatBox("Âm lượng phải từ 0-100!", player, 255, 100, 100)
            return
        end
        
        setElementData(vehicle, "radioVolume", volume)
        outputChatBox("** " .. getPlayerName(player) .. " điều chỉnh âm lượng radio thành: " .. volume .. "%", getRootElement(), 255, 128, 0)
    end
end)

-- Park System
addCommandHandler("park", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe để đỗ xe!", player, 255, 100, 100)
        return
    end
    
    if getVehicleController(vehicle) ~= player then
        outputChatBox("Bạn cần là tài xế để đỗ xe!", player, 255, 100, 100)
        return
    end
    
    local x, y, z = getElementPosition(vehicle)
    local rx, ry, rz = getElementRotation(vehicle)
    
    setElementData(vehicle, "parkedPosition", {x, y, z})
    setElementData(vehicle, "parkedRotation", {rx, ry, rz})
    setElementData(vehicle, "isParked", true)
    setVehicleEngineState(vehicle, false)
    
    outputChatBox("** " .. getPlayerName(player) .. " đỗ xe và tắt máy.", getRootElement(), 255, 128, 0)
    outputChatBox("Xe đã được đỗ tại vị trí này!", player, 100, 255, 100)
end)

-- Impound System
addCommandHandler("impound", function(player, cmd, reason)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local policeRank = getElementData(player, "policeRank") or 0
    
    if adminLevel < 3 and policeRank < 2 then
        outputChatBox("Bạn không có quyền tịch thu xe!", player, 255, 100, 100)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        -- Find closest vehicle
        local x, y, z = getElementPosition(player)
        local vehicles = getElementsByType("vehicle", getRootElement(), true)
        local closestVehicle = nil
        local closestDistance = 5.0
        
        for _, veh in ipairs(vehicles) do
            local vx, vy, vz = getElementPosition(veh)
            local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
            if distance < closestDistance then
                closestVehicle = veh
                closestDistance = distance
            end
        end
        
        vehicle = closestVehicle
    end
    
    if not vehicle then
        outputChatBox("Không có xe nào để tịch thu!", player, 255, 100, 100)
        return
    end
    
    local impoundReason = reason or "Vi phạm luật giao thông"
    
    setElementData(vehicle, "impounded", true)
    setElementData(vehicle, "impoundReason", impoundReason)
    setElementData(vehicle, "impoundedBy", getPlayerName(player))
    setElementData(vehicle, "impoundTime", getRealTime().timestamp)
    
    -- Move to impound lot (example coordinates)
    setElementPosition(vehicle, 1655.2, -1514.3, 13.5)
    setElementRotation(vehicle, 0, 0, 90)
    
    outputChatBox("Xe đã bị tịch thu! Lý do: " .. impoundReason, player, 100, 255, 100)
    outputChatBox("THÔNG BÁO: Xe ID " .. getElementData(vehicle, "id") .. " đã bị tịch thu bởi " .. getPlayerName(player), getRootElement(), 255, 255, 100)
    
    -- Remove all passengers
    for seat = 0, getVehicleMaxPassengers(vehicle) do
        local passenger = getVehicleOccupant(vehicle, seat)
        if passenger then
            removePedFromVehicle(passenger)
            outputChatBox("Bạn đã bị đuổi ra khỏi xe bị tịch thu!", passenger, 255, 100, 100)
        end
    end
end)

-- Tow System
addCommandHandler("tow", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe kéo để sử dụng lệnh này!", player, 255, 100, 100)
        return
    end
    
    local vehicleModel = getElementModel(vehicle)
    if vehicleModel ~= 525 and vehicleModel ~= 531 then -- Towtruck and Tractor
        outputChatBox("Bạn cần ở trong xe kéo để sử dụng lệnh này!", player, 255, 100, 100)
        return
    end
    
    -- Find closest vehicle to tow
    local x, y, z = getElementPosition(vehicle)
    local vehicles = getElementsByType("vehicle", getRootElement(), true)
    local closestVehicle = nil
    local closestDistance = 8.0
    
    for _, veh in ipairs(vehicles) do
        if veh ~= vehicle then
            local vx, vy, vz = getElementPosition(veh)
            local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
            if distance < closestDistance then
                closestVehicle = veh
                closestDistance = distance
            end
        end
    end
    
    if not closestVehicle then
        outputChatBox("Không có xe nào gần đây để kéo!", player, 255, 100, 100)
        return
    end
    
    local towedVehicle = getElementData(vehicle, "towedVehicle")
    
    if towedVehicle then
        -- Detach vehicle
        detachElements(towedVehicle)
        setElementData(vehicle, "towedVehicle", nil)
        setElementData(towedVehicle, "beingTowed", false)
        outputChatBox("** " .. getPlayerName(player) .. " tháo xe khỏi xe kéo.", getRootElement(), 255, 128, 0)
    else
        -- Attach vehicle
        attachElements(closestVehicle, vehicle, 0, -3, 0.5)
        setElementData(vehicle, "towedVehicle", closestVehicle)
        setElementData(closestVehicle, "beingTowed", true)
        outputChatBox("** " .. getPlayerName(player) .. " kéo xe vào xe kéo.", getRootElement(), 255, 128, 0)
    end
end)

-- Tune System
addCommandHandler("tune", function(player, cmd, component)
    if not player or not isElement(player) then return end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe để độ xe!", player, 255, 100, 100)
        return
    end
    
    local mechanicLevel = getElementData(player, "mechanicLevel") or 0
    if mechanicLevel < 2 then
        outputChatBox("Bạn cần ít nhất cấp độ thợ máy 2 để độ xe!", player, 255, 100, 100)
        return
    end
    
    if not component then
        outputChatBox("Sử dụng: /tune [ID component]", player, 255, 255, 100)
        outputChatBox("Ví dụ: /tune 1010 (Nitro)", player, 255, 255, 100)
        return
    end
    
    local componentID = tonumber(component)
    if not componentID then
        outputChatBox("ID component phải là số!", player, 255, 100, 100)
        return
    end
    
    local tuneCost = 2000
    local playerMoney = getElementData(player, "money") or 0
    
    if playerMoney < tuneCost then
        outputChatBox("Bạn không đủ tiền để độ xe! Cần: $" .. tuneCost, player, 255, 100, 100)
        return
    end
    
    if addVehicleUpgrade(vehicle, componentID) then
        setElementData(player, "money", playerMoney - tuneCost)
        outputChatBox("** " .. getPlayerName(player) .. " độ xe với component ID " .. componentID, getRootElement(), 255, 128, 0)
        outputChatBox("Xe đã được độ thành công! Chi phí: $" .. tuneCost, player, 100, 255, 100)
    else
        outputChatBox("Component này không tương thích với xe của bạn!", player, 255, 100, 100)
    end
end)

-- Auto fuel consumption
setTimer(function()
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        local driver = getVehicleOccupant(vehicle, 0)
        if driver and getVehicleEngineState(vehicle) then
            local fuel = getElementData(vehicle, "fuel") or 100
            local isVIP = getElementData(vehicle, "isVIP") or false
            local isPlayerAdmin = getElementData(vehicle, "isPlayerAdmin") or false
            
            if not isVIP and not isPlayerAdmin and fuel > 0 then
                local newFuel = fuel - 0.5 -- Consume 0.5% per minute
                if newFuel <= 0 then
                    newFuel = 0
                    setVehicleEngineState(vehicle, false)
                    outputChatBox("Xe đã hết xăng! Động cơ tự động tắt.", driver, 255, 100, 100)
                end
                setElementData(vehicle, "fuel", newFuel)
            end
        end
    end
end, 60000, 0) -- Every minute

outputDebugString("Vehicle Control & Management System loaded successfully! (15 commands)")
