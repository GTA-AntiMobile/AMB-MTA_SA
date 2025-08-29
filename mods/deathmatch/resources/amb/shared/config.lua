-- AMB Roleplay Configuration
-- Shared constants and configuration for AMB Roleplay

-- Server Configuration
SERVER_NAME = "AMB Roleplay"
SERVER_VERSION = "1.0.0"
SERVER_MAX_PLAYERS = 500
SERVER_MAX_PING = 1200
WEB_SERVER = "26.142.249.17"
SAMP_WEB = "http://26.142.249.17:8081/"
XP_RATE = 25 -- XP Rates for jobs
XP_RATE_HOURLY = 2 -- XP Bonus per paycheck (LEVEL * XP_RATE * XP_RATE_HOURLY)

-- Audio
SIREN_SOUND = "http://sampweb.ng-gaming.net/brendan/siren.mp3"

-- Timer Types
TIMER_TYPES = {
    TPMATRUNTIMER = 1,
    TPDRUGRUNTIMER = 2,
    ARMSTIMER = 3,
    GIVEWEAPONTIMER = 4,
    HOSPITALTIMER = 5,
    SEXTIMER = 6,
    FLOODPROTECTION = 7,
    HEALTIMER = 8,
    GUARDTIMER = 9,
    TPTRUCKRUNTIMER = 10,
    SHOPORDERTIMER = 11,
    SELLMATSTIMER = 12,
    TPPIZZARUNTIMER = 13,
    PIZZATIMER = 14,
    CRATETIMER = 15
}

-- Object IDs
OBJECTS = {
    RED_FLAG = 1580,
    BLUE_FLAG = 1579,
    HILL = 1578,
    SPEEDGUN = 43
}

-- Misc Configuration
VEHICLE_RESPAWN = 7200
MAX_NOP_WARNINGS = 4
NEW_VULNERABLE = 24

-- Database Configuration is in config/settings.lua

-- Player Data Structure
PLAYER_DATA_STRUCTURE = {
    -- Basic Info
    id = 0,
    username = "",
    password = "",
    email = "",
    registered_date = "",
    last_login = "",
    
    -- Character Info
    level = 1,
    experience = 0,
    money = 5000,
    bank_money = 0,
    skin = 299,
    
    -- Position
    pos_x = 1481.0,
    pos_y = -1771.0,
    pos_z = 18.8,
    pos_a = 0.0,
    interior = 0,
    virtual_world = 0,
    
    -- Admin
    admin_level = 0,
    helper_level = 0,
    donator_level = 0,
    
    -- Statistics
    hours_played = 0,
    kills = 0,
    deaths = 0,
    arrests = 0,
    
    -- Status
    health = 100,
    armor = 0,
    hunger = 100,
    thirst = 100,
    
    -- Jobs
    job = 0,
    job_level = 1,
    job_exp = 0,
    
    -- Vehicles
    vehicles_owned = {},
    
    -- Properties
    properties_owned = {},
    
    -- Faction
    faction_id = 0,
    faction_rank = 0,
    faction_leader = false,
    
    -- Temp Data
    logged_in = false,
    spawned = false,
    selecting_skin = false,
    in_tutorial = false,
    
    -- Timers
    active_timers = {}
}

-- Color Constants (converted from PAWN hex to RGB)
COLORS = {
    WHITE = {255, 255, 255},
    BLACK = {0, 0, 0},
    RED = {255, 0, 0},
    GREEN = {0, 255, 0},
    BLUE = {0, 0, 255},
    YELLOW = {255, 255, 0},
    ORANGE = {255, 165, 0},
    PURPLE = {128, 0, 128},
    GREY = {128, 128, 128},
    LIGHTBLUE = {173, 216, 230},
    LIGHTGREEN = {144, 238, 144},
    LIGHTRED = {255, 182, 193},
    LIGHTYELLOW = {255, 255, 224},
    
    -- Admin Colors
    ADMIN_COLOR = {255, 194, 14},
    HELPER_COLOR = {255, 140, 0},
    DONATOR_COLOR = {255, 215, 0},
    
    -- System Colors
    SUCCESS_COLOR = {0, 255, 0},
    ERROR_COLOR = {255, 0, 0},
    INFO_COLOR = {0, 191, 255},
    WARNING_COLOR = {255, 255, 0}
}

