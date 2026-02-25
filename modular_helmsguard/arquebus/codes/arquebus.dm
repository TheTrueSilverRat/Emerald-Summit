/* STONEDELF: I have to define an entirely new filepath because
I don't really want the arquebus to inherit some of the procs and vars from Vanderlin's flintlocks.*/




/*------------\
|  RIFLE  |
\------------*/



/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket
	name = "arquebus musket"
	icon = 'modular_helmsguard/arquebus/icons/arquebus.dmi'
	desc = "A Helmsguard pattern of musket commonly used in pike and shot formations. It needs to be wielded with two hands to be properly used.\
	To use it, you must first fill it with blastpowder, then insert a lead ball and ram it with a ramrod before firing. A ramrod is usually stored on\
	the side of the musket itself. (Use middle click to insert/remove the ramrod.)"
	icon_state = "arquebus_ramrod"
	item_state = "musket"
	bigboy = TRUE
	recoil = 10
	randomspread = 2
	spread = 2
	force = 10
	experimental_inhand = TRUE
	experimental_onback = TRUE
	var/damage_mult = 3.5
	dropshrink = 0
	possible_item_intents = list(INTENT_GENERIC)
	gripped_intents = list(/datum/intent/shoot/musket, /datum/intent/shoot/musket/arc, POLEARM_BASH)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musk
	associated_skill = /datum/skill/combat/polearms
	slot_flags = ITEM_SLOT_BACK
	wlength = WLENGTH_LONG
	w_class = WEIGHT_CLASS_BULKY
	wdefense = GOOD_PARRY
	blade_dulling = DULLING_BASHCHOP
	max_blade_int = 100
	sellprice = 300
	var/bayonet_affixed = FALSE
	var/obj/item/ramrod/myrod = null
	var/obj/item/weapon/knife/dagger/bayonet/bayonet
	fire_sound = list('modular_helmsguard/arquebus/sound/arquefire.ogg',
				'modular_helmsguard/arquebus/sound/arquefire2.ogg',
				'modular_helmsguard/arquebus/sound/arquefire3.ogg',
				'modular_helmsguard/arquebus/sound/arquefire4.ogg',
				'modular_helmsguard/arquebus/sound/arquefire5.ogg')
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	cartridge_wording = "musket ball"
	can_parry = TRUE
	max_integrity = 30
	load_sound = 'sound/foley/nockarrow.ogg'
	var/click_delay = 0.5
//	var/cocked = FALSE
	var/ramrod_inserted = TRUE
	var/powdered = FALSE
	var/wound = FALSE
	var/rammed = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/Initialize()
	. = ..()
	myrod = new /obj/item/ramrod(src)

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/update_icon_state()
	. = ..()
	icon_state = "arquebus[ramrod_inserted ? "_ramrod" : ""][bayonet_affixed ? "_bayonet" : ""]"

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/attack_self(mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	interact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 2,"nx" = 7,"ny" = 3,"wx" = -2,"wy" = 1,"ex" = 1,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 30,"eturn" = -30,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -2,"nx" = -5,"ny" = -1,"wx" = -8,"wy" = 2,"ex" = 8,"ey" = 2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -45,"sturn" = 45,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)


/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/attack_self_secondary(mob/user, params)
	if(bayonet)
		if(do_after(user, 2 SECONDS, src))
			user.put_in_hands(bayonet)
			bayonet_affixed = FALSE
			possible_item_intents -= SPEAR_THRUST
			gripped_intents -= POLEARM_THRUST
			sharpness = IS_BLUNT
			bayonet.max_blade_int = max_blade_int
			bayonet.blade_int = blade_int
			max_blade_int = 0
			blade_int = 0
			armor_penetration = 0
			spread -= bayonet.spread
			force -= bayonet.force
			bayonet = null
			to_chat(user, span_info("I remove the bayonet from \the [src]."))
			playsound(src.loc, 'sound/items/sharpen_long2.ogg', 100, FALSE, -1)
		update_appearance(UPDATE_ICON_STATE)
	..()


