
/obj/item/gun/ballistic/revolver/grenadelauncher/pistol
	name = "puffer"
	desc = "The current zenith of Dwarven and Humen cooperation on the Eastern continent. It uses alchemical blastpowder to propel metal balls for devastating effect."
	icon = 'icons/roguetown/weapons/guns.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "puffer_uncocked_ramrod"
	item_state = "puffer"
	bigboy = FALSE
	recoil = 8
	randomspread = 2
	spread = 3
	force = 15
	experimental_inhand = FALSE
	experimental_onback = FALSE
	var/click_delay = 0.5
	var/damage_mult = 1.625
	var/obj/item/ramrod/rod
	cartridge_wording = "ball"
	var/rammed = FALSE
	load_sound = 'sound/foley/nockarrow.ogg'
	fire_sound = null // handled in shoot_live_shot()
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	fire_sound = list('modular_helmsguard/arquebus/sound/arquefire.ogg',
				'modular_helmsguard/arquebus/sound/arquefire2.ogg',
				'modular_helmsguard/arquebus/sound/arquefire3.ogg',
				'modular_helmsguard/arquebus/sound/arquefire4.ogg',
				'modular_helmsguard/arquebus/sound/arquefire5.ogg')
	dropshrink = 0.7
	associated_skill = /datum/skill/combat/firearms
	possible_item_intents = list(/datum/intent/shoot/musket, /datum/intent/shoot/musket/arc, /datum/intent/sword/strike)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musk
	gripped_intents = null
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	sellprice = 200 // This kind of equipment is very hard to come by in Rockhill.
	grid_height = 32
	grid_width = 96
	var/cocked = FALSE
	var/ramrod_inserted = TRUE
	var/powdered = FALSE
	var/can_spin = TRUE
	var/last_spunned
	var/spin_cooldown = 3 SECONDS

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/update_icon_state()
	. = ..()
	icon_state = "puffer_[cocked ? "cocked" : "uncocked"][ramrod_inserted ? "_ramrod" : ""]"

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	user.adjust_experience(/datum/skill/combat/firearms, (user.STAINT*5))
	new /obj/effect/particle_effect/sparks/muzzle(get_ranged_target_turf(user, user.dir, 1))
	spawn (5)
		new/obj/effect/particle_effect/smoke(get_ranged_target_turf(user, user.dir, 1))
	spawn (10)
		new/obj/effect/particle_effect/smoke(get_ranged_target_turf(user, user.dir, 2))
	spawn (16)
		new/obj/effect/particle_effect/smoke(get_ranged_target_turf(user, user.dir, 1))
	for(var/mob/M in range(5, user))
		if(!M.stat)
			shake_camera(M, 3, 1)
	for(var/mob/M in GLOB.player_list)
		if(!is_in_zweb(M.z, src.z))
			continue

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/shoot_with_empty_chamber(mob/living/user)
	playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketcock.ogg', 100, FALSE)
	to_chat(user, "<span class='warning'>*click!*</span>")
	cocked = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/attack_right(mob/user, params)
	. = ..()
	if(!user.is_holding(src))
		to_chat(user, "<span class='warning'>I need to hold \the [src] to cock it!</span>")
		return
	if(cocked)
		cocked = FALSE
		to_chat(user, "<span class='warning'>I carefully de-cock \the [src].</span>")
		playsound(src.loc, 'sound/combat/Ranged/muskclick.ogg', 100, FALSE)
	else
		playsound(src.loc, 'sound/combat/Ranged/muskclick.ogg', 100, FALSE)
		to_chat(user, "<span class='info'>I cock \the [src].</span>")
		cocked = TRUE
	update_icon(UPDATE_ICON_STATE)

/*
/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/attack_self_secondary(mob/user, params)
	. = ..()
	if(!wheellock)
		return
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(user.get_skill_level(/datum/skill/combat/firearms) <= 0)
		to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(wound)
		to_chat(user, "<span class='info'>\The [src]'s mechanism is already wound!</span>")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/windtime = 3.5
	windtime = windtime - (user.get_skill_level(/datum/skill/combat/firearms) / 2)
	if(do_after(user, windtime SECONDS, src) && !wound)
		to_chat(user, "<span class='info'>I wind \the [src]'s mechanism.</span>")
		playsound(src.loc, 'sound/foley/winding.ogg', 100, FALSE)
		wound = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
*/
/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/MiddleClick(mob/user, params)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(rod)
			H.put_in_hands(rod)
			rod = null
			ramrod_inserted = FALSE
			to_chat(user, "<span class='info'>I remove the ramrod from \the [src].</span>")
			playsound(src.loc, 'sound/items/sharpen_short1.ogg', 100, FALSE, -1)
		else if(istype(H.get_active_held_item(), /obj/item/ramrod))
			var/obj/item/ramrod/rrod = H.get_active_held_item()
			rrod.forceMove(src)
			rod = rrod
			ramrod_inserted = TRUE
			to_chat(user, "<span class='info'>I put \the [rrod] into \the [src].</span>")
			playsound(src.loc, 'modular_helmsguard/arquebus/sound/musketload.ogg', 100, FALSE, -1)
		update_icon(UPDATE_ICON_STATE)

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!cocked)
		return
	if(!rammed)
		return
	if(!powdered)
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
	playsound(src.loc, 'sound/combat/Ranged/muskclick.ogg', 100, FALSE)
	cocked = FALSE
	rammed = FALSE
	powdered = FALSE
	sleep(click_delay)
	update_icon(UPDATE_ICON_STATE)
	..()

