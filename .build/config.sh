not_pushed_ignore=true

upload_to_wesnoth_versions=(1.16)

#icon() {
#	hex="misc/blank-hex.png"
#	drake="icons/unit-groups/race_drake_30.png"
#	drake2="$drake~FL()"
#	wose="icons/unit-groups/race_wose_30.png"
#	wose2="$wose~FL()"
#	echo "$hex~BLIT($drake,6,6)~BLIT($wose,9,36)~BLIT($drake2,39,6)~BLIT($wose2,36,36)"
#}
#addon_manager_args=("--pbl-key" "icon" "$(icon)")

addon_manager_args=("--pbl-key" "icon" "$(cat src/doc/icon.txt)")
