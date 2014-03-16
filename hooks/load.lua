-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"

local hook

hook = function(self, data)
	ActorTalents:loadDefinition("/data-skirmisher/talents.lua")
  ActorTemporaryEffects:loadDefinition("/data-skirmisher/effects.lua")
	Birther:loadDefinition("/data-skirmisher/birth.lua")
end
class:bindHook("ToME:load", hook)

hook = function(self, data)
  if data.moved and not data.force and self.skirmisher_reload_on_move then
    -- Swift Shoot cooldown. (Change back in 1.1.6)
    local swift = self:getTalentFromId("T_SKIRMISHER_SWIFT_SHOT")
    local cooldown = self.talents_cd[swift.id] or 0
    if cooldown > 0 then
      self.talents_cd[swift.id] = math.max(cooldown - 1, 0)
    end

    -- Reload on move.
		local ammo, err = self:hasAmmo()
    if not ammo then return end
		for i = 1, self.skirmisher_reload_on_move do
			if ammo.combat.shots_left >= ammo.combat.capacity then break end
			ammo.combat.shots_left = ammo.combat.shots_left + 1
		end
  end
end
class:bindHook("Actor:move", hook)
