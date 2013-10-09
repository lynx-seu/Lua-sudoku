
local table = table

function makeRt( ... )

local rt = {}

--[[makes rt class]]  
	function rt:makeTable( t )
		rt.tab = {}
		rt.tab = t
	end  --[[]]
	
	function rt:rndNumber()
		local len = #rt.tab
		
		
		
	end
	
	function rt:getSize()
	
	
	end
	
	if { ... } then
		rt:makeTable( {...} )
	end
	
	return rt
	
end

function getTableSize( tab )
	local i = 0
	for k, v in pairs( tab ) do
		if type( i ) == "number" then
			i = i + 1
		else
			v = nil
			k = nil
		end
	end
	return i
end

function rand(num)
	local num = math.Round( math.random() * (num - 1) ) + 1
	return num
end