-- Spawn Locations
SPAWN_LOCATIONS = {
    -- Los Santos
    {1481.0, -1771.0, 18.8, 0.0},
    {1457.0, -1011.0, 26.8, 0.0},
    {2495.0, -1687.0, 13.5, 0.0},
    
    -- Las Venturas
    {2227.0, 1602.0, 10.0, 0.0},
    {2126.0, 2379.0, 10.8, 0.0},
    
    -- San Fierro
    {-1605.0, 720.0, 12.0, 0.0},
    {-2026.0, 156.0, 29.0, 0.0}
}

-- Vehicle Models and Names
VEHICLE_NAMES = {
    [400] = "Landstalker",
    [401] = "Bravura",
    [402] = "Buffalo",
    [403] = "Linerunner",
    [404] = "Perenniel",
    [405] = "Sentinel",
    [406] = "Dumper",
    [407] = "Firetruck",
    [408] = "Trashmaster",
    [409] = "Stretch",
    [410] = "Manana",
    [411] = "Infernus",
    [412] = "Voodoo",
    [413] = "Pony",
    [414] = "Mule",
    [415] = "Cheetah",
    [416] = "Ambulance",
    [417] = "Leviathan",
    [418] = "Moonbeam",
    [419] = "Esperanto",
    [420] = "Taxi",
    [421] = "Washington",
    [422] = "Bobcat",
    [423] = "Mr Whoopee",
    [424] = "BF Injection",
    [425] = "Hunter",
    [426] = "Premier",
    [427] = "Enforcer",
    [428] = "Securicar",
    [429] = "Banshee",
    [430] = "Predator",
    [431] = "Bus",
    [432] = "Rhino",
    [433] = "Barracks",
    [434] = "Hotknife",
    [435] = "Trailer",
    [436] = "Previon",
    [437] = "Coach",
    [438] = "Cabbie",
    [439] = "Stallion",
    [440] = "Rumpo",
    [441] = "RC Bandit",
    [442] = "Romero",
    [443] = "Packer",
    [444] = "Monster",
    [445] = "Admiral",
    [446] = "Squalo",
    [447] = "Seasparrow",
    [448] = "Pizzaboy",
    [449] = "Tram",
    [450] = "Trailer",
    [451] = "Turismo",
    -- ... (abbreviated for space, full list would continue)
}

-- Skin Names
SKIN_NAMES = {
    [0] = "Carl Johnson",
    [1] = "The Truth",
    [2] = "Maccer",
    [7] = "Taxi Driver",
    [14] = "Normal Ped",
    [15] = "Biker",
    [16] = "Biker 2",
    [17] = "Pimp",
    [18] = "Normal Ped 2",
    [19] = "Gangster",
    [20] = "Gangster 2",
    -- ... (abbreviated for space)
    [299] = "Brian (Custom)",
    [300] = "Con Me May (Custom)",
    [301] = "Dylan (Custom)",
    [302] = "LAPD Officer (Custom)",
    [303] = "Nam 1 (Custom)",
    [304] = "Nam 2 (Custom)",
    [305] = "Nu 1 (Custom)",
    [306] = "Nu 2 (Custom)"
}

-- Export all constants
_G.AMB_CONFIG = {
    SERVER_NAME = SERVER_NAME,
    SERVER_VERSION = SERVER_VERSION,
    SERVER_MAX_PLAYERS = SERVER_MAX_PLAYERS,
    SERVER_MAX_PING = SERVER_MAX_PING,
    WEB_SERVER = WEB_SERVER,
    SAMP_WEB = SAMP_WEB,
    XP_RATE = XP_RATE,
    XP_RATE_HOURLY = XP_RATE_HOURLY,
    SIREN_SOUND = SIREN_SOUND,
    TIMER_TYPES = TIMER_TYPES,
    OBJECTS = OBJECTS,
    VEHICLE_RESPAWN = VEHICLE_RESPAWN,
    MAX_NOP_WARNINGS = MAX_NOP_WARNINGS,
    NEW_VULNERABLE = NEW_VULNERABLE,
    PLAYER_DATA_STRUCTURE = PLAYER_DATA_STRUCTURE,
    COLORS = COLORS,
    SPAWN_LOCATIONS = SPAWN_LOCATIONS,
    VEHICLE_NAMES = VEHICLE_NAMES,
    SKIN_NAMES = SKIN_NAMES
}
