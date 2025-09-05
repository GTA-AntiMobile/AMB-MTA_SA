-- ================================================================
-- AMB MTA:SA - Database Module
-- ================================================================
local db_connection = nil

-- Hash password (MD5)
function WP_Hash(password)
    if not password then
        return ""
    end
    return md5(password)
end

-- Init DB connection
function initDatabase()

    if not DATABASE_CONFIG or not DATABASE_CONFIG.mysql then
        outputDebugString("[DATABASE] ERROR: DATABASE_CONFIG not found in settings.lua!", 1)
        return false
    end

    local cfg = DATABASE_CONFIG.mysql
    local connStr = string.format("dbname=%s;host=%s;port=%d", cfg.database, cfg.host, cfg.port)
    db_connection = dbConnect("mysql", connStr, cfg.user, cfg.password, "share=1")
    _G.db_connection = db_connection

    if db_connection then
        -- createAccountsTable() -- Commented out - using existing database from original.sql
        return true
    else
        outputDebugString("[DATABASE] ❌ Failed to connect!", 1)
        return false
    end
end

-- Create accounts table if not exists
function createAccountsTable()
    if not db_connection then
        return
    end
    local query = [[
        CREATE TABLE IF NOT EXISTS accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            Username VARCHAR(32) UNIQUE NOT NULL,
            `Key` VARCHAR(256) NOT NULL,
            Level INT DEFAULT 1,
            AdminLevel INT DEFAULT 0,
            VIPLevel INT DEFAULT 0,
            Money BIGINT DEFAULT 5000,
            Bank BIGINT DEFAULT 20000,
            XP INT DEFAULT 0,
            Model INT DEFAULT 299,
            SPos_x FLOAT DEFAULT 1642.9,
            SPos_y FLOAT DEFAULT -2237.6,
            SPos_z FLOAT DEFAULT 13.5,
            SPos_r FLOAT DEFAULT 0,
            pHealth FLOAT DEFAULT 100,
            pArmor FLOAT DEFAULT 0,
            `Int` INT DEFAULT 0,
            VirtualWorld INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_login DATETIME DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]]
    dbExec(db_connection, query)
end

-- Load account data
function dbLoadPlayerData(username)
    if not db_connection then
        return nil
    end
    local qh = dbQuery(db_connection, "SELECT * FROM accounts WHERE Username=? LIMIT 1", username)
    local result = dbPoll(qh, -1)
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

-- Create account
function dbCreateAccount(username, password)
    if not db_connection then
        return false, "DB not connected"
    end
    if dbLoadPlayerData(username) then
        return false, "Username already exists"
    end
    local hashed = WP_Hash(password)
    local success = dbExec(db_connection, "INSERT INTO accounts (Username, `Key`) VALUES (?, ?)", username, hashed)
    return success, success and "Account created" or "Failed to create account"
end

-- Save player
function dbSavePlayer(player)
    if not db_connection or not isElement(player) then
        return
    end
    local username = getElementData(player, "username")
    if not username then
        return
    end

    local x, y, z = getElementPosition(player)
    local _, _, rot = getElementRotation(player)

    -- Get skin using newmodels system to handle custom skins properly
    local skin = 299 -- default fallback
    local newmodelsResource = getResourceFromName("newmodels_azul")
    if newmodelsResource and getResourceState(newmodelsResource) == "running" then
        skin = exports["newmodels_azul"]:getElementModel(player) or 299
    else
        skin = getElementModel(player)
    end

    local money = getPlayerMoney(player)
    local health = getElementHealth(player)
    local armor = getPedArmor(player)
    local interior = getElementInterior(player)
    local dim = getElementDimension(player)

    dbExec(db_connection, [[
        UPDATE accounts SET 
        SPos_x=?, SPos_y=?, SPos_z=?, SPos_r=?,
        Model=?, Money=?, pHealth=?, pArmor=?,
        `Int`=?, VirtualWorld=?, AdminLevel=?
        WHERE Username=?
    ]], x, y, z, rot, skin, money, health, armor, interior, dim, username)
end

