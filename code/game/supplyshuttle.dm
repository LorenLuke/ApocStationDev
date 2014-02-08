//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_STATION_AREATYPE "/area/supply/station" //Type of the supply shuttle area for station
#define SUPPLY_DOCK_AREATYPE "/area/supply/dock"	//Type of the supply shuttle area for dock

var/supply_money = 25000
var/crate_sell = 10
var/metal_sell = 8
var/glass_sell = 8
var/plasteel_sell = 30
var/diamond_sell = 500
var/uranium_sell = 125
var/plasma_sell = 25
var/gold_sell = 100
var/silver_sell = 50
var/clown_sell = 750
var/adamantine_sell = 1000
var/mythril_sell = 750
var/EU_sell = 250

var/metal_count = 0
var/glass_count = 0
var/plasteel_count = 0
var/diamond_count = 0
var/uranium_count = 0
var/plasma_count = 0
var/gold_count = 0
var/silver_count = 0
var/clown_count = 0
var/adamantine_count = 0
var/mythril_count = 0
var/EU_count = 0

var/datum/controller/supply_shuttle/supply_shuttle = new()

var/list/mechtoys = list(
	/obj/item/toy/prize/ripley,
	/obj/item/toy/prize/fireripley,
	/obj/item/toy/prize/deathripley,
	/obj/item/toy/prize/gygax,
	/obj/item/toy/prize/durand,
	/obj/item/toy/prize/honk,
	/obj/item/toy/prize/marauder,
	/obj/item/toy/prize/seraph,
	/obj/item/toy/prize/mauler,
	/obj/item/toy/prize/odysseus,
	/obj/item/toy/prize/phazon
	)

/area/supply/station //DO NOT TURN THE lighting_use_dynamic STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	lighting_use_dynamic = 0
	requires_power = 0

/area/supply/dock //DO NOT TURN THE lighting_use_dynamic STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	lighting_use_dynamic = 0
	requires_power = 0

//SUPPLY PACKS MOVED TO /code/defines/obj/supplypacks.dm

