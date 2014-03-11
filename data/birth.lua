newBirthDescriptor{
   type = "subclass",
   name = "Skirmisher",
   desc = {
      "While able to take maximum advantage of their Sling by using deft movements to avoid and confuse enemies that try to get close, the Skirmisher truly excels when fighting other ranged users. They have mastered the use of their Shield as well as their Sling and are nearly impossible to defeat in a standoff.",
      "They use: ",
      "#GOLD#Stat modifiers:",
      "#LIGHT_BLUE# * +0 Strength, +4 Dexterity, +0 Constitution",
      "#LIGHT_BLUE# * +0 Magic, +1 Willpower, +4 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +0",
   },
   power_source = {technique=true},
   stats = {dex = 4, cun = 4, wil = 1},
   talents_types = {
     -- Class
     ["technique/skirmisher-slings"]={true, 0.3},
     ["cunning/called-shots"]={true, 0.3},
     ["cunning/trapping"]={false, 0.1},
     -- Generic
     ["technique/combat-training"]={true, 0.3},
     ["cunning/survival"]={true, 0.3},
     ["technique/field-control"]={false, 0.1},
   },
   unlockable_talents_types = {
     ["cunning/poisons"]={false, 0.2, "rogue_poisons"},
   },
   talents = {
      [ActorTalents.T_WEAPON_COMBAT] = 1,
      [ActorTalents.T_SHOOT] = 1,
      [ActorTalents.T_SKIRMISHER_SLING_SUPREMACY] = 1,
      [ActorTalents.T_SKIRMISHER_KNEECAPPER] = 1,
   },
   copy = {
      resolvers.equip{
         id=true,
         {type="armor", subtype="light", name="rough leather armour", autoreq=true,ego_chance=-1000},
         {type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
         {type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
      },
   },
   copy_add = {
      life_rating = 0,
   },
}

-- Add to warrior
getBirthDescriptor("class", "Warrior").descriptor_choices.subclass.Skirmisher = "allow"
