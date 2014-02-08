/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "xray"
	damage = 60
	stun = 10
	weaken = 10
	stutter = 10

/obj/item/weapon/gun/projectile/sniperrifle
	name = "L.W.B.S.R."
	desc = "A light-weight, high-caliber, bluespace rifle fitted with an enhanced optic."
	icon = 'icons/obj/BSR.dmi'
	icon_state = "sniper"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	origin_tech = "combat=6;materials=5;powerstorage=4"
	projectile_type = "/obj/item/projectile/beam/sniper"
	charge_cost = 250
	fire_delay = 35
	w_class = 4.0
	var/zoom = 0
	dropped(mob/user)
		usr.client.view = world.view


/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(AC.caliber == caliber && loaded.len < max_shells)
			user.drop_item()
			AC.loc = src
			loaded += AC
			num_loaded++
	if(num_loaded)
		user << "\blue You load [num_loaded] shell\s into the gun!"
	A.update_icon()
	update_icon()
	return


/obj/item/weapon/gun/projectile/attack_self(mob/user as mob)
	if (target)
		return ..()
	if (loaded.len)
		if (load_method == SPEEDLOADER)
			var/obj/item/ammo_casing/AC = loaded[1]
			loaded -= AC
			AC.loc = get_turf(src) //Eject casing onto ground.
			user << "\blue You unload shell from \the [src]!"
		if (load_method == MAGAZINE)
			var/obj/item/ammo_magazine/AM = empty_mag
			for (var/obj/item/ammo_casing/AC in loaded)
				AM.stored_ammo += AC
				loaded -= AC
			AM.loc = get_turf(src)
			empty_mag = null
			update_icon()
			AM.update_icon()
			user << "\blue You unload magazine from \the [src]!"
	else
		user << "\red Nothing loaded in \the [src]!"


/obj/item/weapon/gun/projectile/sniperrifle/verb/zoom()
	set category = "Special Verbs"
	set name = "Zoom"
	set src in view(usr, 0)
	set popup_menu = 0
	if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
		usr << "You cannot do this at this time."
		return
	if(do_after(user, 10))
	src.zoom = !src.zoom
	usr << ("<font color='[src.zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
	if(zoom)
		usr.client.view = 12
		usr << sound('sound/mecha/imag_enh.ogg',volume=50)
	else
		usr.client.view = world.view//world.view - default mob view size
	return