/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/code = null
	var/lastattempt = null
	var/attempts = 3
	locked = 1
	var/min = 1
	var/max = 10

/obj/structure/closet/crate/secure/loot/New()
	..()
	code = rand(min,max)
	var/loot = rand(1,30)
	switch(loot)
		if(1)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus(src)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(2)
			new/obj/item/weapon/pickaxe/drill(src)
			new/obj/item/device/taperecorder(src)
			new/obj/item/clothing/suit/space/rig(src)
			new/obj/item/clothing/head/helmet/space/rig(src)
		if(3)
			for(var/i = 0, i < 12, i++)
				new/obj/item/weapon/coin/diamond(src)
		if(4)
			new/obj/item/weapon/bananapeel(src)
		if(5)
			for(var/i = 0, i < 6, i++)
				new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(7)
			new/obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)
		if(9 to 10)
			for(var/i = 0, i < 10, i++)
				new/obj/item/weapon/ore/diamond(src)
		if(11)
			return
		if(12)
			new/obj/item/seeds/deathberryseed(src)
			new/obj/item/seeds/deathnettleseed(src)
		if(13)
			new/obj/machinery/hydroponics(src)
		if(14)
			new/obj/item/seeds/cashseed(src)
		if(15)
			for(var/i = 0, i < 3, i++)
				new/obj/item/weapon/reagent_containers/glass/beaker/noreact(src)
		if(16 to 17)
			for(var/i = 0, i < 9, i++)
				new/obj/item/bluespace_crystal(src)
		if(19)
			for(var/i = 0, i < 4, i++)
				new/obj/item/weapon/melee/classic_baton(src)
		if(20)
			new/obj/item/weapon/storage/lockbox/clusterbang(src)
		if(21)
			new/obj/item/weapon/aiModule/robocop(src)
		if(22)
			new/obj/item/clothing/under/chameleon(src)
			for(var/i = 0, i < 7, i++)
				new/obj/item/clothing/tie/horrible(src)
		if(23)
			new/obj/item/clothing/under/shorts(src)
			new/obj/item/clothing/under/shorts/red(src)
			new/obj/item/clothing/under/shorts/blue(src)
		//Dummy crates start here.
		if(24 to 29)
			return
		if(8)
			return
		if(6)
			return
		if(18)
			return
		//Dummy crates end here.
		if(30)
			for(var/i = 0, i < 4, i++)
				new/obj/item/weapon/melee/baton(src)

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user as mob)
	if(locked)
		user << "<span class='notice'>The crate is locked with a Deca-code lock.</span>"
		var/input = input(usr, "Enter digit from [min] to [max].", "Deca-Code Lock", "") as num
		if(in_range(src, user))
			input = Clamp(input, 0, 10)
			if (input == code)
				user << "<span class='notice'>The crate unlocks!</span>"
				locked = 0
			else if (input == null || input > max || input < min)
				user << "<span class='notice'>You leave the crate alone.</span>"
			else
				user << "<span class='warning'>A red light flashes.</span>"
				lastattempt = input
				attempts--
				if (attempts == 0)
					user << "<span class='danger'>The crate's anti-tamper system activates!</span>"
					var/turf/T = get_turf(src.loc)
					explosion(T, 0, 1, 2, 1)
					del(src)
					return
		else
			user << "<span class='notice'>You attempt to interact with the device using a hand gesture, but it appears this crate is from before the DECANECT came out.</span>"
			return
	else
		return ..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(locked)
		if (istype(W, /obj/item/weapon/card/emag))
			user << "<span class='notice'>The crate unlocks!</span>"
			locked = 0
		if (istype(W, /obj/item/weapon/melee/energy/blade))
			overlays.Cut()
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, "sparks", 60, 1)
			src.locked = 0
			src.broken = 1
		if (istype(W, /obj/item/device/multitool))
			user << "<span class='notice'>DECA-CODE LOCK REPORT:</span>"
			if (attempts == 1)
				user << "<span class='warning'>* Anti-Tamper Bomb will activate on next failed access attempt.</span>"
			else
				user << "<span class='notice'>* Anti-Tamper Bomb will activate after [src.attempts] failed access attempts.</span>"
			if (lastattempt == null)
				user << "<span class='notice'> has been made to open the crate thus far.</span>"
				return
			// hot and cold
			if (code > lastattempt)
				user << "<span class='notice'>* Last access attempt lower than expected code.</span>"
			else
				user << "<span class='notice'>* Last access attempt higher than expected code.</span>"
		else src.attack_hand(user)
	else ..()


	if(is_type_in_list(W, list(/obj/item/weapon/packageWrap, /obj/item/weapon/cable_coil, /obj/item/device/radio/electropack, /obj/item/weapon/wirecutters)))
		return ..()
	if(locked && (istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)))
		overlays.Cut()
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 60, 1)
		src.locked = 0
		src.broken = 1
		user << "<span class='notice'>You unlock \the [src].</span>"
		return
	if(!opened)
		src.togglelock(user)
		return
	return ..()

