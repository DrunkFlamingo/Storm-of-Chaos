local soc_location = {} --# assume soc_location: SOC_LOCATION

--v function(model: STORM_OF_CHAOS,region_key: string) --> SOC_LOCATION
function soc_location.New(model,region_key)
    --institate new object
    local self = {}
    setmetatable(self, {
        __index = soc_location
    }) --# assume self: SOC_LOCATION

    self.model = model
    self.region_key = region_key



    return self
end