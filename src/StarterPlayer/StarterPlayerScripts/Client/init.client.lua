for _, child in script:GetDescendants() do if child:IsA("ModuleScript") then shared[child.Name] = require(child) end end
for _, mod in shared do if type(mod.initialize) == 'function' then mod.initialize() end end
for _, mod in shared do if type(mod.start) == 'function' then task.defer(mod.start) end end