/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/attackby(obj/item/I, mob/user, params)
	var/ramtime = 5.5
	ramtime = ramtime - (user.get_skill_level(/datum/skill/combat/firearms) / 2)
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing/caseless/bullet))
		if(!powdered)
			to_chat(user, "<span class='warning'>The [src] is not powdered!</span>")
			return
		else
			..()
	// Check if the item used is a ramrod
	if(istype(I, /obj/item/ramrod))
		if(user.get_skill_level(/datum/skill/combat/firearms) <= 0)
			to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
			return
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>I need to hold \the [src] to ram it!</span>")
			return
		if(chambered)
			if(!powdered)
				to_chat(user, "<span class='warning'>I need to powder the [src] before I can ram it.</span>")
				return
			if(!rammed)
				playsound(src.loc, 'modular_helmsguard/arquebus/sound/ramrod.ogg', 100, FALSE)
				if(do_after(user, ramtime SECONDS, src))
					to_chat(user, "<span class='info'>I ram \the [src].</span>")
					rammed = TRUE
	else
		// Check if the item used is a reagent container
		if(istype(I, /obj/item/reagent_containers))
			if(user.get_skill_level(/datum/skill/combat/firearms) <= 0)
				to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
				return
			if(powdered)
				to_chat(user, "<span class='warning'>\The [src] is already powdered!</span>")
				return
			// Check if the reagent container contains at least 5u of blastpowder
			if(I.reagents.get_reagent_amount(/datum/reagent/blastpowder) >= 5)
				to_chat(user, "<span class='info'>I am filling \the [src] with blastpowder...</span>")
				playsound(src.loc, 'modular_helmsguard/arquebus/sound/pour_powder.ogg', 100, FALSE)
				if(do_after(user, ramtime SECONDS, src))
					to_chat(user, "<span class='info'>The [src] have been powdered.</span>")
					// Subtract 5u of blastpowder from the reagent container
					I.reagents.remove_reagent(/datum/reagent/blastpowder, 5)
					// Set the 'powdered' flag on the pistol
					powdered = TRUE
				return 1
			else
				to_chat(user, "<span class='warning'>Not enough blastpowder in [I] to powder the [src].</span>")
				return 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.get_active_held_item(), /obj/item/weapon/knife/dagger/bayonet))
			if(!H.is_holding(src))
				to_chat(user, span_warning("I need to hold \the [src] to affix a bayonet to it!"))
				return
			if(do_after(user, ramtime SECONDS, src))
				var/obj/item/weapon/knife/dagger/bayonet/attached_bayonet = H.get_active_held_item()
				attached_bayonet.forceMove(src)
				bayonet = attached_bayonet
				bayonet_affixed = TRUE
				possible_item_intents += SPEAR_THRUST
				gripped_intents += POLEARM_THRUST
				sharpness = IS_SHARP
				max_blade_int = attached_bayonet.max_blade_int
				blade_int = attached_bayonet.blade_int
				armor_penetration = 5
				spread += bayonet.spread
				force += bayonet.force
				to_chat(user, span_info("I affix the bayonet to \the [src]."))
				playsound(src.loc, 'modular_helmsguard/sheath_sounds/put_back_dagger.ogg', 100, FALSE, -1)
			update_appearance(UPDATE_ICON_STATE)
	return ..()


