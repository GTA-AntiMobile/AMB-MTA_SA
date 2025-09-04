-- ================================
-- AMB MTA:SA - Server Lockdown System
-- Migrated from SA-MP open.mp server
-- ================================
-- Lockdown system variables
local lockdownSystem = {
    islandLockdown = {
        active = false,
        startTime = 0,
        gatePosition = {-1083.9, 4289.7, 7.6},
        sirenSound = nil,
        autoEndTimer = nil
    },
    serverLockdown = {
        active = false,
        reason = "",
        startTime = 0,
        adminName = ""
    }
}

-- Island lockdown command (for high admins)
addCommandHandler("alockdown", function(player)
    local adminLevel = getElementData(player, "player.adminLevel") or 0

    if adminLevel < 4 then
        outputChatBox("Ban khong duoc phep su dung lenh nay!", player, 255, 100, 100)
        return
    end

    if not lockdownSystem.islandLockdown.active then
        -- Start island lockdown
        lockdownSystem.islandLockdown.active = true
        lockdownSystem.islandLockdown.startTime = getRealTime().timestamp

        -- Move gate (simulated - would need actual gate object)
        -- MoveDynamicObject equivalent would be moveObject in MTA

        -- Alert all players in range
        local gatePos = lockdownSystem.islandLockdown.gatePosition
        for _, targetPlayer in ipairs(getElementsByType("player")) do
            local x, y, z = getElementPosition(targetPlayer)
            local distance = getDistanceBetweenPoints3D(x, y, z, gatePos[1], gatePos[2], gatePos[3])

            if distance <= 500 then
                outputChatBox(
                    "** LOA TO ** CO NGUOI XAM NHAP TRAI PHEP!! CO NGUOI XAM NHAP TRAI PHEP!! YEU CAU BAT GIU!!",
                    targetPlayer, 255, 255, 0)

                -- Play siren sound (would need sound file)
                -- playSound equivalent in MTA
            end
        end

        -- Notify police department
        local message = string.format("** %s da dong lai moi hoat dong san xuat tai co so san xuat vu khi **",
            getPlayerName(player))

        for _, cop in ipairs(getElementsByType("player")) do
            local job = getElementData(cop, "player.job")
            if job == 1 then -- Police
                outputChatBox(message, cop, 0, 255, 255)
            end
        end

        -- Set auto-end timer (15 minutes)
        lockdownSystem.islandLockdown.autoEndTimer = setTimer(function()
            endIslandLockdown()
        end, 900000, 1)

        outputChatBox("Island lockdown initiated. Auto-end in 15 minutes.", player, 255, 255, 0)
        outputDebugString("[LOCKDOWN] " .. getPlayerName(player) .. " initiated island lockdown")

    else
        -- End island lockdown
        endIslandLockdown()
        outputChatBox("Island lockdown ended manually.", player, 0, 255, 0)
    end
end)

-- Function to end island lockdown
function endIslandLockdown()
    if lockdownSystem.islandLockdown.active then
        lockdownSystem.islandLockdown.active = false

        -- Stop timer if active
        if lockdownSystem.islandLockdown.autoEndTimer then
            killTimer(lockdownSystem.islandLockdown.autoEndTimer)
            lockdownSystem.islandLockdown.autoEndTimer = nil
        end

        -- Move gate back (simulated)
        -- moveObject back to original position

        -- Stop siren sounds
        if lockdownSystem.islandLockdown.sirenSound then
            -- stopSound equivalent
        end

        -- Notify police
        for _, cop in ipairs(getElementsByType("player")) do
            local job = getElementData(cop, "player.job")
            if job == 1 then -- Police
                outputChatBox("** Threat eliminated. Island operations resumed. **", cop, 0, 255, 0)
            end
        end

        outputDebugString("[LOCKDOWN] Island lockdown ended")
    end
end

