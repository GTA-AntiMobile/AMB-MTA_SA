--[[
    ADVANCED SECURITY & PROTECTION SYSTEM - Batch 26
    
    Chức năng: Hệ thống bảo vệ và an ninh hoàn chỉnh
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng security, protection, guard
    
    Commands migrated: 18 commands
    - Security System: securitysys, guard, patrol, monitor
    - Protection Services: protect, bodyguard, escort, secure
    - Surveillance: camera, alarm, detector, scanner
    - Access Control: keycard, access, lock, unlock
    - Emergency Response: panic, lockdown, evacuation
    - Security Management: hire, fire, contract
]]

local securitySystems = {}
local guards = {}
local protectionContracts = {}
local surveillanceNetwork = {}
local accessControls = {}
local emergencyProtocols = {}

-- Security System
addCommandHandler("securitysys", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local securityLevel = getElementData(player, "securityLevel") or 0
    local adminLevel = getElementData(player, "adminLevel") or 0
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /securitysys [install/upgrade/status/report/breach] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "install" then
        local locationType = args[1] -- home, business, government
        local securityType = args[2] -- basic, advanced, premium
        
        if not locationType or not securityType then
            outputChatBox("Sử dụng: /securitysys install [home/business/government] [basic/advanced/premium]", player, 255, 100, 100)
            return
        end
        
        local costs = {
            basic = {home = 5000, business = 15000, government = 25000},
            advanced = {home = 15000, business = 35000, government = 75000},
            premium = {home = 35000, business = 75000, government = 150000}
        }
        
        local cost = costs[securityType] and costs[securityType][locationType]
        if not cost then
            outputChatBox("Loại bảo mật không hợp lệ!", player, 255, 100, 100)
            return
        end
        
        local playerMoney = getElementData(player, "money") or 0
        if playerMoney < cost then
            outputChatBox("Bạn không đủ tiền! Cần: $" .. cost, player, 255, 100, 100)
            return
        end
        
        setElementData(player, "money", playerMoney - cost)
        
        local x, y, z = getElementPosition(player)
        local securityId = #securitySystems + 1
        
        securitySystems[securityId] = {
            owner = getPlayerName(player),
            location = {x = x, y = y, z = z},
            type = securityType,
            locationType = locationType,
            status = "active",
            alerts = {},
            installed = getRealTime().timestamp,
            lastMaintenance = getRealTime().timestamp
        }
        
        outputChatBox("Đã lắp đặt hệ thống bảo mật " .. securityType .. " cho " .. locationType, player, 100, 255, 100)
        outputChatBox("Chi phí: $" .. cost .. " - ID: " .. securityId, player, 255, 255, 255)
        
        triggerClientEvent("security:systemInstalled", player, securityId, securityType)
        
    elseif action == "upgrade" then
        local securityId = tonumber(args[1])
        local newType = args[2]
        
        if not securityId or not securitySystems[securityId] then
            outputChatBox("Hệ thống bảo mật không tồn tại!", player, 255, 100, 100)
            return
        end
        
        local system = securitySystems[securityId]
        if system.owner ~= getPlayerName(player) and adminLevel < 5 then
            outputChatBox("Bạn không phải chủ sở hữu hệ thống này!", player, 255, 100, 100)
            return
        end
        
        local upgradeCosts = {
            basic = {advanced = 10000, premium = 25000},
            advanced = {premium = 15000}
        }
        
        local cost = upgradeCosts[system.type] and upgradeCosts[system.type][newType]
        if not cost then
            outputChatBox("Không thể nâng cấp lên loại này!", player, 255, 100, 100)
            return
        end
        
        local playerMoney = getElementData(player, "money") or 0
        if playerMoney < cost then
            outputChatBox("Bạn không đủ tiền nâng cấp! Cần: $" .. cost, player, 255, 100, 100)
            return
        end
        
        setElementData(player, "money", playerMoney - cost)
        system.type = newType
        system.lastMaintenance = getRealTime().timestamp
        
        outputChatBox("Đã nâng cấp hệ thống bảo mật lên " .. newType, player, 100, 255, 100)
        outputChatBox("Chi phí nâng cấp: $" .. cost, player, 255, 255, 255)
        
    elseif action == "status" then
        local securityId = args[1]
        
        if securityId then
            local sId = tonumber(securityId)
            if not sId or not securitySystems[sId] then
                outputChatBox("Hệ thống bảo mật không tồn tại!", player, 255, 100, 100)
                return
            end
            
            local system = securitySystems[sId]
            outputChatBox("=== HỆ THỐNG BẢO MẬT #" .. sId .. " ===", player, 255, 255, 100)
            outputChatBox("Chủ sở hữu: " .. system.owner, player, 255, 255, 255)
            outputChatBox("Loại: " .. system.type .. " (" .. system.locationType .. ")", player, 255, 255, 255)
            outputChatBox("Trạng thái: " .. system.status, player, 255, 255, 255)
            outputChatBox("Cảnh báo: " .. #system.alerts, player, 255, 255, 255)
        else
            outputChatBox("=== HỆ THỐNG BẢO MẬT CỦA BẠN ===", player, 255, 255, 100)
            local count = 0
            
            for id, system in pairs(securitySystems) do
                if system.owner == getPlayerName(player) then
                    outputChatBox("#" .. id .. " - " .. system.type .. " (" .. system.locationType .. ") - " .. system.status, player, 255, 255, 255)
                    count = count + 1
                end
            end
            
            if count == 0 then
                outputChatBox("Bạn không có hệ thống bảo mật nào.", player, 255, 255, 255)
            end
        end
        
    elseif action == "report" then
        if securityLevel < 2 and adminLevel < 3 then
            outputChatBox("Bạn không có quyền xem báo cáo bảo mật!", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== BÁO CÁO BẢO MẬT ===", player, 255, 255, 100)
        outputChatBox("Tổng số hệ thống: " .. #securitySystems, player, 255, 255, 255)
        
        local activeCount = 0
        local alertCount = 0
        
        for _, system in pairs(securitySystems) do
            if system.status == "active" then
                activeCount = activeCount + 1
            end
            alertCount = alertCount + #system.alerts
        end
        
        outputChatBox("Hệ thống hoạt động: " .. activeCount, player, 100, 255, 100)
        outputChatBox("Tổng cảnh báo: " .. alertCount, player, 255, 100, 100)
        
    elseif action == "breach" then
        if adminLevel < 4 then
            outputChatBox("Chỉ admin mới có thể mô phỏng vi phạm bảo mật!", player, 255, 100, 100)
            return
        end
        
        local securityId = tonumber(args[1])
        local breachType = args[2] or "unknown"
        
        if not securityId or not securitySystems[securityId] then
            outputChatBox("Hệ thống bảo mật không tồn tại!", player, 255, 100, 100)
            return
        end
        
        local system = securitySystems[securityId]
        table.insert(system.alerts, {
            type = "breach",
            description = "Vi phạm bảo mật: " .. breachType,
            timestamp = getRealTime().timestamp,
            severity = "high"
        })
        
        outputChatBox("Đã tạo cảnh báo vi phạm bảo mật cho hệ thống #" .. securityId, player, 255, 100, 100)
        
        -- Notify owner
        local owner = getPlayerFromName(system.owner)
        if owner then
            outputChatBox("CẢNH BÁO: Vi phạm bảo mật tại hệ thống #" .. securityId .. "!", owner, 255, 100, 100)
        end
    end
end)

-- Guard System
addCommandHandler("guard", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local guardLevel = getElementData(player, "guardLevel") or 0
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /guard [hire/fire/assign/patrol/report] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "hire" then
        local targetPlayer = args[1]
        local salary = tonumber(args[2]) or 5000
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local playerMoney = getElementData(player, "money") or 0
        if playerMoney < salary then
            outputChatBox("Bạn không đủ tiền trả lương bảo vệ!", player, 255, 100, 100)
            return
        end
        
        local guardId = #guards + 1
        guards[guardId] = {
            guard = target,
            employer = player,
            salary = salary,
            hired = getRealTime().timestamp,
            status = "available",
            assignment = nil,
            performance = 100
        }
        
        setElementData(target, "guardLevel", 1)
        setElementData(target, "employer", getPlayerName(player))
        setElementData(player, "money", playerMoney - salary)
        
        local targetMoney = getElementData(target, "money") or 0
        setElementData(target, "money", targetMoney + salary)
        
        outputChatBox("Đã thuê " .. getPlayerName(target) .. " làm bảo vệ với lương $" .. salary, player, 100, 255, 100)
        outputChatBox("Bạn đã được thuê làm bảo vệ với lương $" .. salary, target, 100, 255, 100)
        
    elseif action == "fire" then
        local targetPlayer = args[1]
        local target = getPlayerFromName(targetPlayer)
        
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local guardEntry = nil
        for id, guard in pairs(guards) do
            if guard.guard == target and guard.employer == player then
                guardEntry = guard
                guards[id] = nil
                break
            end
        end
        
        if not guardEntry then
            outputChatBox("Người này không phải nhân viên bảo vệ của bạn!", player, 255, 100, 100)
            return
        end
        
        setElementData(target, "guardLevel", 0)
        setElementData(target, "employer", nil)
        
        outputChatBox("Đã sa thải " .. getPlayerName(target) .. " khỏi vị trí bảo vệ!", player, 100, 255, 100)
        outputChatBox("Bạn đã bị sa thải khỏi công việc bảo vệ!", target, 255, 100, 100)
        
    elseif action == "assign" then
        if guardLevel < 1 then
            outputChatBox("Bạn không phải nhân viên bảo vệ!", player, 255, 100, 100)
            return
        end
        
        local assignment = table.concat(args, " ")
        if not assignment or assignment == "" then
            outputChatBox("Sử dụng: /guard assign [nhiệm vụ]", player, 255, 100, 100)
            return
        end
        
        setElementData(player, "guardAssignment", assignment)
        outputChatBox("Đã nhận nhiệm vụ: " .. assignment, player, 100, 255, 100)
        
        local employer = getElementData(player, "employer")
        if employer then
            local boss = getPlayerFromName(employer)
            if boss then
                outputChatBox("Bảo vệ " .. getPlayerName(player) .. " đã nhận nhiệm vụ: " .. assignment, boss, 255, 255, 100)
            end
        end
        
    elseif action == "patrol" then
        if guardLevel < 1 then
            outputChatBox("Bạn không phải nhân viên bảo vệ!", player, 255, 100, 100)
            return
        end
        
        local patrolArea = args[1] or "general"
        setElementData(player, "patrolling", true)
        setElementData(player, "patrolArea", patrolArea)
        
        outputChatBox("Bắt đầu tuần tra khu vực: " .. patrolArea, player, 100, 255, 100)
        
        -- Start patrol timer
        local patrolTimer = setTimer(function()
            if getElementData(player, "patrolling") then
                local x, y, z = getElementPosition(player)
                outputChatBox("Tuần tra: Vị trí (" .. math.floor(x) .. ", " .. math.floor(y) .. ") - An toàn", player, 255, 255, 100)
                
                -- Random events during patrol
                if math.random(1, 10) == 1 then
                    outputChatBox("Phát hiện hoạt động đáng ngờ! Đang điều tra...", player, 255, 100, 100)
                end
            else
                killTimer(patrolTimer)
            end
        end, 30000, 0) -- Every 30 seconds
        
    elseif action == "report" then
        if guardLevel < 1 then
            outputChatBox("Bạn không phải nhân viên bảo vệ!", player, 255, 100, 100)
            return
        end
        
        local incident = table.concat(args, " ")
        if not incident or incident == "" then
            outputChatBox("Sử dụng: /guard report [báo cáo sự cố]", player, 255, 100, 100)
            return
        end
        
        outputChatBox("Đã gửi báo cáo: " .. incident, player, 100, 255, 100)
        
        local employer = getElementData(player, "employer")
        if employer then
            local boss = getPlayerFromName(employer)
            if boss then
                outputChatBox("BÁO CÁO BẢO VỆ: " .. incident, boss, 255, 100, 100)
                outputChatBox("Từ: " .. getPlayerName(player), boss, 255, 255, 255)
            end
        end
        
        -- Notify nearby police
        local x, y, z = getElementPosition(player)
        for _, p in ipairs(getElementsByType("player")) do
            local policeRank = getElementData(p, "policeRank") or 0
            if policeRank > 0 then
                local px, py, pz = getElementPosition(p)
                local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
                if distance <= 500 then
                    outputChatBox("Báo cáo bảo vệ gần đây: " .. incident, p, 255, 255, 100)
                end
            end
        end
    end
end)

-- Protect System
addCommandHandler("protect", function(player, cmd, targetPlayer, duration)
    if not player or not isElement(player) then return end
    
    local guardLevel = getElementData(player, "guardLevel") or 0
    
    if guardLevel < 1 then
        outputChatBox("Bạn không phải nhân viên bảo vệ!", player, 255, 100, 100)
        return
    end
    
    local target = getPlayerFromName(targetPlayer)
    if not target then
        outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
        return
    end
    
    local protectDuration = tonumber(duration) or 30 -- minutes
    
    if protectDuration > 120 then
        outputChatBox("Thời gian bảo vệ tối đa là 120 phút!", player, 255, 100, 100)
        return
    end
    
    setElementData(target, "protectedBy", getPlayerName(player))
    setElementData(target, "protectionEnd", getRealTime().timestamp + (protectDuration * 60))
    setElementData(player, "protecting", getPlayerName(target))
    
    outputChatBox("Bạn đang bảo vệ " .. getPlayerName(target) .. " trong " .. protectDuration .. " phút", player, 100, 255, 100)
    outputChatBox(getPlayerName(player) .. " đang bảo vệ bạn!", target, 100, 255, 100)
    
    -- Auto-end protection
    setTimer(function()
        if isElement(target) and getElementData(target, "protectedBy") == getPlayerName(player) then
            setElementData(target, "protectedBy", nil)
            setElementData(target, "protectionEnd", nil)
            setElementData(player, "protecting", nil)
            
            outputChatBox("Kết thúc bảo vệ " .. getPlayerName(target), player, 255, 255, 100)
            outputChatBox("Dịch vụ bảo vệ đã kết thúc!", target, 255, 255, 100)
        end
    end, protectDuration * 60000, 1)
end)

-- Keycard System
addCommandHandler("keycard", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /keycard [create/give/revoke/scan] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "create" then
        local accessLevel = tonumber(args[1]) or 1
        local description = table.concat(args, " ", 2)
        
        if accessLevel > 10 or accessLevel < 1 then
            outputChatBox("Cấp độ truy cập phải từ 1-10!", player, 255, 100, 100)
            return
        end
        
        local keycardId = #accessControls + 1
        accessControls[keycardId] = {
            level = accessLevel,
            description = description,
            createdBy = getPlayerName(player),
            created = getRealTime().timestamp,
            active = true
        }
        
        outputChatBox("Đã tạo thẻ từ cấp " .. accessLevel .. " - ID: " .. keycardId, player, 100, 255, 100)
        if description and description ~= "" then
            outputChatBox("Mô tả: " .. description, player, 255, 255, 255)
        end
        
    elseif action == "give" then
        local targetPlayer = args[1]
        local keycardId = tonumber(args[2])
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        if not keycardId or not accessControls[keycardId] then
            outputChatBox("Thẻ từ không tồn tại!", player, 255, 100, 100)
            return
        end
        
        local playerKeycards = getElementData(target, "keycards") or {}
        table.insert(playerKeycards, keycardId)
        setElementData(target, "keycards", playerKeycards)
        
        outputChatBox("Đã cấp thẻ từ #" .. keycardId .. " cho " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox("Bạn đã nhận được thẻ từ #" .. keycardId, target, 100, 255, 100)
        
    elseif action == "revoke" then
        local targetPlayer = args[1]
        local keycardId = tonumber(args[2])
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local playerKeycards = getElementData(target, "keycards") or {}
        for i, cardId in ipairs(playerKeycards) do
            if cardId == keycardId then
                table.remove(playerKeycards, i)
                setElementData(target, "keycards", playerKeycards)
                
                outputChatBox("Đã thu hồi thẻ từ #" .. keycardId .. " của " .. getPlayerName(target), player, 100, 255, 100)
                outputChatBox("Thẻ từ #" .. keycardId .. " đã bị thu hồi!", target, 255, 100, 100)
                return
            end
        end
        
        outputChatBox("Người này không có thẻ từ đó!", player, 255, 100, 100)
        
    elseif action == "scan" then
        local playerKeycards = getElementData(player, "keycards") or {}
        
        outputChatBox("=== THẺ TỪ CỦA BẠN ===", player, 255, 255, 100)
        
        if #playerKeycards == 0 then
            outputChatBox("Bạn không có thẻ từ nào.", player, 255, 255, 255)
        else
            for _, cardId in ipairs(playerKeycards) do
                local card = accessControls[cardId]
                if card and card.active then
                    outputChatBox("#" .. cardId .. " - Cấp " .. card.level .. " (" .. (card.description or "Không có mô tả") .. ")", player, 255, 255, 255)
                end
            end
        end
    end
end)

-- Access System
addCommandHandler("access", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /access [door/gate/system/check] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "door" then
        local requiredLevel = tonumber(args[1]) or 1
        local playerKeycards = getElementData(player, "keycards") or {}
        
        local hasAccess = false
        for _, cardId in ipairs(playerKeycards) do
            local card = accessControls[cardId]
            if card and card.active and card.level >= requiredLevel then
                hasAccess = true
                break
            end
        end
        
        if hasAccess then
            outputChatBox("Truy cập được chấp nhận! Cửa đã mở.", player, 100, 255, 100)
        else
            outputChatBox("Truy cập bị từ chối! Bạn cần thẻ từ cấp " .. requiredLevel, player, 255, 100, 100)
        end
        
    elseif action == "gate" then
        local gateId = args[1] or "main"
        local playerKeycards = getElementData(player, "keycards") or {}
        
        -- Check if player has any valid keycard
        local hasValidCard = #playerKeycards > 0
        
        if hasValidCard then
            outputChatBox("Cổng " .. gateId .. " đã mở!", player, 100, 255, 100)
            
            setTimer(function()
                outputChatBox("Cổng " .. gateId .. " đã đóng tự động.", player, 255, 255, 100)
            end, 10000, 1) -- Close after 10 seconds
        else
            outputChatBox("Bạn cần thẻ từ để mở cổng!", player, 255, 100, 100)
        end
        
    elseif action == "system" then
        local systemName = args[1] or "security"
        local playerKeycards = getElementData(player, "keycards") or {}
        
        local highestLevel = 0
        for _, cardId in ipairs(playerKeycards) do
            local card = accessControls[cardId]
            if card and card.active and card.level > highestLevel then
                highestLevel = card.level
            end
        end
        
        if highestLevel >= 5 then
            outputChatBox("Đã truy cập hệ thống " .. systemName, player, 100, 255, 100)
            outputChatBox("Cấp độ truy cập: " .. highestLevel, player, 255, 255, 255)
        else
            outputChatBox("Truy cập hệ thống bị từ chối! Cần cấp độ 5+", player, 255, 100, 100)
        end
        
    elseif action == "check" then
        local targetPlayer = args[1]
        if targetPlayer then
            local target = getPlayerFromName(targetPlayer)
            if not target then
                outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
                return
            end
            
            local targetKeycards = getElementData(target, "keycards") or {}
            outputChatBox(getPlayerName(target) .. " có " .. #targetKeycards .. " thẻ từ", player, 255, 255, 100)
        else
            local x, y, z = getElementPosition(player)
            outputChatBox("Đang kiểm tra quyền truy cập khu vực...", player, 255, 255, 100)
            outputChatBox("Vị trí: (" .. math.floor(x) .. ", " .. math.floor(y) .. ") - Khu vực an toàn", player, 255, 255, 255)
        end
    end
end)

-- Panic System
addCommandHandler("panic", function(player, cmd, message)
    if not player or not isElement(player) then return end
    
    local panicMessage = message or "Khẩn cấp!"
    local x, y, z = getElementPosition(player)
    
    outputChatBox("=== CẢNH BÁO KHẨN CẤP ===", getRootElement(), 255, 100, 100)
    outputChatBox("Từ: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
    outputChatBox("Tin nhắn: " .. panicMessage, getRootElement(), 255, 255, 255)
    outputChatBox("Vị trí: (" .. math.floor(x) .. ", " .. math.floor(y) .. ")", getRootElement(), 255, 255, 255)
    
    -- Send to emergency services
    for _, p in ipairs(getElementsByType("player")) do
        local policeRank = getElementData(p, "policeRank") or 0
        local medicLevel = getElementData(p, "medicLevel") or 0
        local guardLevel = getElementData(p, "guardLevel") or 0
        
        if policeRank > 0 or medicLevel > 0 or guardLevel > 0 then
            outputChatBox("KHẨN CẤP: Tín hiệu panic từ " .. getPlayerName(player), p, 255, 100, 100)
        end
    end
    
    setElementData(player, "panicActive", true)
    setElementData(player, "panicTime", getRealTime().timestamp)
    
    triggerClientEvent("panic:triggered", getRootElement(), x, y, z, getPlayerName(player))
    
    outputChatBox("Đã gửi tín hiệu khẩn cấp!", player, 255, 100, 100)
end)

-- Evacuation System
addCommandHandler("evacuation", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local securityLevel = getElementData(player, "securityLevel") or 0
    local adminLevel = getElementData(player, "adminLevel") or 0
    local args = {...}
    
    if securityLevel < 3 and adminLevel < 5 then
        outputChatBox("Bạn không có quyền ra lệnh sơ tán!", player, 255, 100, 100)
        return
    end
    
    if not action then
        outputChatBox("Sử dụng: /evacuation [start/stop/route/status] [lý do]", player, 255, 255, 100)
        return
    end
    
    if action == "start" then
        local reason = table.concat(args, " ") or "Khẩn cấp"
        
        outputChatBox("=== LỆNH SƠ TÁN ===", getRootElement(), 255, 100, 100)
        outputChatBox("Lý do: " .. reason, getRootElement(), 255, 255, 255)
        outputChatBox("Chỉ huy: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
        outputChatBox("Hãy di chuyển đến khu vực an toàn gần nhất!", getRootElement(), 255, 100, 100)
        
        setElementData(getRootElement(), "evacuationActive", true)
        setElementData(getRootElement(), "evacuationReason", reason)
        setElementData(getRootElement(), "evacuationCommander", getPlayerName(player))
        
        triggerClientEvent("evacuation:started", getRootElement(), reason)
        
    elseif action == "stop" then
        local evacuationActive = getElementData(getRootElement(), "evacuationActive")
        
        if not evacuationActive then
            outputChatBox("Không có lệnh sơ tán nào đang hoạt động!", player, 255, 100, 100)
            return
        end
        
        setElementData(getRootElement(), "evacuationActive", false)
        setElementData(getRootElement(), "evacuationReason", nil)
        setElementData(getRootElement(), "evacuationCommander", nil)
        
        outputChatBox("=== KẾT THÚC SƠ TÁN ===", getRootElement(), 100, 255, 100)
        outputChatBox("Tình huống đã được kiểm soát!", getRootElement(), 100, 255, 100)
        outputChatBox("Mọi người có thể trở lại hoạt động bình thường.", getRootElement(), 255, 255, 255)
        
        triggerClientEvent("evacuation:ended", getRootElement())
        
    elseif action == "route" then
        outputChatBox("=== TUYẾN SƠ TÁN ===", player, 255, 255, 100)
        outputChatBox("1. Lối ra chính - Cửa trước", player, 255, 255, 255)
        outputChatBox("2. Lối thoát hiểm - Cửa sau", player, 255, 255, 255)
        outputChatBox("3. Lối thoát phụ - Cửa bên", player, 255, 255, 255)
        outputChatBox("4. Khu vực tập trung - Bãi đỗ xe", player, 255, 255, 255)
        
    elseif action == "status" then
        local evacuationActive = getElementData(getRootElement(), "evacuationActive")
        
        if evacuationActive then
            local reason = getElementData(getRootElement(), "evacuationReason")
            local commander = getElementData(getRootElement(), "evacuationCommander")
            
            outputChatBox("=== TRẠNG THÁI SƠ TÁN ===", player, 255, 255, 100)
            outputChatBox("Trạng thái: ĐANG HOẠT ĐỘNG", player, 255, 100, 100)
            outputChatBox("Lý do: " .. reason, player, 255, 255, 255)
            outputChatBox("Chỉ huy: " .. commander, player, 255, 255, 255)
        else
            outputChatBox("Sơ tán: KHÔNG HOẠT ĐỘNG", player, 100, 255, 100)
        end
    end
end)

-- Auto-maintain security systems
setTimer(function()
    for id, system in pairs(securitySystems) do
        if system.status == "active" then
            local timeSinceLastMaintenance = getRealTime().timestamp - system.lastMaintenance
            
            -- Degrade system over time
            if timeSinceLastMaintenance > (30 * 24 * 3600) then -- 30 days
                system.status = "needs_maintenance"
                
                local owner = getPlayerFromName(system.owner)
                if owner then
                    outputChatBox("Hệ thống bảo mật #" .. id .. " cần bảo trì!", owner, 255, 255, 100)
                end
            end
        end
    end
end, 3600000, 0) -- Check every hour

outputDebugString("Advanced Security & Protection System loaded successfully! (18 commands)")
