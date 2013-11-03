
local font_30 = love.graphics.newFont( "coolvetica.ttf", 30)
local font_16 = love.graphics.newFont( "coolvetica.ttf", 16)
local font_debug = love.graphics.newFont( "coolvetica.ttf", 10)

--[[------------------------------------------------------------

	Things to note:
	* the table structure !!!
	* that this is a single function that returns a table

---------------------------------------------------------------]]

function giveBoard()

	local game = {}
	
	game.state = "pregame"
	-- "pregame" 	- before board generation  --sounds weird
	-- "play" 		- normal play state
	-- "pause" 		- paused
	-- "win"        - sudoku solved
	
	game.drawing = {}
	game.drawing.step = 40
	game.drawing.min  = 30
	
	game.selection = {}
	game.selection.square = 0
	game.selection.subsquare = 0
	game.selection.last = { 0, 0 }
	
	game.options = {}

	game.correctness = {}
	game.correctness.rows = {}
	game.correctness.columns = {}
	game.correctness.squares = {}

	--[[
	game.correctness.lastTestMessage = {}
	game.correctness.lastTestMessage.row 	= "Nil"
	game.correctness.lastTestMessage.column = "Nil"
	game.correctness.lastTestMessage.square = "Nil"
	]]

	game.debugPrint = ""

	game.timer = {}
	game.timer.running	= false
	game.timer.time		= 0
	game.timer.began	= 0

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
	
--[[ loads the game ]]
	function game:load( settings )
		self.options = settings --doesn't do anything
		self:createBoard()
		--self:testBed()
	end

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
					local n = testN()
					if n then 
						self.field[i][j] = {val = n, ed = testL(0.25) }
					end
				end
				
			end
		end
	end

	function game:clearBoard()

		for i = 1, 9 do
			for j = 1, 9 do
				--sudoku cell data
				-- val 	- number
				-- ed	- editable
				-- col	- color
				self.field[i][j] = {val = 0, ed = true }
			end
		end

	end

	function game:betterTestBed( perc )
		for i = 1, 9 do
			for j = 1, 9 do
				if testL( perc or 0.3) then
					local num = testN()
					--local lists = {self:getCoumpoundList(i, j)}
					local lRow, lCol, lSq = self:getCoumpoundList(i, j)
					local hV = table.hasValue

					--local numberDuplicate = false
					--[[for k, v in pairs( lists ) do
						if table.hasValue( v, num ) then numberDuplicate = true end
					end]]

					local hRow, hCol, hSq = hV(lRow, num), hV( lCol, num ), hV( lSq, num )

					local sRow, sCol, sSq = " ", " ", " "
					if hRow then sRow = "T" else sRow = "N" end
					if hCol then sCol = "T" else sCol = "N" end
					if hSq  then sSq  = "T" else sSq  = "N" end

					--self.debugPrint = self.debugPrint..i..", "..j.." : "..sRow..", "..sCol..", "..sSq.."\n"

					if not ( hRow or hCol or hSq ) then 
						self.field[i][j] = {val = num, ed = false } 
					--elseif perc then
						--self.field[i][j] = {val = num, ed = true } 
					end

				end

			end
		end
	end

	function game:validateBoard()
		for i = 1, 9 do
			for j = 1, 9 do
				self:notifyChange(i, j)
			end
		end
	end
	
--[[ main draw function ]]
--[[ damnit for being inconsistent
	 drawBorder and drawBoard dont care for states,
	 but drawGUI has ifs for states ]]

	function game:draw()
		if self.state == "pregame" then
			self:drawBorder()
		elseif self.state == "play" then
			self:drawBoard()
		elseif self.state == "win" then
			self:drawBorder()
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
		local step = self.drawing.step   --size of the grid step
		local min = self.drawing.min     --smallest coordinate of the grid
		local max = min + 9 * step       --biggest coordinate of the grid
	
		love.graphics.setColor( 255, 255, 255 )
	
	--[[ debug draw of completed sets ]]
	if self.options.debug then
		self:drawCompleted(step, min, max)
	end

	--[[ draws the net ]]
		self:drawGrid(step, min, max)
		
	--[[ draws selections ]]
		self:drawSelections(step, min, max)
		
	--[[ draws numbers]]
		self:drawNumbers(step, min, max)
		
	end
	
	function game:drawNumbers(step, min, max)
		love.graphics.setColor( 255, 255, 255 )
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
					love.graphics.setFont( font_30 )
					love.graphics.print(num, min + (x - 0.5) * step, min + (y - 0.5) * step, 0, 1, 1, 8, 17)--, step/3*2, step/3*2)--, step * 0.5, step*0.5 )
					--love.graphics.print( text, x, y, r, sx, sy, ox, oy, kx, ky )
				end
				
				--[[  
				--little debug letters
				if self.options.debug then
					love.graphics.setColor( 255, 255, 255 )
					love.graphics.setFont( font_debug )
					love.graphics.print(num, min + (x - 1.0) * step + 4, min + (y - 1.0) * step + 3)--, step/3*2, step/3*2)--, step * 0.5, step*0.5 )
					if lock then
						love.graphics.setColor( 0, 200, 0 )
						love.graphics.print( "t", min + (x - 1.0) * step + 4, min + (y - 1.0) * step + 13)
					else
						love.graphics.setColor( 200, 0, 0 )
						love.graphics.print( "f", min + (x - 1.0) * step + 4, min + (y - 1.0) * step + 13)
					end
				end
				]]
			end
		end
	end
	
	--[[ draws the grid ]]
	function game:drawGrid(step, min, max)
		love.graphics.setColor( 255, 255, 255 )
		for i = 0, 9 do
			if i % 3 == 0 then 
				love.graphics.setLineWidth(3)
			else
				love.graphics.setLineWidth(1)
			end
			love.graphics.line( min + i * step, min 		  , min + i * step, max 		   )
			love.graphics.line( min			  , min + i * step, max			  , min + i * step )
		end
	end
	
	--[[ draws selected squares ]]
	function game:drawSelections(step, min, max)

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
	end
	
