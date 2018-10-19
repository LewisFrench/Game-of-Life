function love.load()
	Canvas = {
		mapSize = 20,
		mapDimensions = 800,
		map = {},
		test = 0
	}
	-- Initial map size set to 20x20
	Canvas.map = initialiseMap(Canvas.mapSize)
	love.window.setMode(Canvas.mapDimensions,Canvas.mapDimensions + 100)
	love.graphics.setBackgroundColor(0.9,0.9,0.9,1.0)
end

function initialiseMap(mapSize)
	-- Sets the tables for the map:
	--		(mapSize) tables filled with (mapSize) numbers
	map = {}
	for row = 1, mapSize do
	  map[row] = {}
	  for tile = 1, mapSize do
		  map[row][tile] = 0
	  end	
	end
	
	return map
end

function drawMenu()
	-- Fills the base rectangle with the desirec colour
	love.graphics.setColor(1.0,0.6,1.0,1.0)
	love.graphics.rectangle("fill",0, 800, 1000,200)
end

function drawGrid()
	-- Sets color to black
	love.graphics.setColor(0.0,0.0,0.0,1.0)
	-- Draws border around the grid area
	love.graphics.rectangle("line", 0,0, Canvas.mapDimensions, Canvas.mapDimensions)
	
	-- Determines the width and height of each square tile by dividing entire length by tile quantity
	tileSize = Canvas.mapDimensions / Canvas.mapSize
	
	-- Draws horizontal and vertical lines between each tile position
	for i =1,Canvas.mapSize do
		love.graphics.line(tileSize*i, 0, tileSize*i, Canvas.mapDimensions)
		love.graphics.line(0,tileSize*i, Canvas.mapDimensions, tileSize*i)
	end
end

function love.mousepressed(x, y, button)
	-- calculates the ordinal position of each tile horizontally
	-- converted to integer through subtraction of self%1
	xIndex = ((x/(Canvas.mapSize*2))+1 ) 
	xIndex = xIndex - (xIndex%1)
	
	yIndex = ((y/(Canvas.mapSize*2))+1 ) 
	yIndex = yIndex - (yIndex%1)
	
	-- If clicked, changes tile to opposite state
	if  Canvas.map[xIndex][yIndex] == 1 then
	  Canvas.map[xIndex][yIndex] = 0
	else
	  Canvas.map[xIndex][yIndex] = 1
	end
end

function checkNeighbours(xPos,yPos)
	-- Resets count variable
	liveCount = 0
	-- Searches the immediate neighbours of each tile
	--[[
	(X-1,Y-1) (X,Y-1) (X+1,Y-1)
	(X-1,Y)   (X,Y)   (X+1,Y)
	(X-1,Y+1) (X,Y+1  (X+1,Y+1)
	]]--
	for i= -1, 1 do
	  for y= -1, 1 do
	  -- Ensures no tiles are searched outside of the grid boundaries
	    if (i+xPos > 0) and (y+yPos > 0) and (i+xPos <= Canvas.mapSize) and (y+yPos <= Canvas.mapSize) then
	      -- If neighbour is alive, add to the count of live neighbours
	      if Canvas.map[i+xPos][y+yPos] == 1 then
	        liveCount = liveCount + 1
          end
	    end
	  end
	end
	return liveCount
end

function checkState()
  -- Initialise neighbours to the same dimensions as the main map
  neighbours = {}
  -- Iterate through each grid tile
  for i = 1, Canvas.mapSize do
    neighbours[i] = {}
    for y = 1, Canvas.mapSize do
      -- Store number of neighbours and subtract the tile's own value (tile cannot be its own neighbour)
      neighbours[i][y] = checkNeighbours(i,y) - Canvas.map[i][y]
    end
  end
	for i = 1, Canvas.mapSize do
		for y = 1, Canvas.mapSize do
			-- Neighbours table then determines the values for the tiles
			-- Give or maintain life to tiles with three neighbours
			if neighbours[i][y] == 3 then
				Canvas.map[i][y] = 1
			-- maintain life for tiles with two neighbours
			elseif neighbours[i][y] == 2 and Canvas.map[i][y] == 1 then
				Canvas.map[i][y] = 1
			-- other tiles die through isolation or overpopulation ( too few or too many neighbours)
			else
				Canvas.map[i][y] = 0
			end	
		end
	end
end


function love.update()
	
end
-- Triggers an iteration of the algorithm when the spacebar is pressed
function love.keypressed(key)
	if key == "space" then
		checkState()
	end

end


function love.draw()
	-- draw map
	-- size of each tile is calculated by dividing the width of the grid by number of tiles
	interval = Canvas.mapDimensions/Canvas.mapSize
	for i = 1, Canvas.mapSize do
		for y=1, Canvas.mapSize do
			-- If a tile is alive, then
			if Canvas.map[i][y] == 1 then
				-- Live tile colour is set
				love.graphics.setColor(0.0,1.0,0.0,0.3)
				-- i and y have 1 subtracted to offset coordinates and Lua table 1-indexing differences
				love.graphics.rectangle("fill", ((i-1)*interval) , ((y-1)*interval), interval,interval)
			end
		end
	end
	-- Draw the gridlines and the menu
	drawMenu()
	drawGrid()

	
end
