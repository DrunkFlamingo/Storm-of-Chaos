soc_boss = {} --# assume soc_boss: SOC_BOSS


--v function(model: STORM_OF_CHAOS, faction_key: string, spawn_regions: map<number,string>, conquest_rate: number, conquest_path: vector<string>, goal_region: string, hunt_player: boolean, random_move_after_goal: boolean) --> SOC_BOSS
function soc_boss.new_boss(model, faction_key, spawn_regions, conquest_rate, conquest_path, goal_region, hunt_player, random_move_after_goal)
    local self = {}
    setmetatable(self, {
        __index = soc_boss
    }) --# assume self: SOC_BOSS

    self.model = model
    self.faction_key = faction_key
    self.spawn_regions = spawn_regions
    self.conquest_path = conquest_path
    self.conquest_rate = conquest_rate
    self.goal_region = goal_region
    self.hunt_player = hunt_player
    self.random_move_after_goal = random_move_after_goal

    return self
end


