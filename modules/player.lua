-- MODULE : PLAYER
---------------------------------------------------------------------------------------------
local RitnEvent = require(ritnlib.defines.core.class.event)
---------------------------------------------------------------------------------------------


local function on_player_changed_surface(e)
    local rEvent = RitnEvent(e)
    local rPlayer = RitnEvent(e):getPlayer()
    
    rPlayer:changeSurface()
    
    log('on_player_changed_surface')
end



local function on_player_changed_force(e)
    local rEvent = RitnEvent(e)
    local rPlayer = RitnEvent(e):getPlayer()
    
    rPlayer:changeForce()
    
    log('on_player_changed_force')
end


local function on_pre_player_left_game(e)
    local rEvent = RitnEvent(e)
    local rPlayer = RitnEvent(e):getPlayer()
    
    local msg = 'on_pre_player_left_game: player: '.. rPlayer.name .. ' - surface: '..rPlayer.surface.name..' - reason: '.. rEvent:getReason()
    print(msg)
    log('on_pre_player_left_game')
end


local function on_player_cheat_mode_enabled(e)
    remote.call("RitnCoreGame", "cheatModeActivated")

    log('on_player_cheat_mode_enabled')
end


---------------------------------------------------------------------------------------------
local module = {events = {}}
---------------------------------------------------------------------------------------------
-- Events Player
module.events[defines.events.on_player_cheat_mode_enabled] = on_player_cheat_mode_enabled
module.events[defines.events.on_player_changed_surface] = on_player_changed_surface
module.events[defines.events.on_player_changed_force] = on_player_changed_force
module.events[defines.events.on_pre_player_left_game] = on_pre_player_left_game
---------------------------------------------------------------------------------------------
return module