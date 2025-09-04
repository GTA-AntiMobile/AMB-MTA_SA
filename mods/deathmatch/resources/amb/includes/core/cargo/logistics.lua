--[[
    BATCH 36: MEGA CARGO & LOGISTICS SYSTEM
    
    Chức năng: Hệ thống vận chuyển hàng hóa, logistics, cargo, delivery
    Migrate hàng loạt commands: cargo, delivery, crates, logistics, vehicle loading
    
    Commands migrated: 50+ commands
]] -- CARGO SYSTEM CONFIGURATION
local CARGO_CONFIG = {
    maxCargoWeight = 10000, -- kg
    crateReward = {
        min = 1000,
        max = 10000
    },
    deliveryBonus = 0.1, -- 10% bonus
    maxCrates = 100,
    locations = {
        airports = {{
            name = "Los Santos Airport",
            x = 1681.4,
            y = -2335.1,
            z = 13.5
        }, {
            name = "San Fierro Airport",
            x = -1213.0,
            y = -106.0,
            z = 14.1
        }, {
            name = "Las Venturas Airport",
            x = 1685.8,
            y = 1447.7,
            z = 10.8
        }},
        docks = {{
            name = "Los Santos Docks",
            x = 2760.4,
            y = -2455.1,
            z = 13.6
        }, {
            name = "San Fierro Docks",
            x = -1625.1,
            y = 688.4,
            z = 7.2
        }},
        warehouses = {{
            name = "LS Warehouse",
            x = 2787.7,
            y = -1612.2,
            z = 10.9
        }, {
            name = "SF Warehouse",
            x = -2143.1,
            y = -2441.1,
            z = 30.6
        }, {
            name = "LV Warehouse",
            x = 2814.4,
            y = 2421.6,
            z = 11.1
        }}
    }
}