/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper Plastic flaps"
	desc = "I definitely cant get past those. No way."
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4
	explosion_resistance = 5

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/stool/bed/B = A
	if (istype(A, /obj/structure/stool/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	else if(istype(A, /mob/living)) // You Shall Not Pass!
		var/mob/living/M = A
		if(!M.lying && !istype(M, /mob/living/carbon/monkey) && !istype(M, /mob/living/carbon/slime) && !istype(M, /mob/living/simple_animal/mouse))  //If your not laying down, or a small creature, no pass.
			return 0
	return ..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			del(src)
		if (2)
			if (prob(50))
				del(src)
		if (3)
			if (prob(5))
				del(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

	New() //set the turf below the flaps to block air
		var/turf/T = get_turf(loc)
		if(T)
			T.blocks_air = 1
		..()

	Del() //lazy hack to set the turf to allow air to pass if it's a simulated floor
		var/turf/T = get_turf(loc)
		if(T)
			if(istype(T, /turf/simulated/floor))
				T.blocks_air = 0
		..()

/obj/machinery/computer/supplycomp
	name = "Supply shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "supply"
	req_access = list(access_cargo)
	circuit = "/obj/item/weapon/circuitboard/supplycomp"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "categories"
	var/datum/supply_manifest/X = new()


/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/weapon/circuitboard/ordercomp"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "categories"

/*
/obj/effect/marker/supplymarker
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "X"
	invisibility = 101
	anchored = 1
	opacity = 0
*/

/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/order_rank = null
	var/comment = null
	var/reason = null
	var/cost = null
	var/crate_type = null
	var/crate = null
	var/access_needed = "None"
	var/manifest = null

/datum/supply_manifest
	var/manifest_number
	var/list/prepped_manifests = list()
	var/list/manifestorderlist = list()
	var/list/manifestreturnlist = list()
	var/list/manifestselllist = list()
	var/manifestdescription
	var/manifest_crate
	var/manifest_crate/cost = 0
	var/manifest_crate/contains = list()
	var/sell = 0

	New()

proc/supply_buymanifest(var/num,var/list/orderlist,var/list/returnlist)
	var/datum/supply_manifest/SM = new()
	SM.manifest_number = num
	SM.manifestorderlist = orderlist
	SM.manifestreturnlist = returnlist
	SM.sell = 0
	supply_shuttle.manifestlist += SM
	return SM

proc/supply_sellmanifest(var/num,var/list/selllist)
	var/datum/supply_manifest/SM = new()
	SM.manifest_number = num
	for (var/i = 0, i<=selllist, i++)
		var/datum/supply_order/O
		O.ordernum = ""
		O.object = selllist[i]
		SM.manifestselllist += O
	SM.sell = 1

	for (var/obj/structure/closet/crate/C in selllist)
		var/datum/supply_order/SO = new()
		var/datum/supply_packs/P = C
		SO.ordernum = ""
		SO.manifest = C.contents
		SO.object = P
		P.cost = 5

		for(var/atom in C.contents)
			var/atom/A = atom
			if(istype(A, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/M = A
				metal_count += M.amount
				P.cost += metal_sell*metal_count
			if(istype(A, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/M = A
				glass_count += M.amount
				P.cost += glass_sell*glass_count
			if(istype(A, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/M = A
				plasteel_count += M.amount
				P.cost += plasteel_sell*plasteel_count
			if(istype(A, /obj/item/stack/sheet/mineral/diamond))
				var/obj/item/stack/sheet/mineral/diamond/M = A
				diamond_count += M.amount
				P.cost += diamond_sell*diamond_count
			if(istype(A, /obj/item/stack/sheet/mineral/uranium))
				var/obj/item/stack/sheet/mineral/uranium/M = A
				uranium_count += M.amount
				P.cost += uranium_sell*uranium_count
			if(istype(A, /obj/item/stack/sheet/mineral/plasma))
				var/obj/item/stack/sheet/mineral/plasma/M = A
				plasma_count += M.amount
				P.cost += plasma_sell*plasma_count
			if(istype(A, /obj/item/stack/sheet/mineral/gold))
				var/obj/item/stack/sheet/mineral/gold/M = A
				gold_count += M.amount
				P.cost += gold_sell*gold_count
			if(istype(A, /obj/item/stack/sheet/mineral/silver))
				var/obj/item/stack/sheet/mineral/silver/M = A
				silver_count += M.amount
				P.cost += silver_sell*silver_count
			if(istype(A, /obj/item/stack/sheet/mineral/clown))
				var/obj/item/stack/sheet/mineral/clown/M = A
				clown_count += M.amount
				P.cost += clown_sell*clown_count
			if(istype(A, /obj/item/stack/sheet/mineral/adamantine))
				var/obj/item/stack/sheet/mineral/adamantine/M = A
				adamantine_count += M.amount
				P.cost += adamantine_sell*adamantine_count
			if(istype(A, /obj/item/stack/sheet/mineral/mythril))
				var/obj/item/stack/sheet/mineral/mythril/M = A
				mythril_count += M.amount
				P.cost += mythril_sell*mythril_count
			if(istype(A, /obj/item/stack/sheet/mineral/enruranium))
				var/obj/item/stack/sheet/mineral/enruranium/M = A
				EU_count += M.amount
				P.cost += EU_sell*EU_count

		SM.manifestselllist += SO

	supply_shuttle.manifestlist += SM
	return SM

proc/supply_getmanifest(var/num)
	for (var/datum/supply_manifest/SM in supply_shuttle.manifestlist)
		if (num == SM.manifest_number)
			return SM




/datum/controller/supply_shuttle
	var/processing = 1
	var/processing_interval = 300
	var/iteration = 0
	//supply points

	var/points = 50
	var/points_per_process = 1
	var/points_per_slip = 2
	var/points_per_crate = 20
	var/plasma_per_point = 2 // 2 plasma for 1 point

	//control
	var/ordernum
	var/manifestnum
	var/list/manifestlist = list()
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/supply_packs = list()
	//shuttle movement
	var/at_station = 0
	var/movetime = 1200
	var/departtime = 150
	var/moving = 0
	var/eta_timeofday
	var/eta
	var/fuel_cost = 100


	New()
		ordernum = rand(400,9000)
		manifestnum = rand(1,300)
//		var/datum/supply_manifest/X
//		X.manifest_number = manifestnum
//		var/datum/money_account/department_account = department_accounts["Cargo"]
//		supply_money = department_account.money


	//Supply shuttle ticker - handles supply point regenertion and shuttle travelling between centcomm and the station
	proc/process()
		for(var/typepath in (typesof(/datum/supply_packs) - /datum/supply_packs))
			var/datum/supply_packs/P = new typepath()
			supply_packs[P.name] = P

		spawn(0)
			set background = 1
			while(1)
				if(processing)
					iteration++
					if(moving == 1)
						var/ticksleft = (eta_timeofday - world.timeofday)
						if(ticksleft > 0)
							eta = round(ticksleft/600,1)
						else
							eta = 0
							send()
				sleep(processing_interval)

	proc/send()
		var/area/from
		var/area/dest
		var/area/the_shuttles_way
		switch(at_station)
			if(1)
				from = locate(SUPPLY_STATION_AREATYPE)
				dest = locate(SUPPLY_DOCK_AREATYPE)
				the_shuttles_way = from
				at_station = 0
			if(0)
				from = locate(SUPPLY_DOCK_AREATYPE)
				dest = locate(SUPPLY_STATION_AREATYPE)
				the_shuttles_way = dest
				at_station = 1
		moving = 0

		//Do I really need to explain this loop?
		for(var/mob/living/unlucky_person in the_shuttles_way)
			unlucky_person.gib()

		from.move_contents_to(dest)

		var/datum/money_account/department_account = department_accounts["Cargo"]
		department_account.money = supply_money


/*
		var/ordernum = text2num(href_list["orddetail"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		var/list/orderlist = supply_shuttle.shoppinglist
		temp = "Invalid Request"

		for(var/i=1, i<=orderlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.shoppinglist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
		temp = "Viewing Order: #[O.ordernum]<BR><BR>"
		temp += "Crate Requested: [O.crate_type]<BR>"
		temp += "Crate Contents: <BR>[O.manifest]<BR>"
		temp += "Requested by: [O.orderedby], [O.order_rank]<BR>"
		temp += "Reason: [O.reason]<BR>"
		temp += "Access restrictions: [O.access_needed]<BR>"
		temp += "Cost: $[O.cost]<BR>"
		temp += "<A href='?src=\ref[src];cancelorder=[O.ordernum]'>Cancel Order (15% restocking fee)</A> | <A href='?src=\ref[src];printorder=[O.ordernum]'>Print Order Form</A>"
		temp += "<BR><A href='?src=\ref[src];vieworders=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
*/

		supply_shuttle.manifestnum ++

	//Check whether the shuttle is allowed to move
	proc/can_move()
		if(moving) return 0

		var/area/shuttle = locate(/area/supply/station)
		if(!shuttle) return 0

		if(forbidden_atoms_check(shuttle))
			return 0

		return 1

	//To stop things being sent to centcomm which should not be sent to centcomm. Recursively checks for these types.
	proc/forbidden_atoms_check(atom/A)
		if(istype(A,/mob/living))
			return 1
		if(istype(A,/obj/item/weapon/disk/nuclear))
			return 1
		if(istype(A,/obj/machinery/nuclearbomb))
			return 1
		if(istype(A,/obj/item/device/radio/beacon))
			return 1

		for(var/i=1, i<=A.contents.len, i++)
			var/atom/B = A.contents[i]
			if(.(B))
				return 1

	//Sellin
	proc/sell()
		var/list/sellinglist = list()
		var/shuttle_at
		if(at_station)	shuttle_at = SUPPLY_STATION_AREATYPE
		else			shuttle_at = SUPPLY_DOCK_AREATYPE

		var/area/shuttle = locate(shuttle_at)
		if(!shuttle)	return


		for(var/atom/movable/MA in shuttle)
			if(MA.anchored)	continue

			// Must be in a crate!
			if(istype(MA,/obj/structure/closet/crate))

				metal_count = 0
				glass_count = 0
				plasteel_count = 0
				diamond_count = 0
				uranium_count = 0
				plasma_count = 0
				gold_count = 0
				silver_count = 0
				clown_count = 0
				adamantine_count = 0
				mythril_count = 0
				EU_count = 0
				sellinglist = list()

				points += points_per_crate
				sellinglist += MA
				for(var/atom in MA)
					var/atom/A = atom
					if(istype(A, /obj/item/stack/sheet/metal))
						var/obj/item/stack/sheet/metal/M = A
						metal_count += M.amount
						supply_money += metal_sell*metal_count
					if(istype(A, /obj/item/stack/sheet/glass))
						var/obj/item/stack/sheet/glass/M = A
						glass_count += M.amount
						supply_money += glass_sell*glass_count
					if(istype(A, /obj/item/stack/sheet/plasteel))
						var/obj/item/stack/sheet/plasteel/M = A
						plasteel_count += M.amount
						supply_money += plasteel_sell*plasteel_count
					if(istype(A, /obj/item/stack/sheet/mineral/diamond))
						var/obj/item/stack/sheet/mineral/diamond/M = A
						diamond_count += M.amount
						supply_money += diamond_sell*diamond_count
					if(istype(A, /obj/item/stack/sheet/mineral/uranium))
						var/obj/item/stack/sheet/mineral/uranium/M = A
						uranium_count += M.amount
						supply_money += uranium_sell*uranium_count
					if(istype(A, /obj/item/stack/sheet/mineral/plasma))
						var/obj/item/stack/sheet/mineral/plasma/M = A
						plasma_count += M.amount
						supply_money += plasma_sell*plasma_count
					if(istype(A, /obj/item/stack/sheet/mineral/gold))
						var/obj/item/stack/sheet/mineral/gold/M = A
						gold_count += M.amount
						supply_money += gold_sell*gold_count
					if(istype(A, /obj/item/stack/sheet/mineral/silver))
						var/obj/item/stack/sheet/mineral/silver/M = A
						silver_count += M.amount
						supply_money += silver_sell*silver_count
					if(istype(A, /obj/item/stack/sheet/mineral/clown))
						var/obj/item/stack/sheet/mineral/clown/M = A
						clown_count += M.amount
						supply_money += clown_sell*clown_count
					if(istype(A, /obj/item/stack/sheet/mineral/adamantine))
						var/obj/item/stack/sheet/mineral/adamantine/M = A
						adamantine_count += M.amount
						supply_money += adamantine_sell*adamantine_count
					if(istype(A, /obj/item/stack/sheet/mineral/mythril))
						var/obj/item/stack/sheet/mineral/mythril/M = A
						mythril_count += M.amount
						supply_money += mythril_sell*mythril_count
					if(istype(A, /obj/item/stack/sheet/mineral/enruranium))
						var/obj/item/stack/sheet/mineral/enruranium/M = A
						EU_count += M.amount
						supply_money += EU_sell*EU_count






//			var/sellingmanifest
//			sellingmanifest = supply_getmanifest(manifestnum)

			supply_money += 20
			del(MA)
		supply_sellmanifest(manifestnum, sellinglist)



	//Buyin
	proc/buy()
		if(!shoppinglist.len) return

		var/shuttle_at
		if(at_station)	shuttle_at = SUPPLY_STATION_AREATYPE
		else			shuttle_at = SUPPLY_DOCK_AREATYPE

		var/area/shuttle = locate(shuttle_at)
		if(!shuttle)	return

		var/list/clear_turfs = list()

		for(var/turf/T in shuttle)
			if(T.density || T.contents.len)	continue
			clear_turfs += T

		for(var/S in shoppinglist)
			if(!clear_turfs.len)	break
			var/i = rand(1,clear_turfs.len)
			var/turf/pickedloc = clear_turfs[i]
			clear_turfs.Cut(i,i+1)

			var/datum/supply_order/SO = S
			var/datum/supply_packs/SP = SO.object

			var/atom/A = new SP.containertype(pickedloc)
			A.name = "[SP.containername] [SO.comment ? "([SO.comment])":"" ]"

			//supply manifest generation begin

			var/obj/item/weapon/paper/contents_list/slip = new /obj/item/weapon/paper/contents_list(A)
			slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
			slip.info +="Order #[SO.ordernum]<br>"
			slip.info +="Destination: [station_name]<br>"
			slip.info +="[supply_shuttle.shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>"
			slip.info +="CONTENTS:<br><ul>"

			//spawn the stuff, finish generating the manifest while you're at it
			if(SP.access)
				A:req_access = list()
				A:req_access += text2num(SP.access)

			var/list/contains
			if(istype(SP,/datum/supply_packs/randomised))
				var/datum/supply_packs/randomised/SPR = SP
				contains = list()
				if(SPR.contains.len)
					for(var/j=1,j<=SPR.num_contained,j++)
						contains += pick(SPR.contains)
			else
				contains = SP.contains

			for(var/typepath in contains)
				if(!typepath)	continue
				var/atom/B2 = new typepath(A)
				if(SP.amount && B2:amount) B2:amount = SP.amount
				slip.info += "<li>[B2.name]</li>" //add the item to the manifest

			//manifest finalisation
			slip.info += "</ul><br>"
			slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"
			if (SP.contraband) slip.loc = null	//we are out of blanks for Form #44-D Ordering Illicit Drugs.

//		generate_manifest(supply_shuttle.manifestnum, for(var/atom/movable/MA in shuttle), 1)

		supply_shuttle.shoppinglist.Cut()

		return



/obj/item/weapon/paper/contents_list
	name = "Contents List"


/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)

	if(..())
		return
	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		dat += {"<BR><B>Supply shuttle</B><HR>
		Location: [supply_shuttle.moving ? "Moving to station ([supply_shuttle.eta] Mins.)":supply_shuttle.at_station ? "Station":"Dock"]<BR>
		<HR>Cargo Account: $[supply_money]<BR>
		<BR>\n<A href='?src=\ref[src];order=categories'>Request items</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>View approved orders</A><BR><BR>
		<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR><BR>
		<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

	if( isturf(loc) && (in_range(src, usr) || istype(usr, /mob/living/silicon)) )
		usr.set_machine(src)

	if(href_list["order"])
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<b>Cargo Account: $[supply_money]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp = "<b>Cargo Account: $[supply_money]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR><BR>"
			temp += "<b>Request from: [last_viewed_group]</b><BR><BR>"
			for(var/supply_name in supply_shuttle.supply_packs )
				var/datum/supply_packs/N = supply_shuttle.supply_packs[supply_name]
				if(N.hidden || N.contraband || N.group != last_viewed_group) continue								//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: $[N.cost]<BR>"		//the obj because it would get caught by the garbage

	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		//Find the correct supply_pack datum
		var/datum/supply_packs/P = supply_shuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))	return
		var/timeout = world.time + 600
		var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","") as null|text),1,MAX_MESSAGE_LEN)
		if(world.time > timeout)	return
		if(!reason)	return

		var/crate_access_needed = replacetext(get_access_desc(P.access))
		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		supply_shuttle.ordernum++
/*
		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(loc)
		reqform.name = "Requisition Form - [P.name]"
		reqform.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"
		reqform.info += "INDEX: #[supply_shuttle.ordernum]<br>"
		reqform.info += "COST: $[P.cost]<br>"
		reqform.info += "REQUESTED BY: [idname]<br>"
		reqform.info += "RANK: [idrank]<br>"
		reqform.info += "REASON: [reason]<br>"
		reqform.info += "SUPPLY CRATE TYPE: [P.name]<br>"
		reqform.info += "ACCESS RESTRICTION: [replacetext(get_access_desc(P.access))]<br>"
		reqform.info += "CONTENTS:<br>"
		reqform.info += P.manifest
		reqform.info += "<hr>"
		reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"


		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5
*/

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order()
		O.ordernum = supply_shuttle.ordernum
		O.object = P
		O.cost = P.cost
		O.orderedby = idname
		O.order_rank = idrank
		O.reason = reason
		O.crate_type = P.name
		O.access_needed = crate_access_needed
		O.manifest = P.manifest
		supply_shuttle.requestlist += O

		temp = "Thanks for your request. The cargo team will process it as soon as possible.<BR>"
		temp += "You can also <A href='?src=\ref[src];printrecp=[O.ordernum]'><b>print a receipt</b><A> for your own records.<BR><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["printrecp"])
		var/ordernum = text2num(href_list["printrecp"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		temp = "Receipt for Order #[ordernum] printed for your records. Don't lose it!"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
		var/obj/item/weapon/paper/orderform = new /obj/item/weapon/paper(loc)
		orderform.name= "Receipt #[O.ordernum]"
		orderform.info += "Supply Pack Type Requested: [O.crate_type]<BR><BR>"
		orderform.info += "Cost: $[O.cost]<BR>"
		orderform.info += "Contents: <BR>[O.manifest]"
		orderform.info += "Requested by: <b>[O.orderedby]</b>, <i>[O.order_rank]</i><BR><HR>"
		orderform.info += "Stamp this receipt to confirm payment for the above order."


	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		user << "\red Access Denied."
		return

	if(..())
		return
	user.set_machine(src)
	post_signal("supply")
	var/dat
	if (temp)
		dat = temp
	else
		dat += {"<BR><B>Supply shuttle</B><HR>
		\nLocation: [supply_shuttle.moving ? "Moving to station.":supply_shuttle.at_station ? "Station":"Away"]<BR>
		<HR>\nCargo Account: $[supply_money]<BR>\n<BR>
		[supply_shuttle.moving ? "\n*Must be away to order items*<BR>\n<BR>":supply_shuttle.at_station ? "\n*Must be away to order items*<BR>\n<BR>":"\n<A href='?src=\ref[src];order=categories'>Order items</A><BR>\n<BR>"]
		[supply_shuttle.moving ? "\n*Shuttle already called*<BR>\n<BR>":supply_shuttle.at_station ? "\n<A href='?src=\ref[src];send=1'>Send back to Centcomm (Fuel Cost: $[supply_shuttle.fuel_cost])</A><BR>\n<BR>":"\n<A href='?src=\ref[src];send=1'>Send to [station_name()] (Fuel Cost: $[supply_shuttle.fuel_cost])</A><BR>\n<BR>"]
		\n<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR>\n<BR>
		\n<A href='?src=\ref[src];vieworders=1'>View orders</A><BR>\n<BR>
		\n<A href='?src=\ref[src];viewmanifest=1'>View manifests</A><BR>\n<BR>
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/supplycomp/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag) && !hacked)
		user << "\blue Special supplies unlocked."
		hacked = 1
		return
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				new /obj/item/weapon/shard( loc )
				var/obj/item/weapon/circuitboard/supplycomp/M = new /obj/item/weapon/circuitboard/supplycomp( A )
				for (var/obj/C in src)
					C.loc = loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				var/obj/item/weapon/circuitboard/supplycomp/M = new /obj/item/weapon/circuitboard/supplycomp( A )
				if(can_order_contraband)
					M.contraband_enabled = 1
				for (var/obj/C in src)
					C.loc = loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		attack_hand(user)
	return

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	X.manifest_number = supply_shuttle.manifestnum
	if(!supply_shuttle)
		world.log << "## ERROR: Eek. The supply_shuttle controller datum is missing somehow."
		return
	if(..())
		return

	if(isturf(loc) && ( in_range(src, usr) || istype(usr, /mob/living/silicon) ) )
		usr.set_machine(src)

	//Calling the shuttle
	if(href_list["send"])
		if(!supply_shuttle.can_move())
			temp = "For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else if((supply_money < supply_shuttle.fuel_cost)&&(supply_shuttle.at_station))
			temp = "Not enough money in cargo account to cover fuel costs for supply shuttle return.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		else if((supply_money < supply_shuttle.fuel_cost)&&!(supply_shuttle.at_station))
			temp = "Not enough money in cargo account to cover fuel costs for supply shuttle delivery.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

//			Cargo Pays for fuel here


		else if(supply_shuttle.at_station)
			supply_shuttle.moving = -1
//			generate_manifest(supply_shuttle.manifestnum, supply_shuttle.shopping_list, 0)
			supply_shuttle.sell()
			supply_shuttle.send()

/*
			supply_shuttle.eta_timeofday = (world.timeofday + supply_shuttle.departtime) % 864000
			temp = "The supply shuttle has been called and will arrive in approximately [round(supply_shuttle.movetime/10,1)] minutes.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			var/datum/transaction/T = new()
			T.target_name = "Cargo Account"
			T.purpose = "Fuel Cost for Supply Shuttle transit from Central Command to [station_name()]"
			T.amount = "([supply_shuttle.fuel_cost])"
			T.source_terminal = "Central Command Fuel Resources Terminal #467"
			T.date = current_date_string
			T.time = worldtime2text()
			department_account.transaction_log.Add(T)
			department_account.money -= supply_shuttle.fuel_cost
			supply_money = department_account.money
			post_signal("supply")
*/
			supply_shuttle.eta_timeofday = (world.timeofday + supply_shuttle.departtime) % 864000
			temp = "The supply shuttle has prepped for departure and will be leaving soon.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			var/datum/transaction/T = new()
			T.target_name = "Cargo Account"
			T.purpose = "Fuel Cost for Supply Shuttle transit from [station_name()] to Central Command"
			T.amount = "([supply_shuttle.fuel_cost])"
			T.source_terminal = "Central Command Fuel Resources Terminal #467"
			T.date = current_date_string
			T.time = worldtime2text()
//			department_account.transaction_log.Add(T)
//			department_account.money -= supply_shuttle.fuel_cost
			supply_money -= supply_shuttle.fuel_cost

		else
			supply_shuttle.moving = 1
			supply_shuttle.buy()
			supply_buymanifest(X.manifest_number, X.manifestorderlist, X.manifestreturnlist)
			supply_shuttle.eta_timeofday = (world.timeofday + supply_shuttle.movetime) % 864000
			temp = "The supply shuttle has been called and will arrive in [round(supply_shuttle.movetime/600,1)] minutes.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
/*
			var/datum/transaction/T = new()
			T.target_name = "Cargo Account"
			T.purpose = "Fuel Cost for Supply Shuttle transit from Central Command to [station_name()]"
			T.amount = "([supply_shuttle.fuel_cost])"
			T.source_terminal = "Central Command Fuel Resources Terminal #467"
			T.date = current_date_string
			T.time = worldtime2text()
			department_account.transaction_log.Add(T)
*/
			supply_money -= supply_shuttle.fuel_cost
			post_signal("supply")

	else if (href_list["order"])
		if(supply_shuttle.moving) return
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<b>Cargo Account: $[supply_money]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp = "<b>Cargo Account: $[supply_money]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR><BR>"
			temp += "<b>Request from: [last_viewed_group]</b><BR><BR>"
			for(var/supply_name in supply_shuttle.supply_packs )
				var/datum/supply_packs/N = supply_shuttle.supply_packs[supply_name]
				if((N.hidden && !hacked) || (N.contraband && !can_order_contraband) || N.group != last_viewed_group) continue								//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: $[N.cost]<BR>"		//the obj because it would get caught by the garbage


	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		//Find the correct supply_pack datum
		var/datum/supply_packs/P = supply_shuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))	return
		var/timeout = world.time + 600
		var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","") as null|text),1,MAX_MESSAGE_LEN)
		if(world.time > timeout)	return
		if(!reason)	return
		var/crate_access_needed = replacetext(get_access_desc(P.access))
		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		supply_shuttle.ordernum++

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order()
		O.ordernum = supply_shuttle.ordernum
		O.object = P
		O.cost = P.cost
		O.orderedby = idname
		O.order_rank = idrank
		O.reason = reason
		O.crate_type = P.name
		O.access_needed = crate_access_needed
		O.manifest = P.manifest
		supply_shuttle.requestlist += O

		temp = "Order request placed.<BR>"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> | <A href='?src=\ref[src];mainmenu=1'>Main Menu</A> | <A href='?src=\ref[src];confirmorder=[O.ordernum]'>Authorize Order</A> | <A href='?src=\ref[src];printreq=[O.ordernum]'>Print Request Form</A>"

	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
//		for (var/i=1, i<=supply_shuttle.manifestlist.len, i++)
//			selected_manifest = supply_shuttle.manifestlist[i]
//			if (selected_manifest.manifestnum == manifestnum)
//				selected_manifest.manifestorderlist += O
		var/datum/supply_packs/P
		temp = "Invalid Request"
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
				if(supply_money >= P.cost)
/*
					var/datum/transaction/T = new()
					T.target_name = "Cargo Account"
					T.purpose = "Order #[O.ordernum]-[P.name] for [O.orderedby], [O.order_rank]"
					T.amount = "([P.cost])"
					T.source_terminal = "Central Command Supply Requisitions Department"
					T.date = current_date_string
					T.time = worldtime2text()
					department_account.transaction_log.Add(T)
*/
					supply_money -= P.cost
					supply_shuttle.requestlist.Cut(i,i+1)
					supply_shuttle.shoppinglist += O
					X.manifestorderlist += O
					temp = "Thanks for your order.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				else
					temp = "Not enough funds.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				break

	else if (href_list["vieworders"])

		temp = "Current pending orders: <BR><BR>"
		for(var/S in supply_shuttle.shoppinglist)
			var/datum/supply_order/SO = S
			temp += "<A href='?src=\ref[src];orddetail=[SO.ordernum]'>#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby][SO.comment ? " ([SO.comment])":""]</A> [supply_shuttle.moving ? "":supply_shuttle.at_station ? "":"<BR><A href='?src=\ref[src];cancelorder=[SO.ordernum]'>Cancel Order (15% restocking fee) </A> | <A href='?src=\ref[src];printorder=[SO.ordernum]'>Print Confirmed Order</A><BR><BR>"]<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"


	else if (href_list["viewrequests"])
		temp = "Current Requests: <BR><BR>"
		for(var/S in supply_shuttle.requestlist)
			var/datum/supply_order/SO = S
			temp += "<A href='?src=\ref[src];reqdetail=[SO.ordernum]'>#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby][SO.comment ? " ([SO.comment])":""]</A> [supply_shuttle.moving ? "":supply_shuttle.at_station ? "":"<BR><A href='?src=\ref[src];confirmorder=[SO.ordernum]'>Approve</A> | <A href='?src=\ref[src];rreq=[SO.ordernum]'>Remove</A> | <A href='?src=\ref[src];printreq=[SO.ordernum]'>Print Pending Order</A><BR><BR>"]<BR>"
		temp += "<BR><A href='?src=\ref[src];clearreq=1'>Clear list</A>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["orddetail"])

		temp = "Order placeholder"
		var/ordernum = text2num(href_list["orddetail"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		var/list/orderlist = supply_shuttle.shoppinglist
		temp = "Invalid Request"

		for(var/i=1, i<=orderlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.shoppinglist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
		temp = "Viewing Order: #[O.ordernum]<BR><BR>"
		temp += "Crate Requested: [O.crate_type]<BR>"
		temp += "Crate Contents: <BR>[O.manifest]<BR>"
		temp += "Requested by: [O.orderedby], [O.order_rank]<BR>"
		temp += "Reason: [O.reason]<BR>"
		temp += "Access restrictions: [O.access_needed]<BR>"
		temp += "Cost: $[O.cost]<BR>"
		temp += "<A href='?src=\ref[src];cancelorder=[O.ordernum]'>Cancel Order (15% restocking fee)</A> | <A href='?src=\ref[src];printorder=[O.ordernum]'>Print Order Form</A>"
		temp += "<BR><A href='?src=\ref[src];vieworders=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"


	else if (href_list["reqdetail"])
		temp = "Req placeholder"
		var/ordernum = text2num(href_list["reqdetail"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		var/list/reqlist = supply_shuttle.requestlist
		temp = "Invalid Request"
		for(var/i=1, i<=reqlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
		temp = "Viewing Order: #[O.ordernum]<BR><BR>"
		temp += "Crate Requested: [O.crate_type]<BR>"
		temp += "Crate Contents: <BR>[O.manifest]<BR>"
		temp += "Requested by: [O.orderedby], [O.order_rank]<BR>"
		temp += "Reason: [O.reason]<BR>"
		temp += "Access restrictions: [O.access_needed]<BR>"
		temp += "Cost: $[O.cost]<BR>"
		temp += "<BR><A href='?src=\ref[src];confirmorder=[O.ordernum]'>Authorize Order</A>  | <A href='?src=\ref[src];rreq=[O.ordernum]'>Remove Request</A> | <A href='?src=\ref[src];printreq=[O.ordernum]'>Print Request Form</A>"
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"


	else if (href_list["printorder"])
		var/ordernum = text2num(href_list["printorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		temp = "Invalid Order"
		for(var/i=1, i<=supply_shuttle.shoppinglist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.shoppinglist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
		temp = "Printing Order Form: #[ordernum]<BR><BR><A href='?src=\ref[src];orderdetail=[ordernum]'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

		var/obj/item/weapon/paper/orderform = new /obj/item/weapon/paper(loc)
		orderform.name= "Order Form #[O.ordernum] - [O.crate_type]"
		orderform.info += "<h3>[station_name] Supply Order Form</h3><hr> "
		orderform.info += "Cost: $[O.cost]<BR>"
		orderform.info += "Supply Pack Type Requested: [O.crate_type]<BR>"
		orderform.info += "Contents: [O.manifest]<BR>"
		orderform.info += "Requested by: <b>[O.orderedby]</b>, <i>[O.order_rank]</i><BR>"
		orderform.info += "Reason: [O.reason]<BR>"
		orderform.info += "Access restrictions: [O.access_needed]<BR><HR>"
		orderform.info += "This order has been approved."
		orderform.stamps += "<HR><i>This paper has been stamped by the Shuttle Supply Console.</i>"

		orderform.update_icon()	//Fix for appearing blank when printed.


	else if (href_list["printreq"])
		var/ordernum = text2num(href_list["printreq"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		temp = "Invalid Request"
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
		temp = "Printing Request Form: #[ordernum]<BR><BR><A href='?src=\ref[src];confirmorder=[O.ordernum]'>Authorize Order</A> <A href='?src=\ref[src];reqdetail=[O.ordernum]'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

		var/obj/item/weapon/paper/orderform = new /obj/item/weapon/paper(loc)
		orderform.name= "Request Form #[O.ordernum] - [O.crate_type]"
		orderform.info += "<h3>[station_name] Supply Order Form</h3><hr> "
		orderform.info += "Cost: $[O.cost]<BR>"
		orderform.info += "Supply Pack Type Requested: [O.crate_type]<BR>"
		orderform.info += "Contents: [O.manifest]<BR>"
		orderform.info += "Requested by: <b>[O.orderedby]</b>, <i>[O.order_rank]</i><BR>"
		orderform.info += "Reason: [O.reason]<BR>"
		orderform.info += "Access restrictions: [O.access_needed]<BR><HR>"
		orderform.info += "Stamp below to approve this order."

		orderform.update_icon()	//Fix for appearing blank when printed.



	else if(href_list["cancelorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["cancelorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		temp = "Invalid Request"
		for(var/i=1, i<=supply_shuttle.shoppinglist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.shoppinglist[i]
			if(SO.ordernum == ordernum)
				O = SO
				X.manifestreturnlist += O
//				current_manifest.manifestreturnlist += SO
				P = O.object
			var/restock_cost = round(P.cost*0.85)

/*
			var/datum/transaction/T = new()
			T.target_name = "Cargo Account"
			T.purpose = "Order #[O.ordernum] Cancelled, refunded [P.cost] minus restocking fee"
			T.amount = "[restock_cost]"
			T.source_terminal = "Central Command Supply Requisitions Department"
			T.date = current_date_string
			T.time = worldtime2text()
			department_account.transaction_log.Add(T)
*/
			supply_money += restock_cost
			X.manifestorderlist.Cut(i,i+1)
			supply_shuttle.shoppinglist.Cut(i,i+1)



//			supply_shuttle.manifestreturnlist += O
		temp = "Order cancelled, the cost has been refunded, minus the restocking fee.<BR>"
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"


	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		temp = "Invalid Request.<BR>"
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				supply_shuttle.requestlist.Cut(i,i+1)
				temp = "Request removed.<BR>"
				break
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["clearreq"])
		supply_shuttle.requestlist.Cut()
		temp = "List cleared.<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"


//bug: Cost is just last crate plus fuel

	else if (href_list["viewmanifest"])
		temp = "Past Manifests: <BR><BR>"
		var/total_cost = 0
		for(var/datum/supply_manifest/SM in supply_shuttle.manifestlist)
			for (var/datum/supply_order/O in SM.manifestorderlist)
				total_cost += O.cost
			for (var/datum/supply_order/O in SM.manifestreturnlist)
				total_cost += (O.cost * 0.15)
			for (var/datum/supply_order/O in SM.manifestselllist)
				total_cost -= O.cost

			total_cost += supply_shuttle.fuel_cost
//			temp += "<A href='?src=\ref[src];reqdetail=[SM.manifest_number]'>Supply Manifest #[SM.manifest_number]: [SM.sell? "Outgoing":"Incoming"] Shipment: [SM.sell? SM.manifestselllist.len : SM.manifestorderlist.len] Crates-Cost with Fuel $[(supply_shuttle.fuel_cost+total_cost)<0?"([(supply_shuttle.fuel_cost+total_cost)*-1])":"[(supply_shuttle.fuel_cost+total_cost)]"]</A><BR>"
			temp += "Supply Manifest #[SM.manifest_number]: [SM.sell? "Outgoing":"Incoming"] Shipment: [SM.sell? SM.manifestselllist.len : SM.manifestorderlist.len] Crate[SM.manifestorderlist.len==1? "":"s"][SM.manifestreturnlist.len>0? " [SM.manifestreturnlist.len] Restocked Order[SM.manifestreturnlist.len==1?"s":""]": ""]-Cost with Fuel $[(supply_shuttle.fuel_cost+total_cost)<0?"([(total_cost)*-1])":"[total_cost]"]<BR>"
			total_cost = 0

		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"


	else if (href_list["mandetail"])
		temp = "Manifest Detail Placeholder"
		temp = ""
		var/datum/supply_manifest/SM
		var/total_cost = 0
		var/selected_num = text2num(href_list["mandetail"])
		for(var/datum/supply_manifest/tester in supply_shuttle.manifestlist)
			if(tester.manifest_number == selected_num)
				SM = tester

		temp += "<BR>Supply Manifest #[SM.manifest_number]: [SM.sell? "Outgoing":"Incoming"] Shipment [SM.sell? "to":"from"] NanoTrasen Central Command"
		temp += "<BR>Fuel Cost: $[supply_shuttle.fuel_cost]"

		if(SM.manifestorderlist.len > 0)
			temp += "<BR>Ordered Items:"

		for (var/datum/supply_order/O in SM.manifestorderlist)
			total_cost += O.cost
			var/datum/supply_packs/P = O.object
			var/temp_crate_type = O.crate_type
			var/crate_count = 0
			var/list/templist = list()
			for (var/i<0, i<SM.manifestorderlist.len, i++)
				var/datum/supply_order/Q = SM.manifestorderlist[i]
				if(Q.crate_type == temp_crate_type)
					var/obj/structure/closet/crate/O_crate = P
					var/obj/structure/closet/crate/Q_crate = Q.object
					templist = O_crate.contents ^ Q_crate.contents
					if ((templist.len < 0)&&(Q_crate != O.crate))
						SM.manifestorderlist.Cut(i,i+1)
						crate_count += 1
			temp += "<BR>[crate_count] x $[O.cost] ([O.crate_type])"

			var/list/contains
			contains = P.contains
			for(var/obj/x in contains)
				var/mineral = 0
				if(istype(x, /obj/item/stack/sheet/glass))
					mineral = 1
				if(istype(x, /obj/item/stack/sheet/metal))
					mineral = 1
				if(istype(x, /obj/item/stack/sheet/plasteel))
					mineral = 1
				if(istype(x, /obj/item/stack/sheet/mineral))
					mineral = 1
				temp += "<li>[x.name]</li>" //add the item to the manifest
//					if(mineral)
//						var/object/item/stack/sheet/SH = x
//						temp += "<li>[SH.name] : [SH.amount] sheets</li>" //add the item to the manifest

			//manifest finalisation
			temp += "</ul><br>"




			temp += "<BR>"
		if(SM.manifestreturnlist.len > 0)
			temp += "<BR>Items returned before departure:"
		for (var/datum/supply_order/O in SM.manifestreturnlist)
			total_cost += (O.cost * 0.15)

		if(SM.manifestselllist.len > 0)
			temp += "<BR>Sold Items:"
		for (var/datum/supply_order/O in SM.manifestselllist)
			total_cost -= O.cost


//		temp += "
		if(SM.sell)
			temp += "<BR>[SM.manifestselllist.len] Crates-Total Cost $([total_cost*-1])"
		else
			temp += "<BR>[SM.manifestorderlist.len] Crates-Total Cost $[total_cost]<BR>"
		temp += "<BR><BR><A href='?src=\ref[src];viewmanifest=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"




//temp += "<A href='?src=\ref[src];orddetail=[SO.ordernum]'>#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby][SO.comment ? " ([SO.comment])":""]</A> [supply_shuttle.moving ? "":supply_shuttle.at_station ? "":"<BR><A href='?src=\ref[src];cancelorder=[SO.ordernum]'>Cancel Order</A> | <A href='?src=\ref[src];printorder=[SO.ordernum]'>Print Confirmed Order</A><BR><BR>"]<BR>"
		temp += "<BR><A href='?src=\ref[src];viewmanifest=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"



	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)

/*
/obj/machinery/computer/supplycomp/proc/generate_manifest(var/manifestnum, var/manifestlist, var/manifestreturnlist, var/move)

	var/
*/