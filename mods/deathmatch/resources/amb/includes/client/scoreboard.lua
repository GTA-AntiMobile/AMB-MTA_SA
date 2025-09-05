-- ================================
-- AMB Scoreboard System
-- TAB to show player list with stats
-- ================================
local screenW, screenH = guiGetScreenSize()
local scoreboardWindow = nil
local isScoreboardVisible = false

-- Scoreboard configuration
local SCOREBOARD_WIDTH = 600
local SCOREBOARD_HEIGHT = 400
local PLAYER_ROW_HEIGHT = 25

-- Create scoreboard GUI
function createScoreboardGUI()
    if scoreboardWindow then
        return
    end

    local x = (screenW - SCOREBOARD_WIDTH) / 2
    local y = (screenH - SCOREBOARD_HEIGHT) / 2

    scoreboardWindow = guiCreateWindow(x, y, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT,
        "AMB Vietnamese Roleplay - Players Online", false)
    guiWindowSetSizable(scoreboardWindow, false)

    -- Create gridlist for players
    local gridlist = guiCreateGridList(10, 30, SCOREBOARD_WIDTH - 20, SCOREBOARD_HEIGHT - 50, false, scoreboardWindow)

    -- Add columns
    local colID = guiGridListAddColumn(gridlist, "ID", 0.08)
    local colName = guiGridListAddColumn(gridlist, "Player Name", 0.25)
    local colLevel = guiGridListAddColumn(gridlist, "Level", 0.1)
    local colMoney = guiGridListAddColumn(gridlist, "Money", 0.15)
    local colJob = guiGridListAddColumn(gridlist, "Job", 0.18)
    local colPing = guiGridListAddColumn(gridlist, "Ping", 0.1)
    local colAdmin = guiGridListAddColumn(gridlist, "Admin", 0.12)

    -- Populate with players (sorted by ID like SA-MP)
    local players = {}
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "loggedIn") then
            local playerID = getElementData(player, "ID")
            if playerID then
                table.insert(players, {
                    player = player,
                    id = playerID
                })
            end
        end
    end

    -- Sort by ID (SA-MP style: 0, 1, 2, 3...)
    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    -- Add sorted players to gridlist
    for _, playerData in ipairs(players) do
        local player = playerData.player
        local row = guiGridListAddRow(gridlist)

        -- Get player ID (consistent with server-side)
        local playerID = tostring(playerData.id)

        guiGridListSetItemText(gridlist, row, colID, playerID, false, false)
        guiGridListSetItemText(gridlist, row, colName, getPlayerName(player), false, false)
        guiGridListSetItemText(gridlist, row, colLevel, tostring(getElementData(player, "level") or 1), false, false)
        guiGridListSetItemText(gridlist, row, colMoney, "$" .. formatMoney(getPlayerMoney(player) or 0), false, false)
        guiGridListSetItemText(gridlist, row, colJob, tostring(getElementData(player, "job") or "Civilian"), false,
            false)
        guiGridListSetItemText(gridlist, row, colPing, tostring(getPlayerPing(player)) .. "ms", false, false)

        local adminLevel = getElementData(player, "adminLevel") or 0
        local adminText = adminLevel > 0 and "Admin " .. adminLevel or "Player"
        guiGridListSetItemText(gridlist, row, colAdmin, adminText, false, false)

        -- Color admin rows
        if adminLevel > 0 then
            guiGridListSetItemColor(gridlist, row, colAdmin, 255, 200, 0)
        end
    end

    -- Add close button
    local closeBtn = guiCreateButton(SCOREBOARD_WIDTH - 100, SCOREBOARD_HEIGHT - 35, 80, 25, "Close", false,
        scoreboardWindow)
    if closeBtn then
        addEventHandler("onClientGUIClick", closeBtn, function()
            hideScoreboard()
        end, false)
    end

    guiSetVisible(scoreboardWindow, false)
end

-- Format money with commas
function formatMoney(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

-- Show scoreboard
function showScoreboard()
    if not scoreboardWindow then
        createScoreboardGUI()
    end

    -- Refresh player list
    if not scoreboardWindow then
        return
    end

    local gridlist = getElementChildren(scoreboardWindow)[1]
    if not gridlist then
        return
    end

    guiGridListClear(gridlist)

    -- Get all logged in players and sort by ID (SA-MP style)
    local players = {}
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "loggedIn") then
            local playerID = getElementData(player, "ID")
            if playerID then
                table.insert(players, {
                    player = player,
                    id = playerID
                })
            end
        end
    end

    -- Sort by ID (SA-MP style: 0, 1, 2, 3...)
    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    -- Add sorted players to gridlist
    for _, playerData in ipairs(players) do
        local player = playerData.player
        local row = guiGridListAddRow(gridlist)
        local colID, colName, colLevel, colMoney, colJob, colPing, colAdmin = 1, 2, 3, 4, 5, 6, 7

        -- Get player ID (consistent with server-side)
        local playerID = tostring(playerData.id)

        guiGridListSetItemText(gridlist, row, colID, playerID, false, false)
        guiGridListSetItemText(gridlist, row, colName, getPlayerName(player), false, false)
        guiGridListSetItemText(gridlist, row, colLevel, tostring(getElementData(player, "level") or 1), false, false)
        guiGridListSetItemText(gridlist, row, colMoney, "$" .. formatMoney(getPlayerMoney(player) or 0), false, false)
        guiGridListSetItemText(gridlist, row, colJob, tostring(getElementData(player, "job") or "Civilian"), false,
            false)
        guiGridListSetItemText(gridlist, row, colPing, tostring(getPlayerPing(player)) .. "ms", false, false)

        local adminLevel = getElementData(player, "adminLevel") or 0
        local adminText = adminLevel > 0 and "Admin " .. adminLevel or "Player"
        guiGridListSetItemText(gridlist, row, colAdmin, adminText, false, false)

        if adminLevel > 0 then
            guiGridListSetItemColor(gridlist, row, colAdmin, 255, 200, 0)
        end
    end

    guiSetVisible(scoreboardWindow, true)
    showCursor(true)
    isScoreboardVisible = true
end

-- Hide scoreboard
function hideScoreboard()
    if scoreboardWindow then
        guiSetVisible(scoreboardWindow, false)
        showCursor(false)
        isScoreboardVisible = false
    end
end

-- Toggle scoreboard
function toggleScoreboard()
    if isScoreboardVisible then
        hideScoreboard()
    else
        showScoreboard()
    end
end

-- Bind TAB key
bindKey("tab", "down", toggleScoreboard)

-- Hide on ESC
bindKey("escape", "down", function()
    if isScoreboardVisible then
        hideScoreboard()
    end
end)

outputChatBox("📊 Scoreboard loaded! Press TAB to view players", 0, 255, 127)
