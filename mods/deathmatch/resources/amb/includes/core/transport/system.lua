-- ================================
-- AMB MTA:SA - Transportation & Delivery Commands
-- Mass migration of transportation and delivery system commands
-- ================================

-- Taxi system
addCommandHandler("taxi", function(player, cmd, action, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    if not action then
        outputChatBox("🚕 ===== TAXI SYSTEM =====", player, 255, 255, 0)
        outputChatBox("• /taxi call [location] - Goi taxi", player, 255, 255, 255)
        outputChatBox("• /taxi accept - Nhan cuoc (tai xe)", player, 255, 255, 255)
        outputChatBox("• /taxi fare [price] - Set gia cuoc", player, 255, 255, 255)
        outputChatBox("• /taxi duty - On/Off duty (tai xe)", player, 255, 255, 255)
        outputChatBox("• /taxi pay - Tra tien cuoc", player, 255, 255, 255)
        return
    end
    
    if action == "call" then
        local location = table.concat({...}, " ")
        if not location or location == "" then
            outputChatBox("Su dung: /taxi call [location]", player, 255, 255, 255)
            return
        end
        
        if getElementData(player, "taxiRequest") then
            outputChatBox("❌ Ban da co taxi request roi.", player, 255, 100, 100)
            return
        end
        
        -- Create taxi request
        local x, y, z = getElementPosition(player)
        local requestData = {
            passenger = getPlayerName(player),
            location = location,
            x = x, y = y, z = z,
            time = getRealTime().timestamp
        }
        
        setElementData(player, "taxiRequest", requestData)
        
        outputChatBox(string.format("🚕 Da goi taxi den %s. Dang cho tai xe...", location), player, 255, 255, 0)
        
        -- Notify available taxi drivers
        for _, driver in ipairs(getElementsByType("player")) do
            local driverData = getElementData(driver, "playerData") or {}
            if driverData.job == "Taxi Driver" and getElementData(driver, "taxiDuty") then
                outputChatBox(string.format("🚕 TAXI REQUEST: %s can taxi den %s", getPlayerName(player), location), driver, 255, 255, 0)
                outputChatBox("🚕 Su dung /taxi accept de nhan cuoc", driver, 255, 255, 100)
            end
        end
        
    elseif action == "accept" then
        if playerData.job ~= "Taxi Driver" then
            outputChatBox("❌ Ban khong phai taxi driver.", player, 255, 100, 100)
            return
        end
        
        if not getElementData(player, "taxiDuty") then
            outputChatBox("❌ Ban can on duty truoc (/taxi duty).", player, 255, 100, 100)
            return
        end
        
        if getElementData(player, "taxiCustomer") then
            outputChatBox("❌ Ban da co khach hang roi.", player, 255, 100, 100)
            return
        end
        
        -- Find nearest taxi request
        local px, py, pz = getElementPosition(player)
        local nearestRequest = nil
        local nearestDistance = 1000
        local nearestPlayer = nil
        
        for _, p in ipairs(getElementsByType("player")) do
            local request = getElementData(p, "taxiRequest")
            if request then
                local distance = getDistanceBetweenPoints3D(px, py, pz, request.x, request.y, request.z)
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestRequest = request
                    nearestPlayer = p
                end
            end
        end
        
        if not nearestRequest then
            outputChatBox("❌ Khong co taxi request nao.", player, 255, 100, 100)
            return
        end
        
        -- Accept the request
        setElementData(player, "taxiCustomer", getPlayerName(nearestPlayer))
        setElementData(nearestPlayer, "taxiDriver", getPlayerName(player))
        removeElementData(nearestPlayer, "taxiRequest")
        
        outputChatBox(string.format("✅ Da nhan cuoc cua %s den %s", getPlayerName(nearestPlayer), nearestRequest.location), player, 0, 255, 0)
        outputChatBox(string.format("🚕 Tai xe %s da nhan cuoc cua ban!", getPlayerName(player)), nearestPlayer, 0, 255, 0)
        
        -- Create checkpoint for driver
        local x, y, z = nearestRequest.x, nearestRequest.y, nearestRequest.z
        local checkpoint = createMarker(x, y, z - 1, "checkpoint", 3, 255, 255, 0, 150)
        setElementData(checkpoint, "taxiPickup", getPlayerName(player))
        
    elseif action == "fare" then
        local fare = tonumber((...))
        if not fare or fare < 10 or fare > 1000 then
            outputChatBox("❌ Gia cuoc phai tu $10-1000.", player, 255, 100, 100)
            return
        end
        
        if playerData.job ~= "Taxi Driver" then
            outputChatBox("❌ Ban khong phai taxi driver.", player, 255, 100, 100)
            return
        end
        
        local customerName = getElementData(player, "taxiCustomer")
        if not customerName then
            outputChatBox("❌ Ban khong co khach hang nao.", player, 255, 100, 100)
            return
        end
        
        local customer = getPlayerFromName(customerName)
        if not customer then
            outputChatBox("❌ Khach hang da disconnect.", player, 255, 100, 100)
            setElementData(player, "taxiCustomer", nil)
            return
        end
        
        setElementData(customer, "taxiFare", fare)
        
        outputChatBox(string.format("🚕 Da set gia cuoc $%d cho %s", fare, customerName), player, 255, 255, 0)
        outputChatBox(string.format("🚕 Gia cuoc: $%d. Su dung /taxi pay de tra tien", fare), customer, 255, 255, 0)
        
    elseif action == "duty" then
        if playerData.job ~= "Taxi Driver" then
            outputChatBox("❌ Ban khong phai taxi driver.", player, 255, 100, 100)
            return
        end
        
        local onDuty = getElementData(player, "taxiDuty")
        setElementData(player, "taxiDuty", not onDuty)
        
        local status = onDuty and "OFF" or "ON"
        outputChatBox(string.format("🚕 Taxi duty: %s", status), player, 255, 255, 0)
        
    elseif action == "pay" then
        local driverName = getElementData(player, "taxiDriver")
        if not driverName then
            outputChatBox("❌ Ban khong co taxi driver nao.", player, 255, 100, 100)
            return
        end
        
        local fare = getElementData(player, "taxiFare")
        if not fare then
            outputChatBox("❌ Chua co gia cuoc nao duoc set.", player, 255, 100, 100)
            return
        end
        
        if (playerData.money or 0) < fare then
            outputChatBox("❌ Ban khong co du tien.", player, 255, 100, 100)
            return
        end
        
        local driver = getPlayerFromName(driverName)
        if not driver then
            outputChatBox("❌ Tai xe da disconnect.", player, 255, 100, 100)
            return
        end
        
        -- Process payment
        playerData.money = (playerData.money or 0) - fare
        setElementData(player, "playerData", playerData)
        
        local driverData = getElementData(driver, "playerData") or {}
        driverData.money = (driverData.money or 0) + fare
        setElementData(driver, "playerData", driverData)
        
        -- Clean up
        removeElementData(player, "taxiDriver")
        removeElementData(player, "taxiFare")
        setElementData(driver, "taxiCustomer", nil)
        
        outputChatBox(string.format("💰 Da tra $%d cho taxi driver %s", fare, driverName), player, 0, 255, 0)
        outputChatBox(string.format("💰 Nhan $%d tu khach hang %s", fare, getPlayerName(player)), driver, 0, 255, 0)
    end
end)

-- Bus system
addCommandHandler("bus", function(player, cmd, action, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    if not action then
        outputChatBox("🚌 ===== BUS SYSTEM =====", player, 255, 255, 0)
        outputChatBox("• /bus route [1-5] - Chon tuyen bus", player, 255, 255, 255)
        outputChatBox("• /bus stop - Dung bus tai station", player, 255, 255, 255)
        outputChatBox("• /bus fare [price] - Set gia ve", player, 255, 255, 255)
        outputChatBox("• /bus duty - On/Off duty (tai xe)", player, 255, 255, 255)
        return
    end
    
    if action == "route" then
        if playerData.job ~= "Bus Driver" then
            outputChatBox("❌ Ban khong phai bus driver.", player, 255, 100, 100)
            return
        end
        
        local route = tonumber((...))
        if not route or route < 1 or route > 5 then
            outputChatBox("❌ Route phai tu 1-5.", player, 255, 100, 100)
            return
        end
        
        local routes = {
            [1] = "Los Santos Downtown",
            [2] = "Los Santos Airport", 
            [3] = "San Fierro City",
            [4] = "Las Venturas Strip",
            [5] = "Country Side"
        }
        
        setElementData(player, "busRoute", route)
        outputChatBox(string.format("🚌 Da chon route %d: %s", route, routes[route]), player, 0, 255, 0)
        
    elseif action == "duty" then
        if playerData.job ~= "Bus Driver" then
            outputChatBox("❌ Ban khong phai bus driver.", player, 255, 100, 100)
            return
        end
        
        local onDuty = getElementData(player, "busDuty")
        setElementData(player, "busDuty", not onDuty)
        
        local status = onDuty and "OFF" or "ON"
        outputChatBox(string.format("🚌 Bus duty: %s", status), player, 255, 255, 0)
        
    elseif action == "fare" then
        if playerData.job ~= "Bus Driver" then
            outputChatBox("❌ Ban khong phai bus driver.", player, 255, 100, 100)
            return
        end
        
        local fare = tonumber((...))
        if not fare or fare < 5 or fare > 100 then
            outputChatBox("❌ Gia ve phai tu $5-100.", player, 255, 100, 100)
            return
        end
        
        setElementData(player, "busFare", fare)
        outputChatBox(string.format("🚌 Da set gia ve bus $%d", fare), player, 0, 255, 0)
    end
end)

-- Trucking system
addCommandHandler("truck", function(player, cmd, action, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    if not action then
        outputChatBox("🚛 ===== TRUCKING SYSTEM =====", player, 255, 255, 0)
        outputChatBox("• /truck load [cargo] - Load hang hoa", player, 255, 255, 255)
        outputChatBox("• /truck unload - Unload hang hoa", player, 255, 255, 255)
        outputChatBox("• /truck info - Thong tin cargo", player, 255, 255, 255)
        outputChatBox("• /truck duty - On/Off duty", player, 255, 255, 255)
        return
    end
    
    if action == "duty" then
        if playerData.job ~= "Trucker" then
            outputChatBox("❌ Ban khong phai trucker.", player, 255, 100, 100)
            return
        end
        
        local onDuty = getElementData(player, "truckDuty")
        setElementData(player, "truckDuty", not onDuty)
        
        local status = onDuty and "OFF" or "ON"
        outputChatBox(string.format("🚛 Truck duty: %s", status), player, 255, 255, 0)
        
    elseif action == "load" then
        if playerData.job ~= "Trucker" then
            outputChatBox("❌ Ban khong phai trucker.", player, 255, 100, 100)
            return
        end
        
        if not getElementData(player, "truckDuty") then
            outputChatBox("❌ Ban can on duty truoc.", player, 255, 100, 100)
            return
        end
        
        local cargo = table.concat({...}, " ")
        if not cargo or cargo == "" then
            outputChatBox("Su dung: /truck load [cargo type]", player, 255, 255, 255)
            outputChatBox("Cargo types: food, electronics, furniture, materials, fuel", player, 255, 255, 255)
            return
        end
        
        local cargoTypes = {
            food = {pay = 200, destination = "Restaurant"},
            electronics = {pay = 500, destination = "Electronics Store"},
            furniture = {pay = 300, destination = "Furniture Store"}, 
            materials = {pay = 400, destination = "Construction Site"},
            fuel = {pay = 600, destination = "Gas Station"}
        }
        
        if not cargoTypes[cargo] then
            outputChatBox("❌ Cargo type khong hop le.", player, 255, 100, 100)
            return
        end
        
        if getElementData(player, "truckCargo") then
            outputChatBox("❌ Truck da co cargo roi.", player, 255, 100, 100)
            return
        end
        
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            outputChatBox("❌ Ban can o trong truck.", player, 255, 100, 100)
            return
        end
        
        -- Load cargo
        local cargoData = {
            type = cargo,
            pay = cargoTypes[cargo].pay,
            destination = cargoTypes[cargo].destination,
            loaded = getRealTime().timestamp
        }
        
        setElementData(player, "truckCargo", cargoData)
        
        -- Create delivery checkpoint
        local destinations = {
            {1500, -1500, 13}, -- LS
            {-2000, -100, 35}, -- SF
            {2000, 1000, 10}   -- LV
        }
        
        local dest = destinations[math.random(#destinations)]
        local checkpoint = createMarker(dest[1], dest[2], dest[3] - 1, "checkpoint", 5, 255, 0, 0, 150)
        setElementData(checkpoint, "truckDelivery", getPlayerName(player))
        setElementData(player, "deliveryCheckpoint", checkpoint)
        
        outputChatBox(string.format("🚛 Da load %s. Pay: $%d", cargo, cargoData.pay), player, 0, 255, 0)
        outputChatBox(string.format("🚛 Deliver den %s (checkpoint tren map)", cargoData.destination), player, 255, 255, 0)
        
    elseif action == "unload" then
        local cargoData = getElementData(player, "truckCargo")
        if not cargoData then
            outputChatBox("❌ Truck khong co cargo nao.", player, 255, 100, 100)
            return
        end
        
        -- Check if at delivery point
        local checkpoint = getElementData(player, "deliveryCheckpoint")
        if not checkpoint or not isElement(checkpoint) then
            outputChatBox("❌ Ban can den checkpoint delivery.", player, 255, 100, 100)
            return
        end
        
        local px, py, pz = getElementPosition(player)
        local cx, cy, cz = getElementPosition(checkpoint)
        
        if getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz) > 10 then
            outputChatBox("❌ Ban can gan checkpoint hon.", player, 255, 100, 100)
            return
        end
        
        -- Complete delivery
        playerData.money = (playerData.money or 0) + cargoData.pay
        setElementData(player, "playerData", playerData)
        
        removeElementData(player, "truckCargo")
        destroyElement(checkpoint)
        removeElementData(player, "deliveryCheckpoint")
        
        outputChatBox(string.format("✅ Da giao %s thanh cong! Nhan $%d", cargoData.type, cargoData.pay), player, 0, 255, 0)
        
    elseif action == "info" then
        local cargoData = getElementData(player, "truckCargo")
        if not cargoData then
            outputChatBox("❌ Truck khong co cargo nao.", player, 255, 100, 100)
            return
        end
        
        outputChatBox("🚛 ===== CARGO INFO =====", player, 255, 255, 0)
        outputChatBox(string.format("• Type: %s", cargoData.type), player, 255, 255, 255)
        outputChatBox(string.format("• Destination: %s", cargoData.destination), player, 255, 255, 255)
        outputChatBox(string.format("• Payment: $%d", cargoData.pay), player, 255, 255, 255)
    end
end)

-- Pilot system
addCommandHandler("pilot", function(player, cmd, action, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    if not action then
        outputChatBox("✈️ ===== PILOT SYSTEM =====", player, 255, 255, 0)
        outputChatBox("• /pilot flight [destination] - Tao chuyen bay", player, 255, 255, 255)
        outputChatBox("• /pilot board - Len may bay", player, 255, 255, 255)
        outputChatBox("• /pilot takeoff - Cat canh", player, 255, 255, 255)
        outputChatBox("• /pilot land - Ha canh", player, 255, 255, 255)
        outputChatBox("• /pilot duty - On/Off duty", player, 255, 255, 255)
        return
    end
    
    if action == "duty" then
        if playerData.job ~= "Pilot" then
            outputChatBox("❌ Ban khong phai pilot.", player, 255, 100, 100)
            return
        end
        
        local onDuty = getElementData(player, "pilotDuty")
        setElementData(player, "pilotDuty", not onDuty)
        
        local status = onDuty and "OFF" or "ON"
        outputChatBox(string.format("✈️ Pilot duty: %s", status), player, 255, 255, 0)
        
    elseif action == "flight" then
        if playerData.job ~= "Pilot" then
            outputChatBox("❌ Ban khong phai pilot.", player, 255, 100, 100)
            return
        end
        
        local destination = table.concat({...}, " ")
        if not destination or destination == "" then
            outputChatBox("Su dung: /pilot flight [destination]", player, 255, 255, 255)
            outputChatBox("Destinations: Los Santos, San Fierro, Las Venturas", player, 255, 255, 255)
            return
        end
        
        local destinations = {
            ["Los Santos"] = {1500, -2500, 13, 1000},
            ["San Fierro"] = {-2000, -200, 35, 1200},
            ["Las Venturas"] = {1700, 1400, 10, 800}
        }
        
        local destData = destinations[destination]
        if not destData then
            outputChatBox("❌ Destination khong hop le.", player, 255, 100, 100)
            return
        end
        
        local flightData = {
            destination = destination,
            x = destData[1], y = destData[2], z = destData[3],
            fare = destData[4],
            pilot = getPlayerName(player),
            passengers = {}
        }
        
        setElementData(player, "currentFlight", flightData)
        
        outputChatBox(string.format("✈️ Chuyen bay den %s (Fare: $%d) da duoc tao", destination, flightData.fare), player, 0, 255, 0)
        outputChatBox("✈️ Hanh khach co the su dung /pilot board de len may bay", root, 255, 255, 0)
        
    elseif action == "board" then
        -- Find pilot with active flight
        local pilot = nil
        local flightData = nil
        
        for _, p in ipairs(getElementsByType("player")) do
            local pData = getElementData(p, "playerData") or {}
            if pData.job == "Pilot" then
                local flight = getElementData(p, "currentFlight")
                if flight then
                    local px, py, pz = getElementPosition(player)
                    local pilotX, pilotY, pilotZ = getElementPosition(p)
                    if getDistanceBetweenPoints3D(px, py, pz, pilotX, pilotY, pilotZ) < 20 then
                        pilot = p
                        flightData = flight
                        break
                    end
                end
            end
        end
        
        if not pilot or not flightData then
            outputChatBox("❌ Khong co chuyen bay nao gan day.", player, 255, 100, 100)
            return
        end
        
        if (playerData.money or 0) < flightData.fare then
            outputChatBox(string.format("❌ Ban can $%d de mua ve may bay.", flightData.fare), player, 255, 100, 100)
            return
        end
        
        -- Board flight
        table.insert(flightData.passengers, getPlayerName(player))
        setElementData(pilot, "currentFlight", flightData)
        
        playerData.money = (playerData.money or 0) - flightData.fare
        setElementData(player, "playerData", playerData)
        
        -- Pay pilot
        local pilotData = getElementData(pilot, "playerData") or {}
        pilotData.money = (pilotData.money or 0) + flightData.fare
        setElementData(pilot, "playerData", pilotData)
        
        outputChatBox(string.format("✈️ Da len may bay den %s ($%d)", flightData.destination, flightData.fare), player, 0, 255, 0)
        outputChatBox(string.format("✈️ %s da len may bay", getPlayerName(player)), pilot, 255, 255, 0)
        
    elseif action == "takeoff" then
        if playerData.job ~= "Pilot" then
            outputChatBox("❌ Ban khong phai pilot.", player, 255, 100, 100)
            return
        end
        
        local flightData = getElementData(player, "currentFlight")
        if not flightData then
            outputChatBox("❌ Khong co chuyen bay nao active.", player, 255, 100, 100)
            return
        end
        
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            outputChatBox("❌ Ban can o trong may bay.", player, 255, 100, 100)
            return
        end
        
        outputChatBox("✈️ TAKEOFF! Chuyen bay bat dau!", player, 0, 255, 0)
        
        -- Notify passengers
        for _, passengerName in ipairs(flightData.passengers) do
            local passenger = getPlayerFromName(passengerName)
            if passenger then
                outputChatBox("✈️ May bay da cat canh! Chuc ban chuyen bay vui ve!", passenger, 0, 255, 0)
            end
        end
    end
end)

-- Delivery system for any job
addCommandHandler("delivery", function(player, cmd, action, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    if not action then
        outputChatBox("📦 ===== DELIVERY SYSTEM =====", player, 255, 255, 0)
        outputChatBox("• /delivery start [item] - Bat dau delivery", player, 255, 255, 255)
        outputChatBox("• /delivery complete - Hoan thanh delivery", player, 255, 255, 255)
        outputChatBox("• /delivery cancel - Huy delivery", player, 255, 255, 255)
        outputChatBox("• /delivery info - Thong tin delivery", player, 255, 255, 255)
        return
    end
    
    if action == "start" then
        local item = table.concat({...}, " ")
        if not item or item == "" then
            outputChatBox("Su dung: /delivery start [item]", player, 255, 255, 255)
            outputChatBox("Items: pizza, mail, medicine, package, documents", player, 255, 255, 255)
            return
        end
        
        local items = {
            pizza = {pay = 50, time = 300},
            mail = {pay = 30, time = 180},
            medicine = {pay = 100, time = 240},
            package = {pay = 80, time = 360},
            documents = {pay = 120, time = 420}
        }
        
        if not items[item] then
            outputChatBox("❌ Item khong hop le.", player, 255, 100, 100)
            return
        end
        
        if getElementData(player, "activeDelivery") then
            outputChatBox("❌ Ban da co delivery active roi.", player, 255, 100, 100)
            return
        end
        
        -- Create random delivery point
        local destinations = {
            {1500, -1500, 13}, {-2000, -100, 35}, {2000, 1000, 10},
            {1200, -800, 20}, {-1800, 600, 25}, {2200, 1200, 12}
        }
        
        local dest = destinations[math.random(#destinations)]
        local deliveryData = {
            item = item,
            pay = items[item].pay,
            timeLimit = getRealTime().timestamp + items[item].time,
            destX = dest[1], destY = dest[2], destZ = dest[3]
        }
        
        setElementData(player, "activeDelivery", deliveryData)
        
        -- Create checkpoint
        local checkpoint = createMarker(dest[1], dest[2], dest[3] - 1, "checkpoint", 3, 0, 255, 0, 150)
        setElementData(checkpoint, "deliveryPlayer", getPlayerName(player))
        setElementData(player, "deliveryCheckpoint", checkpoint)
        
        outputChatBox(string.format("📦 Delivery started: %s (Pay: $%d)", item, deliveryData.pay), player, 0, 255, 0)
        outputChatBox(string.format("📦 Time limit: %d seconds", items[item].time), player, 255, 255, 0)
        
    elseif action == "complete" then
        local deliveryData = getElementData(player, "activeDelivery")
        if not deliveryData then
            outputChatBox("❌ Ban khong co delivery nao active.", player, 255, 100, 100)
            return
        end
        
        -- Check if at checkpoint
        local checkpoint = getElementData(player, "deliveryCheckpoint")
        if not checkpoint or not isElement(checkpoint) then
            outputChatBox("❌ Checkpoint khong ton tai.", player, 255, 100, 100)
            return
        end
        
        local px, py, pz = getElementPosition(player)
        local cx, cy, cz = getElementPosition(checkpoint)
        
        if getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz) > 5 then
            outputChatBox("❌ Ban can gan checkpoint hon.", player, 255, 100, 100)
            return
        end
        
        -- Check time limit
        if getRealTime().timestamp > deliveryData.timeLimit then
            outputChatBox("❌ Delivery da qua han. Ban khong nhan duoc tien.", player, 255, 100, 100)
        else
            playerData.money = (playerData.money or 0) + deliveryData.pay
            setElementData(player, "playerData", playerData)
            outputChatBox(string.format("✅ Delivery hoan thanh! Nhan $%d", deliveryData.pay), player, 0, 255, 0)
        end
        
        -- Clean up
        removeElementData(player, "activeDelivery")
        destroyElement(checkpoint)
        removeElementData(player, "deliveryCheckpoint")
        
    elseif action == "cancel" then
        local deliveryData = getElementData(player, "activeDelivery")
        if not deliveryData then
            outputChatBox("❌ Ban khong co delivery nao active.", player, 255, 100, 100)
            return
        end
        
        -- Clean up
        removeElementData(player, "activeDelivery")
        local checkpoint = getElementData(player, "deliveryCheckpoint")
        if checkpoint and isElement(checkpoint) then
            destroyElement(checkpoint)
        end
        removeElementData(player, "deliveryCheckpoint")
        
        outputChatBox("❌ Da huy delivery.", player, 255, 255, 100)
        
    elseif action == "info" then
        local deliveryData = getElementData(player, "activeDelivery")
        if not deliveryData then
            outputChatBox("❌ Ban khong co delivery nao active.", player, 255, 100, 100)
            return
        end
        
        local timeLeft = deliveryData.timeLimit - getRealTime().timestamp
        outputChatBox("📦 ===== DELIVERY INFO =====", player, 255, 255, 0)
        outputChatBox(string.format("• Item: %s", deliveryData.item), player, 255, 255, 255)
        outputChatBox(string.format("• Payment: $%d", deliveryData.pay), player, 255, 255, 255)
        outputChatBox(string.format("• Time left: %d seconds", math.max(0, timeLeft)), player, 255, 255, 255)
    end
end)

outputDebugString("[AMB] Transportation & Delivery system loaded - 4 main commands with subcommands")
