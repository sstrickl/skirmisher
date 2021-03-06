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

require "engine.class"
require "engine.interface.ActorProject"
local Map = require "engine.Map"

local _M = loadPrevious(...)
local base_canWearObject = _M.canWearObject
local base_projectDoStop = _M.projectDoStop
local base_incStamina = _M.incStamina
local base_onTakeHit = _M.onTakeHit

-- Remove shield reqs if you know buckler stuff
function _M:canWearObject(o, try_slot)
  if o.subtype == "shield" and self:knowTalent(self.T_SKIRMISHER_BUCKLER_EXPERTISE) then
    print("[SKIRMISHER] Using skirmisher shield check")
    -- we still have to do checks on the slot, copy/pasted mostly

    -- Check forbidden slot
    if o.slot_forbid then
      local inven = self:getInven(o.slot_forbid)
      -- If the object cant coexist with that inventory slot and it exists and is not empty, refuse wearing
      if inven and #inven > 0 then
        return nil, "cannot use currently due to an other worn object"
      end
    end

    -- Check that we are not the forbidden slot of any other worn objects
    for id, inven in pairs(self.inven) do
      if self.inven_def[id].is_worn and (not self.inven_def[id].infos or not self.inven_def[id].infos.etheral) then
        for i, wo in ipairs(inven) do
          if wo.slot_forbid and wo.slot_forbid == (try_slot or o.slot) then
            return nil, "cannot use currently due to an other worn object"
          end
        end
      end
    end

    return true

  else
    return base_canWearObject(self, o, try_slot)
  end
end

-- This seems like the only reasonable place to do projectile deflection
-- we're also going to prevent phasing projectiles from stopping anywhere but their target
function _M:projectDoStop(typ, tg, damtype, dam, particles, lx, ly, tmp, rx, ry, projectile)
  print("[SKIRMISHER] using modified projectDoStop")
  -- Abort if phasing and not at target
  if projectile.project.def.tg.archery and projectile.project.def.tg.archery.phasing then
    print("PHASING", lx, ly, projectile.project.def.x, projectile.project.def.y)
    local target = game.level.map(lx, ly, game.level.map.ACTOR)
    if (lx ~= projectile.project.def.x or ly ~= projectile.project.def.y) and
      target ~= projectile.project.def.tg.archery.phase_target
    then return end
  end

  -- Deflection check
  local target = game.level.map:call(lx, ly, Map.ACTOR)
  if target and target.getTalentFromId and target ~= projectile.src then
    if target:knowTalent(target.T_SKIRMISHER_BUCKLER_MASTERY) then
      local t = target:getTalentFromId(target.T_SKIRMISHER_BUCKLER_MASTERY)
      lx, ly = t.offsetTarget(target, t, lx, ly, projectile)
    end
  end

  return base_projectDoStop(self, typ, tg, damtype, dam, particles, lx, ly, tmp, rx, ry, projectile)
end

-- Trigger Eternal Warrior on stamina spend
function _M:incStamina(stamina)
  print("[SKIRMISHER] using modified incStamina")
  if self:knowTalent(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR) then
    local t = self:getTalentFromId(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR)
    t.onIncStamina(self, t, stamina)
  end
  base_incStamina(self, stamina)
end

-- Reduce damage and trigger for Trained Reactions
function _M:onTakeHit(value, src, death_note)
  print("[SKIRMISHER] using modified onTakeHit")
  local newValue = value
  if self:attr("incoming_reduce") then
    newValue = newValue * (100-self:attr("incoming_reduce")) / 100
  end
  local finalDamage = base_onTakeHit(self, newValue, src, death_note)
  if self:knowTalent(self.T_SKIRMISHER_TRAINED_REACTIONS) then
    local t = self:getTalentFromId(self.T_SKIRMISHER_TRAINED_REACTIONS)
    finalDamage = t.onHit(self, t, finalDamage)
  end
  return finalDamage
end

-- Directed Speed will be cancelled by non-movement actions.
local breakStepUp = _M.breakStepUp
function _M:breakStepUp()
  breakStepUp(self)
  if self:hasEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED) then
    self:removeEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED)
  end
end

return _M
