-- << mirrorfaction_utils

_G.mirrorfaction = {}
local mirrorfaction = mirrorfaction
local ipairs = ipairs
local table = table
local type = type

function mirrorfaction.stateless_iter(a, i)
	i = i + 1
	local v = a[i]
	if v ~= nil then
		return i, v
	end
end

function mirrorfaction.array_filter(arr, func)
	local result = {}
	for _, elem in ipairs(arr) do
		if func(elem) then result[#result + 1] = elem end
	end
	return result
end


local function compare_array(arr_left, arr_right)
	for i = 1, #arr_left do
		local prop_left, prop_right = arr_left[i], arr_right[i]
		if prop_left ~= prop_right then
			if type(prop_left) == "boolean" then
				return not prop_left and prop_right
			else
				return prop_left < prop_right
			end
		end
	end
end


function mirrorfaction.array_sort_by_tuple(arr, func) -- possible to introduce `func` caching
	table.sort(arr, function(elem_left, elem_right)
		return compare_array(func(elem_left), func(elem_right))
	end)
end


-- >>