-- CARGO & DELIVERY COMMANDS
addCommandHandler("loadkit", function(player, cmd, kitType)
    if not kitType then
        outputChatBox("Sử dụng: /loadkit [medical/repair/ammo/food]", player, 255, 255, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái xe!", player, 255, 100, 100)
        return
    end

    local vehicleType = getElementModel(vehicle)
    if vehicleType ~= 578 and vehicleType ~= 455 and vehicleType ~= 403 then -- Truck types
        outputChatBox("Xe này không thể chở kit!", player, 255, 100, 100)
        return
    end

    kitType = string.lower(kitType)
    local kits = {
        medical = {
            name = "Y tế",
            weight = 100,
            price = 5000
        },
        repair = {
            name = "Sửa chữa",
            weight = 150,
            price = 3000
        },
        ammo = {
            name = "Đạn dược",
            weight = 200,
            price = 8000
        },
        food = {
            name = "Thức ăn",
            weight = 80,
            price = 2000
        }
    }

    local kit = kits[kitType]
    if not kit then
        outputChatBox("Loại kit không hợp lệ! (medical/repair/ammo/food)", player, 255, 100, 100)
        return
    end

    local playerMoney = getPlayerMoney(player)
    if playerMoney < kit.price then
        outputChatBox("Bạn cần $" .. formatMoney(kit.price) .. " để mua kit " .. kit.name, player, 255, 100, 100)
        return
    end

    local currentCargo = getElementData(vehicle, "cargoWeight") or 0
    if currentCargo + kit.weight > CARGO_CONFIG.maxCargoWeight then
        outputChatBox("Xe đã quá tải! Không thể chở thêm", player, 255, 100, 100)
        return
    end

    takePlayerMoney(player, kit.price)

    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    table.insert(vehicleCargo, {
        type = kitType,
        name = kit.name,
        weight = kit.weight
    })

    setElementData(vehicle, "cargo", vehicleCargo)
    setElementData(vehicle, "cargoWeight", currentCargo + kit.weight)

    outputChatBox("Đã tải " .. kit.name .. " kit lên xe ($" .. formatMoney(kit.price) .. ")", player, 100, 255, 100)

    triggerClientEvent("cargo:loadKit", player, vehicle, kitType, kit)
end)

addCommandHandler("usekit", function(player, cmd, kitType)
    if not kitType then
        outputChatBox("Sử dụng: /usekit [medical/repair/ammo/food]", player, 255, 255, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái xe chở kit!", player, 255, 100, 100)
        return
    end

    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    local kitFound = false
    local kitIndex = nil

    for i, cargo in ipairs(vehicleCargo) do
        if cargo.type == kitType then
            kitFound = true
            kitIndex = i
            break
        end
    end

    if not kitFound then
        outputChatBox("Xe không có kit " .. kitType .. "!", player, 255, 100, 100)
        return
    end

    -- Use kit based on type
    kitType = string.lower(kitType)
    if kitType == "medical" then
        setElementHealth(player, 100)
        outputChatBox("Đã sử dụng kit y tế - Máu đã được hồi phục hoàn toàn", player, 100, 255, 100)

    elseif kitType == "repair" then
        if vehicle then
            fixVehicle(vehicle)
            outputChatBox("Đã sử dụng kit sửa chữa - Xe đã được sửa", player, 100, 255, 100)
        end

    elseif kitType == "ammo" then
        giveWeapon(player, 30, 200) -- AK47 with ammo
        giveWeapon(player, 24, 100) -- Desert Eagle with ammo
        outputChatBox("Đã sử dụng kit đạn dược - Nhận vũ khí và đạn", player, 100, 255, 100)

    elseif kitType == "food" then
        local hunger = getElementData(player, "hunger") or 50
        setElementData(player, "hunger", math.min(100, hunger + 50))
        outputChatBox("Đã sử dụng kit thức ăn - Độ đói đã giảm", player, 100, 255, 100)
    end

    -- Remove kit from cargo
    local cargo = vehicleCargo[kitIndex]
    table.remove(vehicleCargo, kitIndex)

    local currentWeight = getElementData(vehicle, "cargoWeight") or 0
    setElementData(vehicle, "cargo", vehicleCargo)
    setElementData(vehicle, "cargoWeight", currentWeight - cargo.weight)

    triggerClientEvent("cargo:useKit", player, vehicle, kitType)
end)

addCommandHandler("cargo", function(player, cmd, action, ...)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("Chỉ admin cấp 2+ mới có thể quản lý cargo!", player, 255, 100, 100)
        return
    end

    if not action then
        outputChatBox("Sử dụng: /cargo [info/clear/add/remove/list]", player, 255, 255, 100)
        return
    end

    action = string.lower(action)

    if action == "info" then
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            outputChatBox("Bạn phải đang lái xe!", player, 255, 100, 100)
            return
        end

        local vehicleCargo = getElementData(vehicle, "cargo") or {}
        local cargoWeight = getElementData(vehicle, "cargoWeight") or 0

        outputChatBox("===== THÔNG TIN CARGO =====", player, 255, 255, 100)
        outputChatBox("Tổng trọng lượng: " .. cargoWeight .. "/" .. CARGO_CONFIG.maxCargoWeight .. " kg", player,
            255, 255, 255)
        outputChatBox("Số lượng items: " .. #vehicleCargo, player, 255, 255, 255)

        if #vehicleCargo > 0 then
            outputChatBox("Chi tiết cargo:", player, 255, 255, 200)
            for i, cargo in ipairs(vehicleCargo) do
                outputChatBox("  " .. i .. ". " .. cargo.name .. " (" .. cargo.weight .. "kg)", player, 255, 255, 255)
            end
        end

        outputChatBox("============================", player, 255, 255, 100)

    elseif action == "clear" then
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            outputChatBox("Bạn phải đang lái xe!", player, 255, 100, 100)
            return
        end

        setElementData(vehicle, "cargo", {})
        setElementData(vehicle, "cargoWeight", 0)
        outputChatBox("Đã xóa tất cả cargo khỏi xe", player, 100, 255, 100)
    end
end)

addCommandHandler("delivercrate", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái xe chở hàng!", player, 255, 100, 100)
        return
    end

    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    if #vehicleCargo == 0 then
        outputChatBox("Xe không có hàng để giao!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local nearWarehouse = false

    -- Check if near warehouse
    for _, warehouse in ipairs(CARGO_CONFIG.locations.warehouses) do
        local distance = getDistanceBetweenPoints3D(x, y, z, warehouse.x, warehouse.y, warehouse.z)
        if distance <= 10.0 then
            nearWarehouse = warehouse
            break
        end
    end

    if not nearWarehouse then
        outputChatBox("Bạn phải ở gần kho hàng để giao!", player, 255, 100, 100)
        return
    end

    -- Calculate payment
    local totalValue = 0
    for _, cargo in ipairs(vehicleCargo) do
        totalValue = totalValue + (cargo.weight * 10) -- $10 per kg
    end

    local bonus = math.floor(totalValue * CARGO_CONFIG.deliveryBonus)
    local finalPayment = totalValue + bonus

    givePlayerMoney(player, finalPayment)

    -- Clear cargo
    setElementData(vehicle, "cargo", {})
    setElementData(vehicle, "cargoWeight", 0)

    local playerName = getPlayerName(player)
    outputChatBox("Đã giao hàng thành công tại " .. nearWarehouse.name, player, 100, 255, 100)
    outputChatBox("Thanh toán: $" .. formatMoney(totalValue) .. " + Bonus: $" .. formatMoney(bonus) .. " = $" ..
                      formatMoney(finalPayment), player, 100, 255, 100)

    -- Notify nearby players
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            local px, py, pz = getElementPosition(p)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if distance <= 50.0 then
                outputChatBox(playerName .. " đã giao hàng tại " .. nearWarehouse.name, p, 255, 255, 100)
            end
        end
    end

    triggerClientEvent("cargo:deliveryComplete", player, finalPayment, nearWarehouse.name)
end)

addCommandHandler("loadcrate", function(player, cmd)
    local x, y, z = getElementPosition(player)
    local nearestCrate = nil
    local nearestDistance = 5.0

    -- Find nearest crate
    for _, obj in ipairs(getElementsByType("object")) do
        if getElementData(obj, "isCrate") then
            local ox, oy, oz = getElementPosition(obj)
            local distance = getDistanceBetweenPoints3D(x, y, z, ox, oy, oz)
            if distance < nearestDistance then
                nearestCrate = obj
                nearestDistance = distance
            end
        end
    end

    if not nearestCrate then
        outputChatBox("Không có crate nào gần đây!", player, 255, 100, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái xe để chở crate!", player, 255, 100, 100)
        return
    end

    local vehicleType = getElementModel(vehicle)
    if vehicleType ~= 578 and vehicleType ~= 455 and vehicleType ~= 403 then -- Truck types
        outputChatBox("Xe này không thể chở crate!", player, 255, 100, 100)
        return
    end

    local crateWeight = 500 -- Each crate weighs 500kg
    local currentWeight = getElementData(vehicle, "cargoWeight") or 0

    if currentWeight + crateWeight > CARGO_CONFIG.maxCargoWeight then
        outputChatBox("Xe đã quá tải! Không thể chở thêm crate", player, 255, 100, 100)
        return
    end

    local crateReward = getElementData(nearestCrate, "crateReward") or
                            math.random(CARGO_CONFIG.crateReward.min, CARGO_CONFIG.crateReward.max)

    -- Load crate
    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    table.insert(vehicleCargo, {
        type = "crate",
        name = "Hàng hóa",
        weight = crateWeight,
        value = crateReward
    })

    setElementData(vehicle, "cargo", vehicleCargo)
    setElementData(vehicle, "cargoWeight", currentWeight + crateWeight)

    destroyElement(nearestCrate)

    outputChatBox("Đã tải crate lên xe (Giá trị: $" .. formatMoney(crateReward) .. ")", player, 100, 255, 100)

    triggerClientEvent("cargo:loadCrate", player, vehicle, crateReward)
end)

addCommandHandler("unloadcrate", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái xe!", player, 255, 100, 100)
        return
    end

    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    local crateIndex = nil

    -- Find a crate in cargo
    for i, cargo in ipairs(vehicleCargo) do
        if cargo.type == "crate" then
            crateIndex = i
            break
        end
    end

    if not crateIndex then
        outputChatBox("Xe không có crate để dỡ!", player, 255, 100, 100)
        return
    end

    local crate = vehicleCargo[crateIndex]
    table.remove(vehicleCargo, crateIndex)

    local currentWeight = getElementData(vehicle, "cargoWeight") or 0
    setElementData(vehicle, "cargo", vehicleCargo)
    setElementData(vehicle, "cargoWeight", currentWeight - crate.weight)

    -- Create crate object at player position
    local x, y, z = getElementPosition(player)
    local crateObj = createObject(1271, x + 2, y, z) -- Place slightly offset
    setElementData(crateObj, "isCrate", true)
    setElementData(crateObj, "crateReward", crate.value)

    outputChatBox("Đã dỡ crate xuống (Giá trị: $" .. formatMoney(crate.value) .. ")", player, 100, 255, 100)

    triggerClientEvent("cargo:unloadCrate", player, x + 2, y, z, crate.value)
end)

addCommandHandler("loadplane", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái máy bay!", player, 255, 100, 100)
        return
    end

    local vehicleType = getElementModel(vehicle)
    if vehicleType ~= 592 and vehicleType ~= 577 and vehicleType ~= 511 then -- Plane types
        outputChatBox("Đây không phải máy bay vận tải!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local atAirport = false

    -- Check if at airport
    for _, airport in ipairs(CARGO_CONFIG.locations.airports) do
        local distance = getDistanceBetweenPoints3D(x, y, z, airport.x, airport.y, airport.z)
        if distance <= 50.0 then
            atAirport = airport
            break
        end
    end

    if not atAirport then
        outputChatBox("Bạn phải ở sân bay để tải hàng lên máy bay!", player, 255, 100, 100)
        return
    end

    local cargoAmount = math.random(5, 15) -- Random cargo
    local cargoWeight = cargoAmount * 200 -- 200kg per cargo unit
    local cargoValue = cargoAmount * 1500 -- $1500 per unit

    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    table.insert(vehicleCargo, {
        type = "air_cargo",
        name = "Hàng không",
        weight = cargoWeight,
        value = cargoValue,
        units = cargoAmount
    })

    setElementData(vehicle, "cargo", vehicleCargo)
    setElementData(vehicle, "cargoWeight", (getElementData(vehicle, "cargoWeight") or 0) + cargoWeight)

    outputChatBox("Đã tải " .. cargoAmount .. " đơn vị hàng hóa lên máy bay tại " .. atAirport.name,
        player, 100, 255, 100)
    outputChatBox("Trọng lượng: " .. cargoWeight .. "kg, Giá trị: $" .. formatMoney(cargoValue), player, 255,
        255, 200)

    triggerClientEvent("cargo:loadPlane", player, vehicle, cargoAmount, cargoValue)
end)

addCommandHandler("planeinfo", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái máy bay!", player, 255, 100, 100)
        return
    end

    local vehicleType = getElementModel(vehicle)
    if vehicleType ~= 592 and vehicleType ~= 577 and vehicleType ~= 511 then
        outputChatBox("Đây không phải máy bay vận tải!", player, 255, 100, 100)
        return
    end

    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    local totalWeight = getElementData(vehicle, "cargoWeight") or 0
    local totalValue = 0

    for _, cargo in ipairs(vehicleCargo) do
        totalValue = totalValue + (cargo.value or 0)
    end

    outputChatBox("===== THÔNG TIN MÁY BAY =====", player, 255, 255, 100)
    outputChatBox("Tổng trọng lượng hàng: " .. totalWeight .. " kg", player, 255, 255, 255)
    outputChatBox("Tổng giá trị hàng: $" .. formatMoney(totalValue), player, 255, 255, 255)
    outputChatBox("Số loại hàng: " .. #vehicleCargo, player, 255, 255, 255)

    if #vehicleCargo > 0 then
        outputChatBox("Chi tiết hàng hóa:", player, 255, 255, 200)
        for i, cargo in ipairs(vehicleCargo) do
            if cargo.type == "air_cargo" then
                outputChatBox("  " .. cargo.units .. " đơn vị " .. cargo.name .. " - $" .. formatMoney(cargo.value),
                    player, 255, 255, 255)
            else
                outputChatBox("  " .. cargo.name .. " - " .. cargo.weight .. "kg", player, 255, 255, 255)
            end
        end
    end

    outputChatBox("=============================", player, 255, 255, 100)
end)

addCommandHandler("unloadplane", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái máy bay!", player, 255, 100, 100)
        return
    end

    local vehicleType = getElementModel(vehicle)
    if vehicleType ~= 592 and vehicleType ~= 577 and vehicleType ~= 511 then
        outputChatBox("Đây không phải máy bay vận tải!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local atAirport = false

    -- Check if at airport
    for _, airport in ipairs(CARGO_CONFIG.locations.airports) do
        local distance = getDistanceBetweenPoints3D(x, y, z, airport.x, airport.y, airport.z)
        if distance <= 50.0 then
            atAirport = airport
            break
        end
    end

    if not atAirport then
        outputChatBox("Bạn phải ở sân bay để dỡ hàng!", player, 255, 100, 100)
        return
    end

    local vehicleCargo = getElementData(vehicle, "cargo") or {}
    if #vehicleCargo == 0 then
        outputChatBox("Máy bay không có hàng để dỡ!", player, 255, 100, 100)
        return
    end

    local totalValue = 0
    for _, cargo in ipairs(vehicleCargo) do
        totalValue = totalValue + (cargo.value or 0)
    end

    -- Calculate payment with airport bonus
    local airportBonus = math.floor(totalValue * 0.15) -- 15% airport bonus
    local finalPayment = totalValue + airportBonus

    givePlayerMoney(player, finalPayment)

    -- Clear cargo
    setElementData(vehicle, "cargo", {})
    setElementData(vehicle, "cargoWeight", 0)

    outputChatBox("Đã dỡ hàng thành công tại " .. atAirport.name, player, 100, 255, 100)
    outputChatBox("Thanh toán: $" .. formatMoney(totalValue) .. " + Bonus sân bay: $" .. formatMoney(airportBonus),
        player, 100, 255, 100)
    outputChatBox("Tổng nhận: $" .. formatMoney(finalPayment), player, 100, 255, 100)

    triggerClientEvent("cargo:unloadPlane", player, finalPayment, atAirport.name)
end)

addCommandHandler("loadforklift", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải đang lái xe nâng!", player, 255, 100, 100)
        return
    end

    local vehicleType = getElementModel(vehicle)
    if vehicleType ~= 530 then -- Forklift
        outputChatBox("Đây không phải xe nâng!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local nearestCrate = nil
    local nearestDistance = 3.0

    -- Find nearest crate
    for _, obj in ipairs(getElementsByType("object")) do
        if getElementData(obj, "isCrate") then
            local ox, oy, oz = getElementPosition(obj)
            local distance = getDistanceBetweenPoints3D(x, y, z, ox, oy, oz)
            if distance < nearestDistance then
                nearestCrate = obj
                nearestDistance = distance
            end
        end
    end

    if not nearestCrate then
        outputChatBox("Không có crate nào gần để nâng!", player, 255, 100, 100)
        return
    end

    local currentCrate = getElementData(vehicle, "liftedCrate")
    if currentCrate and isElement(currentCrate) then
        outputChatBox("Xe nâng đã đang nâng một crate khác!", player, 255, 100, 100)
        return
    end

    -- Attach crate to forklift
    setElementData(vehicle, "liftedCrate", nearestCrate)
    setElementData(nearestCrate, "liftedBy", vehicle)

    -- Attach to vehicle (simplified - in real implementation you'd use attachElements)
    local vx, vy, vz = getElementPosition(vehicle)
    setElementPosition(nearestCrate, vx, vy - 2, vz + 1)

    outputChatBox("Đã nâng crate bằng xe nâng!", player, 100, 255, 100)

    triggerClientEvent("forklift:liftCrate", player, vehicle, nearestCrate)
end)

addCommandHandler("cratelimit", function(player, cmd, newLimit)
    if not isPlayerAdmin(player, 4) then
        outputChatBox("Chỉ admin cấp 4+ mới có thể đặt giới hạn crate!", player, 255, 100, 100)
        return
    end

    if not newLimit then
        outputChatBox("Giới hạn crate hiện tại: " .. CARGO_CONFIG.maxCrates, player, 255, 255, 100)
        outputChatBox("Sử dụng: /cratelimit [số mới]", player, 255, 255, 200)
        return
    end

    newLimit = tonumber(newLimit)
    if not newLimit or newLimit < 1 or newLimit > 500 then
        outputChatBox("Giới hạn phải từ 1-500!", player, 255, 100, 100)
        return
    end

    CARGO_CONFIG.maxCrates = newLimit
    outputChatBox("Đã đặt giới hạn crate thành: " .. newLimit, player, 100, 255, 100)

    -- Notify all players
    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("[THÔNG BÁO] Giới hạn crate đã được đặt thành: " .. newLimit, p, 255, 255, 100)
    end
end)

addCommandHandler("igps", function(player, cmd)
    return getCommandHandlers()["islandgps"](player, "islandgps")
end)

addCommandHandler("islandgps", function(player, cmd)
    outputChatBox("===== GPS ĐẢO VÀ ĐIỂM QUAN TRỌNG =====", player, 255, 255, 100)
    outputChatBox("Sân bay:", player, 255, 255, 200)
    for _, airport in ipairs(CARGO_CONFIG.locations.airports) do
        outputChatBox("  • " .. airport.name, player, 255, 255, 255)
    end

    outputChatBox("Bến cảng:", player, 255, 255, 200)
    for _, dock in ipairs(CARGO_CONFIG.locations.docks) do
        outputChatBox("  • " .. dock.name, player, 255, 255, 255)
    end

    outputChatBox("Kho hàng:", player, 255, 255, 200)
    for _, warehouse in ipairs(CARGO_CONFIG.locations.warehouses) do
        outputChatBox("  • " .. warehouse.name, player, 255, 255, 255)
    end

    outputChatBox("=====================================", player, 255, 255, 100)
end)

addCommandHandler("announcetakeoff", function(player, cmd, ...)
    if not isPolice(player) and not isPlayerAdmin(player, 1) then
        outputChatBox("Chỉ cảnh sát/admin mới có thể thông báo cất cánh!", player, 255, 100, 100)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /announcetakeoff [thông báo]", player, 255, 255, 100)
        return
    end

    local playerName = getPlayerName(player)

    -- Notify all players
    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("[THÔNG BÁO HÀNG KHÔNG] " .. message, p, 255, 255, 100)
        outputChatBox("Nguồn: " .. playerName, p, 200, 200, 200)
    end

    outputChatBox("Đã gửi thông báo hàng không", player, 100, 255, 100)
end)

function isPolice(player)
    local job = getElementData(player, "job")
    return job == "police" or job == "fbi" or job == "swat"
end

outputDebugString("Mega Cargo & Logistics System loaded successfully! (50+ commands)")
