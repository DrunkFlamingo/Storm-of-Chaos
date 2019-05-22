local recruiter_unit = {} --# assume recruiter_unit: REC_UNIT

--v function(unit_key: string, absolute_key: string) --> REC_UNIT
function new_recruiter_unit(unit_key, absolute_key)
    local self = {} 
    setmetatable(self, {
        __index = recruiter_unit
    }) --# assume self: REC_UNIT

    self.absolute_key = absolute_key
    self.unit_key = unit_key
    self.is_default = (absolute_key == unit_key)
    self.groups = {} --:map<string, boolean>
    self.weight = 1 --:number

    return self
end

--v function(self: REC_UNIT, groupID: string)
function recruiter_unit.attach_group(self, groupID)
    self.groups[groupID] = true
end

--v function(self: REC_UNIT, weight: number)
function recruiter_unit.set_weight(self, weight)
    self.weight = weight
end