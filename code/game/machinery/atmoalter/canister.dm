/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"
	density = 1
	var/health = 100.0
	flags = FPRINT | CONDUCT

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/canister_color = "yellow"
	var/can_label = 1
	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0
	var/release_log = ""
	var/obj/item/device/attached_device
	var/mob/attacher = null

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	canister_color = "red"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Toxin (Bio)\]"
	icon_state = "orange"
	canister_color = "orange"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	canister_color = "black"
	can_label = 0
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	canister_color = "grey"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/update_icon()
	src.overlays = 0

	if (src.destroyed)
		src.icon_state = text("[]-1", src.canister_color)

	else
		icon_state = "[canister_color]"
		if(holding)
			overlays += "can-open"

		if(connected_port)
			overlays += "can-connector"

		var/tank_pressure = air_contents.return_pressure()

		if (tank_pressure < 10)
			overlays += image('icons/obj/atmos.dmi', "can-o0")
		else if (tank_pressure < ONE_ATMOSPHERE)
			overlays += image('icons/obj/atmos.dmi', "can-o1")
		else if (tank_pressure < 15*ONE_ATMOSPHERE)
			overlays += image('icons/obj/atmos.dmi', "can-o2")
		else
			overlays += image('icons/obj/atmos.dmi', "can-o3")
		if (attached_device)
			var/obj/item/device/assembly/A = attached_device
			var/icon/test = getFlatIcon(A)
			test.Shift(NORTH,1)
			test.Shift(EAST,6)
			overlays += test

	return

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)

		src.destroyed = 1
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		src.density = 0
		update_icon()

		if (src.holding)
			src.holding.loc = src.loc
			src.holding = null

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process()
	if (destroyed)
		return

	..()

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = min(release_pressure - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
			src.update_icon()

	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	if(air_contents.temperature > PLASMA_FLASHPOINT)
		air_contents.zburn()

	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents


/obj/machinery/portable_atmospherics/canister/proc/process_activation(var/obj/item/device/D)
	return

/obj/machinery/portable_atmospherics/canister/process_activation(var/obj/item/device/D)
	if(valve_open == 0)
		valve_open = 1
	else
		valve_open = 0



	var/turf/canturf = get_turf(src)
	var/area/A = get_area(canturf)

	var/attacher_name = ""
	if(!attacher)
		attacher_name = "Unknown"
	else
		attacher_name = "[attacher.name]([attacher.ckey])"

	var/log_str = "[src] releave valve [valve_open ? "opened" : "closed"] remotely in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[canturf.x];Y=[canturf.y];Z=[canturf.z]'>[A.name]</a> "
	log_str += "with [attached_device ? attached_device : "no device"] <BR> Attacher: [attacher_name]"

	if(attacher)
		log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[attacher]'>?</A>)"

	var/mob/mob = get_mob_by_key(src.fingerprintslast)
	var/last_touch_info = ""
	if(mob)
		last_touch_info = "(<A HREF='?_src_=holder;adminmoreinfo=\ref[mob]'>?</A>)"

	log_str += "<BR> Last touched by: [src.fingerprintslast][last_touch_info]"
	bombers += log_str
	message_admins(log_str, 0, 1)
	log_game(log_str)




/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/blob_act()
	src.health -= 200
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		src.health -= round(Proj.damage / 2)
		healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/meteorhit(var/obj/O as obj)
	src.health = 0
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda) && !(isassembly(W)))
		visible_message("\red [user] hits the [src] with a [W]!")
		src.health -= W.force
		src.add_fingerprint(user)
		healthcheck()

	if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/weapon/tank/jetpack))
		var/datum/gas_mixture/thejetpack = W:air_contents
		var/env_pressure = thejetpack.return_pressure()
		var/pressure_delta = min(10*ONE_ATMOSPHERE - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure
		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*thejetpack.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			thejetpack.merge(removed)
			user << "You pulse-pressurize your jetpack from the tank."
		return

	if(isassembly(W))
		var/obj/item/device/assembly/A = W
		if(A.secured)
			user << "<span class='notice'>The device is secured.</span>"
			return
		if(attached_device)
			user << "<span class='warning'>There is already an device attached to the valve, remove it first.</span>"
			return
		user.drop_item()
		A.loc = src

		var/icon/test = getFlatIcon(A)
//		test.Shift(EAST,2)
		test.Shift(SOUTH,4)
		overlays += test
		attached_device = A
		user << "<span class='notice'>You attach the [A] to the valve controls and secure it.</span>"
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).
		bombers += "[key_name(user)] attached a [A] to a [src]."
		message_admins("[key_name_admin(user)] attached a [A] to a [src].")
		log_game("[key_name_admin(user)] attached a [A] to a [src].")
		attacher = user


	..()






