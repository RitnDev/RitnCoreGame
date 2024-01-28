-- RitnForce
----------------------------------------------------------------
local class = require(ritnlib.defines.class.core)
local LibForce = require(ritnlib.defines.class.luaClass.force)
----
local flib = require(ritnlib.defines.core.functions)
----------------------------------------------------------------



----------------------------------------------------------------
--- CLASSE DEFINES
----------------------------------------------------------------
local RitnForce = class.newclass(LibForce, function(base, LuaForce)
    if LuaForce == nil then return end
    if LuaForce.valid == false then return end
    if LuaForce.object_name ~= "LuaForce" then return end
    LibForce.init(base, LuaForce)
    --------------------------------------------------
    base.data = remote.call("RitnCoreGame", "get_forces")
    base.data_player = remote.call("RitnCoreGame", "get_data", "force_player")
    base.data_force = remote.call("RitnCoreGame", "get_data", "force")
    base.data_force.name = base.name
    base.data_force.index = base.index
    --------------------------------------------------
end)

----------------------------------------------------------------

-- nb surfaces
function RitnForce:length()
    return #self.data
end

-- force enemy ?
function RitnForce:isEnemy()
    return self.force.is_enemy()
end

----------------------------------------------------------------

-- init data force
function RitnForce:new()
    if self.data[self.name] then return self end 
    log('> '..self.object_name..':new() -> '..self.name)

    self.data[self.name] = self.data_force

    self:setException(false)

    local nb_forces = remote.call('RitnCoreGame', 'get_values', 'forces') + 1
    remote.call('RitnCoreGame', 'set_values', 'forces', nb_forces)

    return self
end

-- create new force
function RitnForce:create(force_name)
    log('> RitnForce:create() -> '..force_name)

    local LuaForce = game.create_force(force_name)
    LuaForce.reset()
    LuaForce.research_queue_enabled = true
    LuaForce.chart(force_name, {{x = -200, y = -200}, {x = 200, y = 200}})
    
    for _,force in pairs(game.forces) do
        if string.sub(force.name, 1, 5) ~= "enemy" and force.name ~= "neutral" then
          LuaForce.set_friend(force.name, true)
          game.forces["player"].set_friend(LuaForce.name, true)
        end
    end
 
    for r_name, recipe in pairs(game.forces["player"].recipes) do
        LuaForce.recipes[r_name].enabled = recipe.enabled
    end

    self(LuaForce):new()

    return self
end


function RitnForce.delete(force_name)
    core_data_forces = remote.call("RitnCoreGame", "get_forces")

    if core_data_forces[force_name] == nil then return end
    -- vidage de la liste des players de cette force
    core_data_forces[force_name].players = {}
    
    if not core_data_forces[force_name].exception then 
        -- suppression de la force : global.core.forces[force_name] = nil
        core_data_forces[force_name] = nil
    end

    -- update global.core.forces
    remote.call("RitnCoreGame", "set_forces", core_data_forces) 

    local nb_forces = remote.call('RitnCoreGame', 'get_values', 'forces') - 1
    remote.call('RitnCoreGame', 'set_values', 'forces', nb_forces)
end


-- GET EXCEPTION
function RitnForce:getException()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getException() -> '..self.name)
    return self.data[self.name].exception
end


-- SET EXCEPTION
function RitnForce:setException(value)
    if type(value) ~= "boolean" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':setException() -> '..self.name)

    if self.name ~= "player"
    and self.name ~= "enemy"
    and self.name ~= "neutral" then 
        self.data[self.name].exception = value
    end

    self:update()
    
    return self
end


-- GET FINISH
function RitnForce:getFinish()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getFinish() -> '..self.name)

    return self.data[self.name].finish
end


-- SET FINISH
function RitnForce:setFinish(value)
    if type(value) ~= "boolean" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end
    log('> '..self.object_name..':setFinish() -> '..self.name) 

    self.data[self.name].finish = value

    self:update()
    
    return self
end


----------------------------------------------------------------

function RitnForce:addPlayer(LuaPlayer)
    log('> '..self.object_name..':addPlayer() -> '..self.name)

    self:new() 

    self.data[self.name].players[LuaPlayer.name] = self.data_player
    self.data[self.name].players[LuaPlayer.name].name = LuaPlayer.name
    log('> player '.. LuaPlayer.name .. ' -> force : ' .. self.name .. ' (add)')

    --if self.name ~= "player" then 
        self.data[self.name].force_used = flib.tableBusy(self.data[self.name].players)
    --end

    self:update()

    return self
end


function RitnForce:removePlayer(LuaPlayer)
    log('> '..self.object_name..':removePlayer() -> '..self.name)

    self:new() 

    if self.data[self.name].players[LuaPlayer.name] == nil then return self end

    self.data[self.name].players[LuaPlayer.name] = nil

    --if self.name ~= "player" then 
        self.data[self.name].force_used = flib.tableBusy(self.data[self.name].players)
    --end

    log('> player '.. LuaPlayer.name .. ' -> force : ' .. self.name .. ' (remove)')

    self:update()

    return self
end


function RitnForce:listPlayers()
    log('> '..self.object_name..':listPlayers() -> '..self.name)
    if self.data[self.name].players == nil then return {} end

    return self.data[self.name].players
end


----------------------------------------------------------------
-- UPDATE DATA
function RitnForce:update()
    remote.call("RitnCoreGame", "set_forces", self.data) 
    return self
end

----------------------------------------------------------------
return RitnForce