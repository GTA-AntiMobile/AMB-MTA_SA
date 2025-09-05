-- ================================
-- AMB MTA:SA - Admin & Moderation System
-- Migrated from SA-MP open.mp server  
-- ================================
-- Admin and moderation systems
local adminSystem = {
    suspensions = {},
    warnings = {},
    bans = {},
    ipBans = {},
    whitelist = {},
    reports = {},
    settings = {
        chatReports = true,
        reports = true,
        cappingLimit = 50
    },
    adminLevels = {
        [1] = "Moderator",
        [2] = "Administrator",
        [3] = "Senior Admin",
        [4] = "Executive Admin",
        [5] = "Head Admin",
        [6] = "Co-Owner",
        [7] = "Owner"
    }
}

-- Suspension system
addCommandHandler("osuspend", function(player, _, playerIdOrName, hours, ...)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not hours or not ... then
        outputChatBox("Su dung: /osuspend [player] [hours] [reason]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local reason = table.concat({...}, " ")
    local suspendHours = tonumber(hours)

    if not suspendHours or suspendHours <= 0 then
        outputChatBox("So gio suspend phai lon hon 0!", player, 255, 0, 0)
        return
    end

    local suspendUntil = getRealTime().timestamp + (suspendHours * 3600)

    adminSystem.suspensions[getElementData(target, "account.name")] = {
        reason = reason,
        admin = getPlayerName(player),
        until_time = suspendUntil,
        hours = suspendHours
    }

    setElementData(target, "account.suspended", true)
    setElementData(target, "account.suspendUntil", suspendUntil)

    outputChatBox(getPlayerName(target) .. " da bi suspend " .. suspendHours .. " gio boi " .. getPlayerName(player),
        root, 255, 255, 0)
    outputChatBox("Ly do: " .. reason, root, 255, 255, 255)
    outputChatBox("Ban da bi suspend " .. suspendHours .. " gio. Ly do: " .. reason, target, 255, 0, 0)

    -- Kick player
    setTimer(function()
        if isElement(target) then
            kickPlayer(target, player, "Suspended for " .. suspendHours .. " hours: " .. reason)
        end
    end, 2000, 1)
end)

addCommandHandler("ounsuspend", function(player, _, accountName)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not accountName then
        outputChatBox("Su dung: /ounsuspend [account name]", player, 255, 255, 255)
        return
    end

    if adminSystem.suspensions[accountName] then
        adminSystem.suspensions[accountName] = nil
        outputChatBox("Account " .. accountName .. " da duoc unsuspend boi " .. getPlayerName(player), root, 255, 255, 0)

        -- If player is online
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "account.name") == accountName then
                setElementData(p, "account.suspended", false)
                setElementData(p, "account.suspendUntil", nil)
                break
            end
        end
    else
        outputChatBox("Account khong bi suspend!", player, 255, 0, 0)
    end
end)

-- Ban system
addCommandHandler("permaban", function(player, _, playerIdOrName, ...)
    if not hasPermission(player, "admin", 4) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not ... then
        outputChatBox("Su dung: /permaban [player] [reason]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local reason = table.concat({...}, " ")
    local accountName = getElementData(target, "account.name")
    local playerIP = getPlayerIP(target)

    adminSystem.bans[accountName] = {
        reason = reason,
        admin = getPlayerName(player),
        time = getRealTime().timestamp,
        ip = playerIP,
        permanent = true
    }

    outputChatBox(getPlayerName(target) .. " was permanently banned boi " .. getPlayerName(player) .. ", ly do: " ..
                      reason, root, 255, 0, 0)
    banPlayer(target, true, false, false, player, reason)
end)

addCommandHandler("banaccount", function(player, _, accountName, ...)
    if not hasPermission(player, "admin", 4) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not accountName or not ... then
        outputChatBox("Su dung: /banaccount [account] [reason]", player, 255, 255, 255)
        return
    end

    local reason = table.concat({...}, " ")

    adminSystem.bans[accountName] = {
        reason = reason,
        admin = getPlayerName(player),
        time = getRealTime().timestamp,
        permanent = true
    }

    -- Check if player is online
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "account.name") == accountName then
            outputChatBox(getPlayerName(p) .. " was banned boi " .. getPlayerName(player) .. ", ly do: " .. reason,
                root, 255, 0, 0)
            banPlayer(p, true, false, false, player, reason)
            return
        end
    end

    outputChatBox("Account " .. accountName .. " da bi ban (offline)", player, 255, 255, 0)
end)

