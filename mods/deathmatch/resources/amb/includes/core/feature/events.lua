-- ================================
-- AMB MTA:SA - Events & Special Systems
-- Migrated from SA-MP open.mp server
-- ================================

-- Event systems for special gameplay features
local eventSystem = {
    chanceGambler = false,
    zombie = {
        active = false,
        weather = false,
        infected = {}
    },
    arena = {
        active = false,
        players = {},
        teams = {},
        locations = {
            {x = 1412.6, y = -41.4, z = 1000.8, name = "Ganton Gym"},
            {x = 768.0, y = 5.7, z = 1000.7, name = "Cobra Martial Arts"},
            {x = -975.9, y = 1060.9, z = 1345.7, name = "Doherty Garage"}
        }
    }
}

-- Chance Gambler Event Commands
addCommandHandler("togchancegambler", function(player)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    eventSystem.chanceGambler = not eventSystem.chanceGambler
    
    if eventSystem.chanceGambler then
        outputChatBox("Ban da kich hoat su kien chance gambler", player, 255, 255, 255)
        outputChatBox("Su kien Chance Gambler da duoc kich hoat!", root, 255, 255, 0)
    else
        outputChatBox("Ban da tat su kien chance gambler", player, 255, 255, 255)
        outputChatBox("Su kien Chance Gambler da ket thuc!", root, 255, 255, 0)
    end
end)

addCommandHandler("gamblechances", function(player)
    if not eventSystem.chanceGambler then
        outputChatBox("Su kien chance gambler chua duoc kich hoat!", player, 255, 0, 0)
        return
    end
    
    local chances = getElementData(player, "player.rewardChances") or 0
    local availableChances = math.floor(chances / 3)
    
    if availableChances < 1 then
        outputChatBox("Ban khong co bat ky co hoi nao", player, 128, 128, 128)
        return
    end
    
    -- Check if near Pershing Square
    local x, y, z = getElementPosition(player)
    local dist = getDistanceBetweenPoints3D(x, y, z, 1479.1, -1675.6, 14.0)
    if dist > 20 then
        outputChatBox("Ban khong o Pershing Square", player, 128, 128, 128)
        return
    end
    
    -- Show gambling dialog
    local message = "Ban phai roll so lon hon 4 de nhan doi so co hoi cua ban.\n\n"
    message = message .. "Co hoi hien tai: " .. availableChances .. "\n"
    message = message .. "Tat ca hoac khong co gi!"
    
    showDialog(player, "CHANCE_GAMBLER", "Su kien Chance Gambler - Tat ca hoac khong co gi", message, "Roll", "Huy")
end)

addCommandHandler("chances", function(player)
    if not eventSystem.chanceGambler then
        return
    end
    
    local chances = getElementData(player, "player.rewardChances") or 0
    local availableChances = math.floor(chances / 3)
    
    outputChatBox("Co hoi: " .. availableChances, player, 0, 255, 255)
end)

-- Handle chance gambler dialog
addEvent("onPlayerDialogResponse", true)
addEventHandler("onPlayerDialogResponse", root, function(dialogID, button, item, text)
    if dialogID == "CHANCE_GAMBLER" and button == 1 then
        local chances = getElementData(source, "player.rewardChances") or 0
        local availableChances = math.floor(chances / 3)
        
        if availableChances >= 1 then
            local roll = math.random(1, 6)
            
            if roll > 4 then
                -- Win - double chances
                local newChances = availableChances * 2 * 3
                setElementData(source, "player.rewardChances", newChances)
                outputChatBox("Roll: " .. roll .. " - BAN THANG! Co hoi da duoc nhan doi!", source, 0, 255, 0)
            else
                -- Lose - lose all chances
                setElementData(source, "player.rewardChances", 0)
                outputChatBox("Roll: " .. roll .. " - BAN THUA! Mat tat ca co hoi!", source, 255, 0, 0)
            end
        end
    end
end)

-- Zombie Event System
addCommandHandler("zombiehelp", function(player)
    outputChatBox("=== Zombie Event Commands ===", player, 255, 255, 0)
    outputChatBox("/buycure - Mua thuoc tri zombie ($5000)", player, 255, 255, 255)
    outputChatBox("/zombieweather - Admin: Thay doi thoi tiet zombie", player, 255, 255, 255)
    outputChatBox("/zombieevent - Admin: Bat/tat su kien zombie", player, 255, 255, 255)
    outputChatBox("/makezombie [player] - Admin: Bien thanh zombie", player, 255, 255, 255)
    outputChatBox("/unzombie [player] - Admin: Chua zombie", player, 255, 255, 255)
    outputChatBox("/bite [player] - Zombie: Can player", player, 255, 255, 255)
end)

