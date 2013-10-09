
local font_30 = love.graphics.newFont( "coolvetica.ttf", 30)
local font_16 = love.graphics.newFont( "coolvetica.ttf", 16)

function giveBoard()

	local game = {}
	
	game.state = "pregame"
	-- "pregame" 	- before board generation  --sounds weird
	-- "play" 		- normal play state
	-- "pause" 		- paused
	
	game.drawing = {}
	game.drawing.step = 40
	game.drawing.min  = 30
	
	game.selection = {}
	game.selection.square = 0
	game.selection.subsquare = 0
	game.selection.last = { 0, 0 }
	
	game.options = {}
	
--[[  -=Table structure=-
	
	row| 1 2 3 4 5 6 7 8 9           
	---+-----------------          
	   | 1 2 3 4 5 6 7 8 9       
	   | 1 2 3 4 5 6 7 8 9
	   | 1 2 3 4 5 6 7 8 9
	   | 1 2 3 4 5 6 7 8 9
	   | 1 2 3 4 5 6 7 8 9
	   | 1 2 3 4 5 6 7 8 9
	   | 1 2 3 4 5 6 7 8 9
	   | 1 2 3 4 5 6 7 8 9
	   | 1 2 3 4 5 6 7 8 9
	]]
	
	--[[  Square/subsquare structure  (numpad)
	
	   |   |		789|789|798
	 7 | 8 | 9		456|456|456
	   |   |		123|123|123
	---+---+---		---+---+---
	   |   |		789|789|789
	 4 | 5 | 6		456|456|456
	   |   |		123|123|123
	---+---+---		---+---+---
	   |   |		789|789|789
	 1 | 2 | 3		456|456|456
	   |   |		123|123|123
	]]
	
--[[ board initialization ]]
	function game:createBoard()
		self.field = {}
		
		for i = 1, 9 do
			self.field[i] = {}
			for j = 1, 9 do
				--sudoku cell data
				-- val 	- number
				-- ed	- editable
				-- col	- color
				self.field[i][j] = {val = 0, ed = true}
			end
		end
		
	end
	
	
--[[ makes random value table]]
	function game:testBed()
		for i = 1, 9 do
			for j = 1, 9 do
				if testL(0.25) then
					self.field[i][j] = {val = testN(), ed = testL(0.25)}
				end
			end
		end
	end
	
--[[uşkrauna şaidimà su taisyklëmis]]
	function game:load( settings )
		self.options = settings
		self:createBoard()
		--self:testBed()
	end
	
--[[ main draw function ]]
	function game:draw()
		if self.state == "pregame" then
			self:drawBorder()
		elseif self.state == "play" then
			self:drawBoard()
		end
		self:drawGUI()
	end
	
--[[ draws only edges ]]
	function game:drawBorder()
		love.graphics.setLineWidth(3)
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.line( self.drawing.min, self.drawing.min, self.drawing.min + self.drawing.step * 9, self.drawing.min )
		love.graphics.line( self.drawing.min, self.drawing.min, self.drawing.min, self.drawing.min + self.drawing.step * 9 )
		love.graphics.line( self.drawing.min + self.drawing.step * 9 , self.drawing.min + self.drawing.step * 9 , self.drawing.min + self.drawing.step * 9, self.drawing.min )
		love.graphics.line( self.drawing.min + self.drawing.step * 9 , self.drawing.min + self.drawing.step * 9 , self.drawing.min, self.drawing.min + self.drawing.step * 9 )
	end
	
