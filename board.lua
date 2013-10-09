
local font_30 = love.graphics.newFont( "coolvetica.ttf", 30)

function giveBoard()

	local game = {}
	
	game.paused = false
	
	game.drawing = {}
	game.drawing.step = 40
	game.drawing.min  = 30
	
	game.selection = {}
	game.selection.square = 0
	game.selection.subsquare = 0
	game.selection.last = { 0, 0 }
	
	game.options = {}
	
	--[[
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
	
	--[[
	
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
	
	
--[[sukuria lentà su atsitiktiniais skaiciais]]
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
	
--[[pieğia lentà]]
	function game:draw()
		self:drawBoard()
	end
	
--[[pieğia tik krağtus]]
	function game:drawBorder()
		love.graphics.setLineWidth(3)
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( self.drawing.min, self.drawing.min, self.drawing.step*9, self.drawing.step*9 )
	end
	
--[[pieğia visà lentà]]
	function game:drawBoard()
	
	--[[kintamieji]]
		local step = self.drawing.step
		local min = self.drawing.min
		local max = min + 9 * step
	
		love.graphics.setColor( 255, 255, 255 )
	
	--[[pieğia tinklelá]]
		for i = 0, 9 do
			if i % 3 == 0 then 
				love.graphics.setLineWidth(3)
			else
				love.graphics.setLineWidth(1)
			end
			love.graphics.line( min + i * step, min 		  , min + i * step, max 		   )
			love.graphics.line( min			  , min + i * step, max			  , min + i * step )
		end
		
	--[[pieğia şymëjimus]]
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
		
	--[[pieğia skaièius]]
		love.graphics.setFont( font_30 )
		for x = 1, 9 do
			for y = 1, 9 do
				local num, lock = self.field[x][y].val, self.field[x][y].ed
				
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
	
	
--[[reguliuoja mygtukø paspaudimas]]
	function game:keyPress(k, u)
	
		local num = validKey( k )
		if not num  then return end
		
		if num == -1 then
			if validSelection( self.selection.last[0] ) and validSelection( self.selection.last[1] ) then
					self.selection.last = 0
			end			
		elseif num == 0 then
			if validSelection( self.selection.subsquare ) and validSelection( self.selection.square ) then
				self.selection.subsquare = 0
			elseif validSelection( self.selection.square ) then
				self.selection.square = 0
			end
		elseif validSelection( self.selection.subsquare ) then 
			self:setNumber( num, self.selection.subsquare, self.selection.square )
		elseif validSelection( self.selection.square ) then 
			if validSelection( num ) then
				local cx, cy = coordinateFromSquares( self.selection.square, num )
				if self.field[cx][cy].ed then
					self.selection.subsquare = num
				end
			end
		else
			self.selection.square = num
		end
		
	end

--[[skaièiaus keitimas]]
	function game:setNumber( num, sub, sq )
		self.selection.number 		= 0
		self.selection.subsquare 	= 0
		self.selection.square 		= 0
				
		local cx, cy = coordinateFromSquares( sq, sub )
				
		if self.field[cx][cy].ed then 
			self.field[cx][cy].val = num
			self.selection.number 		= 0
			self.selection.subsquare 	= 0
			self.selection.square 		= 0
			return true
		end
		return false
	end
	
	--[[grazina skaiciu ir keiciamuma ARBA langelio struktura]]
	function game:getNumberSq(sub, sq, tab)
		local cx, cy = coordinateFromSquares( sq, sub )
		if tab then return self.field[cx][cy] end
		return self.field[cx][cy].val, self.field[cx][cy].ed
	end
	
	--[[grazina skaiciu ir keiciamuma ARBA langelio struktura]]
	function game:getNumber(x, y, tab)
		if tab then return self.field[x][y] end
		return self.field[x][y].val, self.field[x][y].ed
	end
	
	--[[grazina eilutes reiksmes]]
	function game:getRowList( row )
		local tab = {}
		for i = 1, 9 do
			--tab[i] = self.field[row][i].val
			tab[i] = self:getNumber(row, i)
		end
		return tab
	end
	
	--[[grazina eilutes reiksmes]]
	function game:getColumnList( column )
		local tab = {}
		for i = 1, 9 do
			--tab[i] = self.field[i][column].val
			tab[i] = self:getNumber(i, column)
		end
		return tab
	end
	
	--[[grazina kvadranto reiksmes]]
	function game:getSquareList( sq )
		local tab = {}
		for i = 1, 9 do
			local cx, cy = coordinateFromSquares( sq, i )
			tab[i] = self:getNumber(cx, cy)
		end
		return tab
	end
	
	--[[sumuoja vienodas reiksmes]]
	function game:getDuplicateSumTable( tab )
		test = {}
		for k, v in pairs( tab ) do
			test[v] = (test[v] or 0) + 1
		end
		return test
	end
	
	function game:areDuplicates( tab, num )
		return tab[num] or 0
	end
	
	--function game:
	
	return game
	
end

function validSelection( num )
	if not type(num) == "number" then return false end
	if num > 0 and num < 10 then return true end
	return false 
end

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
end

--[[transliuoja numpad skaicius i koordinates]]
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

--[[transliuoja numpad seka i nuoseklius skaicius]]
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

--[[vercia kvadrantus i koordinates]]
function coordinateFromSquares( sq, sub )
	local nx, ny = translateNumber( sq )
	local sx, sy = translateNumber( sub )
	return nx * 3 + sx + 1, ny * 3 + sy + 1
end

--[[vercia absoliucias koordinates i kvadrantus]]
function squaresFromCoordinates( x, y )
	local subx = (x - 1) % 3
	local sqx  = ((x - 1) - subx) / 3
	local suby = (y - 1) % 3
	local sqy  = ((y - 1) - suby) / 3
	return numbersFromCoordinates( sqx, sqy ), numbersFromCoordinates( suby, sqy )
end

--[[vercia koordinates i kvadranta ]]
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

--[[patogumo funkcija atsitiktinumui]]
function testL( level )
	return math.random() < level
end

--[[patogumo funkcija skaiciams]]
function testN()
	return math.floor( math.random() * 8 + 1 )
end




