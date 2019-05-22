local recruiter_character = {} --# assume recruiter_character: REC_CHAR

--v function(cqi: CA_CQI, model: REC_MAN) --> REC_CHAR
function new_recruiter_character(cqi, model)
    local self = {}
    setmetatable(self, {
        __index = recruiter_character
    }) --# assume self: REC_CHAR

    self.cqi = cqi
    self.model = model
    self.army_counts = {} --:map<string, number>
    --maps unit keys to quantities in the army
    self.queue_counts = {} --:map<string, number> 
    --maps unit keys to quantities in the queue
    self.army_refresh_is_required = true --:boolean
    self.queue_refresh_is_required = true --:boolean
    --flags for re-evaluating the army and queue
    self.owned_units = {} --:map<string, REC_UNIT>
    --maps unit keys to copies of rec unit objects for their abstraction
    self.group_counts = {} --:map<string, number>
    --maps string group keys to the quantity of units currently possessed in both queue and army.

    return self
end


