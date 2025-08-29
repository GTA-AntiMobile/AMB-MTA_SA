-- ================================================================
-- AMB MTA:SA - Database Module
-- ================================================================

local db_connection = nil

-- Hash password (MD5)
function WP_Hash(password)
    if not password then return "" end
    return md5(password)
end

-- Init DB connection
function initDatabase()
    outputDebugString("[DATABASE] Initializing connection...")

    if not DATABASE_CONFIG or not DATABASE_CONFIG.mysql then
        outputDebugString("[DATABASE] ERROR: DATABASE_CONFIG not found in settings.lua!", 1)
        return false
    end

    local cfg = DATABASE_CONFIG.mysql
    local connStr = string.format("dbname=%s;host=%s;port=%d", cfg.database, cfg.host, cfg.port)
    db_connection = dbConnect("mysql", connStr, cfg.user, cfg.password, "share=1")

    if db_connection then
        outputDebugString("[DATABASE] ✅ Connected to " .. cfg.database .. "@" .. cfg.host)
        createAccountsTable()
        return true
    else
        outputDebugString("[DATABASE] ❌ Failed to connect!", 1)
        return false
    end
end

-- Create accounts table if not exists
function createAccountsTable()
    if not db_connection then return end
    local query = [[
        CREATE TABLE IF NOT EXISTS accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            Username VARCHAR(32) UNIQUE NOT NULL,
            `Key` VARCHAR(256) NOT NULL,
            Level INT DEFAULT 1,
            AdminLevel INT DEFAULT 0,
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
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]]
    dbExec(db_connection, query)
end

-- Load account data
function dbLoadPlayerData(username)
    if not db_connection then return nil end
    local qh = dbQuery(db_connection, "SELECT * FROM accounts WHERE Username=? LIMIT 1", username)
    local result = dbPoll(qh, -1)
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

-- Create account
function dbCreateAccount(username, password)
    if not db_connection then return false, "DB not connected" end
    if dbLoadPlayerData(username) then
        return false, "Username already exists"
    end
    local hashed = WP_Hash(password)
    local success = dbExec(db_connection,
        "INSERT INTO accounts (Username, `Key`) VALUES (?, ?)",
        username, hashed
    )
    return success, success and "Account created" or "Failed to create account"
end

-- Save player
function dbSavePlayer(player)
    if not db_connection or not isElement(player) then return end
    local username = getElementData(player, "username")
    if not username then return end

    local x,y,z = getElementPosition(player)
    local _,_,rot = getElementRotation(player)
    local skin = getElementModel(player)
    local money = getPlayerMoney(player)
    local health = getElementHealth(player)
    local armor = getPedArmor(player)
    local interior = getElementInterior(player)
    local dim = getElementDimension(player)

    dbExec(db_connection, [[
        UPDATE accounts SET 
        SPos_x=?, SPos_y=?, SPos_z=?, SPos_r=?,
        Model=?, Money=?, pHealth=?, pArmor=?,
        `Int`=?, VirtualWorld=?, last_login=NOW()
        WHERE Username=?
    ]],
    x,y,z,rot,skin,money,health,armor,interior,dim,username)
end

-- Exports
function getDatabaseConnection() return db_connection end
function isDatabaseConnected() return db_connection ~= nil end

-- Resource start/stop
addEventHandler("onResourceStart", resourceRoot, initDatabase)
addEventHandler("onResourceStop", resourceRoot, function()
    for _,p in ipairs(getElementsByType("player")) do
        if getElementData(p,"loggedIn") then dbSavePlayer(p) end
    end
    if db_connection then destroyElement(db_connection) end
end)

-- Quit server
addEventHandler("onPlayerQuit", root, function()
    if getElementData(source,"loggedIn") then
        dbSavePlayer(source)
    end
end)
