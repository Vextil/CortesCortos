spaces = require("hs._asm.undocumented.spaces")
internal = require('hs._asm.undocumented.spaces.internal')
-- Load and install the Hyper key extension. Binding to F18
local hyper = require('hyper')

hyper.install('F18')

hyper.bindKey('r', hs.reload)
hyper.remapKey('h', 'left')
hyper.remapKey('j', 'down')
hyper.remapKey('k', 'up')
hyper.remapKey('l', 'right')
hyper.remap({}, 's', {'ctrl', 'shift', 'cmd'}, '4') -- Screenshot area to clipboard
hyper.remap({'shift'}, 's', {'shift', 'cmd'}, '4') -- Screenshot area to desktop
hyper.remap({'option'}, 's', {'shift', 'cmd'}, '5') -- Screenshot/recording tool


hs.application.enableSpotlightForNameSearches(true)
hs.loadSpoon("MiroWindowsManager")

wf = hs.window.filter
eventtap = hs.eventtap
timer = hs.timerSSS

primaryId = "9AD62E4D-080C-9271-8847-1F5F2AD370A6"
secondaryId = "2FB2989A-E9D5-AB76-6F0B-BD9B1D116387"
primarySpaces = {}
secondarySpaces = {}

-- To easily layout windows on the screen, we use hs.grid to create
-- a 4x4 grid. If you want to use a more detailed grid, simply 
-- change its dimension here
local GRID_SIZE = 6
local HALF_GRID_SIZE = GRID_SIZE / 2
-- Set the grid size and add a few pixels of margin
-- Also, don't animate window changes... That's too slow
hs.grid.setGrid(GRID_SIZE .. 'x' .. GRID_SIZE)
hs.grid.setMargins({0, 0})
hs.window.animationDuration = 0

local screenPositions       = {}
screenPositions.left        = {
  x = 0, y = 0,
  w = HALF_GRID_SIZE, h = GRID_SIZE
}
screenPositions.right       = {
  x = HALF_GRID_SIZE, y = 0,
  w = HALF_GRID_SIZE, h = GRID_SIZE
}
screenPositions.top         = {
  x = 0, y = 0,
  w = GRID_SIZE, h = HALF_GRID_SIZE
}
screenPositions.bottom      = {
  x = 0, y = HALF_GRID_SIZE,
  w = GRID_SIZE, h = HALF_GRID_SIZE
}
screenPositions.topLeft     = {
  x = 0, y = 0,
  w = HALF_GRID_SIZE, h = HALF_GRID_SIZE
}
screenPositions.topRight    = {
  x = HALF_GRID_SIZE, y = 0,
  w = HALF_GRID_SIZE, h = HALF_GRID_SIZE
}
screenPositions.bottomLeft  = {
  x = 0, y = HALF_GRID_SIZE,
  w = HALF_GRID_SIZE, h = HALF_GRID_SIZE
}
screenPositions.bottomRight = {
  x = HALF_GRID_SIZE, y = HALF_GRID_SIZE,
  w = HALF_GRID_SIZE, h = HALF_GRID_SIZE
}
screenPositions.max = {
    x = 0, y = 0, w = GRID_SIZE, h = GRID_SIZE
}

screenPositions.f_6w = {
  x = 0, y = 0, w = 5, h = GRID_SIZE
}

screenPositions.o_6w = {
  x = 5, y = 0, w = 1, h = GRID_SIZE
}

logger = hs.logger.new('windowManager')

function setSpaces()
    -- Set spaces
    currentSpace = spaces.activeSpace()
    currentSpaceHotkey = 0
    logger.w('Finding spaces')
    allSpaces = spaces.layout()
    primarySpaces = allSpaces[primaryId]
    secondarySpaces = allSpaces[secondaryId]
    logger.w(dump(spaces.layout()));
end

function positionApp(appTitle, screen, space, position)
    logger.d('Positioning ' .. appTitle)
    if (hs.application.get(appTitle) == nil) then
        logger.e('Application ' .. appTitle .. ' not found')
        return
    end

    hs.application.get(appTitle):activate()
    windows = wf.new(appTitle):setCurrentSpace(nil):getWindows()
    if (#windows == 0) then
        logger.w('No windows found for '.. appTitle)
    end
    for k,v in pairs(windows) do
        if (#internal.windowsOnSpaces(v:id()) <= 1) then
            logger.w('Positioning window '..v:id().. ' of app '..appTitle)
            spaces.moveWindowToSpace(v:id(), space)
            if (position == nil) then
              position = screenPositions.max
            end
            hs.grid.set(v, position, screen)
        end
    end
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function desktop()
    -- Window Layout, Office stationary
    setSpaces()

    -- Get screenss
    screens = hs.screen.allScreens()

    positionApp('Safari', screens[2], secondarySpaces[1], screenPositions.left)
    positionApp('Code', screens[2], secondarySpaces[1], screenPositions.right)
    positionApp('WhatsApp', screens[2], secondarySpaces[2], screenPositions.topLeft)
    positionApp('Slack', screens[2], secondarySpaces[2], screenPositions.topRight)
    positionApp('Spotify', screens[2], secondarySpaces[2], screenPositions.bottomRight)
    positionApp('Music', screens[2], secondarySpaces[2], screenPositions.bottomRight)
    positionApp('GitHub Desktop', screens[2], secondarySpaces[2], screenPositions.bottomLeft)
    positionApp('GitKraken', screens[2], secondarySpaces[2], screenPositions.bottomLeft)
    positionApp('Postman', screens[1], primarySpaces[2], screenPositions.f_6w)
    positionApp('TogglDesktop', screens[1], primarySpaces[2], screenPositions.o_6w)
    positionApp('iTerm2', screens[1], primarySpaces[3], screenPositions.max)
    positionApp('Google Chrome', screens[1], primarySpaces[1], screenPositions.max)
end

function mobile()
    -- Window Layout, Office mobile
    setSpaces()

    -- Get screens
    screens = hs.screen.allScreens()

    positionApp('Safari', screens[1], primarySpaces[1])
    positionApp('Code', screens[1], primarySpaces[2])
    positionApp('GitKraken', screens[1], primarySpaces[3], screenPositions.left)
    positionApp('iTerm2', screens[1], primarySpaces[3], screenPositions.right)
    positionApp('WhatsApp', screens[1], primarySpaces[4], screenPositions.left)
    positionApp('Slack', screens[1], primarySpaces[4], screenPositions.right)
    positionApp('Spotify', screens[1], primarySpaces[4], screenPositions.right)
    positionApp('Music', screens[1], primarySpaces[4], screenPositions.right)
end

hyper.bindKey('d', desktop)
hyper.bindKey('f', mobile)