/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	user.adjust_experience(/datum/skill/combat/firearms, (user.STAINT*5))
 // muh realism or something
	new /obj/effect/particle_effect/sparks/muzzle(get_ranged_target_turf(user, user.dir, 1))
	spawn (5)
		new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
	spawn (10)
		new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 2))
	spawn (16)
		new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
	for(var/mob/M in range(5, user))
		if(!M.stat)
			shake_camera(M, 3, 1)
	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z, src.z))
			continue

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/shoot_with_empty_chamber(mob/living/user)
	playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketcock.ogg', 100, FALSE)
	to_chat(user, "<span class='warning'>*click!*</span>")
	wound = FALSE
	update_appearance(UPDATE_ICON_STATE)

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/MiddleClick(mob/user, params)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(myrod)
			H.put_in_hands(myrod)
			myrod = null
			ramrod_inserted = FALSE
			to_chat(user, "<span class='info'>I remove the ramrod from \the [src].</span>")
			playsound(src.loc, 'sound/items/sharpen_short1.ogg', 100, FALSE, -1)
		else if(istype(H.get_active_held_item(), /obj/item/ramrod))
			var/obj/item/ramrod/rrod = H.get_active_held_item()
			rrod.forceMove(src)
			myrod = rrod
			ramrod_inserted = TRUE
			to_chat(user, "<span class='info'>I put \the [rrod] into \the [src].</span>")
			playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketload.ogg', 100, FALSE, -1)
		update_appearance(UPDATE_ICON_STATE)

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!rammed)
		to_chat(user, "<span class='info'>The [src] is not rammed yet!</span>")
		return
	if(!powdered)
		to_chat(user, "<span class='info'>The [src] is not powdered yet!</span>")
		return
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/BB = CB.BB
		if(user.client)
			if(user.client.chargedprog >= 100)
				BB.accuracy += 15 //better accuracy for fully aiming
		if(user.STAPER > 8)
			BB.accuracy += (user.STAPER - 8) * 4 //each point of perception above 8 increases standard accuracy by 4.
			BB.bonus_accuracy += (user.STAPER - 8) //Also, increases bonus accuracy by 1, which cannot fall off due to distance.
		BB.damage = BB.damage * damage_mult // 80 * 1.5 = 130 of damage.
		BB.bonus_accuracy += (user.get_skill_level(/datum/skill/combat/firearms) * 3) //+3 accuracy per level in firearms
	playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketcock.ogg', 100, FALSE)
	rammed = FALSE
	powdered = FALSE
	wound = FALSE
	sleep(click_delay)
	update_appearance(UPDATE_ICON_STATE)
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_musket/get_dismemberment_chance(obj/item/bodypart/affecting, mob/user) //this is probably shitcode but I'm tired and I'm not repathing the guns to be /weapons, it's better than the musket being a delimbinator 9000
	if(!get_sharpness() || !affecting.can_dismember(src))
		return 0

	var/total_dam = affecting.get_damage()
	var/nuforce = get_complex_damage(src, user)
	var/pristine_blade = TRUE
	if(max_blade_int && dismember_blade_int)
		var/blade_int_modifier = (blade_int / dismember_blade_int)
		//blade is about as sharp as a brick it won't dismember shit
		if(blade_int_modifier <= 0.15)
			return 0
		nuforce *= blade_int_modifier
		pristine_blade = (blade_int >= (dismember_blade_int * 0.95))

	if(user)
		if(istype(user.rmb_intent, /datum/rmb_intent/weak))
			nuforce = 0
		else if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			nuforce *= 1.1

		if(user.used_intent.blade_class == BCLASS_CHOP) //chopping attacks always attempt dismembering
			nuforce *= 1.1
		else if(user.used_intent.blade_class == BCLASS_CUT)
			if(!pristine_blade && (total_dam < affecting.max_damage * 0.8))
				return 0
		else
			return 0

	if(nuforce < 23) //End force needs to be at least this high, after accounting for strong intent and chop. An iron messer should be able to do it, but not a dagger.
		return 0

	var/probability = (nuforce * (total_dam / affecting.max_damage) - 5) //More weight given to total damage accumulated on the limb
	if(affecting.body_zone == BODY_ZONE_HEAD) //Decapitations are harder to pull off in general
		probability *= 0.5
	var/hard_dismember = HAS_TRAIT(affecting, TRAIT_HARDDISMEMBER)
	var/easy_dismember = affecting.rotted || affecting.skeletonized || HAS_TRAIT(affecting, TRAIT_EASYDISMEMBER)
	if(affecting.owner)
		if(!hard_dismember)
			hard_dismember = HAS_TRAIT(affecting.owner, TRAIT_HARDDISMEMBER)
		if(!easy_dismember)
			easy_dismember = HAS_TRAIT(affecting.owner, TRAIT_EASYDISMEMBER)
	if(hard_dismember)
		return min(probability, 5)
	else if(easy_dismember)
		return probability * 1.5
	return probability


/// MUZZLE

/obj/effect/particle_effect/sparks/muzzle
	name = "sparks"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "sparks"
	anchored = TRUE
	light_system = MOVABLE_LIGHT
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE
	pixel_x = -16
	pixel_y = -16
	plane = ABOVE_LIGHTING_PLANE



