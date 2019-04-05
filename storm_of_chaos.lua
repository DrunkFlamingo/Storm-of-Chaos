--v function(t: any)
local function print(t)



end

--these functions create objects

--v function(x: number, y: number, region: string, owner: string, exits: vector<string>) --> SOC_LOCATION
local function create_location(x, y, region, owner, exits)
    local location = {}
    --# assume location: SOC_LOCATION
    location.x = x
    location.y = y
    location.region = region
    location.has_encounter = false --:boolean
    location.encounter = nil --:SOC_ENCOUNTER
    location.owner = cm:get_saved_value("soc_location_saves_"..region.."_owner") or owner
    location.exits = exits
    --v function(self: SOC_LOCATION, encounter: SOC_ENCOUNTER)
    function location.add_encounter(self, encounter)
        self.encounter = encounter
        self.has_encounter = true
    end
    
    location.is_occupied = false --:boolean
    location.occupying_character = nil --:CA_CQI
    --v function(self: SOC_LOCATION, cqi: CA_CQI)
    function location.set_occupant(self, cqi)
        self.occupying_character = cqi
        self.is_occupied = not not cqi
    end

    return location
end

--# type global ENCOUNTER_TYPE = "dilemma" | "incident" | "army"
--v function(encounter_type: ENCOUNTER_TYPE) --> SOC_ENCOUNTER
local function create_encounter(encounter_type)
    local encounter = {}
    --# assume encounter: SOC_ENCOUNTER
    encounter.type = encounter_type
    encounter.faction = nil --:string
    encounter.has_faction = false --:boolean
    encounter.event_key = nil --:string
    encounter.has_event = false --:boolean
    encounter.army = nil --:string
    encounter.has_army = false --:boolean

    --v function(self: SOC_ENCOUNTER, event_key: string)
    function encounter.add_event(self, event_key)
        if self.type == "army" then
            print("tried to add an event to an army encounter!")
            return
        end
        self.event_key = event_key
        self.has_event = true
    end

    --v function(self: SOC_ENCOUNTER, faction: string)
    function encounter.add_faction(self, faction)
        self.faction = faction
        self.has_faction = true
    end

    --v function(self: SOC_ENCOUNTER, army: string)
    function encounter.add_army(self, army)
        if self.type ~= "army" then
            print("tried to add an event to an army encounter!")
            return
        end
        self.army = army
        self.has_army = true
    end


    return encounter
end

--v function(faction: string, subtype: string, forename: string, surname: string, spawnable_regions: vector<string>) --> SOC_BOSS
local function create_boss(faction, subtype, forename, surname, spawnable_regions)
   local boss = {}
   --# assume boss: SOC_BOSS 
    boss.faction = faction
    boss.is_active = not cm:get_faction(faction):is_dead()
    cm:disable_movement_for_faction(faction)
    if boss.is_active then
        boss.location = cm:get_faction(faction):faction_leader():region():name()
    else
        boss.location = nil
    end
    boss.subtype = subtype
    boss.forename = forename
    boss.surname = surname
    boss.spawnable_regions = spawnable_regions
    boss.can_spawn = false
    boss.condition = nil --:function() --> boolean
    --v function(self: SOC_BOSS, condition: function() --> boolean)
    function boss.add_condition(self, condition)
        self.can_spawn = true
        self.condition = condition
    end
    boss.movement_function = nil --:function()
    boss.can_move = false
    return boss
end
storm_of_chaos = {} --# assume storm_of_chaos: STORM_OF_CHAOS
storm_of_chaos.locations = {} --:map<string, SOC_LOCATION>
storm_of_chaos.encounters = {} --:map<string, SOC_ENCOUNTER>






local LOCATIONS = require("region_locations")
cm.first_tick_callbacks[#cm.first_tick_callbacks] = function(context)
    for key, coords in pairs(LOCATIONS) do
        --# assume key: string
        --# assume coords: {number, number}
        local region = cm:get_region(key)
        local owner --:string
        if region:is_abandoned() then
            owner = "abandoned"
        else
            owner = region:owning_faction():name()
        end
        local exits = {} --:vector<string>
        for i = 0, region:adjacent_region_list():num_items() - 1 do
            table.insert(exits, region:adjacent_region_list():item_at(i):name())
        end
        create_location(coords[1], coords[2], key, owner, exits)
    end
end


--v function(character: CA_CHAR, callback: function(context: WHATEVER))
local function add_finished_moving_callback(character, callback)
    core:add_listener(
        "CharacterFinishedMovingCallback_"..tostring(character:command_queue_index()),
        "CharacterFinishedMovingEvent",
        function(context)
            return context:character():command_queue_index() == character:command_queue_index()
        end,
        function(context)
            callback(context)
        end, false)
end

--v function(faction_key: string, region_key: string)
local function move_character_to_region(faction_key, region_key)
    local region = cm:get_region(region_key)
    local faction = cm:get_faction(faction_key)
    local location = storm_of_chaos.locations[region_key]
    local character = faction:faction_leader()

    if location.is_occupied then
        local occupant_cqi = location.occupying_character
        if not faction:at_war_with(cm:get_character_by_cqi(occupant_cqi):faction()) then
            cm:force_declare_war(cm:get_character_by_cqi(occupant_cqi):faction():name(), faction_key, false, false)
        end
        cm:attack(cm:char_lookup_str(character), cm:char_lookup_str(occupant_cqi), true)
    else
        if faction:is_human() and location.has_encounter then
            if location.encounter.type == "army" then
                cm:create_force(location.encounter.faction, location.encounter.army, region_key, location.x, location.y, true, function(char_cqi)
                    if not faction:at_war_with(cm:get_character_by_cqi(char_cqi):faction()) then
                        cm:force_declare_war(cm:get_character_by_cqi(char_cqi):faction():name(), faction_key, false, false)
                    end
                    cm:attack(cm:char_lookup_str(character), cm:char_lookup_str(char_cqi), true)
                end)
            elseif location.encounter.type == "dilemma" then
                cm:move_to(cm:char_lookup_str(character), location.x, location.y, true)
                add_finished_moving_callback(character, function(context)
                    cm:trigger_dilemma(faction_key, location.encounter.event_key, true)
                end)
            elseif location.encounter.type == "incident" then
                cm:move_to(cm:char_lookup_str(character), location.x, location.y, true)
                add_finished_moving_callback(character, function(context)
                    cm:trigger_incident(faction_key, location.encounter.event_key, true)
                end)
            end
        else
            cm:move_to(cm:char_lookup_str(character), location.x, location.y, true)
        end
    end
end