-- Spawn player from DB
function dbSpawnPlayer(player, accountData)
    if not isElement(player) or not accountData then
        return
    end
    local x = tonumber(accountData.SPos_x) or 1642.9
    local y = tonumber(accountData.SPos_y) or -2237.6
    local z = tonumber(accountData.SPos_z) or 13.5
    local rot = tonumber(accountData.SPos_r) or 0
    local interior = tonumber(accountData.Int) or 0
    local dimension = tonumber(accountData.VirtualWorld) or 0

    -- nếu pos = 0 thì fallback về LS
    if (x == 0 and y == 0 and z == 0) then
        x, y, z, rot = 1642.9, -2237.6, 13.5, 0
    end

    local skin = accountData.Model or 299

    -- Fade camera before spawning
    fadeCamera(player, false, 0.0)

    -- For custom skins (20001+), spawn with default skin first, then apply custom model
    local spawnSkin = skin
    if skin >= 20001 and skin <= 29999 then
        spawnSkin = 299 -- Use default skin for spawning
        -- outputDebugString("[SPAWN] Will spawn with default skin 299, then apply custom skin " .. skin)
    end

    -- Actually spawn the player at the saved position
    spawnPlayer(player, x, y, z, rot, spawnSkin, interior, dimension)

    -- Set player properties
    setElementInterior(player, interior)
    setElementDimension(player, dimension)

    -- Check if it's a custom skin using newmodels_azul
    if skin >= 20001 and skin <= 29999 then
        -- Custom skin: apply using newmodels_azul
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            local customModels = exports["newmodels_azul"]:getCustomModels()
            if customModels[skin] and customModels[skin].type == "ped" then
                local success = exports["newmodels_azul"]:setElementCustomModel(player, skin)
                if success then
                    -- outputDebugString("[SKIN] Restored custom ped (ID: " .. tostring(skin) .. ", Name: " .. (customModels[skin].name or "Unknown") .. ") for player " .. getPlayerName(player))
                    setElementData(player, "customSkinID", skin)
                else
                    outputDebugString("[SKIN] Failed to restore custom ped " .. tostring(skin) .. ", using fallback", 2)
                    -- Already spawned with skin 299, so no change needed
                end
            else
                outputDebugString("[SKIN] Custom skin " .. skin .. " not found in models, using default", 2)
                -- Already spawned with skin 299, so no change needed
            end
        else
            outputDebugString("[SKIN] newmodels_azul not available, using default skin for " .. getPlayerName(player), 2)
            -- Already spawned with skin 299, so no change needed
        end
    else
        -- Standard GTA skin (0-312) - already applied during spawn
        if skin >= 0 and skin <= 312 then
            outputDebugString("[SKIN] Spawned standard skin (ID: " .. tostring(skin) .. ") for player " ..
                                  getPlayerName(player))
        else
            outputDebugString("[SKIN] Invalid skin ID " .. tostring(skin) .. ", using default", 2)
            setElementModel(player, 299)
        end
        -- Clear custom skin data for standard skins
        if getElementData(player, "customSkinID") then
            removeElementData(player, "customSkinID")
        end
    end

    -- Restore player stats
    local health = tonumber(accountData.pHealth) or 100
    local armor = tonumber(accountData.pArmor) or 0
    local money = tonumber(accountData.Money) or 5000

    setElementHealth(player, health)
    setPedArmor(player, armor)
    setPlayerMoney(player, money)

    -- Set camera and fade back
    setCameraTarget(player, player)

    -- Delay fade in để đảm bảo mọi thứ đã load
    setTimer(function()
        if isElement(player) then
            fadeCamera(player, true, 1.0)
        end
    end, 1000, 1)
end

-- Exports
function getDatabaseConnection()
    return db_connection
end
function isDatabaseConnected()
    return db_connection ~= nil
end

-- Resource start/stop
addEventHandler("onResourceStart", resourceRoot, initDatabase)
addEventHandler("onResourceStop", resourceRoot, function()
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "loggedIn") then
            dbSavePlayer(p)
        end
    end
    if db_connection then
        destroyElement(db_connection)
    end
end)

-- Quit server
addEventHandler("onPlayerQuit", root, function()
    if getElementData(source, "loggedIn") then
        dbSavePlayer(source)
    end
end)
