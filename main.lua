
require "board"
require "menu"

pooltable = require "pooltable"

board = {}

state = "game"

--[[ game settings table]]
settings = {}
settings.numpad_sequence_reversed = false

--[[ init logic thingys ]]
function love.load()
	board = giveBoard()
	board:load(settings)
end

--[[ calls draw() methods]]
function love.draw()
	love.graphics.clear()
	love.graphics.setBackgroundColor( 0, 0, 0 )
	
	if state == "menu" then
		menu:draw()
	elseif state == "game" then
		board:draw()
	elseif state == "paused" then
		board:drawBorder()
	end
	
end

--[[ not yet needed ]]
function love.update()

end

--[[ returns keypresses to enviroments]]
function love.keypressed( key, unicode )
	if state == "menu" then
		menu:keyPress(key, unicode)
	elseif state == "game" then
		board:keyPress(key, unicode)
	end
end
	