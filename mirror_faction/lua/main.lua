-- << mirror_main

local wesnoth = wesnoth
local mirrorfaction = mirrorfaction
local ipairs = ipairs
local T = wesnoth.require("lua/helper.lua").set_wml_tag_metatable {}

--wesnoth.dofile("~add-ons/mirror_faction/lua/main.lua")

local team_array = {}
do
	local team_name_to_id = {}
	for _, side in ipairs(wesnoth.sides) do
		local team_id = team_name_to_id[side.team_name] or #team_array + 1
		team_name_to_id[side.team_name] = team_id
		team_array[team_id] = team_array[team_id] or {}
		local team_id_array = team_array[team_id]
		team_id_array[#team_id_array + 1] = side
	end
end
for _, team_members in ipairs(team_array) do
	mirrorfaction.array_sort_by_tuple(team_members, function(e)
		return { not e.__cfg.allow_player, e.side }
	end)
end
mirrorfaction.array_sort_by_tuple(team_array, function(e)
	return { -#e, e[1].__cfg.chose_random, e[1].side }
end)


function mirrorfaction.leaders_mirror_show_warning()
	wesnoth.wml_actions.message {
		message = "Your Faction/Leader (side " .. wesnoth.current.side .. ") was replaced to allow fair game play.",
		side_for = wesnoth.current.side,
	}
end

local function set_unit_type(old_unit, type)
	--print("changing side", old_unit.side, old_unit.type, "to", type)
	if type ~= old_unit.type and wesnoth.sides[old_unit.side].__cfg.chose_random == false then
		print("scheduling transformation warning for side " .. old_unit.side)
		wesnoth.wml_actions.event {
			name = "side " .. old_unit.side .. " turn 1",
			first_time_only = true,
			T.lua { code = "mirrorfaction.leaders_mirror_show_warning()" }
		}
	end
	local new_unit = wesnoth.create_unit {
		x = old_unit.x,
		y = old_unit.y,
		name = old_unit.name,
		gender = old_unit.gender,
		unrenamable = old_unit.unrenamable,
		upkeep = old_unit.upkeep,
		canrecruit = old_unit.canrecruit,
		side = old_unit.side,
		max_moves = old_unit.max_moves > 4 and old_unit.max_moves or 5,
		type = type
	}
	wesnoth.wml_actions.kill { id = old_unit.id, fire_event = false, animate = false }
	wesnoth.put_unit(new_unit)
end

local function random_leader_type(faction_id, exclude)
	local faction = mirrorfaction.faction_map[faction_id]
	local leaders_all = mirrorfaction.split_comma_units(faction.random_leader or faction.leader)
	local leaders_filtered = mirrorfaction.array_filter(leaders_all, function(e) return not exclude[e] end)
	-- print_as_json("all", leaders_all, "filtered", leaders_filtered, "exclude", exclude)
	return #leaders_filtered > 0 and leaders_filtered[wesnoth.random(#leaders_filtered)]
		or leaders_all[wesnoth.random(#leaders_all)]
end

local exclude_set = {}
for team_index, team_members in mirrorfaction.stateless_iter, team_array, 0 do
	for member_index, side in ipairs(team_members) do
		local rolemodel_side = team_array[1][member_index]
		local rolemodel_leader = wesnoth.get_units { side = rolemodel_side.side, canrecruit = true }[1]

		side.recruit = rolemodel_side.recruit
		if (rolemodel_leader) then
			for _, old_leader in ipairs(wesnoth.get_units { side = side.side, canrecruit = true }) do
				local new_type = (team_index == 1) and rolemodel_leader.type
					or random_leader_type(rolemodel_side.faction, exclude_set)
				exclude_set[new_type] = true
				set_unit_type(old_leader, new_type)
			end
		end
	end
end


-- >>
