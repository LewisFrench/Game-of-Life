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
	love.graphics.setColor(1.0,0.6,1.0,1.0)
	love.graphics.rectangle("fill",0, 800, 1000,200)
end

function drawGrid()
	love.graphics.setColor(0.0,0.0,0.0,1.0)
	love.graphics.rectangle("line", 0,0, Canvas.mapDimensions, Canvas.mapDimensions)
	tileSize = Canvas.mapDimensions / Canvas.mapSize
	for i =1,Canvas.mapSize do
		love.graphics.line(tileSize*i, 0, tileSize*i, Canvas.mapDimensions)
		love.graphics.line(0,tileSize*i, Canvas.mapDimensions, tileSize*i)
	end
end

function love.mousepressed(x, y, button)


	xIndex = ((x/(Canvas.mapSize*2))+1 ) 
	xIndex = xIndex - (xIndex%1)
	
	yIndex = ((y/(Canvas.mapSize*2))+1 ) 
	yIndex = yIndex - (yIndex%1)
	
	if  Canvas.map[xIndex][yIndex] == 1 then
		Canvas.map[xIndex][yIndex] = 0
	else
		Canvas.map[xIndex][yIndex] = 1
	end
end

function checkNeighbours(xPos,yPos)
	liveCount = 0
	for i= -1, 1 do
		for y= -1, 1 do
			if (i+xPos > 0) and (y+yPos > 0) and (i+xPos <= Canvas.mapSize) and (y+yPos <= Canvas.mapSize) then
				love.graphics.setColor(0.0,0.0,0.0,1.0)
				if Canvas.map[i+xPos][y+yPos] == 1 then
					liveCount = liveCount + 1
				end
			end
		end
	end
	return liveCount
end

function checkState()
	neighbours = {}
	for i = 1, Canvas.mapSize do
		neighbours[i] = {}
		for y = 1, Canvas.mapSize do
			neighbours[i][y] = checkNeighbours(i,y) - Canvas.map[i][y]

			
		end
	end
	for i = 1, Canvas.mapSize do
		for y = 1, Canvas.mapSize do
			if neighbours[i][y] == 3 then
				Canvas.map[i][y] = 1
			elseif neighbours[i][y] == 2 and Canvas.map[i][y] == 1 then
				Canvas.map[i][y] = 1
			else
				Canvas.map[i][y] = 0
			end
			
		end
	end

end


function love.update()
	
end

function love.keypressed(key)
	if key == "space" then
		checkState()
	end

end


function love.draw()
	-- draw map
	interval = Canvas.mapDimensions/Canvas.mapSize
	for i = 1, Canvas.mapSize do
		for y=1, Canvas.mapSize do
			if Canvas.map[i][y] == 1 then
				love.graphics.print(("clicked  ".. i .. "  " .. y),100,200)
					love.graphics.setColor(0.0,1.0,0.0,0.3)
				love.graphics.rectangle("fill", ((i-1)*interval) , ((y-1)*interval), interval,interval)
				love.graphics.setColor(0.0,0.0,0.0,1.0)
				
			end
		end
	end
	drawMenu()
	drawGrid()
	love.graphics.setColor(0.0,0.0,0.0,1.0)
	
end
