/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */


/*
 * DATA CARDS - Used for the teleporter
 */
/obj/item/weapon/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = 1.0
	var/associated_account_number = 0
	var/list/secondary_account_numbers = new()
	var/list/files = list(  )

/obj/item/weapon/card/data
	name = "data disk"
	desc = "A disk of data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/data/verb/label(t as text)
	set name = "Label Disk"
	set category = "Object"
	set src in usr

	if (t)
		src.name = text("Data Disk- '[]'", t)
	else
		src.name = "Data Disk"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/card/data/clown
	name = "coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Land"

/*
 * ID CARDS
 */

/obj/item/weapon/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"

/obj/item/weapon/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	var/uses = 10
	// List of devices that cost a use to emag.
	var/list/devices = list(
		/obj/item/robot_parts,
		/obj/item/weapon/storage/lockbox,
		/obj/item/weapon/storage/secure,
		/obj/item/weapon/circuitboard,
		/obj/item/device/eftpos,
		/obj/item/device/lightreplacer,
		/obj/item/device/taperecorder,
		/obj/item/device/hailer,
		/obj/item/device/megaphone,
		/obj/item/clothing/tie/holobadge,
		/obj/structure/closet/crate/secure,
		/obj/structure/closet/secure_closet,
		/obj/machinery/librarycomp,
		/obj/machinery/computer,
		/obj/machinery/power,
		/obj/machinery/suspension_gen,
		/obj/machinery/shield_capacitor,
		/obj/machinery/shield_gen,
		/obj/machinery/zero_point_emitter,
		/obj/machinery/clonepod,
		/obj/machinery/deployable,
		/obj/machinery/door_control,
		/obj/machinery/porta_turret,
		/obj/machinery/shieldgen,
		/obj/machinery/turretid,
		/obj/machinery/vending,
		/obj/machinery/bot,
		/obj/machinery/door,
		/obj/machinery/telecomms,
		/obj/machinery/mecha_part_fabricator
		)


/obj/item/weapon/card/emag/afterattack(var/obj/item/weapon/O as obj, mob/user as mob)

	for(var/type in devices)
		if(istype(O,type))
			uses--
			break

	if(uses<1)
		user.visible_message("[src] fizzles and sparks - it seems it's been used once too often, and is now broken.")
		user.drop_item()
		var/obj/item/weapon/card/emag_broken/junk = new(user.loc)
		junk.add_fingerprint(user)
		del(src)
		return

	..()

/obj/item/weapon/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	var/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = SLOT_ID

	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0		// determines if this ID has claimed a dorm already

//	if


/obj/item/weapon/card/id/New()
	..()
	spawn(30)
	if(istype(loc, /mob/living/carbon/human))
		blood_type = loc:dna:b_type
		dna_hash = loc:dna:unique_enzymes
		fingerprint_hash = md5(loc:dna:uni_identity)

/obj/item/weapon/card/id/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] []: assignment: []", user, src, src.name, src.assignment), 1)

	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/GetAccess()
	return access

/obj/item/weapon/card/id/GetID()
	return src

/obj/item/weapon/card/id/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W,/obj/item/weapon/id_wallet))
		user << "You slip [src] into [W]."
		src.name = "[src.registered_name]'s [W.name] ([src.assignment])"
		src.desc = W.desc
		src.icon = W.icon
		src.icon_state = W.icon_state
		del(W)
		return

/obj/item/weapon/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	usr << text("\icon[] []: The current assignment on the card is [].", src, src.name, src.assignment)
	usr << "The blood type on the card is [blood_type]."
	usr << "The DNA hash on the card is [dna_hash]."
	usr << "The fingerprint hash on the card is [fingerprint_hash]."
	return


/obj/item/weapon/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"

/obj/item/weapon/card/id/gold
	name = "identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"


/obj/item/weapon/card/id/cap
	name = "Captain's identification card"
	desc = "A golden card bristling with power. You wonder what secrets its owner holds."
	icon_state = "cap"
	item_state = "gold_id"

/obj/item/weapon/card/id/hop
	name = "Head of Personnel's identification card"
	desc = "A green-emblazened card with golden text. It seems its owner might be important."
	icon_state = "hop"
	item_state = "gold_id"

/obj/item/weapon/card/id/hos
	name = "Head of Security's identification card"
	desc = "A card marked in searing red and streaking gold. You suppress the urge to cower in fear."
	icon_state = "hos"
	item_state = "gold_id"

/obj/item/weapon/card/id/ce
	name = "Chief Engineer's identification card"
	desc = "A bronzed glare and golden text give this card a metallic sheen. A masterful piece of metalwork and technology."
	icon_state = "ce"
	item_state = "gold_id"

/obj/item/weapon/card/id/cmo
	name = "Chief Medical Officer's identification card"
	desc = "A card marked with cool blue and soft gold lettering. Its appearance gives you the feeling of being in good hands."
	icon_state = "cmo"
	item_state = "gold_id"

/obj/item/weapon/card/id/rd
	name = "Research Director's identification card"
	desc = "A card, seemingly glowing by blacklit purple and luminescent gold. It feels as if the card itself is bursting with knowledge."
	icon_state = "rd"
	item_state = "gold_id"

