
/datum/species/ethereal
	name = "\improper Ethereal"
	id = "ethereal"
	attack_verb = "burn"
	attack_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ethereal
	mutantstomach = /obj/item/organ/stomach/battery/ethereal
	mutanttongue = /obj/item/organ/tongue/ethereal
	mutant_heart = /obj/item/organ/heart/ethereal //NSV13 - Crystalized Ethereals
	exotic_blood = /datum/reagent/consumable/liquidelectricity //Liquid Electricity. fuck you think of something better gamer
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //They're weak to punches
	attack_type = BURN //burn bish
	damage_overlay_type = "" //We are too cool for regular damage overlays
	species_traits = list(DYNCOLORS, AGENDER, HAIR)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/ethereal
	inherent_traits = list(TRAIT_POWERHUNGRY)
	sexes = FALSE //no fetish content allowed
	hair_color = "fixedmutcolor"
	hair_alpha = 140
	swimming_component = /datum/component/swimming/ethereal

	species_chest = /obj/item/bodypart/chest/ethereal
	species_head = /obj/item/bodypart/head/ethereal
	species_l_arm = /obj/item/bodypart/l_arm/ethereal
	species_r_arm = /obj/item/bodypart/r_arm/ethereal
	species_l_leg = /obj/item/bodypart/l_leg/ethereal
	species_r_leg = /obj/item/bodypart/r_leg/ethereal

	var/current_color
	var/EMPeffect = FALSE
	var/emageffect = FALSE
	var/r1
	var/g1
	var/b1
	var/static/r2 = 237
	var/static/g2 = 164
	var/static/b2 = 149
	//this is shit but how do i fix it? no clue.
	var/drain_time = 0 //used to keep ethereals from spam draining power sources
	inert_mutation = OVERLOAD
	var/obj/effect/dummy/lighting_obj/ethereal_light


/datum/species/ethereal/Destroy(force)
	if(ethereal_light)
		QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	ethereal_light = C.mob_light()

	. = ..()

	if(!ishuman(C))
		return
	var/mob/living/carbon/human/ethereal = C
	default_color = "#[ethereal.dna.features["ethcolor"]]"
	r1 = GETREDPART(default_color)
	g1 = GETGREENPART(default_color)
	b1 = GETBLUEPART(default_color)
	RegisterSignal(ethereal, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))

	spec_updatehealth(ethereal)

	//NSV13 - Ethereal Crystalization
	var/obj/item/organ/heart/ethereal/ethereal_heart = C.getorganslot(ORGAN_SLOT_HEART)
	ethereal_heart.ethereal_color = default_color

	//The following code is literally only to make admin-spawned ethereals not be black.
	C.dna.features["mcolor"] = C.dna.features["ethcolor"] //Ethcolor and Mut color are both dogshit and will be replaced
	for(var/obj/item/bodypart/BP as() in C.bodyparts)
		if(BP.limb_id == SPECIES_ETHEREAL)
			BP.update_limb(is_creating = TRUE)

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	UnregisterSignal(C, COMSIG_ATOM_EMAG_ACT)
	UnregisterSignal(C, COMSIG_ATOM_EMP_ACT)
	QDEL_NULL(ethereal_light)
	return ..()


/datum/species/ethereal/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.ethereal_names)] [random_capital_letter()]"
	if(prob(65))
		. += "[random_capital_letter()]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)


/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/H)
	. = ..()
	if(H.stat != DEAD && !EMPeffect)
		var/healthpercent = max(H.health, 0) / 100
		if(!emageffect)
			current_color = rgb(r2 + ((r1-r2)*healthpercent), g2 + ((g1-g2)*healthpercent), b2 + ((b1-b2)*healthpercent))
		ethereal_light.set_light_range_power_color(2 + (3 * healthpercent), 2 + (2 * healthpercent), current_color) //NSV13- Makes the base brightness a radius of two, and reduces the rate of brightness decline from damage.
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = copytext_char(current_color, 2)
	else
		ethereal_light.set_light_on(FALSE)
		fixed_mut_color = rgb(128,128,128)
	H.update_body()
	H.update_hair() // This should fix the ethereal hair not changing with body, no clue as to why hair is not in update_body but okay - NSV13

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/H, severity)
	SIGNAL_HANDLER

	EMPeffect = TRUE
	spec_updatehealth(H)
	to_chat(H, "<span class='notice'>You feel the light of your body leave you.</span>")
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds

/datum/species/ethereal/proc/on_emag_act(mob/living/carbon/human/H, mob/user)
	SIGNAL_HANDLER

	if(emageffect)
		return
	emageffect = TRUE
	if(user)
		to_chat(user, "<span class='notice'>You tap [H] on the back with your card.</span>")
	H.visible_message("<span class='danger'>[H] starts flickering in an array of colors!</span>")
	handle_emag(H)
	addtimer(CALLBACK(src, PROC_REF(stop_emag), H), 30 SECONDS) //Disco mode for 30 seconds! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.

/datum/species/ethereal/proc/stop_emp(mob/living/carbon/human/H)
	EMPeffect = FALSE
	spec_updatehealth(H)
	to_chat(H, "<span class='notice'>You feel more energized as your shine comes back.</span>")

/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/H)
	if(!emageffect)
		return
	current_color = "#[GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]]"	//Picks a random colour from the Ethereal colour list
	spec_updatehealth(H)
	addtimer(CALLBACK(src, PROC_REF(handle_emag), H), 5) //Call ourselves every 0.5 seconds to change color

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/H)
	emageffect = FALSE
	spec_updatehealth(H)
	H.visible_message("<span class='danger'>[H] stops flickering and goes back to their normal state!</span>")

//NSV13 - Ethereal Stuff - Start
#define NUTRITION_LEVEL_VERY_STARVING 50
#define NUTRITION_LEVEL_DYING 1

/datum/species/ethereal/handle_charge(mob/living/carbon/human/H)
	brutemod = 1.25
	if(HAS_TRAIT(H, TRAIT_NOHUNGER))
		return
	switch(H.nutrition)
		// This is formatted in the following style: from low to high
		// IE: NUTRITION_LEVEL_STARVING (150) to NUTRITION_LEVEL_FED (350)
		if(NUTRITION_LEVEL_FED to INFINITY)
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealfull)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_FED)
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealcharge, 1)
			brutemod = 1.5
		if(NUTRITION_LEVEL_VERY_STARVING to NUTRITION_LEVEL_STARVING)
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealcharge, 2)
			if(H.health > 10.5)
				apply_damage(0.65, TOX, null, null, H)
			brutemod = 1.75
		if(NUTRITION_LEVEL_DYING to NUTRITION_LEVEL_VERY_STARVING)
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealcharge, 3)
			if(H.health > 10.5)
				apply_damage(0.65, TOX, null, null, H)
		else
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealcharge, 4)
			if(H.health > 10.5)
				apply_damage(1, TOX, null, null, H)
			brutemod = 2

#undef NUTRITION_LEVEL_VERY_STARVING
#undef NUTRITION_LEVEL_DYING
//NSV13 - Ethereal Stuff - Stop
