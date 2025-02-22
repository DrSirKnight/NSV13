/obj/structure/overmap/wizard/
	name = "wizard federation ship"
	desc = "A wizard federation owned space faring vessel, staring at it hurts your head."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	faction = "wizard"
	returns_rejected_cargo = FALSE // We won't send freight torpedoes to our enemies, we'll send actual torpedoes to our enemies





/obj/structure/overmap/wizard/ai //Generic wizard ship
	name = "Wizard ship"
	icon = 'nsv13/icons/overmap/new/wizard/castle_overmap.dmi'
	icon_state = "castle"
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	mass = MASS_SMALL
	bound_height = 96
	bound_width = 96
	sprite_size = 48
	damage_states = FALSE
	obj_integrity = 300
	max_integrity = 300
	area_type = /area/ruin/powered/nsv13/gunship
	var/bounty = 1000
	armor = list("overmap_light" = 30, "overmap_medium" = 20, "overmap_heavy" = 30)
	ai_flags = AI_FLAG_DESTROYER
	combat_dice_type = /datum/combat_dice/frigate
	possible_interior_maps = list()

/obj/structure/overmap/wizard/ai/lone // Lone wizard flying through space
	name = "Wizard"
	icon = 'nsv13/icons/overmap/new/wizard/wizard_fighter_overmap.dmi'
	icon_state = "fighter_wizard"
	damage_states = FALSE
	brakes = FALSE
	obj_integrity = 25
	max_integrity = 25
	sprite_size = 48
	faction = "wizard"
	mass = MASS_TINY
	bound_width = 48
	bound_height = 48
	missiles = 4
	torpedoes = 0

	bounty = 250
	armor = list("overmap_light" = 0, "overmap_medium" = 0, "overmap_heavy" = 99)
	ai_flags = AI_FLAG_SWARMER
	combat_dice_type = /datum/combat_dice/fighter
	possible_interior_maps = list()

/obj/structure/overmap/wizard/ai/lone/apply_weapons()
	weapon_types[FIRE_MODE_ANTI_AIR] = new/datum/ship_weapon/fireball(src)
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/magic_missile(src)
	//The bigger the ship, the tankier the shields....
	AddComponent(/datum/component/overmap_shields, 900, 900, 30)

/obj/structure/overmap/wizard/ai/lone/Initialize(mapload)
	. = ..()
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	name = randomname

/obj/structure/overmap/wizard/ai/castle // Appears solo, uses fighters (lone wizards) as reinforcements
	name = "Space Wizard Federation Castle"
	icon = 'nsv13/icons/overmap/new/wizard/castle_overmap.dmi'
	icon_state = "castle"
	sprite_size = 96
	bound_width = 96
	bound_height = 96
	mass = MASS_LARGE

	ai_behaviour = AI_AGGRESSIVE
	ai_flags = AI_FLAG_ELITE | AI_FLAG_BATTLESHIP

	damage_states = FALSE //Remove later

	obj_integrity = 5000
	max_integrity = 5000

	armor = list("overmap_light" = 95, "overmap_medium" = 80, "overmap_heavy" = 45)

	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter
	min_amount_of_fighters_deployed = 1
	max_amount_of_fighters_deployed = 1
	fighter_base_deploy_time = 30
	fighter_deploy_interval = 30

	ai_fighter_type = list(/obj/structure/overmap/wizard/ai/lone)

/obj/structure/overmap/wizard/ai/castle/apply_weapons()
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/touhou(src)
	//weapon_types[FIRE_MODE_MAC] = new/datum/ship_weapon/immovable_rod(src)
	weapon_types[FIRE_MODE_MAC] = new/datum/ship_weapon/star(src)
	//The bigger the ship, the tankier the shields....
	AddComponent(/datum/component/overmap_shields, mass*600, mass*600, mass*15)