addCommandHandler("unban", function(player, _, accountName)
    if not hasPermission(player, "admin", 4) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not accountName then
        outputChatBox("Su dung: /unban [account name]", player, 255, 255, 255)
        return
    end

    if adminSystem.bans[accountName] then
        adminSystem.bans[accountName] = nil
        outputChatBox("Account " .. accountName .. " da duoc unban boi " .. getPlayerName(player), root, 255, 255, 0)
    else
        outputChatBox("Account khong bi ban!", player, 255, 0, 0)
    end
end)

-- IP ban system
addCommandHandler("banip", function(player, _, ip, ...)
    if not hasPermission(player, "admin", 5) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not ip or not ... then
        outputChatBox("Su dung: /banip [IP] [reason]", player, 255, 255, 255)
        return
    end

    local reason = table.concat({...}, " ")

    adminSystem.ipBans[ip] = {
        reason = reason,
        admin = getPlayerName(player),
        time = getRealTime().timestamp
    }

    outputChatBox("IP " .. ip .. " was banned boi " .. getPlayerName(player) .. ", ly do: " .. reason, root, 255, 0, 0)

    -- Kick all players with this IP
    for _, p in ipairs(getElementsByType("player")) do
        if getPlayerIP(p) == ip then
            kickPlayer(p, player, "IP banned: " .. reason)
        end
    end
end)

addCommandHandler("unbanip", function(player, _, ip)
    if not hasPermission(player, "admin", 5) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not ip then
        outputChatBox("Su dung: /unbanip [IP]", player, 255, 255, 255)
        return
    end

    if adminSystem.ipBans[ip] then
        adminSystem.ipBans[ip] = nil
        outputChatBox(getPlayerName(player) .. " has unbanned IP " .. ip, root, 255, 255, 0)
    else
        outputChatBox("IP khong bi ban!", player, 255, 0, 0)
    end
end)

