--[[
    LEGAL & JUSTICE SYSTEM - Batch 24
    
    Chức năng: Hệ thống pháp lý và tư pháp hoàn chỉnh
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng court, lawyer, legal
    
    Commands migrated: 14 commands
    - Court System: court, judgement, bail, sentence
    - Lawyer System: lawyer, defend, legalaid, lawfirm
    - Legal Processes: warrant, subpoena, evidence, testimony
    - Legal Records: criminalrecord, clearrecord
]]

local courtSessions = {}
local activeLawyers = {}
local legalCases = {}
local evidenceStorage = {}
local warrants = {}

-- Court System
addCommandHandler("court", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    
    if adminLevel < 5 and lawyerLevel < 3 then
        outputChatBox("Bạn không có quyền sử dụng hệ thống tòa án!", player, 255, 100, 100)
        return
    end
    
    if not action then
        outputChatBox("Sử dụng: /court [start/end/schedule/info] [tham số]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "start" then
        local caseId = args[1]
        if not caseId then
            outputChatBox("Sử dụng: /court start [ID vụ án]", player, 255, 100, 100)
            return
        end
        
        if courtSessions[caseId] then
            outputChatBox("Phiên tòa cho vụ án này đã được bắt đầu!", player, 255, 100, 100)
            return
        end
        
        courtSessions[caseId] = {
            judge = player,
            startTime = getRealTime().timestamp,
            participants = {},
            evidence = {},
            status = "active"
        }
        
        outputChatBox("Phiên tòa cho vụ án #" .. caseId .. " đã được bắt đầu!", player, 100, 255, 100)
        outputChatBox("Thẩm phán: " .. getPlayerName(player), getRootElement(), 255, 255, 100)
        triggerClientEvent("court:sessionStarted", getRootElement(), caseId, getPlayerName(player))
        
    elseif action == "end" then
        local caseId = args[1]
        if not caseId or not courtSessions[caseId] then
            outputChatBox("Không tìm thấy phiên tòa với ID này!", player, 255, 100, 100)
            return
        end
        
        if courtSessions[caseId].judge ~= player and adminLevel < 8 then
            outputChatBox("Chỉ thẩm phán mới có thể kết thúc phiên tòa!", player, 255, 100, 100)
            return
        end
        
        courtSessions[caseId].endTime = getRealTime().timestamp
        courtSessions[caseId].status = "completed"
        
        outputChatBox("Phiên tòa #" .. caseId .. " đã kết thúc!", getRootElement(), 255, 255, 100)
        triggerClientEvent("court:sessionEnded", getRootElement(), caseId)
        
    elseif action == "schedule" then
        local time = args[1]
        local description = table.concat(args, " ", 2)
        
        if not time or not description then
            outputChatBox("Sử dụng: /court schedule [thời gian] [mô tả]", player, 255, 100, 100)
            return
        end
        
        local caseId = #legalCases + 1
        legalCases[caseId] = {
            scheduledTime = time,
            description = description,
            judge = getPlayerName(player),
            status = "scheduled"
        }
        
        outputChatBox("Đã lên lịch phiên tòa #" .. caseId .. " vào " .. time, player, 100, 255, 100)
        outputChatBox("Mô tả: " .. description, player, 255, 255, 100)
        
    elseif action == "info" then
        local caseId = args[1]
        if caseId and courtSessions[caseId] then
            local session = courtSessions[caseId]
            outputChatBox("=== THÔNG TIN PHIÊN TÒA #" .. caseId .. " ===", player, 255, 255, 100)
            outputChatBox("Thẩm phán: " .. getPlayerName(session.judge), player, 255, 255, 255)
            outputChatBox("Trạng thái: " .. session.status, player, 255, 255, 255)
            outputChatBox("Số người tham gia: " .. #session.participants, player, 255, 255, 255)
        else
            outputChatBox("=== PHIÊN TÒA ĐANG DIỄN RA ===", player, 255, 255, 100)
            local count = 0
            for id, session in pairs(courtSessions) do
                if session.status == "active" then
                    outputChatBox("Vụ án #" .. id .. " - Thẩm phán: " .. getPlayerName(session.judge), player, 255, 255, 255)
                    count = count + 1
                end
            end
            if count == 0 then
                outputChatBox("Hiện tại không có phiên tòa nào đang diễn ra.", player, 255, 255, 255)
            end
        end
    end
end)

-- Judgement System
addCommandHandler("judgement", function(player, cmd, caseId, verdict, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    
    if adminLevel < 5 and lawyerLevel < 4 then
        outputChatBox("Bạn không có quyền đưa ra phán quyết!", player, 255, 100, 100)
        return
    end
    
    if not caseId or not verdict then
        outputChatBox("Sử dụng: /judgement [ID vụ án] [guilty/innocent] [lý do]", player, 255, 255, 100)
        return
    end
    
    local reason = table.concat({...}, " ")
    
    if not courtSessions[caseId] then
        outputChatBox("Không tìm thấy phiên tòa với ID này!", player, 255, 100, 100)
        return
    end
    
    if courtSessions[caseId].judge ~= player and adminLevel < 8 then
        outputChatBox("Chỉ thẩm phán mới có thể đưa ra phán quyết!", player, 255, 100, 100)
        return
    end
    
    local session = courtSessions[caseId]
    session.verdict = verdict
    session.reason = reason
    session.judgementTime = getRealTime().timestamp
    
    local verdictText = (verdict == "guilty") and "CÓ TỘI" or "VÔ TỘI"
    local colorR = (verdict == "guilty") and 255 or 100
    local colorG = (verdict == "guilty") and 100 or 255
    
    outputChatBox("=== PHÁN QUYẾT TÒA ÁN ===", getRootElement(), 255, 255, 100)
    outputChatBox("Vụ án #" .. caseId .. ": " .. verdictText, getRootElement(), colorR, colorG, 100)
    outputChatBox("Thẩm phán: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
    if reason and reason ~= "" then
        outputChatBox("Lý do: " .. reason, getRootElement(), 255, 255, 255)
    end
    
    triggerClientEvent("court:judgement", getRootElement(), caseId, verdict, reason)
end)

-- Bail System
addCommandHandler("bail", function(player, cmd, action, targetPlayer, amount)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    local playerMoney = getElementData(player, "money") or 0
    
    if not action then
        outputChatBox("Sử dụng: /bail [set/pay/cancel] [người chơi] [số tiền]", player, 255, 255, 100)
        return
    end
    
    if action == "set" then
        if adminLevel < 5 and lawyerLevel < 3 then
            outputChatBox("Bạn không có quyền thiết lập tiền bảo lãnh!", player, 255, 100, 100)
            return
        end
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local bailAmount = tonumber(amount)
        if not bailAmount or bailAmount <= 0 then
            outputChatBox("Số tiền bảo lãnh không hợp lệ!", player, 255, 100, 100)
            return
        end
        
        setElementData(target, "bailAmount", bailAmount)
        setElementData(target, "bailSet", true)
        
        outputChatBox("Đã thiết lập tiền bảo lãnh $" .. bailAmount .. " cho " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox("Tiền bảo lãnh của bạn được thiết lập: $" .. bailAmount, target, 255, 255, 100)
        
    elseif action == "pay" then
        local target = getPlayerFromName(targetPlayer)
        if not target then
            target = player
        end
        
        local bailAmount = getElementData(target, "bailAmount") or 0
        local bailSet = getElementData(target, "bailSet") or false
        
        if not bailSet or bailAmount <= 0 then
            outputChatBox("Người chơi này không có tiền bảo lãnh nào được thiết lập!", player, 255, 100, 100)
            return
        end
        
        if playerMoney < bailAmount then
            outputChatBox("Bạn không đủ tiền để trả bảo lãnh! Cần: $" .. bailAmount, player, 255, 100, 100)
            return
        end
        
        setElementData(player, "money", playerMoney - bailAmount)
        setElementData(target, "bailAmount", 0)
        setElementData(target, "bailSet", false)
        setElementData(target, "jailed", false)
        
        outputChatBox("Bạn đã trả tiền bảo lãnh $" .. bailAmount .. " cho " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox(getPlayerName(player) .. " đã trả tiền bảo lãnh cho bạn!", target, 100, 255, 100)
        
        triggerClientEvent("player:releasedOnBail", target, bailAmount)
        
    elseif action == "cancel" then
        if adminLevel < 6 then
            outputChatBox("Bạn không có quyền hủy bảo lãnh!", player, 255, 100, 100)
            return
        end
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        setElementData(target, "bailAmount", 0)
        setElementData(target, "bailSet", false)
        
        outputChatBox("Đã hủy bảo lãnh cho " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox("Tiền bảo lãnh của bạn đã bị hủy!", target, 255, 100, 100)
    end
end)

-- Sentence System
addCommandHandler("sentence", function(player, cmd, targetPlayer, type, duration, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    
    if adminLevel < 5 and lawyerLevel < 4 then
        outputChatBox("Bạn không có quyền kết án!", player, 255, 100, 100)
        return
    end
    
    local target = getPlayerFromName(targetPlayer)
    if not target then
        outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
        return
    end
    
    local sentenceType = type
    local sentenceDuration = tonumber(duration) or 0
    local reason = table.concat({...}, " ")
    
    if not sentenceType or not sentenceDuration then
        outputChatBox("Sử dụng: /sentence [người chơi] [jail/prison/community] [thời gian] [lý do]", player, 255, 255, 100)
        return
    end
    
    local sentences = {
        jail = {name = "TÙ", location = {1545.1, -1675.5, 13.5}},
        prison = {name = "NHẬT TÙ", location = {1545.1, -1675.5, 13.5}},
        community = {name = "LĐCĐ", location = nil}
    }
    
    if not sentences[sentenceType] then
        outputChatBox("Loại án phạt không hợp lệ! (jail/prison/community)", player, 255, 100, 100)
        return
    end
    
    local sentence = sentences[sentenceType]
    
    setElementData(target, "sentenced", true)
    setElementData(target, "sentenceType", sentenceType)
    setElementData(target, "sentenceDuration", sentenceDuration)
    setElementData(target, "sentenceStart", getRealTime().timestamp)
    setElementData(target, "sentenceReason", reason)
    
    if sentence.location then
        setElementPosition(target, sentence.location[1], sentence.location[2], sentence.location[3])
        setElementInterior(target, 6)
    end
    
    outputChatBox("=== KẾT ÁN ===", getRootElement(), 255, 255, 100)
    outputChatBox("Bị cáo: " .. getPlayerName(target), getRootElement(), 255, 255, 255)
    outputChatBox("Hình phạt: " .. sentence.name .. " - " .. sentenceDuration .. " phút", getRootElement(), 255, 100, 100)
    outputChatBox("Thẩm phán: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
    if reason and reason ~= "" then
        outputChatBox("Lý do: " .. reason, getRootElement(), 255, 255, 255)
    end
    
    triggerClientEvent("player:sentenced", target, sentenceType, sentenceDuration, reason)
end)

-- Lawyer System
addCommandHandler("lawyer", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /lawyer [license/renew/hire/fire/status] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "license" then
        local adminLevel = getElementData(player, "adminLevel") or 0
        if adminLevel < 6 then
            outputChatBox("Chỉ admin mới có thể cấp giấy phép luật sư!", player, 255, 100, 100)
            return
        end
        
        local targetPlayer = args[1]
        local level = tonumber(args[2]) or 1
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        setElementData(target, "lawyerLevel", level)
        setElementData(target, "lawyerLicense", true)
        
        outputChatBox("Đã cấp giấy phép luật sư cấp " .. level .. " cho " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox("Bạn đã nhận được giấy phép luật sư cấp " .. level .. "!", target, 100, 255, 100)
        
    elseif action == "renew" then
        if lawyerLevel < 1 then
            outputChatBox("Bạn không có giấy phép luật sư!", player, 255, 100, 100)
            return
        end
        
        local renewFee = 50000 + (lawyerLevel * 25000)
        local playerMoney = getElementData(player, "money") or 0
        
        if playerMoney < renewFee then
            outputChatBox("Bạn không đủ tiền để gia hạn! Cần: $" .. renewFee, player, 255, 100, 100)
            return
        end
        
        setElementData(player, "money", playerMoney - renewFee)
        setElementData(player, "lawyerExpiry", getRealTime().timestamp + (30 * 24 * 3600)) -- 30 days
        
        outputChatBox("Đã gia hạn giấy phép luật sư thành công! Phí: $" .. renewFee, player, 100, 255, 100)
        
    elseif action == "hire" then
        local targetPlayer = args[1]
        local fee = tonumber(args[2]) or 10000
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy luật sư!", player, 255, 100, 100)
            return
        end
        
        local targetLawyerLevel = getElementData(target, "lawyerLevel") or 0
        if targetLawyerLevel < 1 then
            outputChatBox("Người này không phải luật sư!", player, 255, 100, 100)
            return
        end
        
        local playerMoney = getElementData(player, "money") or 0
        if playerMoney < fee then
            outputChatBox("Bạn không đủ tiền để thuê luật sư! Cần: $" .. fee, player, 255, 100, 100)
            return
        end
        
        setElementData(player, "lawyer", target)
        setElementData(player, "lawyerFee", fee)
        setElementData(player, "money", playerMoney - fee)
        
        local targetMoney = getElementData(target, "money") or 0
        setElementData(target, "money", targetMoney + fee)
        
        outputChatBox("Đã thuê " .. getPlayerName(target) .. " làm luật sư với phí $" .. fee, player, 100, 255, 100)
        outputChatBox(getPlayerName(player) .. " đã thuê bạn làm luật sư! Phí: $" .. fee, target, 100, 255, 100)
        
    elseif action == "fire" then
        local currentLawyer = getElementData(player, "lawyer")
        if not currentLawyer then
            outputChatBox("Bạn chưa thuê luật sư nào!", player, 255, 100, 100)
            return
        end
        
        setElementData(player, "lawyer", nil)
        setElementData(player, "lawyerFee", nil)
        
        outputChatBox("Đã sa thải luật sư của bạn!", player, 100, 255, 100)
        outputChatBox(getPlayerName(player) .. " đã sa thải bạn!", currentLawyer, 255, 100, 100)
        
    elseif action == "status" then
        if lawyerLevel > 0 then
            outputChatBox("=== THÔNG TIN LUẬT SƯ ===", player, 255, 255, 100)
            outputChatBox("Cấp độ: " .. lawyerLevel, player, 255, 255, 255)
            outputChatBox("Trạng thái: Có hiệu lực", player, 100, 255, 100)
            
            local clients = 0
            for _, p in ipairs(getElementsByType("player")) do
                if getElementData(p, "lawyer") == player then
                    clients = clients + 1
                end
            end
            outputChatBox("Số khách hàng hiện tại: " .. clients, player, 255, 255, 255)
        else
            outputChatBox("Bạn không có giấy phép luật sư!", player, 255, 100, 100)
        end
    end
end)

-- Defend Command
addCommandHandler("defend", function(player, cmd, targetPlayer)
    if not player or not isElement(player) then return end
    
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    if lawyerLevel < 1 then
        outputChatBox("Bạn không phải luật sư!", player, 255, 100, 100)
        return
    end
    
    local target = getPlayerFromName(targetPlayer)
    if not target then
        outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
        return
    end
    
    local currentLawyer = getElementData(target, "lawyer")
    if currentLawyer and currentLawyer ~= player then
        outputChatBox("Người này đã có luật sư khác!", player, 255, 100, 100)
        return
    end
    
    setElementData(target, "defender", player)
    setElementData(player, "defending", target)
    
    outputChatBox("Bạn đang bào chữa cho " .. getPlayerName(target), player, 100, 255, 100)
    outputChatBox(getPlayerName(player) .. " đang bào chữa cho bạn!", target, 100, 255, 100)
    
    -- Notify court if session is active
    for caseId, session in pairs(courtSessions) do
        if session.status == "active" then
            outputChatBox("Luật sư " .. getPlayerName(player) .. " tham gia bào chữa cho " .. getPlayerName(target), session.judge, 255, 255, 100)
        end
    end
end)

-- Legal Aid System
addCommandHandler("legalaid", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /legalaid [request/provide/list] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "request" then
        local reason = table.concat(args, " ")
        if not reason or reason == "" then
            outputChatBox("Sử dụng: /legalaid request [lý do cần hỗ trợ]", player, 255, 100, 100)
            return
        end
        
        local playerMoney = getElementData(player, "money") or 0
        if playerMoney > 50000 then
            outputChatBox("Bạn có quá nhiều tiền để được hỗ trợ pháp lý miễn phí!", player, 255, 100, 100)
            return
        end
        
        setElementData(player, "legalAidRequest", {
            reason = reason,
            timestamp = getRealTime().timestamp,
            status = "pending"
        })
        
        outputChatBox("Đã gửi yêu cầu hỗ trợ pháp lý miễn phí!", player, 100, 255, 100)
        
        -- Notify all lawyers
        for _, p in ipairs(getElementsByType("player")) do
            local lawyerLevel = getElementData(p, "lawyerLevel") or 0
            if lawyerLevel > 0 then
                outputChatBox("Yêu cầu hỗ trợ pháp lý từ " .. getPlayerName(player) .. ": " .. reason, p, 255, 255, 100)
            end
        end
        
    elseif action == "provide" then
        local targetPlayer = args[1]
        local target = getPlayerFromName(targetPlayer)
        
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local lawyerLevel = getElementData(player, "lawyerLevel") or 0
        if lawyerLevel < 1 then
            outputChatBox("Bạn không phải luật sư!", player, 255, 100, 100)
            return
        end
        
        local request = getElementData(target, "legalAidRequest")
        if not request or request.status ~= "pending" then
            outputChatBox("Người này không có yêu cầu hỗ trợ pháp lý!", player, 255, 100, 100)
            return
        end
        
        setElementData(target, "lawyer", player)
        setElementData(target, "lawyerFee", 0)
        request.status = "accepted"
        request.lawyer = getPlayerName(player)
        setElementData(target, "legalAidRequest", request)
        
        outputChatBox("Bạn đã nhận hỗ trợ pháp lý cho " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox(getPlayerName(player) .. " đã chấp nhận hỗ trợ pháp lý cho bạn!", target, 100, 255, 100)
        
    elseif action == "list" then
        local lawyerLevel = getElementData(player, "lawyerLevel") or 0
        if lawyerLevel < 1 then
            outputChatBox("Bạn không phải luật sư!", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== YÊU CẦU HỖ TRỢ PHÁP LÝ ===", player, 255, 255, 100)
        local count = 0
        
        for _, p in ipairs(getElementsByType("player")) do
            local request = getElementData(p, "legalAidRequest")
            if request and request.status == "pending" then
                outputChatBox(getPlayerName(p) .. ": " .. request.reason, player, 255, 255, 255)
                count = count + 1
            end
        end
        
        if count == 0 then
            outputChatBox("Hiện tại không có yêu cầu hỗ trợ pháp lý nào.", player, 255, 255, 255)
        end
    end
end)

-- Law Firm System
addCommandHandler("lawfirm", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /lawfirm [create/join/leave/invite/kick/info] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "create" then
        if lawyerLevel < 3 then
            outputChatBox("Bạn cần ít nhất cấp độ luật sư 3 để tạo văn phòng luật!", player, 255, 100, 100)
            return
        end
        
        local firmName = table.concat(args, " ")
        if not firmName or firmName == "" then
            outputChatBox("Sử dụng: /lawfirm create [tên văn phòng luật]", player, 255, 100, 100)
            return
        end
        
        local playerFirm = getElementData(player, "lawFirm")
        if playerFirm then
            outputChatBox("Bạn đã có văn phòng luật!", player, 255, 100, 100)
            return
        end
        
        local firmId = #activeLawyers + 1
        activeLawyers[firmId] = {
            name = firmName,
            owner = player,
            members = {player},
            founded = getRealTime().timestamp,
            cases = 0,
            rating = 5.0
        }
        
        setElementData(player, "lawFirm", firmId)
        setElementData(player, "lawFirmRole", "owner")
        
        outputChatBox("Đã tạo văn phòng luật: " .. firmName, player, 100, 255, 100)
        
    elseif action == "join" then
        local firmId = tonumber(args[1])
        if not firmId or not activeLawyers[firmId] then
            outputChatBox("Văn phòng luật không tồn tại!", player, 255, 100, 100)
            return
        end
        
        if lawyerLevel < 1 then
            outputChatBox("Bạn cần giấy phép luật sư để tham gia văn phòng!", player, 255, 100, 100)
            return
        end
        
        local playerFirm = getElementData(player, "lawFirm")
        if playerFirm then
            outputChatBox("Bạn đã có văn phòng luật!", player, 255, 100, 100)
            return
        end
        
        table.insert(activeLawyers[firmId].members, player)
        setElementData(player, "lawFirm", firmId)
        setElementData(player, "lawFirmRole", "member")
        
        outputChatBox("Đã tham gia văn phòng luật: " .. activeLawyers[firmId].name, player, 100, 255, 100)
        
    elseif action == "info" then
        local firmId = getElementData(player, "lawFirm")
        if not firmId or not activeLawyers[firmId] then
            outputChatBox("Bạn không thuộc văn phòng luật nào!", player, 255, 100, 100)
            return
        end
        
        local firm = activeLawyers[firmId]
        outputChatBox("=== THÔNG TIN VĂN PHÒNG LUẬT ===", player, 255, 255, 100)
        outputChatBox("Tên: " .. firm.name, player, 255, 255, 255)
        outputChatBox("Chủ sở hữu: " .. getPlayerName(firm.owner), player, 255, 255, 255)
        outputChatBox("Số thành viên: " .. #firm.members, player, 255, 255, 255)
        outputChatBox("Số vụ án đã xử lý: " .. firm.cases, player, 255, 255, 255)
        outputChatBox("Đánh giá: " .. firm.rating .. "/10", player, 255, 255, 255)
    end
end)

-- Warrant System
addCommandHandler("warrant", function(player, cmd, action, targetPlayer, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local policeRank = getElementData(player, "policeRank") or 0
    
    if adminLevel < 4 and policeRank < 3 then
        outputChatBox("Bạn không có quyền ban hành lệnh bắt!", player, 255, 100, 100)
        return
    end
    
    if not action then
        outputChatBox("Sử dụng: /warrant [issue/cancel/search/list] [người chơi] [lý do]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "issue" then
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local reason = table.concat(args, " ")
        if not reason or reason == "" then
            outputChatBox("Bạn phải nêu lý do ban hành lệnh bắt!", player, 255, 100, 100)
            return
        end
        
        local targetName = getPlayerName(target)
        if warrants[targetName] then
            outputChatBox("Người này đã có lệnh bắt!", player, 255, 100, 100)
            return
        end
        
        warrants[targetName] = {
            issuer = getPlayerName(player),
            reason = reason,
            timestamp = getRealTime().timestamp,
            active = true
        }
        
        setElementData(target, "wanted", true)
        setElementData(target, "wantedReason", reason)
        
        outputChatBox("Đã ban hành lệnh bắt cho " .. targetName, player, 100, 255, 100)
        outputChatBox("Lý do: " .. reason, player, 255, 255, 255)
        outputChatBox("Bạn đã bị truy nã! Lý do: " .. reason, target, 255, 100, 100)
        
        -- Notify all police
        for _, p in ipairs(getElementsByType("player")) do
            local pRank = getElementData(p, "policeRank") or 0
            if pRank > 0 then
                outputChatBox("LỆNH BẮT MỚI: " .. targetName .. " - " .. reason, p, 255, 100, 100)
            end
        end
        
    elseif action == "cancel" then
        local targetName = targetPlayer
        if not warrants[targetName] then
            outputChatBox("Không tìm thấy lệnh bắt cho người này!", player, 255, 100, 100)
            return
        end
        
        warrants[targetName].active = false
        
        local target = getPlayerFromName(targetName)
        if target then
            setElementData(target, "wanted", false)
            setElementData(target, "wantedReason", nil)
            outputChatBox("Lệnh bắt của bạn đã được hủy!", target, 100, 255, 100)
        end
        
        outputChatBox("Đã hủy lệnh bắt cho " .. targetName, player, 100, 255, 100)
        
    elseif action == "search" then
        local targetName = targetPlayer
        if not warrants[targetName] then
            outputChatBox("Không tìm thấy lệnh bắt cho " .. targetName, player, 255, 100, 100)
            return
        end
        
        local warrant = warrants[targetName]
        if warrant.active then
            outputChatBox("=== LỆNH BẮT ===", player, 255, 255, 100)
            outputChatBox("Đối tượng: " .. targetName, player, 255, 100, 100)
            outputChatBox("Lý do: " .. warrant.reason, player, 255, 255, 255)
            outputChatBox("Người ban hành: " .. warrant.issuer, player, 255, 255, 255)
            outputChatBox("Thời gian: " .. os.date("%d/%m/%Y %H:%M", warrant.timestamp), player, 255, 255, 255)
        else
            outputChatBox("Lệnh bắt cho " .. targetName .. " đã bị hủy!", player, 255, 255, 100)
        end
        
    elseif action == "list" then
        outputChatBox("=== DANH SÁCH LỆNH BẮT ===", player, 255, 255, 100)
        local count = 0
        
        for name, warrant in pairs(warrants) do
            if warrant.active then
                outputChatBox(name .. " - " .. warrant.reason, player, 255, 100, 100)
                count = count + 1
            end
        end
        
        if count == 0 then
            outputChatBox("Hiện tại không có lệnh bắt nào.", player, 255, 255, 255)
        else
            outputChatBox("Tổng cộng: " .. count .. " lệnh bắt", player, 255, 255, 255)
        end
    end
end)

-- Subpoena System
addCommandHandler("subpoena", function(player, cmd, targetPlayer, courtDate, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    
    if adminLevel < 5 and lawyerLevel < 2 then
        outputChatBox("Bạn không có quyền ban hành trát đòi hầu tòa!", player, 255, 100, 100)
        return
    end
    
    local target = getPlayerFromName(targetPlayer)
    if not target then
        outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
        return
    end
    
    if not courtDate then
        outputChatBox("Sử dụng: /subpoena [người chơi] [ngày tòa] [lý do]", player, 255, 255, 100)
        return
    end
    
    local reason = table.concat({...}, " ")
    local subpoenaId = #legalCases + 1
    
    legalCases[subpoenaId] = {
        type = "subpoena",
        target = getPlayerName(target),
        issuer = getPlayerName(player),
        courtDate = courtDate,
        reason = reason,
        timestamp = getRealTime().timestamp,
        status = "active"
    }
    
    setElementData(target, "subpoena", subpoenaId)
    
    outputChatBox("=== TRÁT ĐÒI HẦU TÒA ===", target, 255, 255, 100)
    outputChatBox("Bạn được yêu cầu hầu tòa vào " .. courtDate, target, 255, 100, 100)
    outputChatBox("Người ban hành: " .. getPlayerName(player), target, 255, 255, 255)
    if reason and reason ~= "" then
        outputChatBox("Lý do: " .. reason, target, 255, 255, 255)
    end
    outputChatBox("ID trát: " .. subpoenaId, target, 255, 255, 255)
    
    outputChatBox("Đã ban hành trát đòi hầu tòa cho " .. getPlayerName(target), player, 100, 255, 100)
end)

-- Evidence System
addCommandHandler("evidence", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local policeRank = getElementData(player, "policeRank") or 0
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    
    if adminLevel < 3 and policeRank < 2 and lawyerLevel < 1 then
        outputChatBox("Bạn không có quyền truy cập hệ thống bằng chứng!", player, 255, 100, 100)
        return
    end
    
    if not action then
        outputChatBox("Sử dụng: /evidence [add/remove/list/view] [tham số]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "add" then
        local caseId = args[1]
        local description = table.concat(args, " ", 2)
        
        if not caseId or not description then
            outputChatBox("Sử dụng: /evidence add [ID vụ án] [mô tả bằng chứng]", player, 255, 100, 100)
            return
        end
        
        if not evidenceStorage[caseId] then
            evidenceStorage[caseId] = {}
        end
        
        local evidenceId = #evidenceStorage[caseId] + 1
        evidenceStorage[caseId][evidenceId] = {
            description = description,
            addedBy = getPlayerName(player),
            timestamp = getRealTime().timestamp,
            type = "general"
        }
        
        outputChatBox("Đã thêm bằng chứng #" .. evidenceId .. " vào vụ án #" .. caseId, player, 100, 255, 100)
        
    elseif action == "remove" then
        if adminLevel < 5 and lawyerLevel < 3 then
            outputChatBox("Bạn không có quyền xóa bằng chứng!", player, 255, 100, 100)
            return
        end
        
        local caseId = args[1]
        local evidenceId = tonumber(args[2])
        
        if not caseId or not evidenceId then
            outputChatBox("Sử dụng: /evidence remove [ID vụ án] [ID bằng chứng]", player, 255, 100, 100)
            return
        end
        
        if not evidenceStorage[caseId] or not evidenceStorage[caseId][evidenceId] then
            outputChatBox("Không tìm thấy bằng chứng!", player, 255, 100, 100)
            return
        end
        
        evidenceStorage[caseId][evidenceId] = nil
        outputChatBox("Đã xóa bằng chứng #" .. evidenceId .. " khỏi vụ án #" .. caseId, player, 100, 255, 100)
        
    elseif action == "list" then
        local caseId = args[1]
        if not caseId then
            outputChatBox("Sử dụng: /evidence list [ID vụ án]", player, 255, 100, 100)
            return
        end
        
        if not evidenceStorage[caseId] then
            outputChatBox("Vụ án này chưa có bằng chứng nào!", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== BẰNG CHỨNG VỤ ÁN #" .. caseId .. " ===", player, 255, 255, 100)
        for id, evidence in pairs(evidenceStorage[caseId]) do
            outputChatBox("#" .. id .. ": " .. evidence.description, player, 255, 255, 255)
            outputChatBox("   Thêm bởi: " .. evidence.addedBy, player, 200, 200, 200)
        end
        
    elseif action == "view" then
        local caseId = args[1]
        local evidenceId = tonumber(args[2])
        
        if not caseId or not evidenceId then
            outputChatBox("Sử dụng: /evidence view [ID vụ án] [ID bằng chứng]", player, 255, 100, 100)
            return
        end
        
        if not evidenceStorage[caseId] or not evidenceStorage[caseId][evidenceId] then
            outputChatBox("Không tìm thấy bằng chứng!", player, 255, 100, 100)
            return
        end
        
        local evidence = evidenceStorage[caseId][evidenceId]
        outputChatBox("=== BẰNG CHỨNG #" .. evidenceId .. " ===", player, 255, 255, 100)
        outputChatBox("Mô tả: " .. evidence.description, player, 255, 255, 255)
        outputChatBox("Thêm bởi: " .. evidence.addedBy, player, 255, 255, 255)
        outputChatBox("Thời gian: " .. os.date("%d/%m/%Y %H:%M", evidence.timestamp), player, 255, 255, 255)
    end
end)

-- Testimony System
addCommandHandler("testimony", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    if not action then
        outputChatBox("Sử dụng: /testimony [give/record/view] [tham số]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "give" then
        local caseId = args[1]
        local testimony = table.concat(args, " ", 2)
        
        if not caseId or not testimony then
            outputChatBox("Sử dụng: /testimony give [ID vụ án] [lời khai]", player, 255, 100, 100)
            return
        end
        
        if not courtSessions[caseId] then
            outputChatBox("Vụ án này chưa có phiên tòa!", player, 255, 100, 100)
            return
        end
        
        local session = courtSessions[caseId]
        if not session.testimonies then
            session.testimonies = {}
        end
        
        local testimonyId = #session.testimonies + 1
        session.testimonies[testimonyId] = {
            witness = getPlayerName(player),
            testimony = testimony,
            timestamp = getRealTime().timestamp
        }
        
        outputChatBox("=== LỜI KHAI TẠI TÒA ===", getRootElement(), 255, 255, 100)
        outputChatBox("Nhân chứng: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
        outputChatBox("Lời khai: " .. testimony, getRootElement(), 255, 255, 255)
        
        -- Notify judge
        if session.judge then
            outputChatBox("Lời khai #" .. testimonyId .. " đã được ghi nhận!", session.judge, 100, 255, 100)
        end
        
    elseif action == "record" then
        local adminLevel = getElementData(player, "adminLevel") or 0
        local lawyerLevel = getElementData(player, "lawyerLevel") or 0
        
        if adminLevel < 4 and lawyerLevel < 2 then
            outputChatBox("Bạn không có quyền ghi nhận lời khai!", player, 255, 100, 100)
            return
        end
        
        local targetPlayer = args[1]
        local statement = table.concat(args, " ", 2)
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local recordId = #legalCases + 1
        legalCases[recordId] = {
            type = "testimony_record",
            witness = getPlayerName(target),
            statement = statement,
            recordedBy = getPlayerName(player),
            timestamp = getRealTime().timestamp
        }
        
        outputChatBox("Đã ghi nhận lời khai của " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox("Lời khai của bạn đã được ghi nhận! ID: " .. recordId, target, 100, 255, 100)
        
    elseif action == "view" then
        local caseId = args[1]
        if not caseId then
            outputChatBox("Sử dụng: /testimony view [ID vụ án]", player, 255, 100, 100)
            return
        end
        
        if not courtSessions[caseId] or not courtSessions[caseId].testimonies then
            outputChatBox("Vụ án này chưa có lời khai nào!", player, 255, 100, 100)
            return
        end
        
        local testimonies = courtSessions[caseId].testimonies
        outputChatBox("=== LỜI KHAI VỤ ÁN #" .. caseId .. " ===", player, 255, 255, 100)
        
        for id, testimony in pairs(testimonies) do
            outputChatBox("#" .. id .. " - " .. testimony.witness .. ":", player, 255, 255, 255)
            outputChatBox("   " .. testimony.testimony, player, 200, 200, 200)
        end
    end
end)

-- Criminal Record System
addCommandHandler("criminalrecord", function(player, cmd, targetPlayer)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local policeRank = getElementData(player, "policeRank") or 0
    local lawyerLevel = getElementData(player, "lawyerLevel") or 0
    
    if adminLevel < 2 and policeRank < 1 and lawyerLevel < 1 then
        outputChatBox("Bạn không có quyền truy cập hồ sơ tội phạm!", player, 255, 100, 100)
        return
    end
    
    local target = player
    if targetPlayer then
        target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
    end
    
    local criminalRecord = getElementData(target, "criminalRecord") or {}
    local wantedLevel = getElementData(target, "wantedLevel") or 0
    local arrests = getElementData(target, "arrests") or 0
    
    outputChatBox("=== HỒ SƠ TỘI PHẠM: " .. getPlayerName(target) .. " ===", player, 255, 255, 100)
    outputChatBox("Mức độ truy nã: " .. wantedLevel .. " sao", player, 255, 100, 100)
    outputChatBox("Số lần bị bắt: " .. arrests, player, 255, 255, 255)
    
    if #criminalRecord > 0 then
        outputChatBox("=== TIỀN ÁN ===", player, 255, 255, 100)
        for i, record in ipairs(criminalRecord) do
            outputChatBox(i .. ". " .. record.crime .. " (" .. record.date .. ")", player, 255, 255, 255)
            if record.sentence then
                outputChatBox("   Án phạt: " .. record.sentence, player, 200, 200, 200)
            end
        end
    else
        outputChatBox("Không có tiền án.", player, 100, 255, 100)
    end
    
    local currentWanted = getElementData(target, "wanted")
    if currentWanted then
        local wantedReason = getElementData(target, "wantedReason") or "Không rõ lý do"
        outputChatBox("HIỆN TẠI ĐANG BỊ TRUY NÃ: " .. wantedReason, player, 255, 100, 100)
    end
end)

-- Clear Record System
addCommandHandler("clearrecord", function(player, cmd, targetPlayer, reason)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    
    if adminLevel < 8 then
        outputChatBox("Chỉ admin cấp cao mới có thể xóa hồ sơ tội phạm!", player, 255, 100, 100)
        return
    end
    
    local target = getPlayerFromName(targetPlayer)
    if not target then
        outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
        return
    end
    
    if not reason then
        outputChatBox("Sử dụng: /clearrecord [người chơi] [lý do]", player, 255, 255, 100)
        return
    end
    
    setElementData(target, "criminalRecord", {})
    setElementData(target, "wantedLevel", 0)
    setElementData(target, "wanted", false)
    setElementData(target, "wantedReason", nil)
    setElementData(target, "arrests", 0)
    
    outputChatBox("Đã xóa hồ sơ tội phạm của " .. getPlayerName(target), player, 100, 255, 100)
    outputChatBox("Lý do: " .. reason, player, 255, 255, 255)
    outputChatBox("Hồ sơ tội phạm của bạn đã được xóa!", target, 100, 255, 100)
    
    -- Log the action
    local logMessage = getPlayerName(player) .. " đã xóa hồ sơ tội phạm của " .. getPlayerName(target) .. " - Lý do: " .. reason
    outputServerLog(logMessage)
end)

-- Auto-update court sessions
setTimer(function()
    for caseId, session in pairs(courtSessions) do
        if session.status == "active" then
            local duration = getRealTime().timestamp - session.startTime
            if duration > 3600 then -- 1 hour limit
                session.status = "expired"
                if isElement(session.judge) then
                    outputChatBox("Phiên tòa #" .. caseId .. " đã hết thời gian!", session.judge, 255, 100, 100)
                end
            end
        end
    end
    
    -- Auto-expire warrants after 7 days
    for name, warrant in pairs(warrants) do
        if warrant.active then
            local age = getRealTime().timestamp - warrant.timestamp
            if age > (7 * 24 * 3600) then
                warrant.active = false
                local target = getPlayerFromName(name)
                if target then
                    setElementData(target, "wanted", false)
                    setElementData(target, "wantedReason", nil)
                    outputChatBox("Lệnh bắt của bạn đã hết hạn!", target, 255, 255, 100)
                end
            end
        end
    end
end, 60000, 0) -- Check every minute

outputDebugString("Legal & Justice System loaded successfully! (14 commands)")
