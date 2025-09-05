-- AMB Roleplay Enums
-- Shared enums and data structures for AMB Roleplay
-- Group/Faction Data Structure
GROUP_DATA_STRUCTURE = {
    id = 0,
    type = 0,
    motd = "",
    name = "",
    locker_guns = {},
    locker_cost = {},
    allegiance = 0,
    bug_access = 0,
    radio_access = 0,
    dept_radio_access = 0,
    int_radio_access = 0,
    gov_access = 0,
    duty_colour = {255, 255, 255},
    radio_colour = {255, 255, 255},
    locker_stock = 0,
    free_name_change = 0,
    spike_strips = 0,
    barricades = 0,
    cones = 0,
    flares = 0,
    barrels = 0,
    budget = 0,
    budget_payment = 0,
    crate_pos = {0.0, 0.0, 0.0},
    paycheck = {},
    crate_island = 0,
    locker_cost_type = 0,
    crates_order = 0,
    j_count = 0,
    garage_pos = {0.0, 0.0, 0.0}
}

-- Street Information Structure
STREET_INFO_STRUCTURE = {
    name = "",
    area = {0.0, 0.0, 0.0, 0.0, 0.0}
}

-- Locker Data Structure
LOCKER_DATA_STRUCTURE = {
    sql_id = 0,
    pos = {0.0, 0.0, 0.0},
    virtual_world = 0,
    share = 0
}

-- Jurisdiction Data Structure
JURISDICTION_DATA_STRUCTURE = {
    sql_id = 0,
    area_name = ""
}

-- Group Vehicle Data Structure
GROUP_VEHICLE_STRUCTURE = {
    sql_id = 0,
    disabled = 0,
    spawned_id = 0,
    group_id = 0,
    division_id = 0,
    rank_id = 0,
    family_id = 0,
    type = 0,
    load_max = 0,
    model = 0,
    plate = "",
    max_health = 1000.0,
    fuel = 100.0,
    color1 = 0,
    color2 = 0,
    virtual_world = 0,
    interior = 0,
    pos_x = 0.0,
    pos_y = 0.0,
    pos_z = 0.0,
    rot_z = 0.0,
    upkeep = 0,
    modifications = {},
    attached_objects = {{
        id = 0,
        model = 0,
        pos = {0, 0, 0},
        rot = {0, 0, 0}
    }, {
        id = 0,
        model = 0,
        pos = {0, 0, 0},
        rot = {0, 0, 0}
    }}
}

-- Business Data Structure
BUSINESS_STRUCTURE = {
    name = "",
    owner = 0,
    owner_name = "",
    value = 0,
    type = 0,
    level = 1,
    level_progress = 0,
    auto_sale = 0,
    safe_balance = 0,
    inventory = 0,
    inventory_capacity = 100,
    status = 0,
    rank_pay = {0, 0, 0, 0, 0, 0},
    pos = {0.0, 0.0, 0.0},
    interior = 0,
    virtual_world = 0,
    entrance_fee = 0,
    till_balance = 0,
    extortion = 0,
    extortion_rate = 0,
    locks = 0,
    radio = 0,
    radio_freq = 0,
    delivery_point = {0.0, 0.0, 0.0},
    custom_interior = 0,
    custom_interior_pos = {0.0, 0.0, 0.0}
}

-- Property/House Data Structure
PROPERTY_STRUCTURE = {
    id = 0,
    description = "",
    owner = 0,
    owner_name = "",
    price = 0,
    rent_fee = 0,
    rent_available = 0,
    renter = 0,
    renter_name = "",
    pos = {0.0, 0.0, 0.0},
    interior = 0,
    virtual_world = 0,
    locks = 0,
    storage = {},
    weapons = {},
    drugs = {},
    money = 0,
    safe_balance = 0,
    alarm = 0,
    alarm_status = 0,
    rent_time = 0,
    custom_interior = 0,
    custom_interior_pos = {0.0, 0.0, 0.0},
    garage_pos = {0.0, 0.0, 0.0},
    garage_vehicles = {}
}

-- Vehicle Data Structure
VEHICLE_STRUCTURE = {
    id = 0,
    owner = 0,
    model = 0,
    color1 = 0,
    color2 = 0,
    pos = {0.0, 0.0, 0.0, 0.0},
    virtual_world = 0,
    interior = 0,
    health = 1000.0,
    fuel = 100.0,
    mileage = 0.0,
    engine = 0,
    lights = 0,
    alarm = 0,
    doors = 0,
    bonnet = 0,
    boot = 0,
    objective = 0,
    paintjob = 0,
    modifications = {},
    tinted_windows = 0,
    weapon_capacity = 0,
    weapons = {},
    drug_capacity = 0,
    drugs = {},
    impounded = 0,
    impound_fee = 0,
    plate = "",
    plate_type = 0,
    insurance = 0,
    registration = 0,
    tracking = 0,
    immobilizer = 0,
    alarm_upgrade = 0,
    lock_upgrade = 0
}

