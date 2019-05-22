--[[
    REC_MAN
    REC_CHAR
    REC_PATH
    REC_UNIT
    REC_CTRL

class: RecruiterManager --REC_MAN
    subobject: Controller --REC_CTRL
    subobject: RecruiterCharacters --map<CA_CQI, REC_CHAR>
    subobject: DefaultUnits --:map<string, REC_UNIT>
    field: group_limits --map<string, string>
    field: selectedCharacterCQI
    field: 




]]--