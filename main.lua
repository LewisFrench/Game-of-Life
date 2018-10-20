function love.load()
  buttons = {} 
  buttons[1] = {50,810, 65, 65, "play"}
  buttons[2] = {150, 810, 65,65, "pause"}
  buttons[3] = {250,830, 30,30,"-"}
  buttons[4] = {330, 830,30,30,"+"}
  buttons[5] = {410, 820,40,40,"small"}
  buttons[6] = {480, 820,40,40,"mid"}
  buttons[7] = {550, 820,40,40,"large"}
  
  Canvas = {
    mapSize = 60,
    mapDimensions = 800,
    map = {},
	button = buttons,
	play = false,
	playSpeed = 5,
	endCheck = {},
	timeCounter = 0
  }
  
  time = love.timer.getTime();
  -- Initial map size set to 20x20
  Canvas.map = initialiseMap(Canvas.mapSize)
  Canvas.endCheck = Canvas.map
  love.window.setMode(Canvas.mapDimensions,Canvas.mapDimensions + 100)
  love.graphics.setBackgroundColor(0.9,0.9,0.9,1.0)
end

function initialiseMap (mapSize)
  -- Sets the tables for the map:
  --(mapSize) tables filled with (mapSize) numbers
  map = {}
  for row = 1, mapSize do
  map[row] = {}
    for tile = 1, mapSize do
      map[row][tile] = 0
    end  
  end
  return map
end

function drawMenu ()
  -- Fills the base rectangle with the desired colour
  love.graphics.setColor(0.2,0.2,0.4,0.2)
  love.graphics.rectangle("fill",0, 800, 1000,200)
end

function drawGrid ()
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

function love.mousepressed (x, y, button)

	if y<= Canvas.mapDimensions then
		changeTile(x,y)
	else
		clickButton(x,y)
	end
	 
end

function clickButton(x,y)
	action = "none"
	
	for i=1, table.getn(Canvas.button) do
		b = Canvas.button[i]
		if (x >= b[1]) and (x < (b[1] + b[3])) then
			if (y>=b[2]) and (y<= b[2] + b[4]) then
				action= b[5]
				
			end
		end
	end
	if action == "play" then
		Canvas.play = true
	elseif action == "pause" then
		Canvas.play = false
	elseif action == "-" then
		if Canvas.playSpeed >1 then
			Canvas.playSpeed = Canvas.playSpeed-1
		end
	elseif action == "+" then
		if Canvas.playSpeed <50 then
			Canvas.playSpeed = Canvas.playSpeed +1
		end
	end
	if (action == "small") and (Canvas.mapSize ~= 20) then
		Canvas.map = initialiseMap(20)
		Canvas.mapSize = 20
	end
	if action == "mid" and Canvas.mapSize ~= 40 then
		Canvas.map = initialiseMap(40)
		Canvas.mapSize = 40
	end
	if action == "large" and Canvas.mapSize ~= 60 then
		Canvas.map = initialiseMap(60)
		Canvas.mapSize = 60
	end
end
function changeTile (x,y)
  interval = 800/Canvas.mapSize
  -- calculates the ordinal position of each tile horizontally
  -- converted to integer through subtraction of self%1
  xIndex = ((x/interval)+1 ) 
  xIndex = xIndex - (xIndex%1)
  
  yIndex = ((y/interval )+1 ) 
  yIndex = yIndex - (yIndex%1)
  
  -- If clicked, changes tile to opposite state
  if  Canvas.map[xIndex][yIndex] == 1 then
    Canvas.map[xIndex][yIndex] = 0
  else
    Canvas.map[xIndex][yIndex] = 1
  end
end

function checkNeighbours (xPos, yPos)
  -- Resets count variable
  liveCount = 0
  -- Searches the immediate neighbours of each tile
  --[[
  (X-1,Y-1) (X,Y-1) (X+1,Y-1)
  (X-1,Y)   (X,Y)   (X+1,Y)
  (X-1,Y+1) (X,Y+1  (X+1,Y+1)    ]]--
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

function checkState ()
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

function love.update ()
  
end

function love.keypressed (key)
  if key == "space" then
    checkState()
  end
end
-- Triggers an iteration of the algorithm when the spacebar is pressed
function love.draw()
  Canvas.timeCounter = (Canvas.timeCounter +1)%60
  if (Canvas.timeCounter %((60/Canvas.playSpeed) - (Canvas.playSpeed%1))==0) and Canvas.play == true  then
	checkState()
  end
  love.graphics.print(Canvas.timeCounter.."   " ..((60/Canvas.playSpeed) - (60/Canvas.playSpeed%1)) , 300,300)
  -- draw map
  -- size of each tile is calculated by dividing the width of the grid by number of tiles
  interval = Canvas.mapDimensions/Canvas.mapSize

  for i=1, Canvas.mapSize do
    for y=1, Canvas.mapSize do
      -- If a tile is alive, then
      if Canvas.map[i][y] == 1 then
        -- Live tile colour is set
        love.graphics.setColor(0.3,0.5,0.5,0.9)
        -- i and y have 1 subtracted to offset coordinates and Lua table 1-indexing differences
        love.graphics.rectangle("fill", ((i-1)*interval) , ((y-1)*interval), interval,interval)
      end
    end
  end
  -- Draw the gridlines and the menu
  drawMenu()
  drawGrid()
  for i=1,table.getn(Canvas.button) do
	b = Canvas.button[i]
	love.graphics.rectangle("fill", b[1],b[2],b[3],b[4])
	love.graphics.print(b[5], (b[1] +10), (b[2] + b[3] ))
 end
 love.graphics.print(Canvas.playSpeed, 298, 840)
 if Canvas.play == true then
	love.graphics.setColor(0.0,1.0,0.0,0.3)
		
	love.graphics.rectangle("fill", 50,810,65,65)
 end
  love.graphics.setColor(0.0,0.0,0.0,1.0)
end