--[[ draws the whole board ]]
	function game:drawBoard()
	
	--[[ variables ]]
		local step = self.drawing.step
		local min = self.drawing.min
		local max = min + 9 * step
	
		love.graphics.setColor( 255, 255, 255 )
	
	--[[ draws the net ]]
		for i = 0, 9 do
			if i % 3 == 0 then 
				love.graphics.setLineWidth(3)
			else
				love.graphics.setLineWidth(1)
			end
			love.graphics.line( min + i * step, min 		  , min + i * step, max 		   )
			love.graphics.line( min			  , min + i * step, max			  , min + i * step )
		end
		
	--[[ draws selections ]]
		if validSelection( self.selection.subsquare ) and validSelection( self.selection.square ) then
			love.graphics.setColor( 0, 120, 0 )
			love.graphics.setLineWidth(3)
			local x, y = translateNumber( self.selection.square )
			local sx, sy = min + step * 3 * x, min + step * 3 * y
			love.graphics.rectangle( "line", sx, sy, step * 3, step * 3 )
			
			love.graphics.setColor( 0, 255, 0 )
			love.graphics.setLineWidth(1)
			x, y = translateNumber( self.selection.subsquare )
			local dx, dy = sx + x * step, sy + y * step
			love.graphics.rectangle( "line", dx, dy, step, step )
		elseif validSelection( self.selection.square ) then
			love.graphics.setColor( 0, 255, 0 )
			love.graphics.setLineWidth(3)
			local x, y = translateNumber( self.selection.square )
			love.graphics.setLineWidth(3)
			local sx, sy = min + step * 3 * x, min + step * 3 * y
			love.graphics.rectangle( "line", sx, sy, step * 3, step * 3 )
		end
		
	--[[ draws numbers]]
		love.graphics.setFont( font_30 )
		for x = 1, 9 do
			for y = 1, 9 do
				--local num, lock = self.field[x][y].val, self.field[x][y].ed
				local num, lock = self:getNumber(x, y)
				
				if validSelection( num ) then 
					--love.graphics.print(num, min + (x - 0.5) * step, min + (y - 0.5) * step, 0)--, step/3*2, step/3*2)--, step * 0.5, step*0.5 )
					if not lock then
						love.graphics.setColor( 255, 255, 255 )
					else
						love.graphics.setColor( 155, 155, 155 )
					end
					love.graphics.print(num, min + (x - 0.5) * step, min + (y - 0.5) * step, 0, 1, 1, 8, 17)--, step/3*2, step/3*2)--, step * 0.5, step*0.5 )
					--love.graphics.print( text, x, y, r, sx, sy, ox, oy, kx, ky )
				end
				
			end
		end
		
	end
	
--[[ draws GUI ]]
	function game:drawGUI()
		if self.state == "pregame" then
			love.graphics.print( "Press 1 for a garbled random board", 100, 100 )
			love.graphics.print( "Press 2 for a totally empty board", 100, 120 )
		end
	
	end
	
--[[ keypress handling ]]
	function game:keyPress(k, u)
		if self.state == "pregame" then
			if k == "1" then
				self:testBed()
				self.state = "play"
			elseif k == "2" then
				self.state = "play"
			end
			return
		end
	
		local numberKey = validKey( k ) --current key
		if numberKey and self.state == "play" then 
			self:handleKeyNumber(numberKey) 
			return --don't continue keypress, not that it's required now
		end
		
	end
	
--[[ handle selection press ]]
	function game:handleKeyNumber(num)
	
		if num == -1 then -- doesn't do anything yet
			if validSelection( self.selection.last[1] ) and validSelection( self.selection.last[2] ) then
					self.selection.square 		= self.selection.last[1]
					self.selection.subsquare 	= self.selection.last[2]
					self.selection.last = nil
			end			
		elseif num == 0 then -- backs a selection
			if validSelection( self.selection.subsquare ) and validSelection( self.selection.square ) then
				self.selection.subsquare = 0
			elseif validSelection( self.selection.square ) then
				self.selection.square = 0
			end
		elseif validSelection( self.selection.subsquare ) then  -- tries to set a value
			self:setNumber( num, self.selection.subsquare, self.selection.square )
		elseif validSelection( self.selection.square ) then -- sets selection to a valid sub-square
			if validSelection( num ) then
				--local cx, cy = coordinateFromSquares( self.selection.square, num )
				--if self.field[cx][cy].ed then
				--	self.selection.subsquare = num
				--end
				if self:getNumberSq( self.selection.square, num, true ).ed then
					self.selection.subsquare = num
				end
			end
		else -- sets a slection square
			self.selection.square = num
		end
		
	end
	
