#-------------------------------------------------------------------------------------------------------------------------------------------------
#                       Health & Mana Stats
#-------------------------------------------------------------------------------------------------------------------------------------------------

var health_and_mana = {

}
    #Took these out of dictionary, to identify character stats more easily.
    "current_health": 100,
    "max_health": 100,
    "current_mana": 100,
    "max_mana": 100

    #-----------------------------------------------------Health & Mana Stat Helper Functions---------------------------------------------


var amount = 20 
func heal(target, amount):
    target.current_health += amount
    if target.current_health > target.max_health:
        target.current_health = target.max_health
    pass

#-------------------------------------------------------------------------------------------------------------------------------------------------
#                       Attribute Stats
#-------------------------------------------------------------------------------------------------------------------------------------------------
#Now each condition is keyed by name, so you can look one up with status_conditions["Poison"] and check its type with status_conditions["Poison"]["condition_type"]
#-------------------------------------------------------------------------------------------------------------------------------------------------

var stats = { #Enter name_ before stats variable when code is added to party member dictionaries to make it easier to manage and adjust as needed
    "strength": 10,
    "intelligence": 10,
    "vitality": 10,
    "willpower": 10,
    "agility": 10,
    "luck": 10
}

#-------------------------------------------------------------------------------------------------------------------------------------------------
#                       Status Conditions ()
#-------------------------------------------------------------------------------------------------------------------------------------------------

var status_conditions = { #Add actual details later, potentially rework
    "Poison": {"condition_type": "damage_over_time"},
    "Silenced": {"condition_type": "status_effect"},
    "Sleep": {"condition_type": "status_effect"},
    "Burn": {"condition_type": "damage_over_time"},
    "Cursed": {"condition_type": "status_effect"},
    "Frozen": {"condition_type": "status_effect"},
    "Paralyzed": {"condition_type": "status_effect"},
    "Confused": {"condition_type": "status_effect"},
    "Bleeding": {"condition_type": "damage_over_time"},
    "Stunned": {"condition_type": "status_effect"}
}


#-------------------------------------------------------------------------------------------------------------------------------------------------
#                       Helper Functions
#-------------------------------------------------------------------------------------------------------------------------------------------------
func apply_status_condition(target, condition):
    # Apply the specified status condition to the target character
    pass