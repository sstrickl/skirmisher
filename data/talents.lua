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

-- shamelessly copied from nullpack

lowLevReqGen = function(rank)
  local lev_base  = {  0,  4,  8, 12 }
  return {
    level = function(lev) return lev_base[rank]+(lev-1) end,
  }
end

lowReqGen = function(abil, rank)
  local stat_base = { 12, 20, 28, 36 }
  local lev_base  = {  0,  4,  8, 12 }

  local req_table = {
    stat = { [abil] = function(lev) return stat_base[rank] + ((lev-1)*2) end, },
    level = function(lev) return lev_base[rank] + (lev-1) end,
  }
  return req_table
end

highReqGen = function(abil, rank)
  local stat_base = { 22, 30, 38, 46 }
  local lev_base  = { 10, 14, 18, 22 }

  local req_table = {
    stat = {[abil] = function(lev) return stat_base[rank] + ((lev-1)*2) end, },
    level= function(lev) return lev_base[rank] + (lev-1) end,
  }
  return req_table
end


damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

load("/data-skirmisher/talents/skirmisher-slings.lua")
load("/data-skirmisher/talents/called-shots.lua")
load("/data-skirmisher/talents/buckler-training.lua")
load("/data-skirmisher/talents/acrobatics.lua")
