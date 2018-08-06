-- << mirrorfaction_advertisement

local wesnoth = wesnoth
local tostring = tostring

local script_arguments = ...
local remote_version = tostring(script_arguments.remote_version)
local filename = "~add-ons/mirror_faction/target/version.txt"

local side = wesnoth.sides[wesnoth.current.side]
if not side.is_local and side.controller == "human" then
	if not wesnoth.have_file(filename) then
		wesnoth.message("", "Factions are mirrored using 'Mirror Faction' add-on. If you like it, feel free to download it.")
	else
		local local_version = wesnoth.read_file(filename)
		if wesnoth.compare_versions(remote_version, ">", local_version) then
			wesnoth.wml_actions.message {
				caption = "Mirror Faction",
				message = "🠉🠉🠉 Please upgrade your Mirror Faction add-on 🠉🠉🠉"
					.. "\n\n"
					.. local_version .. " -> " .. remote_version
					.. "(You can do that after the game)",
				image = "misc/blank-hex.png~BLIT(icons/unit-groups/race_drake_30.png,5,6)~BLIT(icons/unit-groups/race_wose_30.png,9,36)~BLIT(icons/unit-groups/race_drake_30.png~FL(),40,6)~BLIT(icons/unit-groups/race_wose_30.png~FL(),36,36)",
			}
		end
	end
	wesnoth.wml_actions.remove_event { id = "mirrorfaction_ad" }
end

-- >>
