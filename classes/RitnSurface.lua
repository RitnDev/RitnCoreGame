-- RitnSurface
----------------------------------------------------------------
local class = require(ritnlib.defines.class.core)
local LibSurface = require(ritnlib.defines.class.luaClass.surface)
----
local flib = require(ritnlib.defines.core.functions)
----------------------------------------------------------------



----------------------------------------------------------------
--- CLASSE DEFINES
----------------------------------------------------------------
local RitnSurface = class.newclass(LibSurface, function(base, LuaSurface)
    if LuaSurface == nil then return end
    if LuaSurface.valid == false then return end
    if LuaSurface.object_name ~= "LuaSurface" then return end
    LibSurface.init(base, LuaSurface)
    --------------------------------------------------
    base.data = remote.call("RitnCoreGame", "get_surfaces")
    base.data_player = remote.call("RitnCoreGame", "get_data", "surface_player")
    base.data_surface = remote.call("RitnCoreGame", "get_data", "surface")
    base.data_surface.name = base.name
    ----
    base.enemy_name = ritnlib.defines.core.names.prefix.enemy .. base.name
    base.prefix_lobby = ritnlib.defines.core.names.prefix.lobby
    -- forces link to surface
    base.forces = { "guides" }
    if base.name == "nauvis" then 
    table.insert(base.forces, "player") else 
    table.insert(base.forces, base.name) end
    --------------------------------------------------
end)

----------------------------------------------------------------

-- nb surfaces
function RitnSurface:length()
    return #self.data
end


----------------------------------------------------------------

-- init data surface
function RitnSurface:new()
    if self.data[self.name] then return self end 
    log('> '..self.object_name..':new() -> '..self.name)

    local exception = self.name == "nauvis"

    self.data[self.name] = self.data_surface
    self:setException(exception)

    local nb_surfaces = remote.call('RitnCoreGame', 'get_values', 'surfaces') + 1
    remote.call('RitnCoreGame', 'set_values', 'surfaces', nb_surfaces)

    return self
end



-- GET EXCEPTION
function RitnSurface:getException()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getException() -> '..self.name)
    return self.data[self.name].exception
end


-- SET EXCEPTION
function RitnSurface:setException(value)
    if type(value) ~= "boolean" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':setException() -> '..self.name)

    self.data[self.name].exception = value

    self:update()
    
    return self
end

-- GET FINISH
function RitnSurface:getFinish()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getFinish() -> '..self.name)

    return self.data[self.name].finish
end


-- SET FINISH
function RitnSurface:setFinish(value)
    if type(value) ~= "boolean" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end
    log('> '..self.object_name..':setFinish() -> '..self.name) 

    self.data[self.name].finish = value

    self:update()
    
    return self
end




-- GET ORIGINE
function RitnSurface:getOrigine()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getOrigine() -> '..self.name)

    return self.data[self.name].origine
end


-- SET ORIGINE
function RitnSurface:setOrigine(origine)
    if type(origine) ~= "string" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':setOrigine() -> '..self.name)

    self.data[self.name].origine = origine

    self:update()
    
    return self
end


----------------------------------------------------------------

function RitnSurface:addPlayer(LuaPlayer)
    if string.sub(self.name, 1, string.len(self.prefix_lobby)) == self.prefix_lobby then return self end
    log('> '..self.object_name..':addPlayer() -> '..self.name)

    self:new() 

    self.data[self.name].players[LuaPlayer.name] = self.data_player
    self.data[self.name].players[LuaPlayer.name].name = LuaPlayer.name
    log('> player '.. LuaPlayer.name .. ' -> surface : ' .. self.name .. ' (add)')

    if self.name ~= "nauvis" then 
        self.data[self.name].map_used = flib.tableBusy(self.data[self.name].players)
    end
    --self:updateCeaseFires()

    self:update()

    return self
end


function RitnSurface:removePlayer(LuaPlayer)
    if string.sub(self.name, 1, string.len(self.prefix_lobby)) == self.prefix_lobby then return self end
    log('> '..self.object_name..':removePlayer() -> '..self.name)

    self:new() 

    if self.data[self.name].players[LuaPlayer.name] == nil then return --[[ self:updateCeaseFires() ]] end

    self.data[self.name].players[LuaPlayer.name] = nil

    if self.name ~= "nauvis" then 
        self.data[self.name].map_used = flib.tableBusy(self.data[self.name].players)
    end
    --self:updateCeaseFires()
    log('> player '.. LuaPlayer.name .. ' -> surface : ' .. self.name .. ' (remove)')

    self:update()

    return self
end

--[[ 
function RitnSurface:updateCeaseFires()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    
    local map_used = self.data[self.name].map_used

    for _,force in pairs(self.forces) do
        if game.forces[force] then
            game.forces["enemy"].set_cease_fire(force, not map_used)
            if game.forces[self.enemy_name] then 
                game.forces[self.enemy_name].set_cease_fire(force, not map_used)
            end
        end
    end
  
    return self
end
]]
----------------------------------------------------------------
--[[ 
function RitnSurface:getInventories() 
    return self.data[self.name].inventories
end
]]

function RitnSurface:update()
    remote.call("RitnCoreGame", "set_surfaces", self.data) 
    return self
end

----------------------------------------------------------------
return RitnSurface