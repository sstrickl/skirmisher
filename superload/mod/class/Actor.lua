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
local base_canWearObject = _M.canWearObject

function _M:canWearObject(o, try_slot)
  if o.subtype == "shield" and self:knowTalent(self.T_SKIRMISHER_BUCKLER_EXPERTISE) then
    print("[SKIRMISHER] Using skirmisher shield check")
    -- we still have to do checks on the slot
    
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

-- Directed Speed will be cancelled by non-movement actions.
local breakStepUp = _M.breakStepUp
function _M:breakStepUp()
  breakStepUp(self)
  if self:hasEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED) then
    self:removeEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED)
  end
end

return _M