/obj/item/weapon/card/id/qm
	name = "Quarter Master's identification card"
	desc = "A duct-taped and scratched card with a brown icon and green text. It appears to be worn from frequent use."
	icon_state = "qm"
	item_state = "gold_id"

/obj/item/weapon/card/id/sec
	name = "Security identification card"
	desc = "A silver card, dotted with crimson insigniae. Its construction seems very robust."
	icon_state = "sec"
	item_state = "gold_id"

/obj/item/weapon/card/id/eng
	name = "Engineering identification card"
	desc = "A silver and bronze metallic card. The colors of the master builders."
	icon_state = "eng"
	item_state = "gold_id"

/obj/item/weapon/card/id/med
	name = "Medical identification card"
	desc = "A silver snake and blue background stand out on the card. You're not sure how you feel about this."
	icon_state = "med"
	item_state = "gold_id"

/obj/item/weapon/card/id/sci
	name = "Science identification card"
	desc = "A purple card with light grey lettering. It's very construction is a testament to SCIENCE!"
	icon_state = "sci"
	item_state = "gold_id"

/obj/item/weapon/card/id/gen
	name = "Geneticist identification card"
	desc = "An odd card with blue and purple intertwined on it. The colors almost seem to be forming a double-helix."
	icon_state = "gen"
	item_state = "gold_id"

/obj/item/weapon/card/id/car
	name = "Cargo identification card"
	desc = "A dirtied brown identification card. It is scratched and seems to have splinters in it."
	icon_state = "car"
	item_state = "gold_id"

/obj/item/weapon/card/id/civilian
	name = "identification card"
	desc = "A card bearing a green NanoTrasen hologram on a grey background. It is the identifier of the station's manual labor force."
	icon_state = "civilian"
	item_state = "card-id"

/obj/item/weapon/card/id/assistant
	name = "identification card"
	desc = "A plain grey NanoTrasen employee card, identifying its holder as a staff assistant. Fear the grey tide."
	icon_state = "id"
	item_state = "card-id"

/obj/item/weapon/card/id/syndicate
	name = "agent card"
	access = list(access_maint_tunnels, access_syndicate, access_external_airlocks)
	origin_tech = "syndicate=3"
	var/registered_user=null

/obj/item/weapon/card/id/syndicate/New(mob/user as mob)
	..()
	if(!isnull(user)) // Runtime prevention on laggy starts or where users log out because of lag at round start.
		registered_name = ishuman(user) ? user.real_name : user.name
	else
		registered_name = "Agent Card"
	assignment = "Agent"
	name = "[registered_name]'s ID Card ([assignment])"

/obj/item/weapon/card/id/syndicate/afterattack(var/obj/item/weapon/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		src.access |= I.access
		src.secondary_account_numbers |= I.secondary_account_numbers
		if(istype(user, /mob/living) && user.mind)
			if(user.mind.special_role)
				usr << "\blue The card's microscanners activate as you pass it over the ID, copying its access."

/obj/item/weapon/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered_name)
		//Stop giving the players unsanitized unputs! You are giving ways for players to intentionally crash clients! -Nodrak
		var t = reject_bad_name(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name))
		if(!t) //Same as mob/new_player/prefrences.dm
			alert("Invalid name.")
			return
		src.registered_name = t

		var u = copytext(sanitize(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Agent")),1,MAX_MESSAGE_LEN)
		if(!u)
			alert("Invalid assignment.")
			src.registered_name = ""
			return
		src.assignment = u
		src.name = "[src.registered_name]'s ID Card ([src.assignment])"
		user << "\blue You successfully forge the ID card."
		registered_user = user
	else if(!registered_user || registered_user == user)

		if(!registered_user) registered_user = user  //

		switch(alert("Would you like to display the ID, or retitle it?","Choose.","Rename","Show"))
			if("Rename")
				var t = copytext(sanitize(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name)),1,26)
				if(!t || t == "Unknown" || t == "floor" || t == "wall" || t == "r-wall") //Same as mob/new_player/prefrences.dm
					alert("Invalid name.")
					return
				src.registered_name = t

				var u = copytext(sanitize(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")),1,MAX_MESSAGE_LEN)
				if(!u)
					alert("Invalid assignment.")
					return
				src.assignment = u
				src.name = "[src.registered_name]'s ID Card ([src.assignment])"
				user << "\blue You successfully forge the ID card."
				return
			if("Show")
				..()
	else
		..()



/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate, access_external_airlocks)

/obj/item/weapon/card/id/captains_spare
	name = "Captain's spare identification card"
	desc = "The spare ID of the Grand Leader himself!"
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"
	New()

		var/datum/job/captain/J = new/datum/job/captain
		access = J.get_access()
		secondary_account_numbers = get_secondary_account_numbers(access)

		..()



/obj/item/weapon/card/id/centcom
	name = "\improper Central Command identification card"
	desc = "A highly-polished card with a NanoTrasen logo imprinted onto it and red trim. You nearly tremble at the thought of the power in that card."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"
	New()
		access = get_all_centcom_access()
		..()
