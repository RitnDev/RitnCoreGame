local modules = {}
log('modules RitnCoreGame')
------------------------------------------------------------------------------
-- Inclus les events onInit et onLoad + les ajouts de commandes
modules.storage =   require(ritnlib.defines.core.modules.storage)
modules.events =    require(ritnlib.defines.core.modules.events)
modules.commands =  require(ritnlib.defines.core.modules.commands)
----
modules.player =    require(ritnlib.defines.core.modules.player)
modules.surface =   require(ritnlib.defines.core.modules.surface)
modules.force =     require(ritnlib.defines.core.modules.force)
------------------------------------------------------------------------------
return modules