/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	return src.interact(user)

/obj/machinery/portable_atmospherics/canister/interact(var/mob/user as mob)
	if (src.destroyed)
		return

	user.set_machine(src)
	var/holding_text
	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [holding.air_contents.return_pressure()] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B>[can_label?" <A href='?src=\ref[src];relabel=1'><small>relabel</small></a>":""]<BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Release Valve Attachment: [attached_device ? "<A href='?src=\ref[src];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=\ref[src];rem_device=1'>Remove</A>" : ""]<BR>
Release Valve: <A href='?src=\ref[src];toggle=1'>[valve_open?("Open"):("Closed")]</A><BR>
Release Pressure: <A href='?src=\ref[src];pressure_adj=-1000'>-</A> <A href='?src=\ref[src];pressure_adj=-100'>-</A> <A href='?src=\ref[src];pressure_adj=-10'>-</A> <A href='?src=\ref[src];pressure_adj=-1'>-</A> [release_pressure] <A href='?src=\ref[src];pressure_adj=1'>+</A> <A href='?src=\ref[src];pressure_adj=10'>+</A> <A href='?src=\ref[src];pressure_adj=100'>+</A> <A href='?src=\ref[src];pressure_adj=1000'>+</A><BR>
<HR>
<A href='?src=\ref[user];mach_close=canister'>Close</A><BR>
"}

	user << browse("<html><head><title>[src]</title></head><body>[output_text]</body></html>", "window=canister;size=600x300")
	onclose(user, "canister")
	return

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)

	//Do not use "if(..()) return" here, canisters will stop working in unpowered areas like space or on the derelict.
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=canister")
		onclose(usr, "canister")
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.set_machine(src)

		if(href_list["toggle"])
			if (valve_open)
				if (holding)
					release_log += "Valve was <b>closed</b> by [usr], stopping the transfer into the [holding]<br>"
				else
					release_log += "Valve was <b>closed</b> by [usr], stopping the transfer into the <font color='red'><b>air</b></font><br>"
			else
				if (holding)
					release_log += "Valve was <b>opened</b> by [usr], starting the transfer into the [holding]<br>"
				else
					release_log += "Valve was <b>opened</b> by [usr], starting the transfer into the <font color='red'><b>air</b></font><br>"
			valve_open = !valve_open

		if(href_list["device"])
			attached_device.attack_self(usr)

		if(attached_device)
			if(href_list["rem_device"])
				attached_device.loc = get_turf(src)
				attached_device:holder = null
				attached_device = null
				update_icon()
				src.overlays = new/list()

		if (href_list["remove_tank"])
			if(holding)
				if(istype(holding, /obj/item/weapon/tank))
					holding.manipulated_by = usr.real_name
				holding.loc = loc
				holding = null

		if (href_list["pressure_adj"])
			var/diff = text2num(href_list["pressure_adj"])
			if(diff > 0)
				release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
			else
				release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

		if (href_list["relabel"])
			if (can_label)
				var/list/colors = list(\
					"\[N2O\]" = "redws", \
					"\[N2\]" = "red", \
					"\[O2\]" = "blue", \
					"\[Toxin (Bio)\]" = "orange", \
					"\[CO2\]" = "black", \
					"\[Air\]" = "grey", \
					"\[CAUTION\]" = "yellow", \
				)
				var/label = input("Choose canister label", "Gas canister") as null|anything in colors
				if (label)
					src.canister_color = colors[label]
					src.icon_state = colors[label]
					src.name = "Canister: [label]"
		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/portable_atmospherics/canister/toxins/New()

	..()

	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()

	..()

	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()

	..()

	var/datum/gas/sleeping_agent/trace_gas = new
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

//Dirty way to fill room with gas. However it is a bit easier to do than creating some floor/engine/n2o -rastaf0
/obj/machinery/portable_atmospherics/canister/sleeping_agent/roomfiller/New()
	..()
	var/datum/gas/sleeping_agent/trace_gas = air_contents.trace_gases[1]
	trace_gas.moles = 9*4000
	spawn(10)
		var/turf/simulated/location = src.loc
		if (istype(src.loc))
			while (!location.air)
				sleep(10)
			location.assume_air(air_contents)
			air_contents = new
	return 1

/obj/machinery/portable_atmospherics/canister/nitrogen/New()

	..()

	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()

	..()
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()

	..()
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.update_values()

	src.update_icon()
	return 1