-- Character Data Structure (Extended)
CHARACTER_STRUCTURE = {
    -- Basic Information
    id = 0,
    username = "",
    password = "",
    salt = "",
    email = "",
    registered_date = "",
    last_login = "",

    -- Character Details
    char_name = "",
    age = 18,
    gender = 0, -- 0 = Male, 1 = Female
    ethnicity = 0,
    skin = 299,

    -- Position & World
    pos_x = 1481.0,
    pos_y = -1771.0,
    pos_z = 18.8,
    pos_a = 0.0,
    interior = 0,
    virtual_world = 0,

    -- Financial
    money = 5000,
    bank_money = 0,
    savings_money = 0,

    -- Statistics
    level = 1,
    experience = 0,
    hours_played = 0,

    -- Health & Status
    health = 100,
    armor = 0,
    hunger = 100,
    thirst = 100,
    bladder = 100,
    energy = 100,

    -- Administrative
    admin_level = 0,
    helper_level = 0,
    donator_level = 0,
    warns = 0,
    warn_time = 0,

    -- Faction & Job
    faction_id = 0,
    faction_rank = 0,
    faction_leader = false,
    job = 0,
    job_level = 1,
    job_exp = 0,

    -- Skills
    driving_skill = 0,
    flying_skill = 0,
    sailing_skill = 0,
    bike_skill = 0,

    -- Communication
    phone_number = 0,
    phone_book = {},
    sms_credits = 0,
    call_credits = 0,

    -- Inventory
    inventory = {},
    inventory_slots = 10,

    -- Weapons
    weapons = {},
    weapon_ammo = {},

    -- Vehicles
    vehicles_owned = {},
    current_vehicle = 0,

    -- Properties
    properties_owned = {},

    -- Temp/Session Data
    logged_in = false,
    spawned = false,
    character_selected = false,
    tutorial_step = 0,

    -- Misc
    mask_id = 0,
    disguise = false,
    radio_freq = 0,
    walkietalkie_freq = 0,

    -- Timers & Cooldowns
    last_command_time = 0,
    flood_protection = 0,

    -- Death & Medical
    injured = false,
    bleeding = false,
    unconscious = false,
    death_reason = "",

    -- Drugs & Addiction
    drug_addiction = {},
    drug_tolerance = {},

    -- Crime & Law
    wanted_level = 0,
    arrest_time = 0,
    jail_time = 0,
    crimes = {},

    -- Business & Economy
    businesses_owned = {},
    bank_pin = 0,
    credit_score = 100
}

-- Job Types
JOB_TYPES = {
    UNEMPLOYED = 0,
    TAXI_DRIVER = 1,
    BUS_DRIVER = 2,
    TRUCKER = 3,
    DELIVERY = 4,
    MECHANIC = 5,
    MEDIC = 6,
    POLICE = 7,
    FIREFIGHTER = 8,
    PILOT = 9,
    LAWYER = 10,
    BODYGUARD = 11,
    HITMAN = 12,
    DRUG_DEALER = 13,
    ARMS_DEALER = 14,
    THIEF = 15,
    SMUGGLER = 16,
    FARMER = 17,
    FISHERMAN = 18,
    MINER = 19,
    LUMBERJACK = 20
}

-- Faction Types
FACTION_TYPES = {
    CIVILIAN = 0,
    POLICE = 1,
    MEDICAL = 2,
    FIRE_DEPARTMENT = 3,
    GOVERNMENT = 4,
    GANG = 5,
    MAFIA = 6,
    BIKER_CLUB = 7,
    STREET_RACERS = 8,
    BUSINESS = 9,
    NEWS = 10
}

-- Business Types
BUSINESS_TYPES = {
    NONE = 0,
    RESTAURANT = 1,
    CLOTHING_STORE = 2,
    ELECTRONICS = 3,
    BANK = 4,
    GAS_STATION = 5,
    CASINO = 6,
    NIGHTCLUB = 7,
    BAR = 8,
    GUNSTORE = 9,
    CARDEALER = 10,
    PAINTBALL = 11,
    DRIVING_SCHOOL = 12,
    BOAT_DEALER = 13,
    AIRCRAFT_DEALER = 14,
    FURNITURE_STORE = 15,
    HARDWARE_STORE = 16,
    PHARMACY = 17,
    HOSPITAL = 18,
    MOVIE_THEATER = 19,
    INTERNET_CAFE = 20
}

-- Vehicle Types
VEHICLE_TYPES = {
    STANDARD = 0,
    POLICE = 1,
    MEDICAL = 2,
    FIRE = 3,
    GOVERNMENT = 4,
    TAXI = 5,
    BUS = 6,
    TRUCK = 7,
    BIKE = 8,
    BOAT = 9,
    AIRCRAFT = 10,
    SPECIAL = 11
}

-- Donator Levels
DONATOR_LEVELS = {
    NONE = 0,
    BRONZE = 1,
    SILVER = 2,
    GOLD = 3,
    PLATINUM = 4,
    DIAMOND = 5
}

-- Export all structures
_G.AMB_ENUMS = {
    GROUP_DATA_STRUCTURE = GROUP_DATA_STRUCTURE,
    STREET_INFO_STRUCTURE = STREET_INFO_STRUCTURE,
    LOCKER_DATA_STRUCTURE = LOCKER_DATA_STRUCTURE,
    JURISDICTION_DATA_STRUCTURE = JURISDICTION_DATA_STRUCTURE,
    GROUP_VEHICLE_STRUCTURE = GROUP_VEHICLE_STRUCTURE,
    BUSINESS_STRUCTURE = BUSINESS_STRUCTURE,
    PROPERTY_STRUCTURE = PROPERTY_STRUCTURE,
    VEHICLE_STRUCTURE = VEHICLE_STRUCTURE,
    CHARACTER_STRUCTURE = CHARACTER_STRUCTURE,
    JOB_TYPES = JOB_TYPES,
    FACTION_TYPES = FACTION_TYPES,
    BUSINESS_TYPES = BUSINESS_TYPES,
    VEHICLE_TYPES = VEHICLE_TYPES,
    ADMIN_LEVELS = ADMIN_LEVELS,
    DONATOR_LEVELS = DONATOR_LEVELS
}
