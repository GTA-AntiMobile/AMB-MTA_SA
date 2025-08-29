-- ================================
-- AMB MTA:SA - Activities & Movement System
-- Migrated from SA-MP open.mp server
-- ================================

-- Activity and movement systems
local activitySystem = {
    swimming = {},
    boxing = {},
    parkour = {},
    flying = {},
    duties = {},
    activities = {
        swimming = {
            locations = {
                {x = 2068.3, y = -1779.4, z = 13.5, name = "Santa Maria Beach"},
                {x = -1494.5, y = 1370.2, z = 7.2, name = "San Fierro Bay"},
                {x = 1310.2, y = 1370.5, z = 10.8, name = "Las Venturas Pool"}
            }
        },
        boxing = {
            locations = {
                {x = 1412.6, y = -41.4, z = 1000.8, interior = 5, name = "Ganton Gym"},
                {x = 768.0, y = 5.7, z = 1000.7, interior = 5, name = "Cobra Martial Arts"}
            }
        },
        parkour = {
            checkpoints = {
                {x = 1481.0, y = -1749.2, z = 15.3},
                {x = 1495.2, y = -1760.8, z = 18.7},
                {x = 1510.5, y = -1755.1, z = 13.5},
                {x = 1525.8, y = -1740.3, z = 13.5}
            }
        }
    }
}

-- Swimming system
addCommandHandler("beginswimming", function(player)
    if activitySystem.swimming[player] then
        outputChatBox("Ban da dang boi roi!", player, 255, 0, 0)
        return
    end
    
    -- Check if near water
    local x, y, z = getElementPosition(player)
    local nearWater = false
    
    for _, location in ipairs(activitySystem.activities.swimming.locations) do
        local dist = getDistanceBetweenPoints3D(x, y, z, location.x, location.y, location.z)
        if dist <= 50 then
            nearWater = location
            break
        end
    end
    
    if not nearWater then
        outputChatBox("Ban can o gan vung nuoc de bat dau boi!", player, 255, 0, 0)
        outputChatBox("Cac dia diem boi:", player, 255, 255, 255)
        for _, loc in ipairs(activitySystem.activities.swimming.locations) do
            outputChatBox("- " .. loc.name, player, 200, 200, 200)
        end
        return
    end
    
    activitySystem.swimming[player] = {
        location = nearWater.name,
        startTime = getRealTime().timestamp,
        distance = 0
    }
    
    setElementData(player, "player.swimming", true)
    outputChatBox("Ban da bat dau boi tai " .. nearWater.name, player, 0, 255, 0)
    outputChatBox("Su dung /stopswimming de dung lai", player, 255, 255, 255)
    
    -- Give swimming skill increase (simplified)
    local currentSkill = getElementData(player, "player.swimmingSkill") or 0
    setElementData(player, "player.swimmingSkill", currentSkill + 1)
end)

addCommandHandler("stopswimming", function(player)
    if not activitySystem.swimming[player] then
        outputChatBox("Ban khong dang boi!", player, 255, 0, 0)
        return
    end
    
    local swimmingData = activitySystem.swimming[player]
    local duration = getRealTime().timestamp - swimmingData.startTime
    
    activitySystem.swimming[player] = nil
    setElementData(player, "player.swimming", false)
    
    outputChatBox("Ban da dung boi sau " .. duration .. " giay", player, 255, 255, 0)
    
    -- Reward experience
    if duration >= 60 then -- At least 1 minute
        local exp = math.floor(duration / 10)
        givePlayerMoney(player, exp)
        outputChatBox("Thuong boi loi: $" .. exp, player, 0, 255, 0)
    end
end)

