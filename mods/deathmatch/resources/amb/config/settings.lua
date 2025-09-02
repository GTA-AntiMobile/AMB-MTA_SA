-- ================================================================
-- AMB MTA:SA - Server Configuration Settings
-- Production Configuration for Vietnamese Roleplay Server
-- Version: 1.0.0-production
-- ================================================================

-- Server Information
SERVER_NAME = "AMB Vietnamese Roleplay [MTA]"
SERVER_VERSION = "1.0.0-production"
SERVER_LANGUAGE = "vietnamese"
SERVER_MAX_PLAYERS = 100
SERVER_WELCOME_MESSAGE = "Chào mừng đến với AMB Vietnamese Roleplay Server!"

-- Database Configuration (MySQL only)
DATABASE_ENABLED = true
DATABASE_TYPE = "mysql"  -- "mysql" only
DATABASE_CONFIG = {
    -- Database type: MySQL only
    type = "mysql",
    
    -- MySQL config (cho production VPS/host)
    mysql = {
        host = "localhost",          -- Thay đổi khi deploy: VPS IP hoặc domain
        port = 3306,
        database = "amb",            -- Đúng tên database từ mysql.cfg
        user = "root",               -- Username MySQL trên VPS
        password = "admin",          -- Password từ mysql.cfg
        charset = "utf8"
    }
}

-- Economy Settings
STARTING_MONEY = 5000
PAYDAY_AMOUNT = 1000
PAYDAY_INTERVAL = 1800000 -- 30 minutes in milliseconds
BANK_INTEREST_RATE = 0.02 -- 2% per payday

-- Admin Settings (Reference to shared/enums.lua)
-- ADMIN_LEVELS được định nghĩa trong shared/enums.lua để tránh trùng lặp

-- VIP Settings
VIP_LEVELS = {
    [1] = "Bronze VIP",
    [2] = "Silver VIP",
    [3] = "Gold VIP",
    [4] = "Platinum VIP",
    [5] = "Diamond VIP"
}

-- Game Settings
SPAWN_HEALTH = 100
SPAWN_ARMOUR = 0
SPAWN_MONEY = STARTING_MONEY
WEATHER_CHANGE_INTERVAL = 600000 -- 10 minutes
TIME_SYNC_ENABLED = true

-- Job Settings
JOB_PAYMENT_INTERVAL = 60000 -- 1 minute
TRUCKER_PAY_PER_KM = 50
PIZZA_DELIVERY_PAY = 200
MECHANIC_REPAIR_PRICE = 500

-- Vehicle Settings
VEHICLE_RESPAWN_TIME = 300000 -- 5 minutes
VEHICLE_FUEL_ENABLED = true
VEHICLE_DAMAGE_ENABLED = true

-- Property Settings
HOUSE_PRICE_MULTIPLIER = 1.5
BUSINESS_INCOME_INTERVAL = 300000 -- 5 minutes
RENT_PAYMENT_INTERVAL = 86400000 -- 24 hours

-- Security Settings
ANTI_CHEAT_ENABLED = true
MONEY_CHEAT_PROTECTION = true
WEAPON_CHEAT_PROTECTION = true
TELEPORT_CHEAT_PROTECTION = true

-- Language Settings
LANGUAGE_PRIORITY = "vietnamese"
FALLBACK_LANGUAGE = "english"

-- Chat Settings
CHAT_DISTANCE = 20.0 -- Local chat distance in meters
SHOUT_DISTANCE = 40.0 -- Shout distance in meters
WHISPER_DISTANCE = 5.0 -- Whisper distance in meters

-- System Messages
SYSTEM_MESSAGES = {
    welcome = "Chào mừng bạn đến với AMB Vietnamese Roleplay!",
    first_join = "Lần đầu tham gia? Sử dụng /newb để được hướng dẫn!",
    payday = "Bạn đã nhận được lương: $%d",
    level_up = "Chúc mừng! Bạn đã lên level %d!",
    insufficient_money = "Bạn không có đủ tiền!",
    command_success = "Lệnh thực hiện thành công!",
    command_failed = "Lệnh thực hiện thất bại!",
    player_not_found = "Không tìm thấy người chơi!",
    access_denied = "Bạn không có quyền thực hiện lệnh này!"
}

-- Color Codes
COLORS = {
    WHITE = "#FFFFFF",
    RED = "#FF0000", 
    GREEN = "#00FF00",
    BLUE = "#0000FF",
    YELLOW = "#FFFF00",
    ORANGE = "#FFA500",
    PURPLE = "#800080",
    PINK = "#FFC0CB",
    GREY = "#808080",
    LIGHTBLUE = "#ADD8E6",
    LIGHTGREEN = "#90EE90"
}

-- Command Permissions
COMMAND_PERMISSIONS = {
    admin = 3,
    ban = 3,
    kick = 2,
    mute = 2,
    heal = 1,
    armor = 1,
    jumpto = 2, -- Old /goto
    gethere = 2,
    setlevel = 4,
    givemoney = 3,
    sethp = 2,
    setarmour = 2
}

-- Feature Toggles
FEATURES = {
    families = true,
    jobs = true,
    properties = true,
    vehicles = true,
    businesses = true,
    phone_system = true,
    banking = true,
    vip_system = true,
    events = true,
    arena = true,
    turf_wars = true,
    zombie_mode = true
}

-- Migration Information
MIGRATION_INFO = {
    source = "SA-MP AMB Gamemode",
    target = "MTA:SA",
    commands_migrated = 1182,
    completion_rate = 100,
    status = "COMPLETE",
    systems = 17,
    version = "1.0.0-production"
}

-- Configuration loaded (minimal logging)
-- Use global variables and MIGRATION_INFO table for programmatic access
