#Move sections into dictionaries later on to make it more organized and easier to manage
 #Variables with a value have placeholders as starting values, must be adjusted later.

    #Declare Health and Mana variables for the player character 
    var health_and_mana = {
        "player_current_health": 100, # Current health of the player character
        "player_max_health": 100, # Maximum health of the player character, which can be increased through leveling up or equipping certain items
        "player_max_health_increase_per_level": 10, # Amount by which maximum health increases per level
        "player_is_dead": false, # Whether the player character is currently dead, which can affect certain abilities and interactions
        "player_is_alive": true, # Whether the player character is currently alive, which can affect certain abilities and interactions
        "player_current_mana": 100, # Current mana of the player character
        "player_max_mana": 100, # Maximum mana of the player character, which can be increased through leveling up or equipping certain items
        "player_max_mana_increase_per_level": 10 # Amount by which maximum mana increases per level
    }

    #Variables to control movement
    var move_variables = {
        "player_move_speed": 100, # Base movement speed of the character, which can be modified by certain effects and equipment
        "player_is_moving": true, # Whether the character is currently moving, which can affect certain abilities and interactions
        "player_is_not_moving": false # Whether the character is currently not moving, which can affect certain abilities and interactions
    }

    #Declare variables for the player's level and experience points, wait to write until after party system is implemented to make it easier to manage and adjust as needed

    #Declare Character stats variables
    var character_attributes = {
        "strength": 10, # Physical power and damage calculation value
        "intelligence": 10, # Mental acuity (lesser effects on mental stability negative effects) and magical power (extra damage)
        "vitality": 10, # Physical toughness and endurance, which can increase health and reduce damage taken
        "willpower": 10, # Magic Defence and Healing Potency
        "agility": 10, # Turn/ATB Speed, Accuracy, Evasion
        "luck": 10 # Crit rate, proc odds, rare item drop rate, and other chance-based effects
    }

    #Declare variables for the player's inventory and equipment
    var player_inventory = [] # List to hold the player's inventory items, which can include consumables, crafting materials, and quest items


    var player_equipment = { # Dictionary to hold the player's equipped items, which can include weapons, armor, and accessories
        "weapon": null, # The currently equipped weapon, which can affect damage output and certain abilities
        "armor": null, # The currently equipped armor, which can affect defense and certain abilities
        "accessory": null, # The currently equipped accessory, which can provide various bonuses and effects
        "boots": null, # The currently equipped boots, which can affect movement speed and certain abilities
        "helmet": null, # The currently equipped helmet, which can affect defense and certain abilities
    }

    #Declare variables for party members

    var party_members = {
        {"name": "Rolin",
        "rolin_"
        "rolin_current_health": 100,
        "rolin_max_health": 100}
    } 