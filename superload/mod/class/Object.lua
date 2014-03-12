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

local _M = loadPrevious(...)
local base_getRequirementDesc = _M.getRequirementDesc

function _M:getRequirementDesc(who)
  if self.subtype == "shield" and who:knowTalent(who.T_SKIRMISHER_BUCKLER_EXPERTISE) then
    print("[SKIRMISHER] Using alternate req desc")
    local req = rawget(self, "require")
    if not req then return nil end
    local stat = req.stat
    local talent = req.talent
    req.stat = nil
    req.talent = nil
    local desc = base_getRequirementDesc(self, who)
    req.stat = stat
    req.talent = talent
    return desc
  else
    return base_getRequirementDesc(self, who)
  end
end

return _M
