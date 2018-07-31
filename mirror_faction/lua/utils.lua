-- << mirrorfaction_utils

_G.mirrorfaction = {}
local mirrorfaction = mirrorfaction
local table = table
local type = type


function mirrorfaction.stateless_iter(a, i)
	i = i + 1
	local v = a[i]
	if v ~= nil then
		return i, v
	end
end


function mirrorfaction.array_sort_by_tuple(arr, func) -- possible to introduce `func` caching
	table.sort(arr, function(left_elem, right_elem)
		local left_arr, right_arr = func(left_elem), func(right_elem)
		for i = 1, #left_arr do
			local left_prop, right_prop = left_arr[i], right_arr[i]
			if left_prop ~= right_prop then
				if type(left_prop) == "boolean" then
					return not left_prop and right_prop
				else
					return left_prop < right_prop
				end
			end
		end
	end)
end


-- >>
