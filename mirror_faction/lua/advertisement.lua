-- << mirrorfaction_advertisement

local wesnoth = wesnoth
local tostring = tostring

local script_arguments = ...
local remote_version = tostring(script_arguments.remote_version)

if not wesnoth.have_file("~add-ons/mirror_faction") then
	wesnoth.message("", "Factions are mirrored using 'Mirror Faction' add-on. If you like it, feel free to download it.")
else
	local local_version = wesnoth.read_file("~add-ons/mirror_faction/target/version.txt")
	if wesnoth.compare_versions(remote_version, ">", local_version) then
		wesnoth.wml_actions.message {
			caption = "Mirror Faction",
			message = [[🠉🠉🠉 Please upgrade your Mirror Faction add-on 🠉🠉🠉

(You can do that after the game)]],
			image = "misc/blank-hex.png~BLIT(icons/unit-groups/race_drake_30.png,5,6)~BLIT(icons/unit-groups/race_wose_30.png,9,36)~BLIT(icons/unit-groups/race_drake_30.png~FL(),40,6)~BLIT(icons/unit-groups/race_wose_30.png~FL(),36,36)",
		}
	end
end

-- >>