-- Server lockdown command (for highest admins)
-- Lockdown System
addCommandHandler("lockdown", function(player, cmd, action, ...)
    if not player or not isElement(player) then
        return
    end

    local adminLevel = getElementData(player, "adminLevel") or 0
    local securityLevel = getElementData(player, "securityLevel") or 0
    local args = {...}

    if adminLevel < 6 and securityLevel < 5 then
        outputChatBox("Bạn không có quyền kích hoạt lockdown!", player, 255, 100, 100)
        return
    end

    if not action then
        outputChatBox("Sử dụng: /lockdown [activate/deactivate/status] [khu vực]", player, 255, 255, 100)
        return
    end

    if action == "activate" then
        local area = table.concat(args, " ") or "Toàn bộ khu vực"

        outputChatBox("=== KÍCH HOẠT LOCKDOWN ===", getRootElement(), 255, 100, 100)
        outputChatBox("Khu vực: " .. area, getRootElement(), 255, 255, 255)
        outputChatBox("Được kích hoạt bởi: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
        outputChatBox("Tất cả hoạt động bị hạn chế!", getRootElement(), 255, 100, 100)

        setElementData(getRootElement(), "lockdownActive", true)
        setElementData(getRootElement(), "lockdownArea", area)
        setElementData(getRootElement(), "lockdownBy", getPlayerName(player))

        triggerClientEvent("lockdown:activated", getRootElement(), area)

    elseif action == "deactivate" then
        local lockdownActive = getElementData(getRootElement(), "lockdownActive")

        if not lockdownActive then
            outputChatBox("Không có lockdown nào đang hoạt động!", player, 255, 100, 100)
            return
        end

        setElementData(getRootElement(), "lockdownActive", false)
        setElementData(getRootElement(), "lockdownArea", nil)
        setElementData(getRootElement(), "lockdownBy", nil)

        outputChatBox("=== HỦY LOCKDOWN ===", getRootElement(), 100, 255, 100)
        outputChatBox("Được hủy bởi: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
        outputChatBox("Các hoạt động trở lại bình thường!", getRootElement(), 100, 255, 100)

        triggerClientEvent("lockdown:deactivated", getRootElement())

    elseif action == "status" then
        local lockdownActive = getElementData(getRootElement(), "lockdownActive")

        if lockdownActive then
            local area = getElementData(getRootElement(), "lockdownArea")
            local by = getElementData(getRootElement(), "lockdownBy")

            outputChatBox("=== TRẠNG THÁI LOCKDOWN ===", player, 255, 255, 100)
            outputChatBox("Trạng thái: ĐANG HOẠT ĐỘNG", player, 255, 100, 100)
            outputChatBox("Khu vực: " .. area, player, 255, 255, 255)
            outputChatBox("Kích hoạt bởi: " .. by, player, 255, 255, 255)
        else
            outputChatBox("Lockdown: KHÔNG HOẠT ĐỘNG", player, 100, 255, 100)
        end
    end
end)

-- Report system
addCommandHandler("report", function(player, cmd, ...)
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /report [loi/bug/hacke/vi pham]", player, 255, 255, 255)
        return
    end

    local playerData = getElementData(player, "playerData") or {}
    local reportID = (getServerData("nextReportID") or 1)
    setServerData("nextReportID", reportID + 1)

    local reportData = {
        id = reportID,
        reporter = getPlayerName(player),
        message = message,
        status = "pending",
        time = getRealTime().timestamp,
        handled_by = nil
    }

    setServerData("report_" .. reportID, reportData)

    outputChatBox(string.format("📝 Da gui report #%d. Admin se xu ly som.", reportID), player, 0, 255, 0)

    -- Notify admins
    for _, admin in ipairs(getElementsByType("player")) do
        local adminData = getElementData(admin, "playerData") or {}
        if (adminData.adminLevel or 0) >= 1 then
            outputChatBox(string.format("📝 NEW REPORT #%d from %s: %s", reportID, getPlayerName(player), message),
                admin, 255, 255, 0)
        end
    end

    outputDebugString(string.format("[REPORT] #%d by %s: %s", reportID, getPlayerName(player), message))
end)

-- Answer report
addCommandHandler("ar", function(player, cmd, reportID, ...)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 1 then
        outputChatBox("❌ Ban can admin level 1 de tra loi report.", player, 255, 100, 100)
        return
    end

    if not reportID then
        outputChatBox("Su dung: /ar [report_id] [tra loi]", player, 255, 255, 255)
        return
    end

    local reportData = getServerData("report_" .. reportID)
    if not reportData then
        outputChatBox("❌ Report khong ton tai.", player, 255, 100, 100)
        return
    end

    local response = table.concat({...}, " ", 2)
    if not response or response == "" then
        outputChatBox("Su dung: /ar [report_id] [tra loi]", player, 255, 255, 255)
        return
    end

    reportData.status = "answered"
    reportData.handled_by = getPlayerName(player)
    reportData.response = response
    setServerData("report_" .. reportID, reportData)

    -- Send response to reporter
    local reporter = getPlayerFromName(reportData.reporter)
    if reporter then
        outputChatBox(string.format("📝 ADMIN RESPONSE to Report #%d:", reportID), reporter, 0, 255, 0)
        outputChatBox(string.format("📝 %s", response), reporter, 255, 255, 255)
    end

    outputChatBox(string.format("✅ Da tra loi report #%d", reportID), player, 0, 255, 0)

    -- Notify other admins
    for _, admin in ipairs(getElementsByType("player")) do
        local adminData = getElementData(admin, "playerData") or {}
        if (adminData.adminLevel or 0) >= 1 and admin ~= player then
            outputChatBox(string.format("📝 %s answered report #%d", getPlayerName(player), reportID), admin, 255,
                255, 100)
        end
    end
end)

-- View reports
addCommandHandler("reports", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 1 then
        outputChatBox("❌ Ban can admin level 1 de xem reports.", player, 255, 100, 100)
        return
    end

    outputChatBox("📝 ===== PENDING REPORTS =====", player, 255, 255, 0)

    local pendingReports = {}
    local reportCount = 0

    -- Get all reports (this is simplified, in real server you'd use database)
    for i = 1, (getServerData("nextReportID") or 1) - 1 do
        local reportData = getServerData("report_" .. i)
        if reportData and reportData.status == "pending" then
            table.insert(pendingReports, reportData)
            reportCount = reportCount + 1
        end
    end

    if reportCount == 0 then
        outputChatBox("• Khong co report nao pending.", player, 255, 255, 255)
    else
        -- Sort by time (newest first)
        table.sort(pendingReports, function(a, b)
            return a.time > b.time
        end)

        for i, report in ipairs(pendingReports) do
            if i > 10 then
                break
            end -- Show max 10 reports
            outputChatBox(string.format("• #%d [%s]: %s", report.id, report.reporter, report.message), player, 255,
                255, 255)
        end

        if #pendingReports > 10 then
            outputChatBox(string.format("... va %d reports khac", #pendingReports - 10), player, 255, 255, 100)
        end
    end

    outputChatBox(string.format("Total pending: %d reports", reportCount), player, 255, 255, 100)
end)

-- Anti-cheat reporting
addCommandHandler("anticheat", function(player, cmd, targetName, cheatType)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 2 then
        outputChatBox("❌ Ban can admin level 2 de su dung anticheat.", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Su dung: /anticheat [player] [type]", player, 255, 255, 255)
        outputChatBox("Types: aimbot, wallhack, speedhack, flyhack, godmode", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    local cheatTypes = {
        aimbot = "Aimbot/Auto-aim",
        wallhack = "Wall hack/ESP",
        speedhack = "Speed hack",
        flyhack = "Fly hack/Airbreak",
        godmode = "God mode/Invincibility"
    }

    if not cheatType or not cheatTypes[cheatType] then
        outputChatBox("❌ Cheat type khong hop le.", player, 255, 100, 100)
        return
    end

    -- Log the detection
    local logData = {
        target = getPlayerName(targetPlayer),
        admin = getPlayerName(player),
        cheat = cheatTypes[cheatType],
        time = getRealTime().timestamp
    }

    -- Store in server data (in real server, this would go to database)
    local logID = (getServerData("nextCheatLogID") or 1)
    setServerData("nextCheatLogID", logID + 1)
    setServerData("cheatlog_" .. logID, logData)

    outputChatBox(string.format("🔍 ANTICHEAT: Logged %s for %s (%s)", cheatTypes[cheatType],
        getPlayerName(targetPlayer), cheatType), player, 255, 100, 100)

    -- Notify other high-level admins
    for _, admin in ipairs(getElementsByType("player")) do
        local adminData = getElementData(admin, "playerData") or {}
        if (adminData.adminLevel or 0) >= 3 and admin ~= player then
            outputChatBox(string.format("🔍 ANTICHEAT: %s flagged %s for %s", getPlayerName(player),
                getPlayerName(targetPlayer), cheatTypes[cheatType]), admin, 255, 100, 100)
        end
    end

    outputDebugString(string.format("[ANTICHEAT] %s flagged %s for %s", getPlayerName(player),
        getPlayerName(targetPlayer), cheatTypes[cheatType]))
end)

-- Warning system
addCommandHandler("warn", function(player, cmd, targetName, ...)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 1 then
        outputChatBox("❌ Ban can admin level 1 de warn nguoi choi.", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Su dung: /warn [player] [ly do]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    local reason = table.concat({...}, " ", 2)
    if not reason or reason == "" then
        reason = "Vi pham quy dinh server"
    end

    local targetData = getElementData(targetPlayer, "playerData") or {}
    targetData.warnings = (targetData.warnings or 0) + 1
    setElementData(targetPlayer, "playerData", targetData)

    -- Log warning
    local warnData = {
        target = getPlayerName(targetPlayer),
        admin = getPlayerName(player),
        reason = reason,
        time = getRealTime().timestamp,
        warnings = targetData.warnings
    }

    local warnID = (getServerData("nextWarnID") or 1)
    setServerData("nextWarnID", warnID + 1)
    setServerData("warning_" .. warnID, warnData)

    outputChatBox(string.format("⚠️ CANH BAO #%d tu admin %s", targetData.warnings, getPlayerName(player)),
        targetPlayer, 255, 255, 0)
    outputChatBox(string.format("⚠️ Ly do: %s", reason), targetPlayer, 255, 255, 0)
    outputChatBox("⚠️ 3 canh bao = ban 1 ngay, 5 canh bao = ban vinh vien", targetPlayer, 255, 100, 100)

    outputChatBox(string.format("⚠️ Da warn %s (Warning #%d). Ly do: %s", getPlayerName(targetPlayer),
        targetData.warnings, reason), player, 255, 255, 0)

    -- Auto-punishment for multiple warnings
    if targetData.warnings >= 5 then
        -- Permanent ban
        banPlayer(targetPlayer, player, "5 warnings - permanent ban")
        outputChatBox(string.format("🔨 %s da bi ban vinh vien vi 5 warnings", getPlayerName(targetPlayer)), root,
            255, 100, 100)
    elseif targetData.warnings >= 3 then
        -- 1 day ban  
        local banTime = 86400 -- 24 hours
        targetData.banTime = getRealTime().timestamp + banTime
        setElementData(targetPlayer, "playerData", targetData)
        kickPlayer(targetPlayer, player, "3 warnings - banned 1 day")
        outputChatBox(string.format("🔨 %s da bi ban 1 ngay vi 3 warnings", getPlayerName(targetPlayer)), root, 255,
            255, 100)
    end

    -- Notify other admins
    for _, admin in ipairs(getElementsByType("player")) do
        local adminData = getElementData(admin, "playerData") or {}
        if (adminData.adminLevel or 0) >= 1 and admin ~= player then
            outputChatBox(string.format("⚠️ %s warned %s (#%d): %s", getPlayerName(player),
                getPlayerName(targetPlayer), targetData.warnings, reason), admin, 255, 255, 100)
        end
    end
end)

-- Check warnings
addCommandHandler("checkwarns", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 1 then
        outputChatBox("❌ Ban can admin level 1 de check warnings.", player, 255, 100, 100)
        return
    end

    local targetPlayer = player
    if targetName then
        targetPlayer = getPlayerFromNameOrId(targetName)
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end

    local targetData = getElementData(targetPlayer, "playerData") or {}
    local warnings = targetData.warnings or 0

    outputChatBox(string.format("⚠️ %s co %d warnings", getPlayerName(targetPlayer), warnings), player, 255, 255, 0)

    -- Show recent warnings
    if warnings > 0 then
        outputChatBox("⚠️ Recent warnings:", player, 255, 255, 100)

        -- This is simplified - in real server you'd query database
        for i = (getServerData("nextWarnID") or 1) - 1, 1, -1 do
            local warnData = getServerData("warning_" .. i)
            if warnData and warnData.target == getPlayerName(targetPlayer) then
                local timeStr = os.date("%d/%m/%Y %H:%M", warnData.time)
                outputChatBox(string.format("• [%s] Admin %s: %s", timeStr, warnData.admin, warnData.reason), player,
                    255, 255, 255)
                break -- Show only latest warning
            end
        end
    end
end)

-- Security scan
addCommandHandler("secscan", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 3 then
        outputChatBox("❌ Ban can admin level 3 de security scan.", player, 255, 100, 100)
        return
    end

    local targetPlayer = targetName and getPlayerFromNameOrId(targetName) or player
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    outputChatBox(string.format("🔍 ===== SECURITY SCAN: %s =====", getPlayerName(targetPlayer)), player, 255, 255, 0)

    local targetData = getElementData(targetPlayer, "playerData") or {}

    -- Check health
    local health = getElementHealth(targetPlayer)
    local armor = getPedArmor(targetPlayer)
    outputChatBox(string.format("• Health: %.1f, Armor: %.1f", health, armor), player, 255, 255, 255)

    -- Check position and velocity
    local x, y, z = getElementPosition(targetPlayer)
    local vx, vy, vz = getElementVelocity(targetPlayer)
    local speed = math.sqrt(vx * vx + vy * vy + vz * vz) * 50 -- Convert to km/h
    outputChatBox(string.format("• Position: %.1f, %.1f, %.1f", x, y, z), player, 255, 255, 255)
    outputChatBox(string.format("• Speed: %.1f km/h", speed), player, 255, 255, 255)

    -- Check money
    outputChatBox(string.format("• Money: $%d, Bank: $%d", targetData.money or 0, targetData.bankMoney or 0), player,
        255, 255, 255)

    -- Check warnings and admin status
    outputChatBox(string.format("• Warnings: %d, Admin Level: %d", targetData.warnings or 0,
        targetData.adminLevel or 0), player, 255, 255, 255)

    -- Check weapon
    local weapon = getPedWeapon(targetPlayer)
    local ammo = getPedTotalAmmo(targetPlayer)
    outputChatBox(string.format("• Weapon: %d, Ammo: %d", weapon, ammo), player, 255, 255, 255)

    -- Check if in vehicle
    local vehicle = getPedOccupiedVehicle(targetPlayer)
    if vehicle then
        local model = getElementModel(vehicle)
        local vHealth = getElementHealth(vehicle)
        outputChatBox(string.format("• Vehicle: Model %d, Health %.1f", model, vHealth), player, 255, 255, 255)
    else
        outputChatBox("• Vehicle: On foot", player, 255, 255, 255)
    end

    -- Check account info
    outputChatBox(string.format("• Level: %d, Job: %s", targetData.level or 1, targetData.job or "Unemployed"),
        player, 255, 255, 255)

    -- Ping and connection info
    local ping = getPlayerPing(targetPlayer)
    outputChatBox(string.format("• Ping: %d ms", ping), player, 255, 255, 255)
end)

-- End lockdown
addCommandHandler("endlockdown", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 5 then
        outputChatBox("❌ Ban can admin level 5 de end lockdown.", player, 255, 100, 100)
        return
    end

    local lockdownEnd = getServerData("lockdownEnd")
    if not lockdownEnd or getRealTime().timestamp >= lockdownEnd then
        outputChatBox("❌ Server khong bi lockdown.", player, 255, 100, 100)
        return
    end

    -- End lockdown
    setServerData("lockdownEnd", nil)
    setServerData("lockdownReason", nil)
    setServerData("lockdownAdmin", nil)

    outputChatBox("✅ LOCKDOWN DA KET THUC!", root, 0, 255, 0)
    outputChatBox(string.format("✅ Lockdown ended boi: Admin %s", getPlayerName(player)), root, 255, 255, 100)

    outputDebugString(string.format("[LOCKDOWN] Ended by %s", getPlayerName(player)))
end)

-- Check if server is in lockdown (for login system)
function isServerLocked()
    local lockdownEnd = getServerData("lockdownEnd")
    return lockdownEnd and getRealTime().timestamp < lockdownEnd
end

-- Spectate system for security
addCommandHandler("spec", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 2 then
        outputChatBox("❌ Ban can admin level 2 de spectate.", player, 255, 100, 100)
        return
    end

    if not targetName then
        -- Stop spectating
        setCameraTarget(player, player)
        outputChatBox("✅ Da dung spectate.", player, 0, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    if targetPlayer == player then
        outputChatBox("❌ Ban khong the spectate chinh minh.", player, 255, 100, 100)
        return
    end

    -- Start spectating
    setCameraTarget(player, targetPlayer)
    outputChatBox(string.format("👁️ Dang spectate %s. Su dung /spec de dung.", getPlayerName(targetPlayer)),
        player, 255, 255, 0)
end)

-- IP check
addCommandHandler("checkip", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 3 then
        outputChatBox("❌ Ban can admin level 3 de check IP.", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Su dung: /checkip [player]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    local ip = getPlayerIP(targetPlayer)
    local serial = getPlayerSerial(targetPlayer)

    outputChatBox(string.format("🔍 %s - IP: %s", getPlayerName(targetPlayer), ip), player, 255, 255, 0)
    outputChatBox(string.format("🔍 Serial: %s", serial), player, 255, 255, 0)

    -- Check for other accounts with same IP
    local sameIP = {}
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= targetPlayer and getPlayerIP(p) == ip then
            table.insert(sameIP, getPlayerName(p))
        end
    end

    if #sameIP > 0 then
        outputChatBox(string.format("⚠️ Cung IP: %s", table.concat(sameIP, ", ")), player, 255, 100, 100)
    else
        outputChatBox("✅ Khong co account nao khac cung IP.", player, 0, 255, 0)
    end
end)

-- Helper functions
function getServerData(key)
    return getElementData(getResourceRootElement(), key)
end

function setServerData(key, value)
    setElementData(getResourceRootElement(), key, value)
end

-- Prevent non-admins from joining during lockdown
addEventHandler("onPlayerJoin", root, function()
    if lockdownSystem.serverLockdown.active then
        local adminLevel = getElementData(source, "player.adminLevel") or 0

        if adminLevel < 2 then
            setTimer(function(player)
                if isElement(player) then
                    kickPlayer(player, "Server is under lockdown: " .. lockdownSystem.serverLockdown.reason)
                end
            end, 1000, 1, source)
        end
    end
end)

-- Lockdown status command
addCommandHandler("lockdownstatus", function(player)
    local adminLevel = getElementData(player, "player.adminLevel") or 0

    if adminLevel < 2 then
        outputChatBox("Ban khong duoc phep su dung lenh nay!", player, 255, 100, 100)
        return
    end

    outputChatBox("=== LOCKDOWN STATUS ===", player, 255, 255, 0)

    -- Server lockdown status
    if lockdownSystem.serverLockdown.active then
        local duration = getRealTime().timestamp - lockdownSystem.serverLockdown.startTime
        local minutes = math.floor(duration / 60)

        outputChatBox(string.format("Server Lockdown: ACTIVE (%d minutes)", minutes), player, 255, 100, 100)
        outputChatBox("Reason: " .. lockdownSystem.serverLockdown.reason, player, 255, 255, 255)
        outputChatBox("Admin: " .. lockdownSystem.serverLockdown.adminName, player, 255, 255, 255)
    else
        outputChatBox("Server Lockdown: INACTIVE", player, 0, 255, 0)
    end

    -- Island lockdown status
    if lockdownSystem.islandLockdown.active then
        local duration = getRealTime().timestamp - lockdownSystem.islandLockdown.startTime
        local minutes = math.floor(duration / 60)
        local remaining = 15 - minutes

        outputChatBox(string.format("Island Lockdown: ACTIVE (%d minutes, %d remaining)", minutes, remaining), player,
            255, 100, 100)
    else
        outputChatBox("Island Lockdown: INACTIVE", player, 0, 255, 0)
    end
end)

-- Reload paintball arenas command
addCommandHandler("areloadpb", function(player)
    local adminLevel = getElementData(player, "player.adminLevel") or 0

    if adminLevel < 1337 then
        outputChatBox("Ban khong duoc phep su dung lenh nay!", player, 255, 100, 100)
        return
    end

    -- Reload paintball arenas (would call paintball arena loading function)
    triggerEvent("onReloadPaintballArenas", resourceRoot)

    outputChatBox("Paintball Arenas dang tai tu he thong.", player, 255, 0, 0)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " reloaded paintball arenas")
end)

-- Emergency unlock command (for console/rcon)
addCommandHandler("emergencyunlock", function(player)
    local adminLevel = getElementData(player, "player.adminLevel") or 0

    if adminLevel < 1338 then
        outputChatBox("Ban khong duoc phep su dung lenh nay!", player, 255, 100, 100)
        return
    end

    -- Force end all lockdowns
    if lockdownSystem.serverLockdown.active then
        lockdownSystem.serverLockdown.active = false
        outputChatBox("Server lockdown forcefully ended.", player, 0, 255, 0)
    end

    if lockdownSystem.islandLockdown.active then
        endIslandLockdown()
        outputChatBox("Island lockdown forcefully ended.", player, 0, 255, 0)
    end

    outputDebugString("[EMERGENCY] " .. getPlayerName(player) .. " used emergency unlock")
end)

-- Auto-save lockdown status (in case of server restart)
setTimer(function()
    if lockdownSystem.serverLockdown.active then
        -- Save lockdown status to file/database
        local status = toJSON(lockdownSystem.serverLockdown)
        setElementData(resourceRoot, "serverLockdownStatus", status)
    end
end, 60000, 0) -- Every minute
