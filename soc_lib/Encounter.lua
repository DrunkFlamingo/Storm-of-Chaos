soc_encounter = {} --# assume global soc_encounter: SOC_ENCOUNTER

--v function(model: STORM_OF_CHAOS,faction_key: string, starting_army_list: map<number, vector<string>>?, starting_validity: (map<number, function(context: STORM_OF_CHAOS)--> boolean>)?) --> SOC_ENCOUNTER
function soc_encounter.New(model, faction_key, starting_army_list, starting_validity)
    local self = {}
    setmetatable(self, {
        __index = soc_encounter
    })--# assume self: SOC_ENCOUNTER
    self.model = model
    self.faction_key = faction_key

    self.armies = starting_army_list or {} --:map<number, vector<string>>
    self.validity = starting_validity or {} --:map<number, function(context: STORM_OF_CHAOS)--> boolean>
    
    return self
end

