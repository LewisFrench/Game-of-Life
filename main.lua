function love.load()
  Canvas = {
    mapSize = 40,
    mapDimensions = 800,
    map = {},
    button = addButtons(),
    play = false,
    playSpeed = 5,
    timeCounter = 0,
    speeds = {60,30,20,15,12,10,6,5,4,3,2,1},
    showHelp = false
  }
  -- Set window title
  love.window.setTitle( "Conway's Game of Life" )
  
  -- Blank map is set to mapSize
  Canvas.map = initialiseMap(Canvas.mapSize)
  -- Creates window to gridsize + 100 for the menu
  love.window.setMode(Canvas.mapDimensions,Canvas.mapDimensions + 100)
  love.graphics.setBackgroundColor(1.0,1.0,1.0,1.0)
end

-- Readability for adding the buttons to the Canvas 
function addButtons()
  buttons = {} 
  buttons[1] = {50,810, 65, 65, "Play"}
  buttons[2] = {150, 810, 65,65, "Pause"}
  buttons[3] = {250,830, 30,30,"-"}
  buttons[4] = {330, 830,30,30,"+"}
  buttons[5] = {410, 810,40,40,"Small"}
  buttons[6] = {470, 810,40,40,"Mid"}
  buttons[7] = {530, 810,40,40,"Large"}
  buttons[8] = {620, 810,65,65,"Clear"}
  buttons[9] = {720, 830,30,30, "Help"}
  return buttons
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
  love.graphics.setColor(0.02,0.2,0.2,1.0)
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
-- Determines the actions necessary when mouse is clicked
function love.mousepressed (x, y, button)
  -- If the user clicks in the grid, then the tiles are affected
  if y<= Canvas.mapDimensions then
    changeTile(x,y)
  else
    -- Otherwise, the user is looking to interact with the menu
    clickButton(x,y)
  end
   
end

function clickButton(x,y)
  -- Stores the string value stored at the end of each button array
  action = "none"
  -- Checks coordinates of mouse click to determine which buttons has been pressed
  for i=1, table.getn(Canvas.button) do
    b = Canvas.button[i]
    if (x >= b[1]) and (x < (b[1] + b[3])) then
      if (y>=b[2]) and (y<= b[2] + b[4]) then
	  -- Sets the action string to the corresponding button
        action= b[5]
      end
    end
  end
  
  -- Handles the Play on/off 
  if action == "Play" then
    Canvas.play = true
  elseif action == "Pause" then
    Canvas.play = false
	
  -- Handles the increment or decrement to the PlaySpeed button 
  elseif action == "-" then
    if Canvas.playSpeed >1 then
      Canvas.playSpeed = Canvas.playSpeed-1
    end
  elseif action == "+" then
    if Canvas.playSpeed <table.getn(Canvas.speeds) then
      Canvas.playSpeed = Canvas.playSpeed +1
    end
  end
  
  -- Handles the change in map size 
  if (action == "Small") and (Canvas.mapSize ~= 20) then
    Canvas.map = initialiseMap(20)
    Canvas.mapSize = 20
    Canvas.play = false
  end
  if action == "Mid" and Canvas.mapSize ~= 40 then
    Canvas.map = initialiseMap(40)
    Canvas.mapSize = 40
    Canvas.play = false
  end
  if action == "Large" and Canvas.mapSize ~= 60 then
    Canvas.map = initialiseMap(60)
    Canvas.mapSize = 60
    Canvas.play = false
  end
  
  -- Clears map by re-intialising map to same size
  if action == "Clear" then
    Canvas.map = initialiseMap(Canvas.mapSize)
    Canvas.play = false
  end
  
  -- Toggles help on and off
  if action == "Help" then
    Canvas.showHelp = not(Canvas.showHelp)
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


-- Allows the user to perform a single iteration by pressing space
function love.keypressed (key)
  if key == "space" then
    checkState()
  end
end

-- Writes instructions on toggles help window to aid user
function showHelp()
  love.graphics.setColor(1.0,1.0,1.0,1.0)
  love.graphics.rectangle("fill", 600,600,200,200)
  love.graphics.setColor(0.0,0.0,0.0,1.0)
  love.graphics.print("SPACE to update once \n\nPLAY to auto-update\n\nPLAY SPEED affects rate \nof auto-update\n\nGRID SIZE affects the number \nof tiles\n\nCLEAR empties all tiles",605,605)

end

function love.draw()
  -- Allows count to increment up to default FPS of 60
  Canvas.timeCounter = (Canvas.timeCounter +1)%60
  -- if the count reaches a multiple of 60/playSpeed, the auto-update runs
  if Canvas.play == true and Canvas.timeCounter%Canvas.speeds[Canvas.playSpeed] == 0 then
    checkState()
  end
  
  -- size of each tile is calculated by dividing the width of the grid by number of tiles
  interval = Canvas.mapDimensions/Canvas.mapSize
  -- Iterates through all tiles
  for i=1, Canvas.mapSize do
    for y=1, Canvas.mapSize do
      -- If a tile is alive, then
      if Canvas.map[i][y] == 1 then
        -- Live tile colour is set
        love.graphics.setColor(0.0,0.0,0.0,1.0)
        -- i and y have 1 subtracted to offset coordinates and Lua table 1-indexing differences
        love.graphics.rectangle("fill", ((i-1)*interval) , ((y-1)*interval), interval,interval)
      end
    end
  end
  
  -- Draw the gridlines and the menu
  drawMenu()
  drawGrid()
  
  --iterates through the buttons, draws them and the string describing their function
  for i=1,table.getn(Canvas.button) do
    b = Canvas.button[i]
    love.graphics.rectangle("fill", b[1],b[2],b[3],b[4])
    love.graphics.print(b[5], (b[1]+2), (b[2] + b[3] ))
 end
 
  -- Draws additional labels encompassing sets of buttons
  love.graphics.print(Canvas.playSpeed, 300,840)
  love.graphics.setColor(0.0,0.0,0.0,1.0)
  love.graphics.print("Play speed", 274,875)
  love.graphics.print("Grid size", 467,875)
  
  -- Uses calculation involving the grid dimensions (20,40,60) to highlight current grid dimensions
  love.graphics.setColor(0.0,1.0,0.0,0.3)
  love.graphics.rectangle("fill", 350+(Canvas.mapSize*3), 810,40,40)
  love.graphics.setColor(1.0,1.0,1.0,0.6)
  
  -- Overlays grey cover on buttons to indicate there is no reason for them to be pressed
  if Canvas.play == true then
    love.graphics.rectangle("fill", 50,810,65,65)
  else
    love.graphics.rectangle("fill", 150,810,65,65)
  end
  
  -- When the user toggles help then the corresponding function is called
  if Canvas.showHelp == true then
    showHelp()
  end
end
