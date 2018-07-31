-- << mirror_main

local wesnoth = wesnoth
local ipairs = ipairs
local pairs = pairs
local table = table
local helper = wesnoth.require("lua/helper.lua")
local T = wesnoth.require("lua/helper.lua").set_wml_tag_metatable {}


--local side_to_team = {}
local team_array = {}
do
	local team_name_to_id = {}
	for _, side in ipairs(wesnoth.sides) do
		local team_id = team_name_to_id[side.team_name] or #team_array + 1
		team_name_to_id[side.team_name] = team_id
		-- side_to_team[side.side] = team_id
		team_array[team_id] = team_array[team_id] or {}
		local team_id_array = team_array[team_id]
		team_id_array[#team_id_array + 1] = side
	end
	for _, team_members in ipairs(team_array) do
		table.sort(team_members, function(a, b) return a.controller > b.controller end)
	end
	table.sort(team_array, function(a, b)
		return #a ~= #b and #a > #b or not a[1].__cfg.chose_random or b[1].__cfg.chose_random
	end)
end


local function unit_wml_copy(old_id, new_id, overrides)
	wesnoth.wml_actions.store_unit {
		T.filter { id = old_id },
		variable = "temp_unit",
	}
	local unit_var = wesnoth.get_variable("temp_unit")
	unit_var.id = new_id
	unit_var.underlying_id = new_id
	for k, v in pairs(overrides) do unit_var[k] = v end
	wesnoth.set_variable("temp_unit", unit_var)
	wesnoth.wml_actions.unstore_unit {
		variable = "temp_unit",
	}
	wesnoth.set_variable("temp_unit", nil)
end

local function stateless_iter(a, i)
	i = i + 1
	local v = a[i]
	if v then
		return i, v
	end
end

for _, team_members in stateless_iter, team_array, 1 do
	for member_index, side in ipairs(team_members) do
		local rolemodel_side = team_array[1][member_index]
		local rolemodel_leader = wesnoth.get_units { side = rolemodel_side.side, canrecruit = true }[1]

		side.recruit = rolemodel_side.recruit
		if (rolemodel_leader) then
			for _, old_leader in ipairs(wesnoth.get_units { side = side.side, canrecruit = true }) do
				local x, y, name = old_leader.x, old_leader.y, old_leader.name
				local new_id = rolemodel_leader.id .. "_mirrored_to_" .. old_leader.id
				wesnoth.wml_actions.kill { id = old_leader.id, fire_event = false, animate = false }
				unit_wml_copy(rolemodel_leader.id, new_id , {x = x, y = y, side = side.side, name = name})
			end
		end
	end
end


--function creepwars.leaders_mirror_show_warning()
--	wesnoth.wml_actions.message {
--		message = "Your Faction/Leader (side " .. wesnoth.current.side .. ") was replaced to allow fair game play.",
--		side_for = wesnoth.current.side,
--		speaker = "unit",
--	}
--end
--
----local sorted_sides = table.sort(wesnoth.sides, function(a, b)
----	return a.team_name ~= b.team_name and a.team_name < b.team_name
----	or a.controller ~= b.controller and a.controller > b.controller -- "human" > "ai"
----	or a.__cfg.chose_random > b.__cfg.chose_random
----end)
--
--local side_choices = table.sort(wesnoth.sides, function(a, b)
--	return a.controller ~= b.controller and a.controller > b.controller -- "human" > "ai"
--		or a.__cfg.chose_random ~= b.__cfg.chose_random and a.__cfg.chose_random > b.__cfg.chose_random
--		or a.team_name ~= b.team_name and a.team_name < b.team_name
--end)
--
--local function set_type(old_unit, type, is_downgrade)
--	--print("changing side", old_unit.side, old_unit.type, "to", type)
--	if is_downgrade == false
--		and wesnoth.sides[old_unit.side].__cfg.chose_random == false
--		and old_unit.type ~= type
--	then
--		-- print("will show a transformation warning for side" .. old_unit.side)
--		wesnoth.wml_actions.event {
--			name = "side " .. old_unit.side .. " turn 1",
--			T.lua { code = "creepwars.leaders_mirror_show_warning()" }
--		}
--	end
--	local new_unit = wesnoth.create_unit {
--		x = old_unit.x,
--		y = old_unit.y,
--		name = old_unit.name,
--		gender = old_unit.gender,
--		unrenamable = old_unit.unrenamable,
--		upkeep = old_unit.upkeep,
--		canrecruit = old_unit.canrecruit,
--		side = old_unit.side,
--		type = type
--	}
--	wesnoth.wml_actions.kill { id = old_unit.id, fire_event = false, animate = false }
--	wesnoth.put_unit(new_unit)
--end
--
--
--local function set_all_leaders(unit_array_function)
--	for team_index, side_array in ipairs(team_array) do
--		side_array = creepwars.array_filter(side_array, function(s)
--			return not is_ai_array[s] and #wesnoth.get_units { canrecruit = true, side = s } > 0
--		end)
--		local unit_array = unit_array_function()
--		for side_in_team_index, side_number in ipairs(side_array) do
--			local unit_type = unit_array[math.fmod(side_in_team_index - team_index + #side_array, #side_array) + 1]
--			for _, unit in ipairs(wesnoth.get_units { canrecruit = true, side = side_number }) do
--				set_type(unit, unit_type, false)
--			end
--		end
--	end
--end
--
--
--local function force_mirror()
--	local units = {}
--	while #units < #wesnoth.sides do
--		units[#units + 1] = random_leader()
--	end
--	for _, side_array in ipairs(creepwars.team_array) do
--		side_array = creepwars.array_filter(side_array, function(s)
--			return not is_ai_array[s] and #wesnoth.get_units { canrecruit = true, side = s } > 0
--		end)
--		for side_in_team_index, side_number in ipairs(side_array) do
--			--print("iterating over side", side_number,
--			--	"chose_random", wesnoth.sides[side_number].__cfg.chose_random,
--			--	"was type", wesnoth.get_units { canrecruit = true, side = side_number }[1].type)
--			if wesnoth.sides[side_number].__cfg.chose_random == false then
--				units[side_in_team_index] = wesnoth.get_units { canrecruit = true, side = side_number }[1].type
--			end
--		end
--	end
--	set_all_leaders(function() return units end)
--end
--
--
--local function force_same_cost()
--	local reference = { random_leader(), random_leader(), random_leader(), random_leader() }
--
--	local function generate_array()
--		local result_array = array_map(reference, function(ref_unit)
--			local unit
--			repeat
--				unit = random_leader()
--			until wesnoth.unit_types[unit].__cfg.cost == wesnoth.unit_types[ref_unit].__cfg.cost
--			return unit
--		end)
--		return result_array
--	end
--
--	return set_all_leaders(generate_array)
--end
--
--
--force_mirror()
---- force_same_cost()


-- >>
