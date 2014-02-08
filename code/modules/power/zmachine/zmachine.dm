/*
////////////////////////////////////////////////
ZMachine:

Radial capacitor banks charge.
Capacitor banks fire
Xray's released
EMP released
Plasma compressed
Plasma heated
////////////////////////////////////////////////















*/

/obj/machinery/zmachine/fuel_compressor
	icon = 'code/modules/power/zmachine/zmachine.dmi'
	icon_state = "fuel_compressor"
	name = "Fuel Compressor"
	var/list/new_assembly_quantities = list("Deuterium" = 150,"Tritium" = 150,"Rodinium-6" = 0,"Stravium-7" = 0, "Pergium" = 0, "Dilithium" = 0)
	var/compressed_matter = 0
	anchored = 1
	layer = 2.9

	var/opened = 1 //0=closed, 1=opened
	var/locked = 0
	var/has_electronics = 0 // 0 - none, bit 1 - circuitboard, bit 2 - wires


/obj/machinery/power/capacitor
	name = "Marx Generator Capacitor Bank"
	icon = 'code/modules/power/zmachine/zmachine.dmi'
	icon_state = "capacitor0"
	var/power_stored = 0
	var/max_power_storage = 50000



/obj/machinery/power/fuel_pellet
	name = "Fuel Pellet"
	desc = "A tiny fuel pellet for creating fusion, housed in a hohlraum"
	icon = 'code/modules/power/zmachine/zmachine.dmi'
	icon_state = "fuel_pellet"
	var/list/fuel_quantities
	layer = 3.1

	New()
		fuel_quantities = list()