--[[subsquare method of setting numbers]]
	function game:setNumber( num, sub, sq )
		self.selection.last = { self.selection.square, self.selection.subsquare }
		self.selection.number 		= 0
		self.selection.subsquare 	= 0
		self.selection.square 		= 0
				
		local cx, cy = coordinateFromSquares( sq, sub )
				
		--check if allowed to change number
		if self.field[cx][cy].ed then 
			self.field[cx][cy].val = num
			self.selection.number 		= 0
			self.selection.subsquare 	= 0
			self.selection.square 		= 0
			return true
		end
		
		return false
	end
	
	--[[based on squares returns value and edit flag OR the cell table]]
	function game:getNumberSq(sub, sq, tab)
		local cx, cy = coordinateFromSquares( sq, sub )
		if tab then return self.field[cx][cy] end
		return self.field[cx][cy].val, self.field[cx][cy].ed
	end
	
	--[[based on x,y returns value and edit flag OR the cell table]]
	function game:getNumber(x, y, tab)
		if tab then return self.field[x][y] end
		return self.field[x][y].val, self.field[x][y].ed
	end
	
	--[[ returns a list with values from row ]]
	function game:getRowList( row )
		local tab = {}
		for i = 1, 9 do
			--tab[i] = self.field[row][i].val
			tab[i] = self:getNumber(row, i)
		end
		return tab
	end
	
	--[[ returns a list with values from column ]]
	function game:getColumnList( column )
		local tab = {}
		for i = 1, 9 do
			--tab[i] = self.field[i][column].val
			tab[i] = self:getNumber(i, column)
		end
		return tab
	end
	
	--[[ returns a list with values from a square ]]
	function game:getSquareList( sq )
		local tab = {}
		for i = 1, 9 do
			local cx, cy = coordinateFromSquares( sq, i )
			tab[i] = self:getNumber(cx, cy)
		end
		return tab
	end
	
	--[[ returns a table of duplicates]]
	--[[ key is number, value is times it appears ]]
	function game:getDuplicateSumTable( tab )
		test = {}
		for k, v in pairs( tab ) do
			test[v] = (test[v] or 0) + 1
		end
		return test
	end
	
	--[[ returns if table has duplicates ]]
	function game:areDuplicates( tab, num )
		return tab[num] or 0
	end
	
	--function game:
	
	return game
	
end

function validSelection( num )
	if type(num) == "number" then 
		return num > 0 and num < 10 
	end
	return false 
end

--[[ filters and transforms keyboard input ]]
function validKey( key )
	if key == "kp0" or key == "0" then return 0 end
	if key == "kp1" or key == "1" then return 1 end
	if key == "kp2" or key == "2" then return 2 end
	if key == "kp3" or key == "3" then return 3 end
	if key == "kp4" or key == "4" then return 4 end
	if key == "kp5" or key == "5" then return 5 end
	if key == "kp6" or key == "6" then return 6 end
	if key == "kp7" or key == "7" then return 7 end
	if key == "kp8" or key == "8" then return 8 end
	if key == "kp9" or key == "9" then return 9 end
	if key == "kp." or key == "." then return -1 end
	return nil
end

--[[translates square into relative coordinates]]
function translateNumber( num )
	if num == 1 then return 0, 2 end
	if num == 2 then return 1, 2 end
	if num == 3 then return 2, 2 end
	if num == 4 then return 0, 1 end
	if num == 5 then return 1, 1 end
	if num == 6 then return 2, 1 end
	if num == 7 then return 0, 0 end
	if num == 8 then return 1, 0 end
	if num == 9 then return 2, 0 end
	return nil
end

--[[ translates numpad sequence into normal sequence ]]
function selectionToArray( num )
	if num == 1 then return 7 end
	if num == 2 then return 8 end
	if num == 3 then return 9 end
	if num == 4 then return 4 end
	if num == 5 then return 5 end
	if num == 6 then return 6 end
	if num == 7 then return 1 end
	if num == 8 then return 2 end
	if num == 9 then return 3 end
end

--[[transforms squares into absolute coordinates]]
function coordinateFromSquares( sq, sub )
	local nx, ny = translateNumber( sq )
	local sx, sy = translateNumber( sub )
	return nx * 3 + sx + 1, ny * 3 + sy + 1
end

--[[transforms absolute coordinates into squares]]
function squaresFromCoordinates( x, y )
	local subx = (x - 1) % 3
	local sqx  = ((x - 1) - subx) / 3
	local suby = (y - 1) % 3
	local sqy  = ((y - 1) - suby) / 3
	return numbersFromCoordinates( sqx, sqy ), numbersFromCoordinates( suby, sqy )
end

--[[transforms relative coordinates into square]]
function numbersFromCoordinates( x, y )
	if x == 0 and y == 0 then return 7 end
	if x == 1 and y == 0 then return 8 end
	if x == 2 and y == 0 then return 9 end
	if x == 0 and y == 1 then return 4 end
	if x == 1 and y == 1 then return 5 end
	if x == 2 and y == 1 then return 6 end
	if x == 0 and y == 2 then return 1 end
	if x == 1 and y == 2 then return 2 end
	if x == 2 and y == 2 then return 3 end
	return 0
end

--[[utility function for random probability]]
function testL( level )
	return math.random() < level
end

--[[utility function for random numbers]]
function testN()
	return math.floor( math.random() * 8 + 1 )
end




