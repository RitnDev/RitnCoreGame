-- MODULE : PLAYER
---------------------------------------------------------------------------------------------
local strings = require(ritnlib.defines.string)
---------------------------------------------------------------------------------------------


local function on_player_changed_surface(e)
    local rEvent = RitnCoreEvent(e)
    local rPlayer = RitnCoreEvent(e):getPlayer()
    
    rPlayer:changeSurface()
    
    log('on_player_changed_surface')
end



local function on_player_changed_force(e)
    local rEvent = RitnCoreEvent(e)
    local rPlayer = RitnCoreEvent(e):getPlayer()
    -- Changement de force dans les data du core
    rPlayer:changeForce()    

    -- On récupère la force du joueur
    local rForce = rPlayer:getForce()

    -- On cache les surfaces sur lequel le joueur ne se trouve pas, sauf celle d'origine
    local origine = strings.defaultValue(rPlayer:getOrigine(), rPlayer.name)
    for _, surface in pairs(game.surfaces) do 
        if surface.name ~= rPlayer.surface.name or surface.name ~= origine then 
            rForce:setHiddenSurface(surface)
        end
    end
    
    log('on_player_changed_force')
end


local function on_pre_player_left_game(e)
    local rEvent = RitnCoreEvent(e)
    local rPlayer = RitnCoreEvent(e):getPlayer()
    
    local msg = 'on_pre_player_left_game: player: '.. rPlayer.name .. ' - surface: '..rPlayer.surface.name..' - reason: '.. rEvent:getReason()
    print(msg)
    log('on_pre_player_left_game')
end


local function on_player_cheat_mode_enabled(e)
    remote.call("RitnCoreGame", "cheatModeActivated")

    log('on_player_cheat_mode_enabled')
end


local function on_player_created(e)
    if game.is_multiplayer() then remote.call("RitnCoreGame", "setMultiplayer") end

    if RitnCoreForce.exists(ritnlib.defines.core.names.force_default) == false then 
        local rEvent = RitnCoreEvent(e):createForceDefault()
        local rForceDefault = RitnCoreForce(rEvent.force)
        rForceDefault:new():setException(true)
    end
end


---------------------------------------------------------------------------------------------
local module = {events = {}}
---------------------------------------------------------------------------------------------
-- Events Player
module.events[defines.events.on_player_created] = on_player_created
module.events[defines.events.on_player_cheat_mode_enabled] = on_player_cheat_mode_enabled
module.events[defines.events.on_player_changed_surface] = on_player_changed_surface
module.events[defines.events.on_player_changed_force] = on_player_changed_force
module.events[defines.events.on_pre_player_left_game] = on_pre_player_left_game
---------------------------------------------------------------------------------------------
return module