/*------------\
|  PISTOL  |
\------------*/
/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol
	name = "arquebus pistol"
	desc = "A Helmsguard pattern of arquebus pistol commonly used as a sidearm by officers and cavalrymen."
	icon = 'icons/roguetown/weapons/32/guns.dmi'
	icon_state = "pistol"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	recoil = 10
	randomspread = 2
	spread = 2
	force = 10
	experimental_inhand = FALSE
	experimental_onback = FALSE
	var/damage_mult = 2.5
	associated_skill = /datum/skill/combat/firearms
	possible_item_intents = list(/datum/intent/shoot/musket, /datum/intent/shoot/musket/arc, /datum/intent/mace/strike/wood, INTENT_GENERIC)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musk
	associated_skill = /datum/skill/combat/firearms
	wlength = WLENGTH_LONG
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	sellprice = 150
	var/obj/item/ramrod/myrod = null
	fire_sound = list('modular_helmsguard/arquebus/sound/arquefire.ogg',
				'modular_helmsguard/arquebus/sound/arquefire2.ogg',
				'modular_helmsguard/arquebus/sound/arquefire3.ogg',
				'modular_helmsguard/arquebus/sound/arquefire4.ogg',
				'modular_helmsguard/arquebus/sound/arquefire5.ogg')
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	cartridge_wording = "musket ball"
	max_integrity = 30
	load_sound = 'sound/foley/nockarrow.ogg'
	var/click_delay = 0.5
//	var/cocked = FALSE
	var/ramrod_inserted = TRUE
	var/powdered = FALSE
	var/wound = FALSE
	var/rammed = FALSE
	var/can_spin = TRUE
	var/last_spunned
	var/spin_cooldown = 3 SECONDS

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol/Initialize()
	. = ..()
	myrod = new /obj/item/ramrod(src)

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol/attackby(obj/item/I, mob/user, params)
	var/ramtime = 5.5
	ramtime = ramtime - (user.get_skill_level(/datum/skill/combat/firearms) / 2)
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing/caseless/bullet))
		if(!powdered)
			to_chat(user, "<span class='warning'>The [src] is not powdered!</span>")
			return
		else
			..()
	// Check if the item used is a ramrod
	if(istype(I, /obj/item/ramrod))
		if(user.get_skill_level(/datum/skill/combat/firearms) <= 0)
			to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
			return
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>I need to hold \the [src] to ram it!</span>")
			return
		if(chambered)
			if(!powdered)
				to_chat(user, "<span class='warning'>I need to powder the [src] before I can ram it.</span>")
				return
			if(!rammed)
				playsound(src.loc, 'modular_helmsguard/arquebus/sound/ramrod.ogg', 100, FALSE)
				if(do_after(user, ramtime SECONDS, src))
					to_chat(user, "<span class='info'>I ram \the [src].</span>")
					rammed = TRUE
	else
		// Check if the item used is a reagent container
		if(istype(I, /obj/item/reagent_containers))
			if(user.get_skill_level(/datum/skill/combat/firearms) <= 0)
				to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
				return
			if(powdered)
				to_chat(user, "<span class='warning'>\The [src] is already powdered!</span>")
				return
			// Check if the reagent container contains at least 5u of blastpowder
			if(I.reagents.get_reagent_amount(/datum/reagent/blastpowder) >= 5)
				to_chat(user, "<span class='info'>I am filling \the [src] with blastpowder...</span>")
				playsound(src.loc, 'modular_helmsguard/arquebus/sound/pour_powder.ogg', 100, FALSE)
				if(do_after(user, ramtime SECONDS, src))
					to_chat(user, "<span class='info'>The [src] have been powdered.</span>")
					// Subtract 5u of blastpowder from the reagent container
					I.reagents.remove_reagent(/datum/reagent/blastpowder, 5)
					// Set the 'powdered' flag on the pistol
					powdered = TRUE
				return 1
			else
				to_chat(user, "<span class='warning'>Not enough blastpowder in [I] to powder the [src].</span>")
				return 0

	return ..()



/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	user.adjust_experience(/datum/skill/combat/firearms, (user.STAINT*5))
 // muh realism or something
	new /obj/effect/particle_effect/sparks/muzzle(get_ranged_target_turf(user, user.dir, 1))
	spawn (5)
		new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
	spawn (10)
		new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 2))
	spawn (16)
		new/obj/effect/particle_effect/smoke/arquebus(get_ranged_target_turf(user, user.dir, 1))
	for(var/mob/M in range(5, user))
		if(!M.stat)
			shake_camera(M, 3, 1)
	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z, src.z))
			continue


