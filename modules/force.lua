-- MODULE : FORCE
---------------------------------------------------------------------------------------------

-- A la creation d'une force, on passe tout les lobby en hidden pour celle-ci
local function on_force_created(e)
    local rEvent = RitnCoreEvent(e)
    local rForce = RitnCoreForce(rEvent.force)
    for _,surface in pairs(game.surfaces) do
        local rSurface = RitnCoreSurface(surface)
        -- si c'est une map "lobby" on la cache à cette force
        if (rSurface.isLobby) then 
            log('> force.name: '.. rForce.name .. ' -> hidden surface: '.. rSurface.name)
            rForce:setHiddenSurface(rSurface.name, true)
        end
    end
    log('> on_force_created')
end


---------------------------------------------------------------------------------------------
local module = {events = {}}
---------------------------------------------------------------------------------------------
-- Events Force
module.events[defines.events.on_force_created] = on_force_created
---------------------------------------------------------------------------------------------
return module