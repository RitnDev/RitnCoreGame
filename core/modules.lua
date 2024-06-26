local modules = {}
------------------------------------------------------------------------------
-- Inclus les events onInit et onLoad + les ajouts de commandes
modules.globals =   require(ritnlib.defines.core.modules.globals)
modules.events =    require(ritnlib.defines.core.modules.events)
modules.commands =  require(ritnlib.defines.core.modules.commands)
----
modules.player =    require(ritnlib.defines.core.modules.player)
------------------------------------------------------------------------------
return modules