/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol/shoot_with_empty_chamber(mob/living/user)
	playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketcock.ogg', 100, FALSE)
	to_chat(user, "<span class='warning'>*click!*</span>")
	wound = FALSE
	update_appearance(UPDATE_ICON_STATE)

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol/MiddleClick(mob/user, params)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(myrod)
			H.put_in_hands(myrod)
			myrod = null
			ramrod_inserted = FALSE
			to_chat(user, "<span class='info'>I remove the ramrod from \the [src].</span>")
			playsound(src.loc, 'sound/items/sharpen_short1.ogg', 100, FALSE, -1)
		else if(istype(H.get_active_held_item(), /obj/item/ramrod))
			var/obj/item/ramrod/rrod = H.get_active_held_item()
			rrod.forceMove(src)
			myrod = rrod
			ramrod_inserted = TRUE
			to_chat(user, "<span class='info'>I put \the [rrod] into \the [src].</span>")
			playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketload.ogg', 100, FALSE, -1)
		update_appearance(UPDATE_ICON_STATE)

/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!rammed)
		to_chat(user, "<span class='info'>The [src] is not rammed yet!</span>")
		return
	if(!powdered)
		to_chat(user, "<span class='info'>The [src] is not powdered yet!</span>")
		return
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/BB = CB.BB
		if(user.client)
			if(user.client.chargedprog >= 100)
				BB.accuracy += 15 //better accuracy for fully aiming
		if(user.STAPER > 8)
			BB.accuracy += (user.STAPER - 8) * 4 //each point of perception above 8 increases standard accuracy by 4.
			BB.bonus_accuracy += (user.STAPER - 8) //Also, increases bonus accuracy by 1, which cannot fall off due to distance.
		BB.damage = BB.damage * damage_mult // 80 * 1.5 = 130 of damage.
		BB.bonus_accuracy += (user.get_skill_level(/datum/skill/combat/firearms) * 3) //+3 accuracy per level in firearms
	playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketcock.ogg', 100, FALSE)
	rammed = FALSE
	powdered = FALSE
	wound = FALSE
	sleep(click_delay)
	update_appearance(UPDATE_ICON_STATE)
	..()

//spinny pistoli
/obj/item/gun/ballistic/revolver/grenadelauncher/arquebus_pistol/attack_self(mob/living/user)
	var/string = "smoothly"
	var/list/strings_noob = list("unsurely", "nervously", "anxiously", "timidly", "shakily", "clumsily", "fumblingly", "awkwardly")
	var/list/strings_moderate = list("smoothly", "confidently", "determinately", "calmly", "skillfully", "decisively")
	var/list/strings_pro = list("masterfully", "expertly", "flawlessly", "elegantly", "artfully", "impeccably")
	var/firearm_skill = (user?.mind ? user.get_skill_level(/datum/skill/combat/firearms) : 1)
	var/noob_spin_sound = 'sound/combat/weaponr1.ogg'
	var/pro_spin_sound = 'modular_helmsguard/arquebus/sound/gunspin.ogg'
	var/spin_sound
	if(firearm_skill <= 2)
		string = pick(strings_noob)
		spin_sound = noob_spin_sound
	if((firearm_skill > 2) && (firearm_skill <= 4))
		string = pick(strings_moderate)
		spin_sound = pro_spin_sound
	if((firearm_skill > 4) && (firearm_skill <= 6))
		string = pick(strings_pro)
		spin_sound = pro_spin_sound
	if(world.time > last_spunned + spin_cooldown)
		can_spin = TRUE
	if(can_spin)
		user.visible_message("<span class='emote'>[user] spins the [src] around their fingers [string]!</span>")
		playsound(src, spin_sound, 100, FALSE, ignore_walls = FALSE)
		last_spunned = world.time
		if(firearm_skill <= 2)
			if(prob(35))
				shoot_live_shot(message = 0)
				user.visible_message("<span class='danger'>[user] accidentally discharged the [src]!</span>")
		if(firearm_skill <= 3)
			if(prob(50))
				user.visible_message("<span class='danger'>[user] accidentally dropped the [src]!</span>")
				user.dropItemToGround(src)
		can_spin = FALSE