/obj/item/ramrod
	name = "ram rod"
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "ramrod"

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/Initialize()
	. = ..()
	var/obj/item/ramrod/rrod = new(src)
	rod = rrod

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/attackby(obj/item/I, mob/user, params)
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


/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/attack_self(mob/living/user)
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





/obj/item/ammo_box/magazine/internal/shot/musk
	ammo_type = /obj/item/ammo_casing/caseless/bullet
	caliber = "musketball"
	max_ammo = 1
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/shot/musk/loaded
	ammo_type = /obj/item/ammo_casing/caseless/bullet
	caliber = "musketball"
	max_ammo = 1
	start_empty = FALSE

/obj/item/reagent_containers/glass/bottle/aflask
	name = "alchemical flask"
	desc = "A small metal flask used for the secure storing of alchemical powders."
	icon = 'icons/roguetown/items/cooking.dmi'
	list_reagents = list(/datum/reagent/blastpowder = 30)
	icon_state = "aflask"

/obj/item/reagent_containers/glass/bottle/aflask/Initialize()
	. = ..()
	icon_state = "aflask"

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/conjured
	sellprice = 0 //Yeah, Let's not sell this.
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musk/loaded

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/conjured/Initialize()
	. = ..()
	cocked = TRUE
	rammed = TRUE
	powdered = TRUE

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/conjured/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()

	QDEL_IN(src, rand(2 SECONDS, 5 SECONDS)) //Apparently, a puffer being broken can still be shot, because that make sense. so we're qdel'ing it right after.
	visible_message(span_warning("The puffer begins to crumble, the enchantment falls!"))

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket
	name = "musket"
	icon = 'icons/roguetown/weapons/64/guns.dmi'
	icon_state = "musket_uncocked_ramrod"
	item_state = "musket"
	bigboy = TRUE
	recoil = 10
	randomspread = 2
	spread = 2
	force = 20
	experimental_inhand = TRUE
	experimental_onback = TRUE
	damage_mult = 3.5
	dropshrink = 0.7
	possible_item_intents = list(INTENT_GENERIC)
	gripped_intents = list(/datum/intent/shoot/musket, /datum/intent/shoot/musket/arc, /datum/intent/spear/bash)
	associated_skill = /datum/skill/combat/polearms
	slot_flags = ITEM_SLOT_BACK
	wlength = WLENGTH_LONG
	w_class = WEIGHT_CLASS_BULKY
	wdefense = 4
	blade_dulling = DULLING_BASHCHOP
	max_blade_int = 100
	sellprice = 400
	var/bayonet_affixed = FALSE
	rod = /obj/item/ramrod/musket
	var/obj/item/weapon/knife/dagger/bayonet/bayonet
	can_parry = TRUE
	max_integrity = 30

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/Initialize()
	. = ..()
	var/obj/item/ramrod/musket/rrod = new(src)
	rod = rrod

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/attack_self(mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user))
		return TRUE
	interact(user)

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/update_icon_state()
	. = ..()
	icon_state = "musket_[cocked ? "cocked" : "uncocked"][ramrod_inserted ? "_ramrod" : ""][bayonet_affixed ? "_bayonet" : ""]"

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen") return list(
				"shrink" = 0.5,
				"sx" = -2,
				"sy" = 0,
				"nx" = 11,
				"ny" = 0,
				"wx" = -4,
				"wy" = -4,
				"ex" = 2,
				"ey" = 0,
				"nturn" = 0,
				"sturn" = 0,
				"wturn" = 0,
				"eturn" = 0,
				"nflip" = 0,
				"sflip" = 0,
				"wflip" = 5,
				"eflip" = 0,
				"northabove" = 0,
				"southabove" = 1,
				"eastabove" = 1,
				"westabove" = 0
				)
			if("wielded") return list(
				"shrink" = 0.5,
				"sx" = 0,
				"sy" = -3,
				"nx" = 0,
				"ny" = -2,
				"wx" = -4,
				"wy" = -3,
				"ex" = 4,
				"ey" = -3,
				"nturn" = -45,
				"sturn" = 45,
				"wturn" = 45,
				"eturn" = 45,
				"nflip" = 4,
				"sflip" = 0,
				"wflip" = 5,
				"eflip" = 0,
				"northabove" = 0,
				"southabove" = 1,
				"eastabove" = 1,
				"westabove" = 0
				)
			if("onback")
				return list(
					"shrink" = 0.5,
					"sx" = 1,
					"sy" = -1,
					"nx" = 1,
					"ny" = -1,
					"wx" = -1,
					"wy" = 0,
					"ex" = 1,
					"ey" = -1,
					"nturn" = 0,
					"sturn" = 0,
					"wturn" = 0,
					"eturn" = 0,
					"nflip" = 5,
					"sflip" = 5,
					"wflip" = 5,
					"eflip" = 5,
					"northabove" = 1,
					"southabove" = 0,
					"eastabove" = 0,
					"westabove" = 0)

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/AltRightClick(mob/user)
	. = ..()
	if(bayonet)
		if(do_after(user, 2 SECONDS, src))
			user.put_in_hands(bayonet)
			bayonet_affixed = FALSE
			possible_item_intents -= SPEAR_THRUST_1H
			gripped_intents -= SPEAR_THRUST
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
			playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)
		update_icon(UPDATE_ICON_STATE)
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/attackby(obj/item/I, mob/user, params)
	var/ramtime = 5.5
	ramtime = ramtime - (user.get_skill_level(/datum/skill/combat/firearms) / 2)
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
				possible_item_intents += SPEAR_THRUST_1H
				gripped_intents += SPEAR_THRUST_1H
				sharpness = IS_SHARP
				max_blade_int = attached_bayonet.max_blade_int
				blade_int = attached_bayonet.blade_int
				armor_penetration = 5
				spread += bayonet.spread
				force += bayonet.force
				to_chat(user, span_info("I affix the bayonet to \the [src]."))
				playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)
			update_icon(UPDATE_ICON_STATE)
	..()

