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

_M = loadPrevious(...)

_M:addCombatTraining("sling", "T_SKIRMISHER_SLING_SUPREMACY")

local base_combatArmorHardiness = _M.combatArmorHardiness
local base_attackTargetWith = _M.attackTargetWith

function _M:combatArmorHardiness()
  local hardy = base_combatArmorHardiness(self)
  if self:knowTalent(self.T_SKIRMISHER_BUCKLER_EXPERTISE) then
    hardy = hardy + self:callTalent(self.T_SKIRMISHER_BUCKLER_EXPERTISE, "getHardiness")
  end
  return util.bound(hardy, 0, 100)
end

function _M:attackTargetWith(target, weapon, damtype, mult, force_dam)
  print("[SKIRMISHER] using modified attackTargetWith")
  if target:knowTalent(target.T_SKIRMISHER_BUCKLER_EXPERTISE) then
    local t = target:getTalentFromId(target.T_SKIRMISHER_BUCKLER_EXPERTISE)
    if t.shouldEvade(target, t) then
      game.logSeen(target, "%s deflects the attack.", target.name:capitalize())
      print("[SKIRMISHER] attack evaded")
      t.onEvade(target, t, self)
      return self:combatSpeed(weapon), false
    end
  end
  return base_attackTargetWith(self, target, weapon, damtype, mult, force_dam)
end

return _M