-- IP check system
addCommandHandler("ip", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /ip [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local ip = getPlayerIP(target)
    outputChatBox("IP cua " .. getPlayerName(target) .. ": " .. ip, player, 255, 255, 0)
end)

addCommandHandler("ipcheck", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /ipcheck [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local targetIP = getPlayerIP(target)
    local matches = {}

    for _, p in ipairs(getElementsByType("player")) do
        if p ~= target and getPlayerIP(p) == targetIP then
            table.insert(matches, getPlayerName(p))
        end
    end

    outputChatBox("IP check cho " .. getPlayerName(target) .. " (" .. targetIP .. "):", player, 255, 255, 0)
    if #matches > 0 then
        outputChatBox("Cung IP: " .. table.concat(matches, ", "), player, 255, 255, 255)
    else
        outputChatBox("Khong co ai cung IP", player, 255, 255, 255)
    end
end)

-- Fine system
addCommandHandler("fine", function(player, _, playerIdOrName, amount, ...)
    if not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not amount or not ... then
        outputChatBox("Su dung: /fine [player] [amount] [reason]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local fineAmount = tonumber(amount)
    if not fineAmount or fineAmount <= 0 then
        outputChatBox("So tien phat phai lon hon 0!", player, 255, 0, 0)
        return
    end

    local reason = table.concat({...}, " ")

    takePlayerMoney(target, fineAmount)

    outputChatBox(
        getPlayerName(target) .. " da tru $" .. fineAmount .. " boi " .. getPlayerName(player) .. ", ly do: " .. reason,
        root, 255, 255, 0)
    outputChatBox("Ban bi phat $" .. fineAmount .. ". Ly do: " .. reason, target, 255, 0, 0)
end)

addCommandHandler("sfine", function(player, _, playerIdOrName, amount, ...)
    if not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not amount or not ... then
        outputChatBox("Su dung: /sfine [player] [amount] [reason]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local fineAmount = tonumber(amount)
    if not fineAmount or fineAmount <= 0 then
        outputChatBox("So tien phat phai lon hon 0!", player, 255, 0, 0)
        return
    end

    local reason = table.concat({...}, " ")

    takePlayerMoney(target, fineAmount)

    -- Silent fine - only to admin
    outputChatBox(getPlayerName(target) .. " was silent fined $" .. fineAmount .. " boi " .. getPlayerName(player) ..
                      ", ly do: " .. reason, player, 255, 255, 0)
    outputChatBox("Ban bi phat $" .. fineAmount .. ". Ly do: " .. reason, target, 255, 0, 0)
end)

-- Settings toggles
addCommandHandler("togchatreports", function(player)
    if not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    adminSystem.settings.chatReports = not adminSystem.settings.chatReports
    local status = adminSystem.settings.chatReports and "BAT" or "TAT"
    outputChatBox("Chat reports da duoc " .. status, player, 255, 255, 0)
end)

addCommandHandler("togreports", function(player)
    if not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    adminSystem.settings.reports = not adminSystem.settings.reports
    local status = adminSystem.settings.reports and "BAT" or "TAT"
    outputChatBox("Reports da duoc " .. status, player, 255, 255, 0)
end)

addCommandHandler("destroycar", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /destroycar [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local vehicle = getPedOccupiedVehicle(target)
    if not vehicle then
        outputChatBox(getPlayerName(target) .. " khong o trong xe!", player, 255, 0, 0)
        return
    end

    blowVehicle(vehicle)
    outputChatBox("Da pha huy xe cua " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox("Xe cua ban da bi admin pha huy!", target, 255, 0, 0)
end)

addCommandHandler("blowup", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /blowup [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local x, y, z = getElementPosition(target)
    createExplosion(x, y, z, 0, target)

    outputChatBox(getPlayerName(player) .. " has exploded " .. getPlayerName(target), root, 255, 255, 0)
end)

-- Vehicle modifications
addCommandHandler("givenos", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /givenos [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local vehicle = getPedOccupiedVehicle(target)
    if not vehicle then
        outputChatBox(getPlayerName(target) .. " khong o trong xe!", player, 255, 0, 0)
        return
    end

    addVehicleUpgrade(vehicle, 1010) -- Nitro
    outputChatBox(getPlayerName(player) .. " has given nos to " .. getPlayerName(target), root, 255, 255, 0)
end)

-- Health and revival commands
addCommandHandler("revive", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /revive [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    if not isPedDead(target) then
        outputChatBox(getPlayerName(target) .. " chua chet!", player, 255, 0, 0)
        return
    end

    spawnPlayer(target, 1481.0, -1749.2, 15.3, 0, 0)
    setElementHealth(target, 100)

    outputChatBox(getPlayerName(target) .. " has been revived by " .. getPlayerName(player), root, 255, 255, 0)
end)

addCommandHandler("revivenear", function(player)
    if not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    local x, y, z = getElementPosition(player)
    local nearbyPlayers = getElementsWithinRange(x, y, z, 10, "player")
    local revivedCount = 0

    for _, target in ipairs(nearbyPlayers) do
        if target ~= player and isPedDead(target) then
            spawnPlayer(target, x, y, z, 0, 0)
            setElementHealth(target, 100)
            revivedCount = revivedCount + 1
        end
    end

    if revivedCount > 0 then
        outputChatBox("Da revive " .. revivedCount .. " nguoi o gan day", player, 0, 255, 0)
        outputChatBox(getPlayerName(player) .. " has revived " .. revivedCount .. " players nearby", root, 255, 255, 0)
    else
        outputChatBox("Khong co ai chet o gan day!", player, 255, 0, 0)
    end
end)

addCommandHandler("forcedeath", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /forcedeath [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    killPed(target)
    outputChatBox(getPlayerName(player) .. " has forced death " .. getPlayerName(target), root, 255, 255, 0)
end)

-- Server announcements
addCommandHandler("motd", function(player, _, ...)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not ... then
        outputChatBox("Su dung: /motd [message]", player, 255, 255, 255)
        return
    end

    local message = table.concat({...}, " ")
    setElementData(getRootElement(), "server.motd", message)

    outputChatBox("=== THONG BAO MAY CHU ===", root, 255, 255, 0)
    outputChatBox(message, root, 255, 255, 255)
    outputChatBox("Ban " .. getPlayerName(player) .. " da thay doi thong bao may chu", root, 200, 200, 200)
end)

-- Whitelist system
addCommandHandler("ipwhitelist", function(player, _, action, ip)
    if not hasPermission(player, "admin", 6) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not action or not ip then
        outputChatBox("Su dung: /ipwhitelist [add/remove/list] [IP]", player, 255, 255, 255)
        return
    end

    if action == "add" then
        adminSystem.whitelist[ip] = true
        outputChatBox("Da them IP " .. ip .. " vao whitelist", player, 0, 255, 0)
    elseif action == "remove" then
        adminSystem.whitelist[ip] = nil
        outputChatBox("Da xoa IP " .. ip .. " khoi whitelist", player, 255, 255, 0)
    elseif action == "list" then
        outputChatBox("=== IP WHITELIST ===", player, 255, 255, 0)
        local count = 0
        for whiteIP, _ in pairs(adminSystem.whitelist) do
            outputChatBox(whiteIP, player, 255, 255, 255)
            count = count + 1
        end
        outputChatBox("Total: " .. count .. " IPs", player, 200, 200, 200)
    else
        outputChatBox("Action khong hop le! (add/remove/list)", player, 255, 0, 0)
    end
end)

-- Server statistics
addCommandHandler("serverstats", function(player)
    if not hasPermission(player, "admin", 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    local playerCount = #getElementsByType("player")
    local vehicleCount = #getElementsByType("vehicle")
    local objectCount = #getElementsByType("object")

    outputChatBox("=== SERVER STATISTICS ===", player, 255, 255, 0)
    outputChatBox("Players online: " .. playerCount, player, 255, 255, 255)
    outputChatBox("Vehicles: " .. vehicleCount, player, 255, 255, 255)
    outputChatBox("Objects: " .. objectCount, player, 255, 255, 255)
    outputChatBox("Uptime: " .. math.floor(getTickCount() / 1000 / 60) .. " minutes", player, 255, 255, 255)
end)

-- Check for suspended players on join
addEventHandler("onPlayerJoin", root, function()
    local accountName = getElementData(source, "account.name")
    if accountName and adminSystem.suspensions[accountName] then
        local suspension = adminSystem.suspensions[accountName]
        if getRealTime().timestamp < suspension.until_time then
            local remainingTime = suspension.until_time - getRealTime().timestamp
            local remainingHours = math.ceil(remainingTime / 3600)

            outputChatBox("Account cua ban dang bi suspend!", source, 255, 0, 0)
            outputChatBox("Ly do: " .. suspension.reason, source, 255, 255, 255)
            outputChatBox("Thoi gian con lai: " .. remainingHours .. " gio", source, 255, 255, 255)

            setTimer(function()
                if isElement(source) then
                    kickPlayer(source, "Account suspended")
                end
            end, 5000, 1)
        else
            -- Suspension expired
            adminSystem.suspensions[accountName] = nil
        end
    end
end)

print("Admin & Moderation System loaded: suspend, ban, fine, weapons, vehicles, health, announcements")