/obj/item/weapon/knife/dagger/bayonet
	name = "bayonet"
	force = 10
	max_blade_int = 100
	var/spread = 2

/obj/item/ramrod/musket
	name = "musket ram rod"
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "ramrod_musket"

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/musket/get_dismemberment_chance(obj/item/bodypart/affecting, mob/user) //this is probably shitcode but I'm tired and I'm not repathing the guns to be /weapons, it's better than the musket being a delimbinator 9000
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

/// INTENTS

/datum/intent/shoot/musket
	chargedrain = 0 //no drain to aim a gun
	charging_slowdown = 4
	warnoffset = 20
	chargetime = 10

/datum/intent/shoot/musket/prewarning()
	if(mastermob && masteritem)
		mastermob.visible_message("<span class='warning'>[mastermob] aims the [masteritem]!</span>")
		playsound(mastermob, pick('modular_helmsguard/arquebus/sound/musketcock.ogg'), 100, FALSE)

/datum/intent/shoot/musket/arc
	name = "arc"
	icon_state = "inarc"
	chargedrain = 1
	charging_slowdown = 3
	warnoffset = 20


/datum/intent/shoot/musket/arc/prewarning()
	if(mastermob && masteritem)
		mastermob.visible_message("<span class='warning'>[mastermob] aims the [masteritem]!</span>")
		playsound(mastermob, pick('modular_helmsguard/arquebus/sound/musketcock.ogg'), 100, FALSE)

/datum/intent/shoot/musket/arc/arc_check()
	return TRUE

/datum/intent/shoot/musket/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		//skill block
		newtime = newtime + 18
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/firearms) * 4)
		//per block
		newtime = newtime + 20
		newtime = newtime - (mastermob.STAPER * 2)
		if(newtime > 0)
			return newtime
		else
			return 0.1
	return chargetime

/datum/intent/shoot/musket/pistol/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		//skill block
		newtime = newtime + 18
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/firearms) * 4)
		//per block
		newtime = newtime + 20
		newtime = newtime - (mastermob.STAPER * 2)
		if(newtime > 0)
			return newtime
		else
			return 1
	return chargetime

//Items

/obj/item/quiver/bullet
	name = "bullet pouch"
	icon_state = "slingpouch"
	item_state = "slingpouch"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	max_storage = 10


/obj/item/quiver/bullet/eatarrow(obj/A)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/bullet))
		if(arrows.len < max_storage)
			A.forceMove(src)
			arrows += A
			update_icon()
			return TRUE
		else
			return FALSE

/obj/item/quiver/bullet/attack_turf(turf/T, mob/living/user)
	if(arrows.len >= max_storage)
		to_chat(user, span_warning("My [src.name] is full!"))
		return
	to_chat(user, span_notice("I begin to gather the ammunition..."))
	for(var/obj/item/ammo_casing/caseless/bullet/musket_balls in T.contents)
		if(do_after(user, 5))
			if(!eatarrow(musket_balls))
				break

/obj/item/quiver/bullet/attackby(obj/A, loc, params)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/bullet))
		if(arrows.len < max_storage)
			if(ismob(loc))
				var/mob/M = loc
				M.doUnEquip(A, TRUE, src, TRUE, silent = TRUE)
			else
				A.forceMove(src)
			arrows += A
			update_icon()
		else
			to_chat(loc, span_warning("Full!"))
		return
	..()

/obj/item/quiver/bullet/attack_right(mob/user)
	if(arrows.len)
		var/obj/O = arrows[arrows.len]
		arrows -= O
		O.forceMove(user.loc)
		user.put_in_hands(O)
		update_icon()
		return TRUE

/obj/item/quiver/sling/update_icon()
	return

// EFFECTSs

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

