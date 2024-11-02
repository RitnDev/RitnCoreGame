-- RitnCoreSurface
----------------------------------------------------------------
local flib = require(ritnlib.defines.core.functions)
----------------------------------------------------------------
--- CLASSE DEFINES
----------------------------------------------------------------
RitnCoreSurface = ritnlib.classFactory.newclass(RitnLibSurface, function(self, LuaSurface)
    RitnLibSurface.init(self, LuaSurface)
    --------------------------------------------------
    self.admin = false
    self.data = remote.call("RitnCoreGame", "get_surfaces")
    self.data_player = remote.call("RitnCoreGame", "get_data", "surface_player")
    self.data_surface = remote.call("RitnCoreGame", "get_data", "surface")
    self.data_surface.index = self.index
    self.data_surface.name = self.name
    ----
    self.prefix_lobby = ritnlib.defines.core.names.prefix.lobby
    --------------------------------------------------
end)

----------------------------------------------------------------

-- nb surfaces
function RitnCoreSurface:length()
    return #self.data
end


----------------------------------------------------------------

-- init data surface
function RitnCoreSurface:new(exception)
    if self.data[self.name] then return self end 
    log('> '..self.object_name..':new() -> '..self.name)
    
    self.data[self.name] = self.data_surface

    -- gestion des exceptions
    local vException = self.isNauvis or self.admin
    if exception ~= nil then 
        if type(exception) == "boolean" then 
            vException = exception
        end
    end
    self:setException(vException)

    local nb_surfaces = remote.call('RitnCoreGame', 'get_values', 'surfaces') + 1
    remote.call('RitnCoreGame', 'set_values', 'surfaces', nb_surfaces)

    return self
end



-- GET EXCEPTION
function RitnCoreSurface:getException()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getException() -> '..self.name)
    return self.data[self.name].exception
end


-- SET EXCEPTION
function RitnCoreSurface:setException(value)
    if type(value) ~= "boolean" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':setException() -> '..self.name)

    self.data[self.name].exception = value

    self:update()
    
    return self
end

-- GET FINISH
function RitnCoreSurface:getFinish()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getFinish() -> '..self.name)

    return self.data[self.name].finish
end


-- SET FINISH
function RitnCoreSurface:setFinish(value)
    if type(value) ~= "boolean" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end
    log('> '..self.object_name..':setFinish() -> '..self.name) 

    self.data[self.name].finish = value

    self:update()
    
    return self
end


-- GET ADMIN
function RitnCoreSurface:getAdmin()
    return self.admin
end


-- SET ADMIN
function RitnCoreSurface:setAdmin(admin)
    local vAdmin = false
    if admin ~= nil then vAdmin = admin end
    if type(vAdmin) ~= "boolean" then return self end
    ----
    self.admin = vAdmin
    ----
    return self
end



-- GET ORIGINE
function RitnCoreSurface:getOrigine()
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':getOrigine() -> '..self.name)

    return self.data[self.name].origine
end


-- SET ORIGINE
function RitnCoreSurface:setOrigine(origine)
    if type(origine) ~= "string" then return self end
    if self.data[self.name] == nil then return error(self.name .. " not init !") end 
    log('> '..self.object_name..':setOrigine() -> '..self.name)

    self.data[self.name].origine = origine

    self:update()
    
    return self
end


----------------------------------------------------------------

function RitnCoreSurface:addPlayer(LuaPlayer)
    if string.sub(self.name, 1, string.len(self.prefix_lobby)) == self.prefix_lobby then return self end
    log('> '..self.object_name..':addPlayer() -> '..self.name)
    
    self:new(exception) 

    self.data[self.name].players[LuaPlayer.name] = self.data_player
    self.data[self.name].players[LuaPlayer.name].name = LuaPlayer.name
    log('> player '.. LuaPlayer.name .. ' -> surface : ' .. self.name .. ' (add)')

    if self.isNauvis == false then 
        self.data[self.name].map_used = flib.tableBusy(self.data[self.name].players)
    end

    self:update()

    return self
end


function RitnCoreSurface:removePlayer(LuaPlayer)
    if string.sub(self.name, 1, string.len(self.prefix_lobby)) == self.prefix_lobby then return self end
    log('> '..self.object_name..':removePlayer() -> '..self.name)

    local exception = self.isNauvis or LuaPlayer.admin
    self:new(exception) 

    if self.data[self.name].players[LuaPlayer.name] == nil then return self end

    self.data[self.name].players[LuaPlayer.name] = nil

    if self.isNauvis == false then 
        self.data[self.name].map_used = flib.tableBusy(self.data[self.name].players)
    end

    log('> player '.. LuaPlayer.name .. ' -> surface : ' .. self.name .. ' (remove)')

    self:update()

    return self
end


function RitnCoreSurface:delete()
    log('> '..self.object_name..':delete() -> '..self.name)
    local core_data_surfaces = remote.call("RitnCoreGame", "get_surfaces")

    if core_data_surfaces[self.name] == nil then return end
    
    if not core_data_surfaces[self.name].exception then 
        -- suppression de la force : storage.core.surfaces[surface_name] = nil
        core_data_surfaces[self.name] = nil
    end

    -- update storage.core.surfaces
    remote.call("RitnCoreGame", "set_surfaces", core_data_surfaces) 

    local nb_surfaces = remote.call('RitnCoreGame', 'get_values', 'surfaces') - 1
    remote.call('RitnCoreGame', 'set_values', 'surfaces', nb_surfaces)
end

----------------------------------------------------------------
function RitnCoreSurface:update()
    remote.call("RitnCoreGame", "set_surfaces", self.data) 
    return self
end
