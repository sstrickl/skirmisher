local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local Birther = require "engine.Birther"

local hook

hook = function(self, data)
	ActorTalents:loadDefinition("/data-skirmisher/talents.lua")
	Birther:loadDefinition("/data-skirmisher/birth.lua")
end
class:bindHook("ToME:load", hook)
