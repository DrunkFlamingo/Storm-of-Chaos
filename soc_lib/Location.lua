local soc_location = {} --# assume soc_location: SOC_LOCATION

--v function(model: STORM_OF_CHAOS,region_key: string, exits: vector<string>) --> SOC_LOCATION
function soc_location.New(model,region_key, exits)
    --institate new object
    local self = {}
    setmetatable(self, {
        __index = soc_location
    }) --# assume self: SOC_LOCATION

    self.model = model
    self.region_key = region_key

    self.encounter_chances = {} --:map<number, map<string, number>> 
    --maps game stage (0-3) to encounter faction name and percent chance.
    self.x = SOC_REGION_LOCATIONS[region_key][1]
    self.y = SOC_REGION_LOCATIONS[region_key][2]
    self.exits = exits
    --a vector of regions you can travel to from here.
    self.is_port = false

    self.has_occupant = false --:boolean
    self.occupant_cqi = nil --:CA_CQI

    return self
end

--v function(self: SOC_LOCATION) --> CA_FACTION
function soc_location.OwningFaction(self)
    local region = cm:get_region(self.region_key)
    if region:is_abandoned() then
        return nil
    else
        return region:owning_faction()
    end
end

--v function(self: SOC_LOCATION) --> boolean
function soc_location.HasOccupant(self)
    return self.has_occupant
end

--v function(self: SOC_LOCATION) --> CA_CHAR
function soc_location.GetOccupant(self)
    if self.has_occupant == false then
        return nil
    end
    return cm:get_character_by_cqi(self.occupant_cqi)
end


--v function(self: SOC_LOCATION, encounter_faction: string, encounter_stage: number, encounter_chance: number)
function soc_location.AddEncounter(self, encounter_faction, encounter_stage, encounter_chance)
    self.encounter_chances[encounter_stage] = self.encounter_chances[encounter_stage] or {}
    self.encounter_chances[encounter_stage][encounter_faction] = encounter_chance
end
