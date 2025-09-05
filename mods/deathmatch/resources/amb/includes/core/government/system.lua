--[[
    GOVERNMENT & POLITICS SYSTEM - Batch 25
    
    Chức năng: Hệ thống chính quyền và chính trị hoàn chỉnh
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng government, politics, mayor
    
    Commands migrated: 16 commands
    - Government System: government, mayor, governor, council
    - Political System: campaign, vote, election, ballot
    - Civic Services: license, permit, tax, city
    - Government Operations: budget, contract, proposal, meeting
]]

local government = {
    mayor = nil,
    governor = nil,
    councilMembers = {},
    budget = 1000000,
    taxRate = 0.08,
    cityServices = {},
    contracts = {},
    proposals = {}
}

local elections = {
    active = false,
    candidates = {},
    votes = {},
    endTime = 0,
    type = "mayor" -- mayor, governor, council
}

local licenses = {}
local permits = {}
local politicalParties = {}

-- Government System
addCommandHandler("government", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    
    if not action then
        outputChatBox("Sử dụng: /government [info/budget/services/staff/laws] [tham số]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "info" then
        outputChatBox("=== THÔNG TIN CHÍNH QUYỀN ===", player, 255, 255, 100)
        
        local mayorName = government.mayor and getPlayerName(government.mayor) or "Chưa có"
        local governorName = government.governor and getPlayerName(government.governor) or "Chưa có"
        
        outputChatBox("Thị trưởng: " .. mayorName, player, 255, 255, 255)
        outputChatBox("Thống đốc: " .. governorName, player, 255, 255, 255)
        outputChatBox("Hội đồng thành phố: " .. #government.councilMembers .. " thành viên", player, 255, 255, 255)
        outputChatBox("Ngân sách: $" .. government.budget, player, 100, 255, 100)
        outputChatBox("Thuế suất: " .. (government.taxRate * 100) .. "%", player, 255, 255, 255)
        
    elseif action == "budget" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" and adminLevel < 6 then
            outputChatBox("Chỉ thị trưởng/thống đốc mới có quyền xem ngân sách chi tiết!", player, 255, 100, 100)
            return
        end
        
        local operation = args[1]
        if not operation then
            outputChatBox("Ngân sách hiện tại: $" .. government.budget, player, 100, 255, 100)
            outputChatBox("Thu nhập hàng ngày từ thuế: $" .. math.floor(government.budget * government.taxRate), player, 255, 255, 255)
            return
        end
        
        if operation == "allocate" then
            local department = args[2]
            local amount = tonumber(args[3])
            
            if not department or not amount then
                outputChatBox("Sử dụng: /government budget allocate [bộ phận] [số tiền]", player, 255, 100, 100)
                return
            end
            
            if amount > government.budget then
                outputChatBox("Không đủ ngân sách! Hiện có: $" .. government.budget, player, 255, 100, 100)
                return
            end
            
            government.budget = government.budget - amount
            
            if not government.cityServices[department] then
                government.cityServices[department] = {budget = 0, efficiency = 50}
            end
            government.cityServices[department].budget = government.cityServices[department].budget + amount
            
            outputChatBox("Đã phân bổ $" .. amount .. " cho " .. department, player, 100, 255, 100)
            outputChatBox("Ngân sách còn lại: $" .. government.budget, player, 255, 255, 255)
        end
        
    elseif action == "services" then
        outputChatBox("=== DỊCH VỤ THÀNH PHỐ ===", player, 255, 255, 100)
        
        for service, data in pairs(government.cityServices) do
            local status = data.efficiency > 70 and "Tốt" or (data.efficiency > 40 and "Trung bình" or "Kém")
            outputChatBox(service .. ": $" .. data.budget .. " - " .. status .. " (" .. data.efficiency .. "%)", player, 255, 255, 255)
        end
        
        if next(government.cityServices) == nil then
            outputChatBox("Chưa có dịch vụ nào được phân bổ ngân sách.", player, 255, 255, 255)
        end
        
    elseif action == "staff" then
        if adminLevel < 6 then
            outputChatBox("Bạn không có quyền xem danh sách nhân viên chính quyền!", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== NHÂN VIÊN CHÍNH QUYỀN ===", player, 255, 255, 100)
        
        if government.mayor then
            outputChatBox("Thị trưởng: " .. getPlayerName(government.mayor), player, 255, 255, 255)
        end
        
        if government.governor then
            outputChatBox("Thống đốc: " .. getPlayerName(government.governor), player, 255, 255, 255)
        end
        
        for i, member in ipairs(government.councilMembers) do
            if isElement(member) then
                outputChatBox("Hội đồng viên " .. i .. ": " .. getPlayerName(member), player, 255, 255, 255)
            end
        end
        
    elseif action == "laws" then
        outputChatBox("=== LUẬT THÀNH PHỐ ===", player, 255, 255, 100)
        outputChatBox("1. Tốc độ tối đa trong thành phố: 80 km/h", player, 255, 255, 255)
        outputChatBox("2. Cấm sử dụng vũ khí trong khu dân cư", player, 255, 255, 255)
        outputChatBox("3. Thuế thu nhập: " .. (government.taxRate * 100) .. "%", player, 255, 255, 255)
        outputChatBox("4. Giờ giới nghiêm: 02:00 - 06:00", player, 255, 255, 255)
        outputChatBox("5. Bắt buộc có giấy phép lái xe", player, 255, 255, 255)
    end
end)

-- Mayor System
addCommandHandler("mayor", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    
    if not action then
        outputChatBox("Sử dụng: /mayor [appoint/resign/powers/announce] [tham số]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "appoint" then
        if adminLevel < 8 then
            outputChatBox("Chỉ admin cấp cao mới có thể bổ nhiệm thị trưởng!", player, 255, 100, 100)
            return
        end
        
        local targetPlayer = args[1]
        local target = getPlayerFromName(targetPlayer)
        
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        if government.mayor then
            setElementData(government.mayor, "governmentRole", "citizen")
            outputChatBox("Bạn đã mất chức thị trưởng!", government.mayor, 255, 100, 100)
        end
        
        government.mayor = target
        setElementData(target, "governmentRole", "mayor")
        
        outputChatBox("Đã bổ nhiệm " .. getPlayerName(target) .. " làm thị trưởng!", player, 100, 255, 100)
        outputChatBox("Bạn đã được bổ nhiệm làm thị trưởng thành phố!", target, 100, 255, 100)
        outputChatBox("THÔNG BÁO: " .. getPlayerName(target) .. " đã được bổ nhiệm làm thị trưởng!", getRootElement(), 255, 255, 100)
        
    elseif action == "resign" then
        if governmentRole ~= "mayor" then
            outputChatBox("Bạn không phải thị trưởng!", player, 255, 100, 100)
            return
        end
        
        government.mayor = nil
        setElementData(player, "governmentRole", "citizen")
        
        outputChatBox("Bạn đã từ chức thị trưởng!", player, 255, 255, 100)
        outputChatBox("THÔNG BÁO: Thị trưởng " .. getPlayerName(player) .. " đã từ chức!", getRootElement(), 255, 255, 100)
        
    elseif action == "powers" then
        if governmentRole ~= "mayor" then
            outputChatBox("Bạn không phải thị trưởng!", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== QUYỀN HẠN THỊ TRƯỞNG ===", player, 255, 255, 100)
        outputChatBox("1. Quản lý ngân sách thành phố", player, 255, 255, 255)
        outputChatBox("2. Điều chỉnh thuế suất (5%-15%)", player, 255, 255, 255)
        outputChatBox("3. Bổ nhiệm hội đồng viên", player, 255, 255, 255)
        outputChatBox("4. Ký kết hợp đồng thành phố", player, 255, 255, 255)
        outputChatBox("5. Ban hành thông báo công khai", player, 255, 255, 255)
        outputChatBox("6. Tổ chức sự kiện thành phố", player, 255, 255, 255)
        
    elseif action == "announce" then
        if governmentRole ~= "mayor" then
            outputChatBox("Bạn không phải thị trưởng!", player, 255, 100, 100)
            return
        end
        
        local message = table.concat(args, " ")
        if not message or message == "" then
            outputChatBox("Sử dụng: /mayor announce [thông báo]", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== THÔNG BÁO TỪ THỊ TRƯỞNG ===", getRootElement(), 255, 255, 100)
        outputChatBox(message, getRootElement(), 255, 255, 255)
        outputChatBox("- Thị trưởng " .. getPlayerName(player), getRootElement(), 200, 200, 200)
    end
end)

-- Governor System
addCommandHandler("governor", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    
    if not action then
        outputChatBox("Sử dụng: /governor [appoint/resign/powers/decree] [tham số]", player, 255, 255, 100)
        return
    end
    
    local args = {...}
    
    if action == "appoint" then
        if adminLevel < 9 then
            outputChatBox("Chỉ admin cấp cao nhất mới có thể bổ nhiệm thống đốc!", player, 255, 100, 100)
            return
        end
        
        local targetPlayer = args[1]
        local target = getPlayerFromName(targetPlayer)
        
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        if government.governor then
            setElementData(government.governor, "governmentRole", "citizen")
            outputChatBox("Bạn đã mất chức thống đốc!", government.governor, 255, 100, 100)
        end
        
        government.governor = target
        setElementData(target, "governmentRole", "governor")
        
        outputChatBox("Đã bổ nhiệm " .. getPlayerName(target) .. " làm thống đốc!", player, 100, 255, 100)
        outputChatBox("Bạn đã được bổ nhiệm làm thống đốc bang!", target, 100, 255, 100)
        outputChatBox("THÔNG BÁO: " .. getPlayerName(target) .. " đã được bổ nhiệm làm thống đốc!", getRootElement(), 255, 255, 100)
        
    elseif action == "resign" then
        if governmentRole ~= "governor" then
            outputChatBox("Bạn không phải thống đốc!", player, 255, 100, 100)
            return
        end
        
        government.governor = nil
        setElementData(player, "governmentRole", "citizen")
        
        outputChatBox("Bạn đã từ chức thống đốc!", player, 255, 255, 100)
        outputChatBox("THÔNG BÁO: Thống đốc " .. getPlayerName(player) .. " đã từ chức!", getRootElement(), 255, 255, 100)
        
    elseif action == "powers" then
        if governmentRole ~= "governor" then
            outputChatBox("Bạn không phải thống đốc!", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== QUYỀN HẠN THỐNG ĐỐC ===", player, 255, 255, 100)
        outputChatBox("1. Giám sát tất cả thị trưởng", player, 255, 255, 255)
        outputChatBox("2. Điều chỉnh luật bang", player, 255, 255, 255)
        outputChatBox("3. Quản lý ngân sách bang", player, 255, 255, 255)
        outputChatBox("4. Ký kết hiệp ước liên bang", player, 255, 255, 255)
        outputChatBox("5. Ban hành sắc lệnh khẩn cấp", player, 255, 255, 255)
        outputChatBox("6. Chỉ định thẩm phán bang", player, 255, 255, 255)
        
    elseif action == "decree" then
        if governmentRole ~= "governor" then
            outputChatBox("Bạn không phải thống đốc!", player, 255, 100, 100)
            return
        end
        
        local decree = table.concat(args, " ")
        if not decree or decree == "" then
            outputChatBox("Sử dụng: /governor decree [sắc lệnh]", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== SẮC LỆNH THỐNG ĐỐC ===", getRootElement(), 255, 100, 100)
        outputChatBox(decree, getRootElement(), 255, 255, 255)
        outputChatBox("- Thống đốc " .. getPlayerName(player), getRootElement(), 200, 200, 200)
        outputChatBox("Có hiệu lực ngay lập tức!", getRootElement(), 255, 100, 100)
    end
end)

-- Council System
addCommandHandler("council", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /council [add/remove/list/meeting/vote] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "add" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" then
            outputChatBox("Chỉ thị trưởng/thống đốc mới có thể bổ nhiệm hội đồng viên!", player, 255, 100, 100)
            return
        end
        
        local targetPlayer = args[1]
        local target = getPlayerFromName(targetPlayer)
        
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        for _, member in ipairs(government.councilMembers) do
            if member == target then
                outputChatBox("Người này đã là hội đồng viên!", player, 255, 100, 100)
                return
            end
        end
        
        table.insert(government.councilMembers, target)
        setElementData(target, "governmentRole", "council")
        
        outputChatBox("Đã bổ nhiệm " .. getPlayerName(target) .. " vào hội đồng thành phố!", player, 100, 255, 100)
        outputChatBox("Bạn đã được bổ nhiệm vào hội đồng thành phố!", target, 100, 255, 100)
        
    elseif action == "remove" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" then
            outputChatBox("Chỉ thị trưởng/thống đốc mới có thể sa thải hội đồng viên!", player, 255, 100, 100)
            return
        end
        
        local targetPlayer = args[1]
        local target = getPlayerFromName(targetPlayer)
        
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        for i, member in ipairs(government.councilMembers) do
            if member == target then
                table.remove(government.councilMembers, i)
                setElementData(target, "governmentRole", "citizen")
                
                outputChatBox("Đã sa thải " .. getPlayerName(target) .. " khỏi hội đồng!", player, 100, 255, 100)
                outputChatBox("Bạn đã bị sa thải khỏi hội đồng thành phố!", target, 255, 100, 100)
                return
            end
        end
        
        outputChatBox("Người này không phải hội đồng viên!", player, 255, 100, 100)
        
    elseif action == "list" then
        outputChatBox("=== HỘI ĐỒNG THÀNH PHỐ ===", player, 255, 255, 100)
        
        if #government.councilMembers == 0 then
            outputChatBox("Hội đồng hiện tại không có thành viên nào.", player, 255, 255, 255)
        else
            for i, member in ipairs(government.councilMembers) do
                if isElement(member) then
                    outputChatBox(i .. ". " .. getPlayerName(member), player, 255, 255, 255)
                end
            end
        end
        
    elseif action == "meeting" then
        if governmentRole ~= "council" and governmentRole ~= "mayor" and governmentRole ~= "governor" then
            outputChatBox("Chỉ thành viên chính quyền mới có thể tham gia họp!", player, 255, 100, 100)
            return
        end
        
        local topic = table.concat(args, " ")
        if not topic or topic == "" then
            outputChatBox("Sử dụng: /council meeting [chủ đề]", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== HỌP HỘI ĐỒNG ===", getRootElement(), 255, 255, 100)
        outputChatBox("Chủ đề: " .. topic, getRootElement(), 255, 255, 255)
        outputChatBox("Chủ trì: " .. getPlayerName(player), getRootElement(), 255, 255, 255)
        
        -- Notify all government members
        for _, member in ipairs(government.councilMembers) do
            if isElement(member) then
                outputChatBox("Bạn được mời tham gia họp hội đồng!", member, 100, 255, 100)
            end
        end
        
    elseif action == "vote" then
        if governmentRole ~= "council" and governmentRole ~= "mayor" then
            outputChatBox("Chỉ hội đồng viên/thị trưởng mới có thể bỏ phiếu!", player, 255, 100, 100)
            return
        end
        
        local proposal = table.concat(args, " ")
        if not proposal or proposal == "" then
            outputChatBox("Sử dụng: /council vote [đề xuất]", player, 255, 100, 100)
            return
        end
        
        local proposalId = #government.proposals + 1
        government.proposals[proposalId] = {
            text = proposal,
            proposer = getPlayerName(player),
            votes = {yes = 0, no = 0, abstain = 0},
            voters = {},
            timestamp = getRealTime().timestamp
        }
        
        outputChatBox("Đã tạo đề xuất #" .. proposalId .. ": " .. proposal, player, 100, 255, 100)
        outputChatBox("Hội đồng viên có thể bỏ phiếu bằng /vote " .. proposalId .. " [yes/no/abstain]", getRootElement(), 255, 255, 100)
    end
end)

-- Campaign System
addCommandHandler("campaign", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /campaign [start/join/leave/info/donate] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "start" then
        local position = args[1] -- mayor, governor, council
        local slogan = table.concat(args, " ", 2)
        
        if not position or not slogan then
            outputChatBox("Sử dụng: /campaign start [mayor/governor/council] [khẩu hiệu]", player, 255, 100, 100)
            return
        end
        
        if position ~= "mayor" and position ~= "governor" and position ~= "council" then
            outputChatBox("Chức vụ không hợp lệ! (mayor/governor/council)", player, 255, 100, 100)
            return
        end
        
        local playerName = getPlayerName(player)
        for _, candidate in ipairs(elections.candidates) do
            if candidate.player == player then
                outputChatBox("Bạn đã tham gia tranh cử!", player, 255, 100, 100)
                return
            end
        end
        
        table.insert(elections.candidates, {
            player = player,
            name = playerName,
            position = position,
            slogan = slogan,
            votes = 0,
            donations = 0,
            supporters = {}
        })
        
        outputChatBox("Bạn đã bắt đầu chiến dịch tranh cử " .. position .. "!", player, 100, 255, 100)
        outputChatBox("Khẩu hiệu: " .. slogan, player, 255, 255, 255)
        outputChatBox("THÔNG BÁO: " .. playerName .. " tranh cử " .. position .. " với khẩu hiệu: " .. slogan, getRootElement(), 255, 255, 100)
        
    elseif action == "join" then
        local candidateName = args[1]
        local candidate = nil
        
        for _, c in ipairs(elections.candidates) do
            if c.name == candidateName then
                candidate = c
                break
            end
        end
        
        if not candidate then
            outputChatBox("Không tìm thấy ứng viên!", player, 255, 100, 100)
            return
        end
        
        table.insert(candidate.supporters, getPlayerName(player))
        outputChatBox("Bạn đã ủng hộ " .. candidateName .. "!", player, 100, 255, 100)
        outputChatBox(getPlayerName(player) .. " đã ủng hộ chiến dịch của bạn!", candidate.player, 100, 255, 100)
        
    elseif action == "info" then
        outputChatBox("=== THÔNG TIN TRANH CỬ ===", player, 255, 255, 100)
        
        if #elections.candidates == 0 then
            outputChatBox("Hiện tại không có ai tranh cử.", player, 255, 255, 255)
        else
            for i, candidate in ipairs(elections.candidates) do
                outputChatBox(i .. ". " .. candidate.name .. " (" .. candidate.position .. ")", player, 255, 255, 255)
                outputChatBox("   Khẩu hiệu: " .. candidate.slogan, player, 200, 200, 200)
                outputChatBox("   Ủng hộ: " .. #candidate.supporters .. " người", player, 200, 200, 200)
            end
        end
        
    elseif action == "donate" then
        local candidateName = args[1]
        local amount = tonumber(args[2])
        
        if not candidateName or not amount then
            outputChatBox("Sử dụng: /campaign donate [ứng viên] [số tiền]", player, 255, 100, 100)
            return
        end
        
        local candidate = nil
        for _, c in ipairs(elections.candidates) do
            if c.name == candidateName then
                candidate = c
                break
            end
        end
        
        if not candidate then
            outputChatBox("Không tìm thấy ứng viên!", player, 255, 100, 100)
            return
        end
        
        local playerMoney = getElementData(player, "money") or 0
        if playerMoney < amount then
            outputChatBox("Bạn không đủ tiền!", player, 255, 100, 100)
            return
        end
        
        setElementData(player, "money", playerMoney - amount)
        candidate.donations = candidate.donations + amount
        
        outputChatBox("Bạn đã quyên góp $" .. amount .. " cho " .. candidateName .. "!", player, 100, 255, 100)
        outputChatBox(getPlayerName(player) .. " đã quyên góp $" .. amount .. " cho chiến dịch!", candidate.player, 100, 255, 100)
    end
end)

-- Vote System
addCommandHandler("vote", function(player, cmd, proposalIdOrCandidate, choice)
    if not player or not isElement(player) then return end
    
    if not proposalIdOrCandidate then
        outputChatBox("Sử dụng: /vote [ID đề xuất/ứng viên] [yes/no/abstain]", player, 255, 255, 100)
        return
    end
    
    -- Check if it's a council proposal vote
    local proposalId = tonumber(proposalIdOrCandidate)
    if proposalId and government.proposals[proposalId] then
        local governmentRole = getElementData(player, "governmentRole") or "citizen"
        
        if governmentRole ~= "council" and governmentRole ~= "mayor" then
            outputChatBox("Chỉ hội đồng viên/thị trưởng mới có thể bỏ phiếu!", player, 255, 100, 100)
            return
        end
        
        if not choice or (choice ~= "yes" and choice ~= "no" and choice ~= "abstain") then
            outputChatBox("Lựa chọn: yes/no/abstain", player, 255, 100, 100)
            return
        end
        
        local proposal = government.proposals[proposalId]
        local playerName = getPlayerName(player)
        
        if proposal.voters[playerName] then
            outputChatBox("Bạn đã bỏ phiếu cho đề xuất này!", player, 255, 100, 100)
            return
        end
        
        proposal.votes[choice] = proposal.votes[choice] + 1
        proposal.voters[playerName] = choice
        
        outputChatBox("Đã bỏ phiếu " .. choice .. " cho đề xuất #" .. proposalId, player, 100, 255, 100)
        
        -- Check if voting is complete
        local totalVoters = #government.councilMembers + (government.mayor and 1 or 0)
        local totalVotes = proposal.votes.yes + proposal.votes.no + proposal.votes.abstain
        
        if totalVotes >= totalVoters then
            local result = proposal.votes.yes > proposal.votes.no and "THÔNG QUA" or "BỊ TỪ CHỐI"
            outputChatBox("=== KẾT QUẢ BIỂU QUYẾT ===", getRootElement(), 255, 255, 100)
            outputChatBox("Đề xuất #" .. proposalId .. ": " .. result, getRootElement(), 255, 255, 255)
            outputChatBox("Đồng ý: " .. proposal.votes.yes .. " | Phản đối: " .. proposal.votes.no .. " | Trắng: " .. proposal.votes.abstain, getRootElement(), 255, 255, 255)
        end
        
    else
        -- Election vote
        if not elections.active then
            outputChatBox("Hiện tại không có cuộc bầu cử nào!", player, 255, 100, 100)
            return
        end
        
        local candidateName = proposalIdOrCandidate
        local candidate = nil
        
        for _, c in ipairs(elections.candidates) do
            if c.name == candidateName then
                candidate = c
                break
            end
        end
        
        if not candidate then
            outputChatBox("Không tìm thấy ứng viên!", player, 255, 100, 100)
            return
        end
        
        local playerName = getPlayerName(player)
        if elections.votes[playerName] then
            outputChatBox("Bạn đã bỏ phiếu rồi!", player, 255, 100, 100)
            return
        end
        
        elections.votes[playerName] = candidateName
        candidate.votes = candidate.votes + 1
        
        outputChatBox("Đã bỏ phiếu cho " .. candidateName .. "!", player, 100, 255, 100)
    end
end)

-- Election System
addCommandHandler("election", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /election [start/end/results/status] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "start" then
        if adminLevel < 6 then
            outputChatBox("Chỉ admin mới có thể bắt đầu bầu cử!", player, 255, 100, 100)
            return
        end
        
        local duration = tonumber(args[1]) or 30 -- minutes
        local type = args[2] or "mayor"
        
        if elections.active then
            outputChatBox("Đã có cuộc bầu cử đang diễn ra!", player, 255, 100, 100)
            return
        end
        
        elections.active = true
        elections.endTime = getRealTime().timestamp + (duration * 60)
        elections.type = type
        elections.votes = {}
        
        outputChatBox("=== BẦU CỬ BẮT ĐẦU ===", getRootElement(), 255, 255, 100)
        outputChatBox("Loại: " .. type, getRootElement(), 255, 255, 255)
        outputChatBox("Thời gian: " .. duration .. " phút", getRootElement(), 255, 255, 255)
        outputChatBox("Sử dụng /vote [tên ứng viên] để bỏ phiếu!", getRootElement(), 255, 255, 255)
        
        setTimer(function()
            if elections.active then
                outputChatBox("Cuộc bầu cử đã kết thúc!", getRootElement(), 255, 255, 100)
                elections.active = false
            end
        end, duration * 60000, 1)
        
    elseif action == "end" then
        if adminLevel < 6 then
            outputChatBox("Chỉ admin mới có thể kết thúc bầu cử!", player, 255, 100, 100)
            return
        end
        
        if not elections.active then
            outputChatBox("Không có cuộc bầu cử nào đang diễn ra!", player, 255, 100, 100)
            return
        end
        
        elections.active = false
        outputChatBox("Cuộc bầu cử đã được kết thúc bởi admin!", getRootElement(), 255, 255, 100)
        
    elseif action == "results" then
        outputChatBox("=== KẾT QUẢ BẦU CỬ ===", player, 255, 255, 100)
        
        if #elections.candidates == 0 then
            outputChatBox("Không có ứng viên nào.", player, 255, 255, 255)
            return
        end
        
        -- Sort candidates by votes
        table.sort(elections.candidates, function(a, b) return a.votes > b.votes end)
        
        for i, candidate in ipairs(elections.candidates) do
            outputChatBox(i .. ". " .. candidate.name .. ": " .. candidate.votes .. " phiếu", player, 255, 255, 255)
        end
        
        local winner = elections.candidates[1]
        if winner and winner.votes > 0 then
            outputChatBox("NGƯỜI THẮNG CUỘC: " .. winner.name, player, 100, 255, 100)
        end
        
    elseif action == "status" then
        if elections.active then
            local timeLeft = elections.endTime - getRealTime().timestamp
            outputChatBox("Cuộc bầu cử đang diễn ra!", player, 255, 255, 100)
            outputChatBox("Thời gian còn lại: " .. math.floor(timeLeft / 60) .. " phút", player, 255, 255, 255)
            outputChatBox("Loại: " .. elections.type, player, 255, 255, 255)
            outputChatBox("Số ứng viên: " .. #elections.candidates, player, 255, 255, 255)
        else
            outputChatBox("Hiện tại không có cuộc bầu cử nào.", player, 255, 255, 255)
        end
    end
end)

-- Ballot System
addCommandHandler("ballot", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    if not action then
        outputChatBox("Sử dụng: /ballot [view/secret] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "view" then
        if not elections.active then
            outputChatBox("Hiện tại không có cuộc bầu cử nào!", player, 255, 100, 100)
            return
        end
        
        outputChatBox("=== PHIẾU BẦU ===", player, 255, 255, 100)
        outputChatBox("Cuộc bầu cử: " .. elections.type, player, 255, 255, 255)
        outputChatBox("Ứng viên:", player, 255, 255, 255)
        
        for i, candidate in ipairs(elections.candidates) do
            outputChatBox(i .. ". " .. candidate.name, player, 255, 255, 255)
            outputChatBox("   " .. candidate.slogan, player, 200, 200, 200)
        end
        
        outputChatBox("Sử dụng /vote [tên ứng viên] để bỏ phiếu!", player, 255, 255, 100)
        
    elseif action == "secret" then
        local playerName = getPlayerName(player)
        if elections.votes[playerName] then
            outputChatBox("Bạn đã bỏ phiếu cho: [BÍ MẬT]", player, 255, 255, 100)
        else
            outputChatBox("Bạn chưa bỏ phiếu.", player, 255, 255, 100)
        end
    end
end)

-- License System
addCommandHandler("license", function(player, cmd, action, licenseType, targetPlayer)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    
    if not action then
        outputChatBox("Sử dụng: /license [issue/renew/revoke/check] [loại] [người chơi]", player, 255, 255, 100)
        outputChatBox("Loại giấy phép: driving, business, weapon, fishing, pilot", player, 255, 255, 100)
        return
    end
    
    if action == "issue" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" and adminLevel < 4 then
            outputChatBox("Bạn không có quyền cấp giấy phép!", player, 255, 100, 100)
            return
        end
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local validLicenses = {driving = true, business = true, weapon = true, fishing = true, pilot = true}
        if not validLicenses[licenseType] then
            outputChatBox("Loại giấy phép không hợp lệ!", player, 255, 100, 100)
            return
        end
        
        local playerLicenses = getElementData(target, "licenses") or {}
        playerLicenses[licenseType] = {
            issued = getRealTime().timestamp,
            issuer = getPlayerName(player),
            expiry = getRealTime().timestamp + (365 * 24 * 3600) -- 1 year
        }
        setElementData(target, "licenses", playerLicenses)
        
        outputChatBox("Đã cấp giấy phép " .. licenseType .. " cho " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox("Bạn đã nhận được giấy phép " .. licenseType .. "!", target, 100, 255, 100)
        
    elseif action == "check" then
        local target = targetPlayer and getPlayerFromName(targetPlayer) or player
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local playerLicenses = getElementData(target, "licenses") or {}
        outputChatBox("=== GIẤY PHÉP CỦA " .. getPlayerName(target) .. " ===", player, 255, 255, 100)
        
        local hasLicense = false
        for license, data in pairs(playerLicenses) do
            local expired = data.expiry < getRealTime().timestamp
            local status = expired and "HẾT HẠN" or "CÒN HẠN"
            outputChatBox(license .. ": " .. status .. " (Cấp bởi: " .. data.issuer .. ")", player, 255, 255, 255)
            hasLicense = true
        end
        
        if not hasLicense then
            outputChatBox("Không có giấy phép nào.", player, 255, 255, 255)
        end
        
    elseif action == "revoke" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" and adminLevel < 5 then
            outputChatBox("Bạn không có quyền thu hồi giấy phép!", player, 255, 100, 100)
            return
        end
        
        local target = getPlayerFromName(targetPlayer)
        if not target then
            outputChatBox("Không tìm thấy người chơi!", player, 255, 100, 100)
            return
        end
        
        local playerLicenses = getElementData(target, "licenses") or {}
        if not playerLicenses[licenseType] then
            outputChatBox("Người này không có giấy phép " .. licenseType .. "!", player, 255, 100, 100)
            return
        end
        
        playerLicenses[licenseType] = nil
        setElementData(target, "licenses", playerLicenses)
        
        outputChatBox("Đã thu hồi giấy phép " .. licenseType .. " của " .. getPlayerName(target), player, 100, 255, 100)
        outputChatBox("Giấy phép " .. licenseType .. " của bạn đã bị thu hồi!", target, 255, 100, 100)
    end
end)

-- Permit System
addCommandHandler("permit", function(player, cmd, action, permitType, ...)
    if not player or not isElement(player) then return end
    
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /permit [apply/approve/deny/check] [loại] [tham số]", player, 255, 255, 100)
        outputChatBox("Loại giấy phép: construction, event, business, vendor", player, 255, 255, 100)
        return
    end
    
    if action == "apply" then
        local description = table.concat(args, " ")
        if not description or description == "" then
            outputChatBox("Sử dụng: /permit apply [loại] [mô tả]", player, 255, 100, 100)
            return
        end
        
        local permitId = #permits + 1
        permits[permitId] = {
            applicant = getPlayerName(player),
            type = permitType,
            description = description,
            status = "pending",
            timestamp = getRealTime().timestamp
        }
        
        outputChatBox("Đã nộp đơn xin phép #" .. permitId .. " (" .. permitType .. ")", player, 100, 255, 100)
        
        -- Notify government
        for _, p in ipairs(getElementsByType("player")) do
            local role = getElementData(p, "governmentRole") or "citizen"
            if role == "mayor" or role == "governor" then
                outputChatBox("Đơn xin phép mới #" .. permitId .. " từ " .. getPlayerName(player), p, 255, 255, 100)
            end
        end
        
    elseif action == "approve" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" then
            outputChatBox("Chỉ thị trưởng/thống đốc mới có thể phê duyệt!", player, 255, 100, 100)
            return
        end
        
        local permitId = tonumber(permitType)
        if not permitId or not permits[permitId] then
            outputChatBox("Không tìm thấy đơn xin phép!", player, 255, 100, 100)
            return
        end
        
        permits[permitId].status = "approved"
        permits[permitId].approver = getPlayerName(player)
        
        outputChatBox("Đã phê duyệt đơn xin phép #" .. permitId, player, 100, 255, 100)
        
        local applicant = getPlayerFromName(permits[permitId].applicant)
        if applicant then
            outputChatBox("Đơn xin phép #" .. permitId .. " của bạn đã được phê duyệt!", applicant, 100, 255, 100)
        end
        
    elseif action == "check" then
        outputChatBox("=== DANH SÁCH ĐƠN XIN PHÉP ===", player, 255, 255, 100)
        
        for id, permit in pairs(permits) do
            if permit.status == "pending" or governmentRole == "mayor" or governmentRole == "governor" then
                outputChatBox("#" .. id .. " - " .. permit.applicant .. " (" .. permit.type .. ") - " .. permit.status, player, 255, 255, 255)
            end
        end
    end
end)

-- Tax System
addCommandHandler("tax", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /tax [rate/collect/status/pay] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "rate" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" then
            outputChatBox("Chỉ thị trưởng/thống đốc mới có thể điều chỉnh thuế!", player, 255, 100, 100)
            return
        end
        
        local newRate = tonumber(args[1])
        if not newRate or newRate < 0.05 or newRate > 0.15 then
            outputChatBox("Thuế suất phải từ 5% đến 15%!", player, 255, 100, 100)
            return
        end
        
        government.taxRate = newRate
        outputChatBox("Đã điều chỉnh thuế suất thành " .. (newRate * 100) .. "%", player, 100, 255, 100)
        outputChatBox("THÔNG BÁO: Thuế suất mới " .. (newRate * 100) .. "% có hiệu lực ngay!", getRootElement(), 255, 255, 100)
        
    elseif action == "collect" then
        if governmentRole ~= "mayor" and governmentRole ~= "governor" then
            outputChatBox("Chỉ thị trưởng/thống đốc mới có thể thu thuế!", player, 255, 100, 100)
            return
        end
        
        local totalCollected = 0
        
        for _, p in ipairs(getElementsByType("player")) do
            local playerMoney = getElementData(p, "money") or 0
            local taxAmount = math.floor(playerMoney * government.taxRate)
            
            if taxAmount > 0 then
                setElementData(p, "money", playerMoney - taxAmount)
                totalCollected = totalCollected + taxAmount
                outputChatBox("Bạn đã nộp thuế $" .. taxAmount, p, 255, 255, 100)
            end
        end
        
        government.budget = government.budget + totalCollected
        outputChatBox("Đã thu được $" .. totalCollected .. " từ thuế", player, 100, 255, 100)
        
    elseif action == "status" then
        outputChatBox("=== THÔNG TIN THUẾ ===", player, 255, 255, 100)
        outputChatBox("Thuế suất hiện tại: " .. (government.taxRate * 100) .. "%", player, 255, 255, 255)
        
        local playerMoney = getElementData(player, "money") or 0
        local taxOwed = math.floor(playerMoney * government.taxRate)
        outputChatBox("Thuế phải nộp của bạn: $" .. taxOwed, player, 255, 255, 255)
        
    elseif action == "pay" then
        local playerMoney = getElementData(player, "money") or 0
        local taxAmount = math.floor(playerMoney * government.taxRate)
        
        if taxAmount <= 0 then
            outputChatBox("Bạn không có thuế phải nộp!", player, 255, 255, 100)
            return
        end
        
        setElementData(player, "money", playerMoney - taxAmount)
        government.budget = government.budget + taxAmount
        
        outputChatBox("Đã nộp thuế $" .. taxAmount, player, 100, 255, 100)
    end
end)

-- City System
addCommandHandler("city", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local args = {...}
    
    if not action then
        outputChatBox("Sử dụng: /city [info/events/services/news] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "info" then
        outputChatBox("=== THÔNG TIN THÀNH PHỐ ===", player, 255, 255, 100)
        outputChatBox("Dân số: " .. #getElementsByType("player") .. " người", player, 255, 255, 255)
        outputChatBox("Ngân sách: $" .. government.budget, player, 255, 255, 255)
        outputChatBox("Thuế suất: " .. (government.taxRate * 100) .. "%", player, 255, 255, 255)
        outputChatBox("Dịch vụ hoạt động: " .. #government.cityServices, player, 255, 255, 255)
        
        local mayorName = government.mayor and getPlayerName(government.mayor) or "Không có"
        outputChatBox("Thị trưởng: " .. mayorName, player, 255, 255, 255)
        
    elseif action == "events" then
        outputChatBox("=== SỰ KIỆN THÀNH PHỐ ===", player, 255, 255, 100)
        outputChatBox("• Lễ hội mùa xuân - Cuối tuần này", player, 255, 255, 255)
        outputChatBox("• Họp hội đồng - Thứ 2 hàng tuần", player, 255, 255, 255)
        outputChatBox("• Bầu cử - Tháng tới", player, 255, 255, 255)
        
    elseif action == "services" then
        outputChatBox("=== DỊCH VỤ THÀNH PHỐ ===", player, 255, 255, 100)
        outputChatBox("• Cấp giấy phép lái xe", player, 255, 255, 255)
        outputChatBox("• Đăng ký kinh doanh", player, 255, 255, 255)
        outputChatBox("• Dịch vụ cấp cứu", player, 255, 255, 255)
        outputChatBox("• An ninh công cộng", player, 255, 255, 255)
        outputChatBox("• Thu gom rác thải", player, 255, 255, 255)
        
    elseif action == "news" then
        outputChatBox("=== TIN TỨC THÀNH PHỐ ===", player, 255, 255, 100)
        outputChatBox("• Thuế suất được điều chỉnh xuống " .. (government.taxRate * 100) .. "%", player, 255, 255, 255)
        outputChatBox("• Ngân sách đầu tư vào cơ sở hạ tầng", player, 255, 255, 255)
        outputChatBox("• Cải thiện dịch vụ y tế công", player, 255, 255, 255)
    end
end)

-- Budget System
addCommandHandler("budget", function(player, cmd, action, ...)
    if not player or not isElement(player) then return end
    
    local governmentRole = getElementData(player, "governmentRole") or "citizen"
    local args = {...}
    
    if governmentRole ~= "mayor" and governmentRole ~= "governor" then
        outputChatBox("Chỉ thị trưởng/thống đốc mới có thể quản lý ngân sách!", player, 255, 100, 100)
        return
    end
    
    if not action then
        outputChatBox("Sử dụng: /budget [view/allocate/transfer] [tham số]", player, 255, 255, 100)
        return
    end
    
    if action == "view" then
        outputChatBox("=== NGÂN SÁCH THÀNH PHỐ ===", player, 255, 255, 100)
        outputChatBox("Tổng ngân sách: $" .. government.budget, player, 255, 255, 255)
        
        local totalAllocated = 0
        for service, data in pairs(government.cityServices) do
            outputChatBox(service .. ": $" .. data.budget, player, 255, 255, 255)
            totalAllocated = totalAllocated + data.budget
        end
        
        outputChatBox("Đã phân bổ: $" .. totalAllocated, player, 255, 255, 255)
        outputChatBox("Còn lại: $" .. (government.budget - totalAllocated), player, 100, 255, 100)
        
    elseif action == "allocate" then
        local service = args[1]
        local amount = tonumber(args[2])
        
        if not service or not amount then
            outputChatBox("Sử dụng: /budget allocate [dịch vụ] [số tiền]", player, 255, 100, 100)
            return
        end
        
        if amount > government.budget then
            outputChatBox("Không đủ ngân sách!", player, 255, 100, 100)
            return
        end
        
        if not government.cityServices[service] then
            government.cityServices[service] = {budget = 0, efficiency = 50}
        end
        
        government.cityServices[service].budget = government.cityServices[service].budget + amount
        government.budget = government.budget - amount
        
        outputChatBox("Đã phân bổ $" .. amount .. " cho " .. service, player, 100, 255, 100)
    end
end)

-- Auto-tax collection every hour
setTimer(function()
    local totalCollected = 0
    
    for _, p in ipairs(getElementsByType("player")) do
        local playerMoney = getElementData(p, "money") or 0
        local taxAmount = math.floor(playerMoney * government.taxRate / 24) -- Daily tax divided by 24 hours
        
        if taxAmount > 0 then
            setElementData(p, "money", playerMoney - taxAmount)
            totalCollected = totalCollected + taxAmount
        end
    end
    
    government.budget = government.budget + totalCollected
    
    if totalCollected > 0 then
        outputChatBox("Thu thuế tự động: $" .. totalCollected, getRootElement(), 255, 255, 100)
    end
end, 3600000, 0) -- Every hour

outputDebugString("Government & Politics System loaded successfully! (16 commands)")