--[[ draws GUI ]]
	function game:drawGUI()
		if self.state == "pregame" then
			love.graphics.print( "Press 1 for a garbled random board", 100, 100 )
			love.graphics.print( "Press 2 for an empty board", 100, 120 )
			love.graphics.print( "Press 3 for a better random board", 100, 140 )
			love.graphics.print( "Press 4 for a filled random board", 100, 160 )
			--love.graphics.setColor( 100, 0, 0 )
			--love.graphics.print( "Press 3 for a test filling algorithm", 100, 140 ) --not yet
		elseif self.state == "play" then
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.setFont( font_debug )
			--love.graphics.print( self.debugPrint, 420, 70 )
		elseif self.state == "win" then
			love.graphics.setColor(255,0, 0)
			love.graphics.setFont( font_30 )
			love.graphics.printf( "A WINNER IS YOU", 80, 80, 200, "center" )
		end
	end
	
--[[ draw complete sets ]]
	function game:drawCompleted(step, min, max)

		local of = 8 --offest for drawing

		--love.graphics.setBlendMode( "additive" )

		love.graphics.setColor( 0, 100, 0, 200 )
		--love.graphics.setColor( 0, 0, 50 )

		for k, v in pairs( self.correctness.squares ) do
			if not not v then 
				local cx, cy = translateNumber(k)
				--love.graphics.rectangle( "fill", min + step * cx * 3 +of, min + step * cy * 3 +of , step * 3-of*2, step * 3-of*2 )
				love.graphics.rectangle( "fill", min + step * cx * 3 , min + step * cy * 3 , step * 3, step * 3 )
			end
		end

		
		for k, v in pairs( self.correctness.rows ) do
			if not not v then 
				love.graphics.rectangle( "fill", min + of, min + step * (k-1) + of, step * 9-of*2, step-of*2 )
			end
		end
		
		for k, v in pairs( self.correctness.columns ) do
			if not not v then 
				love.graphics.rectangle( "fill", min + step * (k-1) +of, min+of , step-of*2 , step * 9 -of*2)
			end
		end

		love.graphics.setBlendMode( "alpha" )

		--[[
		love.graphics.setFont( font_debug )
		love.graphics.setColor( 255, 255, 255, 255 )
		local i = 0
		for k, v in pairs( self.correctness.lastTestMessage ) do
			love.graphics.print(v, 420, 30 + i * 10)
			i = i + 1
		end
		]]
	end

--[[ keypress handling ]]
	function game:keyPress(k, u)
		if self.state == "pregame" then
			self:clearBoard()
			if k == "1" then
				self:testBed()
			elseif k == "2" then
				self:clearBoard()
			elseif k == "3" then
				self:betterTestBed()
			elseif k == "4" then
				self:betterTestBed(0.8)
			end
			self.state = "play"			
			self:validateBoard()
			return
		end
	
		local numberKey = validKey( k ) --current key

		if numberKey then 
			self:handleKeyNumber(numberKey) 
			return
		else
			if k == "v" then
				if validSelection( self.selection.subsquare ) and validSelection( self.selection.square ) then
					self.debugPrint = ""
					self:notifyChange( coordinateFromSquares(self.selection.square, self.selection.subsquare) )
				end
			elseif k == "w" then
				self.state = "win"
			end

			return
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
			if self:getNumberSq(self.selection.square, self.selection.subsquare ) == num then
				self:setNumberSq( 0, self.selection.square, self.selection.subsquare )
			else
				self:setNumberSq( num, self.selection.square, self.selection.subsquare )
			end
		elseif validSelection( self.selection.square ) then -- sets selection to a valid sub-square
			if validSelection( num ) then
				if self:getNumberSq( self.selection.square, num, true ).ed then
					self.selection.subsquare = num
				end
			end
		else -- sets a slection square
			self.selection.square = num
		end
		return true
	end
	