addCommandHandler("zombieevent", function(player)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    eventSystem.zombie.active = not eventSystem.zombie.active
    
    if eventSystem.zombie.active then
        setWeather(19) -- Dark weather
        setTime(0, 0) -- Midnight
        outputChatBox("Su kien Zombie da bat dau! Hay coi chung!", root, 255, 0, 0)
        outputChatBox("Admin " .. getPlayerName(player) .. " da kich hoat su kien zombie", player, 0, 255, 0)
    else
        setWeather(1) -- Normal weather
        setTime(12, 0) -- Noon
        -- Cure all zombies
        for zombiePlayer, _ in pairs(eventSystem.zombie.infected) do
            if isElement(zombiePlayer) then
                setElementModel(zombiePlayer, 0)
                setElementData(zombiePlayer, "player.zombie", false)
            end
        end
        eventSystem.zombie.infected = {}
        
        outputChatBox("Su kien Zombie da ket thuc!", root, 0, 255, 0)
        outputChatBox("Admin " .. getPlayerName(player) .. " da tat su kien zombie", player, 0, 255, 0)
    end
end)

addCommandHandler("zombieweather", function(player)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    eventSystem.zombie.weather = not eventSystem.zombie.weather
    
    if eventSystem.zombie.weather then
        setWeather(19)
        setTime(0, 0)
        outputChatBox("Da chuyen sang thoi tiet zombie", player, 0, 255, 0)
    else
        setWeather(1)
        setTime(12, 0)
        outputChatBox("Da chuyen ve thoi tiet binh thuong", player, 0, 255, 0)
    end
end)

