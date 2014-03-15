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
  stamina = staminaCost(14),
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
    if core.fov.distance(self.x, self.y, tx, ty) > self:getTalentRange(t) then return end
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
    return ([[Use your opponent as a platform and spring off of them, landing on the target square and temporarily gaining a burst of speed from the momentum, letting you run in the same direction you vaulted in %d%% faster for 3 turns. Buff ends if you change directions or stop moving.

Not Implemented: Can be used on Traps to move past them without triggering.]])
      :format(t.speed_bonus(self, t) * 100)
  end,
}

newTalent {
  short_name = "SKIRMISHER_CUNNING_ROLL",
  name = "Cunning Roll",
  type = {"technique/acrobatics", 2},
  require = lowReqGen("dex", 2),
  points = 5,
  random_ego = "attack",
  cooldown = function(self, t) return 20 end,
  no_energy = true,
  stamina = function(self, t)
    return applyPace(self, t, math.max(0, 45 - self:getTalentLevel(t) * 5))
  end,
  tactical = {ESCAPE = 2, BUFF = 1},
  range = function(self, t)
    return 2 + math.floor(self:getTalentLevel(t) / 6)
  end,
  target = function(self, t)
    return {type="beam", range=self:getTalentRange(t), talent=t}
  end,
  combat_physcrit = function(self, t)
    if self:getTalentLevel(t) >= 3 then
      return self:combatCrit()
    end
  end,
  action = function(self, t)
    local tg = self:getTalentTarget(t)
    local x, y, target = self:getTarget(tg)
    if not x or not y then return end
    if self.x == x and self.y == y then return end
    if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return end
    if target or game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self) then
      game.logPlayer(self, "You must have an empty space to roll to.")
    end

    self:move(x, y, true)
    local combat_physcrit = t.combat_physcrit(self, t)
    if combat_physcrit then
      -- Can't set to 0 duration directly, so set to 1 and then decrease by 1.
      self:setEffect("EFF_SKIRMISHER_TACTICAL_POSITION", 1, {combat_physcrit = combat_physcrit})
      local eff = self:hasEffect("EFF_SKIRMISHER_TACTICAL_POSITION")
      eff.dur = eff.dur - 1
    end

    return true
  end,
  info = function(self, t)
    return ([[Move to target empty square, passing through any enemies in the way.
Beginning at rank 3, Cunning Roll doubles your physical critical chance for 1 turn.]])
  end
}

newTalent {
  short_name = "SKIRMISHER_TRAINED_REACTIONS",
  name = "Trained Reactions",
  type = {"technique/acrobatics", 3},
  mode = "sustained",
  points = 5,
  cooldown = 10,
  sustain_stamina = 0,
  require = lowReqGen('dex', 3),
  tactical = { BUFF = 2 },
	
  activate = function(self, t)
    return {}
  end,
  deactivate = function(self, t, p)
    return true
  end,
  getLifeTrigger = function(self, t)
    return self:combatTalentScale(t, 40, 24)
  end,
  getReduction = function(self, t)
    return self:combatTalentScale(t, 50, 66)
  end,
  getTriggerCost = function(self, t)
    return 15
  end,
  -- called by mod/Actor.lua, although it could be a callback one day
  onHit = function(self, t, damage)
    local cost = t.getTriggerCost(self, t)
    if damage > self.max_life * t.getLifeTrigger(self, t) / 100 and self.stamina > cost then
      -- now to find empty space
      local nx, ny = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
      if nx then
        local ox, oy = self.x, self.y
        self:move(nx, ny, true)
        self:setEffect("EFF_SKIRMISHER_DEFENSIVE_ROLL", 1, {reduce = t.getReduction(self, t)})
        local eff = self:hasEffect("EFF_SKIRMISHER_DEFENSIVE_ROLL")
        eff.dur = eff.dur - 1
        self:incStamina(-cost)
        return damage * (100-t.getReduction(self, t)) / 100
      end
    end
    return damage
  end,
  
  info = function(self, t)
    local trigger = t.getLifeTrigger(self, t)
    local reduce = t.getReduction(self, t)
    local cost = t.getTriggerCost(self, t)
    return ([[While sustainted, any time you would lose more than %d%% of your life in a single hit, you instead roll out of the way, moving into an adjacent tile and gaining a temporary buff that reduces this damage and all further damage that turn by %d%%.
			This requires an empty square to move to, costs %d Stamina per roll, and will not trigger if you do not have the Stamina.]])
      :format(trigger, reduce, cost)
  end,
  
}




