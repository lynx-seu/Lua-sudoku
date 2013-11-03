
--[[ TABLE UTILITIES ]]

function table.copy(tab)
	tbl = {}
	for k, v in pairs(tab) do
		if type(v) == "table" then 
			tbl[k] = {}
			tbl[k] = table.copy(v) --recursion ho!
		else
			tbl[k] = v
		end
	end
	return tbl
end

--[[ transforms given table into a set where key is number and value is times it (number) appeared in the table ]]
function table.getNumberCounts( tab )
	local set = {}
	for k, v in pairs( tab ) do
		set[v] = (set[v] or 0) + 1 
	end
	return set
end

--[[checks if given table has the value]]
function table.hasValue( tab, val )
	for k, v in pairs( table.getNumberCounts( tab ) ) do
		if k == val and v > 0 then return true end --
	end
	return false
end

function table.filledSet( tab )
	local setTable = table.getNumberCounts( tab )
	if setTable[0] then return false, setTable[0].." zeroes exist" end
	--for i = 1, 9 do
	for k, v in pairs( setTable ) do
		if v ~= 1 then return false, "Error on number "..k end
	end

	return true, "Everything seems correct"
end

function table.allOfValue(tab, val)
	if not val then val = 1 end
	for k, v in pairs( tab ) do
		if not v == val then return false end
	end
	return true
end

function printTable( tab, offset )
	if not offset then offset = "" end
	

	for k, v in pairs( tab ) do
		if type(v) == "table" then
			printTable(v, offset.."\t")
		end
		print(offset..tostring(k).." : "..tostring(v))--.."\n")
	end

end
