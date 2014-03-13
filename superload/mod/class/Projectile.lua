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
local Map = require "engine.Map"

local _M = loadPrevious(...)
local base_onMove = _M.on_move

function _M:on_move(x, y, target)
  print("[SKIRMISHER] using modified projectile on_move")
  if target.getTalentFromId and target ~= self.src then
    if target:knowTalent(T_SKIRMISHER_BUCKLER_MASTERY) then
      local t = target:getTalentFromId(target.T_SKIRMISHER_BUCKLER_MASTERY)
      --x, y = t.offsetTarget(target, t, x, y)
    end
  end
  base_onMove(self, x, y, target)
end

return _M