-- Boxing system
addCommandHandler("joinboxing", function(player)
    if activitySystem.boxing[player] then
        outputChatBox("Ban da dang tham gia boxing roi!", player, 255, 0, 0)
        return
    end
    
    -- Check if in boxing gym
    local interior = getElementInterior(player)
    local x, y, z = getElementPosition(player)
    local inGym = false
    
    for _, location in ipairs(activitySystem.activities.boxing.locations) do
        if interior == location.interior then
            local dist = getDistanceBetweenPoints3D(x, y, z, location.x, location.y, location.z)
            if dist <= 10 then
                inGym = location
                break
            end
        end
    end
    
    if not inGym then
        outputChatBox("Ban can o trong phong gym de tham gia boxing!", player, 255, 0, 0)
        return
    end
    
    activitySystem.boxing[player] = {
        gym = inGym.name,
        startTime = getRealTime().timestamp,
        fights = 0
    }
    
    setElementData(player, "player.boxing", true)
    setPedFightingStyle(player, 6) -- Boxing style
    
    outputChatBox("Ban da tham gia boxing tai " .. inGym.name, player, 0, 255, 0)
    outputChatBox("Su dung /leaveboxing de roi khoi", player, 255, 255, 255)
    outputChatBox("Fighting style: Boxing", player, 200, 200, 200)
end)

addCommandHandler("leaveboxing", function(player)
    if not activitySystem.boxing[player] then
        outputChatBox("Ban khong dang tham gia boxing!", player, 255, 0, 0)
        return
    end
    
    local boxingData = activitySystem.boxing[player]
    local duration = getRealTime().timestamp - boxingData.startTime
    
    activitySystem.boxing[player] = nil
    setElementData(player, "player.boxing", false)
    setPedFightingStyle(player, 4) -- Normal style
    
    outputChatBox("Ban da roi khoi boxing sau " .. duration .. " giay", player, 255, 255, 0)
    
    -- Reward based on time spent
    if duration >= 300 then -- At least 5 minutes
        local reward = math.floor(duration / 30)
        givePlayerMoney(player, reward)
        outputChatBox("Thuong tap luyen: $" .. reward, player, 0, 255, 0)
    end
end)

