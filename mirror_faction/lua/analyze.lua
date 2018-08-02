-- << mirror_analyze


local wesnoth = wesnoth
local mirrorfaction = mirrorfaction
local string = string
local helper = wesnoth.require("lua/helper.lua")


mirrorfaction.faction_map = {}
local faction_map = mirrorfaction.faction_map
for multiplayer_side in helper.child_range(wesnoth.game_config.era, "multiplayer_side") do
	faction_map[multiplayer_side.id] = multiplayer_side
end


function mirrorfaction.split_comma_units(string_to_split)
	local result = {}
	local n = 1
	for s in string.gmatch(string_to_split or "", " *[^,]+ *") do
		--print_as_json("checking advance string", s)
		if s ~= "" and s ~= "null" and wesnoth.unit_types[s] then
			result[n] = s
			n = n + 1
		end
	end
	--print_as_json("split: acceptable upgrades:", result)
	return result
end


-- >>