addCommandHandler("makezombie", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /makezombie [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    -- Make zombie
    setElementModel(target, 162) -- Zombie skin
    setElementData(target, "player.zombie", true)
    eventSystem.zombie.infected[target] = true
    
    outputChatBox("Ban da bien " .. getPlayerName(target) .. " thanh zombie", player, 0, 255, 0)
    outputChatBox("Ban da bi bien thanh zombie boi admin " .. getPlayerName(player), target, 255, 0, 0)
    outputChatBox(getPlayerName(target) .. " da tro thanh zombie!", root, 255, 255, 0)
end)

addCommandHandler("unzombie", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /unzombie [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    if not getElementData(target, "player.zombie") then
        outputChatBox(getPlayerName(target) .. " khong phai zombie!", player, 255, 0, 0)
        return
    end
    
    -- Cure zombie
    setElementModel(target, 0) -- Normal skin
    setElementData(target, "player.zombie", false)
    eventSystem.zombie.infected[target] = nil
    
    outputChatBox("Ban da chua " .. getPlayerName(target) .. " khoi zombie", player, 0, 255, 0)
    outputChatBox("Ban da duoc chua khoi zombie boi admin " .. getPlayerName(player), target, 0, 255, 0)
end)

addCommandHandler("bite", function(player, _, playerIdOrName)
    if not getElementData(player, "player.zombie") then
        outputChatBox("Chi zombie moi co the can!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /bite [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    if getElementData(target, "player.zombie") then
        outputChatBox(getPlayerName(target) .. " da la zombie roi!", player, 255, 0, 0)
        return
    end
    
    -- Check distance
    local x1, y1, z1 = getElementPosition(player)
    local x2, y2, z2 = getElementPosition(target)
    local dist = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
    
    if dist > 3 then
        outputChatBox("Ban can o gan hon de can!", player, 255, 0, 0)
        return
    end
    
    -- Infect target
    setElementModel(target, 162)
    setElementData(target, "player.zombie", true)
    eventSystem.zombie.infected[target] = true
    
    outputChatBox("Ban da can " .. getPlayerName(target) .. "!", player, 0, 255, 0)
    outputChatBox("Ban bi " .. getPlayerName(player) .. " can va tro thanh zombie!", target, 255, 0, 0)
    outputChatBox(getPlayerName(target) .. " da bi can va tro thanh zombie!", root, 255, 255, 0)
end)

addCommandHandler("buycure", function(player)
    if not getElementData(player, "player.zombie") then
        outputChatBox("Ban khong phai zombie!", player, 255, 0, 0)
        return
    end
    
    local money = getPlayerMoney(player)
    if money < 5000 then
        outputChatBox("Ban can $5000 de mua thuoc chua zombie!", player, 255, 0, 0)
        return
    end
    
    -- Check if near hospital
    local x, y, z = getElementPosition(player)
    local hospitals = {
        {x = 1607.0, y = -1822.3, z = 13.5, name = "All Saints General Hospital"},
        {x = -2655.0, y = 640.1, z = 14.5, name = "San Fierro Medical Center"},
        {x = 1244.3, y = 1432.2, z = 10.8, name = "Las Venturas Hospital"}
    }
    
    local nearHospital = false
    for _, hospital in ipairs(hospitals) do
        local dist = getDistanceBetweenPoints3D(x, y, z, hospital.x, hospital.y, hospital.z)
        if dist <= 10 then
            nearHospital = hospital
            break
        end
    end
    
    if not nearHospital then
        outputChatBox("Ban can o gan benh vien de mua thuoc chua!", player, 255, 0, 0)
        return
    end
    
    -- Cure zombie
    takePlayerMoney(player, 5000)
    setElementModel(player, 0)
    setElementData(player, "player.zombie", false)
    eventSystem.zombie.infected[player] = nil
    
    outputChatBox("Ban da mua thuoc chua zombie tai " .. nearHospital.name .. " ($5000)", player, 0, 255, 0)
    outputChatBox(getPlayerName(player) .. " da tu chua khoi zombie!", root, 255, 255, 0)
end)

-- Health/Armor commands
addCommandHandler("sethp", function(player, _, playerIdOrName, amount)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /sethp [player] [amount]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local hp = tonumber(amount)
    if not hp or hp < 0 or hp > 100 then
        outputChatBox("Mau phai tu 0-100!", player, 255, 0, 0)
        return
    end
    
    setElementHealth(target, hp)
    outputChatBox("Da set mau cua " .. getPlayerName(target) .. " thanh " .. hp, player, 0, 255, 0)
    outputChatBox("Admin " .. getPlayerName(player) .. " da set mau cua ban thanh " .. hp, target, 255, 255, 0)
end)

addCommandHandler("setmyhp", function(player, _, amount)
    if not amount then
        outputChatBox("Su dung: /setmyhp [amount]", player, 255, 255, 255)
        return
    end
    
    local hp = tonumber(amount)
    if not hp or hp < 0 or hp > 100 then
        outputChatBox("Mau phai tu 0-100!", player, 255, 0, 0)
        return
    end
    
    setElementHealth(player, hp)
    outputChatBox("Da set mau cua ban thanh " .. hp, player, 0, 255, 0)
end)

addCommandHandler("setarmor", function(player, _, playerIdOrName, amount)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /setarmor [player] [amount]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local armor = tonumber(amount)
    if not armor or armor < 0 or armor > 100 then
        outputChatBox("Giap phai tu 0-100!", player, 255, 0, 0)
        return
    end
    
    setPedArmor(target, armor)
    outputChatBox("Da set giap cua " .. getPlayerName(target) .. " thanh " .. armor, player, 0, 255, 0)
    outputChatBox("Admin " .. getPlayerName(player) .. " da set giap cua ban thanh " .. armor, target, 255, 255, 0)
end)

addCommandHandler("setmyarmor", function(player, _, amount)
    if not amount then
        outputChatBox("Su dung: /setmyarmor [amount]", player, 255, 255, 255)
        return
    end
    
    local armor = tonumber(amount)
    if not armor or armor < 0 or armor > 100 then
        outputChatBox("Giap phai tu 0-100!", player, 255, 0, 0)
        return
    end
    
    setPedArmor(player, armor)
    outputChatBox("Da set giap cua ban thanh " .. armor, player, 0, 255, 0)
end)

addCommandHandler("setarmorall", function(player, _, amount)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not amount then
        outputChatBox("Su dung: /setarmorall [amount]", player, 255, 255, 255)
        return
    end
    
    local armor = tonumber(amount)
    if not armor or armor < 0 or armor > 100 then
        outputChatBox("Giap phai tu 0-100!", player, 255, 0, 0)
        return
    end
    
    local count = 0
    for _, target in ipairs(getElementsByType("player")) do
        setPedArmor(target, armor)
        count = count + 1
    end
    
    outputChatBox("Da set giap cho tat ca " .. count .. " player thanh " .. armor, player, 0, 255, 0)
    outputChatBox("Admin " .. getPlayerName(player) .. " da set giap cho tat ca thanh " .. armor, root, 255, 255, 0)
end)

-- Jetpack command moved to admin/commands.lua for proper permission handling

-- Cleanup when player quits
addEventHandler("onPlayerQuit", root, function()
    eventSystem.zombie.infected[source] = nil
    eventSystem.arena.players[source] = nil
end)

print("Events System loaded: zombie, chance gambler, health/armor commands")