-- Parkour system
addCommandHandler("beginparkour", function(player)
    if activitySystem.parkour[player] then
        outputChatBox("Ban da dang choi parkour roi!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local firstCP = activitySystem.activities.parkour.checkpoints[1]
    local dist = getDistanceBetweenPoints3D(x, y, z, firstCP.x, firstCP.y, firstCP.z)
    
    if dist > 10 then
        outputChatBox("Ban can o gan diem bat dau parkour!", player, 255, 0, 0)
        outputChatBox("Diem bat dau: X:" .. firstCP.x .. " Y:" .. firstCP.y, player, 255, 255, 255)
        return
    end
    
    activitySystem.parkour[player] = {
        currentCP = 1,
        startTime = getRealTime().timestamp,
        markers = {}
    }
    
    -- Create checkpoint markers
    for i, cp in ipairs(activitySystem.activities.parkour.checkpoints) do
        local marker = createMarker(cp.x, cp.y, cp.z - 1, "checkpoint", 2, 255, 255, 0, 150)
        table.insert(activitySystem.parkour[player].markers, marker)
        
        if i == 1 then
            setMarkerColor(marker, 0, 255, 0, 150) -- Green for current
        end
    end
    
    setElementData(player, "player.parkour", true)
    outputChatBox("Ban da bat dau parkour! Di den cac checkpoint mau xanh", player, 0, 255, 0)
    outputChatBox("Su dung /leaveparkour de dung lai", player, 255, 255, 255)
end)

addCommandHandler("leaveparkour", function(player)
    if not activitySystem.parkour[player] then
        outputChatBox("Ban khong dang choi parkour!", player, 255, 0, 0)
        return
    end
    
    local parkourData = activitySystem.parkour[player]
    
    -- Remove markers
    for _, marker in ipairs(parkourData.markers) do
        if isElement(marker) then
            destroyElement(marker)
        end
    end
    
    activitySystem.parkour[player] = nil
    setElementData(player, "player.parkour", false)
    outputChatBox("Ban da roi khoi parkour", player, 255, 255, 0)
end)

-- Handle parkour checkpoint hits
addEventHandler("onPlayerMarkerHit", root, function(marker, matchingDimension)
    if not activitySystem.parkour[source] then return end
    
    local parkourData = activitySystem.parkour[source]
    local currentCP = parkourData.currentCP
    
    if marker == parkourData.markers[currentCP] then
        if currentCP == #activitySystem.activities.parkour.checkpoints then
            -- Finished parkour
            local duration = getRealTime().timestamp - parkourData.startTime
            local reward = math.floor(1000 - (duration * 10)) -- Faster = more money
            if reward < 100 then reward = 100 end
            
            givePlayerMoney(source, reward)
            outputChatBox("Chuc mung! Ban da hoan thanh parkour trong " .. duration .. " giay!", source, 0, 255, 0)
            outputChatBox("Thuong: $" .. reward, source, 0, 255, 0)
            
            executeCommandHandler("leaveparkour", source)
        else
            -- Next checkpoint
            setMarkerColor(parkourData.markers[currentCP], 128, 128, 128, 150) -- Gray for completed
            parkourData.currentCP = currentCP + 1
            setMarkerColor(parkourData.markers[parkourData.currentCP], 0, 255, 0, 150) -- Green for current
            
            outputChatBox("Checkpoint " .. currentCP .. " hoan thanh! Den checkpoint " .. parkourData.currentCP, source, 255, 255, 0)
        end
    end
end)

-- Professional duties
addCommandHandler("lawyerduty", function(player)
    if not hasPermission(player, "lawyer") then
        outputChatBox("Ban khong phai luat su!", player, 255, 0, 0)
        return
    end
    
    local onDuty = getElementData(player, "player.lawyerDuty") or false
    setElementData(player, "player.lawyerDuty", not onDuty)
    
    if onDuty then
        outputChatBox("Ban da ket thuc ca lam viec luat su", player, 255, 255, 0)
        setElementData(player, "player.dutyName", nil)
    else
        outputChatBox("Ban da bat dau ca lam viec luat su", player, 0, 255, 0)
        setElementData(player, "player.dutyName", "Lawyer")
        outputChatBox("Su dung /contracts de xem hop dong", player, 255, 255, 255)
    end
end)

addCommandHandler("mechduty", function(player)
    if not hasPermission(player, "mechanic") then
        outputChatBox("Ban khong phai tho sua xe!", player, 255, 0, 0)
        return
    end
    
    local onDuty = getElementData(player, "player.mechDuty") or false
    setElementData(player, "player.mechDuty", not onDuty)
    
    if onDuty then
        outputChatBox("Ban da ket thuc ca lam viec tho sua xe", player, 255, 255, 0)
        setElementData(player, "player.dutyName", nil)
    else
        outputChatBox("Ban da bat dau ca lam viec tho sua xe", player, 0, 255, 0)
        setElementData(player, "player.dutyName", "Mechanic")
        outputChatBox("Ban co the sua xe cho nguoi choi khac", player, 255, 255, 255)
    end
end)

addCommandHandler("aduty", function(player) -- Admin duty
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen admin!", player, 255, 0, 0)
        return
    end
    
    local onDuty = getElementData(player, "player.adminDuty") or false
    setElementData(player, "player.adminDuty", not onDuty)
    
    if onDuty then
        outputChatBox("Ban da ket thuc ca admin duty", player, 255, 255, 0)
        setElementData(player, "player.dutyName", nil)
        setElementAlpha(player, 255) -- Visible
    else
        outputChatBox("Ban da bat dau ca admin duty", player, 0, 255, 0)
        setElementData(player, "player.dutyName", "Administrator")
        setElementAlpha(player, 150) -- Semi-transparent
        outputChatBox("Ban dang invisible va co the su dung tat ca admin commands", player, 255, 255, 255)
    end
end)

addCommandHandler("cduty", function(player) -- Cop duty
    if not hasPermission(player, "police") then
        outputChatBox("Ban khong phai canh sat!", player, 255, 0, 0)
        return
    end
    
    local onDuty = getElementData(player, "player.copDuty") or false
    setElementData(player, "player.copDuty", not onDuty)
    
    if onDuty then
        outputChatBox("Ban da ket thuc ca canh sat", player, 255, 255, 0)
        setElementData(player, "player.dutyName", nil)
    else
        outputChatBox("Ban da bat dau ca canh sat", player, 0, 255, 0)
        setElementData(player, "player.dutyName", "Police Officer")
        outputChatBox("Ban co the su dung cac lenh canh sat", player, 255, 255, 255)
    end
end)

-- Games (movement commands moved to admin/commands.lua to avoid conflicts)
addCommandHandler("flipcoin", function(player)
    local result = math.random(1, 2) == 1 and "Ngua" or "Sap"
    outputChatBox(getPlayerName(player) .. " tung dong xu: " .. result, root, 255, 255, 0)
end)

addCommandHandler("dice", function(player, cmd, sides)
    local maxSides = tonumber(sides) or 6
    if maxSides < 2 or maxSides > 100 then
        outputChatBox("So mat xuc xac phai tu 2-100! (mac dinh: 6)", player, 255, 0, 0)
        return
    end
    
    local result = math.random(1, maxSides)
    outputChatBox(getPlayerName(player) .. " tung xuc xac " .. maxSides .. " mat: " .. result, root, 255, 255, 0)
end)

-- Contracts system
addCommandHandler("contracts", function(player)
    if not getElementData(player, "player.lawyerDuty") then
        outputChatBox("Ban can on lawyer duty de xem contracts!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== Hop dong hien tai ===", player, 255, 255, 0)
    outputChatBox("1. Hop dong mua ban nha - $500 phi dich vu", player, 255, 255, 255)
    outputChatBox("2. Hop dong ly hon - $300 phi dich vu", player, 255, 255, 255)
    outputChatBox("3. Hop dong kinh doanh - $800 phi dich vu", player, 255, 255, 255)
    outputChatBox("4. Hop dong bao lanh - $200 phi dich vu", player, 255, 255, 255)
    outputChatBox("Lien he client de tao hop dong", player, 200, 200, 200)
end)

-- Vehicle search system
addCommandHandler("searchcar", function(player, cmd, targetName)
    if not hasPermission(player, "police") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("Su dung: /searchcar [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(target)
    if not vehicle then
        outputChatBox(getPlayerName(target) .. " khong o trong xe!", player, 255, 0, 0)
        return
    end
    
    -- Search vehicle for illegal items
    local illegalItems = {"Drugs", "Illegal Weapons", "Stolen Goods"}
    local foundItems = {}
    
    for _, item in ipairs(illegalItems) do
        if math.random(1, 3) == 1 then -- 33% chance to find each item
            table.insert(foundItems, item)
        end
    end
    
    outputChatBox("Ket qua kham xe cua " .. getPlayerName(target) .. ":", player, 255, 255, 0)
    if #foundItems > 0 then
        for _, item in ipairs(foundItems) do
            outputChatBox("- Tim thay: " .. item, player, 255, 0, 0)
        end
        outputChatBox("Canh sat " .. getPlayerName(player) .. " da tim thay vat bat hop phap trong xe cua ban!", target, 255, 0, 0)
    else
        outputChatBox("Khong tim thay gi bat hop phap", player, 0, 255, 0)
        outputChatBox("Canh sat " .. getPlayerName(player) .. " da kham xe cua ban - sach se", target, 255, 255, 0)
    end
end)

addCommandHandler("takecarweapons", function(player, cmd, targetName)
    if not hasPermission(player, "police") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("Su dung: /takecarweapons [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(target)
    if not vehicle then
        outputChatBox(getPlayerName(target) .. " khong o trong xe!", player, 255, 0, 0)
        return
    end
    
    -- Remove all weapons from target
    takeAllWeapons(target)
    
    outputChatBox("Da thu tat ca vu khi trong xe cua " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox("Canh sat " .. getPlayerName(player) .. " da thu tat ca vu khi trong xe cua ban", target, 255, 0, 0)
end)

-- Cleanup when player quits
addEventHandler("onPlayerQuit", root, function()
    activitySystem.swimming[source] = nil
    activitySystem.boxing[source] = nil
    activitySystem.flying[source] = nil
    
    if activitySystem.parkour[source] then
        for _, marker in ipairs(activitySystem.parkour[source].markers) do
            if isElement(marker) then
                destroyElement(marker)
            end
        end
        activitySystem.parkour[source] = nil
    end
end)

print("Activities System loaded: swimming, boxing, parkour, flying, duties, games, vehicle search")