--[[subsquare method of setting numbers]]
	function game:setNumberSq( num, sq, sub, ed )
	
		local cx, cy = coordinateFromSquares( sq, sub )
				
		return self:setNumber( num, cx, cy, ed )
	end

	function game:setNumber( num, cx, cy, ed )
		self.selection.last = { self.selection.square, self.selection.subsquare }
		self.selection.number 		= 0
		self.selection.subsquare 	= 0
		self.selection.square 		= 0
				
		--editable value override
		if ed then 
			self.field[cx][cy].ed = ed
		end

		--check if allowed to change number
		if self.field[cx][cy].ed then 
			self.field[cx][cy].val = num
			self.selection.number 		= 0
			self.selection.subsquare 	= 0
			self.selection.square 		= 0
			self:notifyChange(cx, cy)
			return true -- SUCCESS
		end

		return false --UNSUCCESS
	end
	
	--[[based on squares returns value and edit flag OR the cell table]]
	function game:getNumberSq(sq, sub, tab)
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
			tab[i] = self:getNumber(i, row)
		end
		return tab
	end
	
	--[[ returns a list with values from column ]]
	function game:getColumnList( column )
		local tab = {}
		for i = 1, 9 do
			--tab[i] = self.field[i][column].val
			tab[i] = self:getNumber(column, i)
		end
		return tab
	end
	
	--[[ returns a list with values from a square ]]
	function game:getSquareList( sq )
		local tab = {}
		for i = 1, 9 do
			--local cx, cy = coordinateFromSquares( sq, i )
			tab[i] = self:getNumberSq(sq, i )--selectionToArray( i ) )
		end
		return tab
	end

	function game:getCoumpoundList( x, y )
		local tr, tc, ts =  y, x, squaresFromCoordinates(x, y)
		return self:getRowList(tr), self:getColumnList(tc), self:getSquareList(ts)
	end
	
	--[[ Updates finished sets ]]
	function game:notifyChange( x, y )
		local row, column, square = y, x, squaresFromCoordinates(x, y)
			self:notifyChangeRow(row)
			self:notifyChangeColumn(column)
			self:notifyChangeSquare(square)
			self:notifyWinConditions()
	end

	function game:notifyChangeRow( num )
		local rowList =  self:getRowList(num)
		local errorMsg = nil

		--[[
		self.debugPrint = self.debugPrint.."Row data\n"
		for k, v in pairs( rowList ) do
			self.debugPrint = self.debugPrint..k..": "..v.."; "
		end
		self.debugPrint = self.debugPrint.."\n"

		for k, v in pairs( table.getNumberCounts( rowList ) ) do
			self.debugPrint = self.debugPrint..k..": "..v.."; "
		end
		self.debugPrint = self.debugPrint.."\n\n"
		]]

		game.correctness.rows[num], errorMsg = table.filledSet( rowList )
		--game.correctness.lastTestMessage.row = errorMsg
	end


	function game:notifyChangeColumn( num )
		local columnList =  self:getColumnList(num)
		local errorMsg = nil

		--[[
		self.debugPrint = self.debugPrint.."Column data\n"
		for k, v in pairs( columnList ) do
			self.debugPrint = self.debugPrint..k..": "..v.."; "
		end
		self.debugPrint = self.debugPrint.."\n"

		for k, v in pairs( table.getNumberCounts( columnList ) ) do
			self.debugPrint = self.debugPrint..k..": "..v.."; "
		end
		self.debugPrint = self.debugPrint.."\n\n"
		]]

		game.correctness.columns[num], errorMsg = table.filledSet( columnList )
		--game.correctness.lastTestMessage.column = errorMsg
	end

	function game:notifyChangeSquare( num )
		local squareList =  self:getSquareList(num)
		local errorMsg = nil

		--[[	
		self.debugPrint = self.debugPrint.."Square data\n"
		for k, v in pairs( squareList ) do
			self.debugPrint = self.debugPrint..k..": "..v.."; "
		end
		self.debugPrint = self.debugPrint.."\n"

		for k, v in pairs( table.getNumberCounts( squareList ) ) do
			self.debugPrint = self.debugPrint..k..": "..v.."; "
		end
		self.debugPrint = self.debugPrint.."\n\n"
		]]

		game.correctness.squares[num], errorMsg = table.filledSet( squareList )
		--game.correctness.lastTestMessage.square = errorMsg
	end

	function game:notifyWinConditions()
		for _, t in pairs( self.correctness ) do
			for _, l in pairs( t ) do
				if l ~= true then return false end
			end	
		end
		game.state = "win"
		return true
	end

	function game:update(dt)

	end

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




