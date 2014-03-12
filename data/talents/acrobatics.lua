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

newTalentType {
  type = "technique/acrobatics",
  name = "Acrobatics",
  generic = true,
  allow_random = true,
  description = "For light footed Rogues who prefer flight to fighting fair!",
}

newTalent {
  short_name = "SKIRMISHER_VAULT",
  name = "Vault",
  type = {"technique/acrobatics", 1},
  require = lowReqGen("dex", 1),
  points = 5,
  random_ego = "attack",
  cooldown = function(self, t) return 25 end,
  stamina = 14,
  tactical = {ESCAPE = 2},
  on_pre_use = function(self, t)
    return not self:attr("never_move")
  end,
  range = function(self, t)
    return math.floor(2 + self:getTalentLevel(t) * 0.5)
  end,
  target = function(self, t)
    return {type="beam", range=self:getTalentRange(t), talent=t}
  end,
  speed_bonus = function(self, t)
    return self:getTalentLevel(t) * 0.1
  end,
  action = function(self, t)
    -- Get Landing Point.
    local tg = self:getTalentTarget(t)
    local tx, ty, target = self:getTarget(tg)
    if not tx or not ty then return end
    if tx == self.x and ty == self.y then return end
    if target or
      game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self)
    then
      game.logPlayer(self, "You must have an empty space to land in.")
      return
    end

    -- Get Launch target.
    local block_actor = function(_, bx, by)
      return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self)
    end
    local line = self:lineFOV(tx, ty, block_actor)
    local lx, ly, is_corner_blocked = line:step()
    local launch_target = game.level.map(lx, ly, Map.ACTOR)
    if not launch_target then
      game.logPlayer(self, "You must have a target to vault over.")
      return
    end

    local ox, oy = self.x, self.y
    self:move(tx, ty, true)

    local give_speed = function()
      self:setEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED, 3, {
                       direction = math.atan2(ty - oy, tx - ox),
                       leniency = math.pi * 0.25, -- 90 degree cone
                       move_speed_bonus = t.speed_bonus(self, t)})
    end
    game:onTickEnd(give_speed)

    return true
  end,
  info = function(self, t)
    return ([[Use your opponent as a platform and spring off of them, landing on the target square.

Not implemented: and temporarily gaining a burst of speed from the momentum, letting you run in the same direction you vaulted in 10%%-50%% (dex) faster for 3 turns. Buff ends if you change directions or stop moving. Can be used on Traps to move past them without triggering.]])
  end,
}
