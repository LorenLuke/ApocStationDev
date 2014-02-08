
datum/zmachine/fusion_reaction/
	var/primary_reactant = ""
	var/secondary_reactant = "Proton"
	var/energy_production = 0
	var/list/products = list()
	var/list/power = list()

datum/zmachine/fusion_reaction/deuterium_deuterium
	primary_reactant = "Deuterium"
	secondary_reactant = "Deuterium"

//1 50%
	power = list(1.01, 3.02)
	products = list("Tritium"=1,"Proton"=1)
//2 50%
	products = list("Helium3"=1, "Neutron"=1)
	power = list(0.82, 2.45)

datum/zmachine/fusion_reaction/deuterium_tritium
	primary_reactant = "Deuterium"
	secondary_reactant = "Tritium"
	products = list("Helium4"=1,"Neutron"=1)
	power = list(3.5, 14.1)

datum/zmachine/fusion_reaction/deuterium_helium3
	primary_reactant = "Deuterium"
	secondary_reactant = "Helium3"
	products = list("Helium4"=1,"Proton"=1)
	power = list(3.6, 14.7)

datum/zmachine/fusion_reaction/deuterium_lithium6
	primary_reactant = "Deuterium"
	secondary_reactant = "Lithium6"
//1
	products = list("Helium4"=2)
	power = list(22.4)
//2
	products = list("Helium3"=1, "Helium4"=1, "Neutron"=1)
	power = list(22.4)
//3
	products = list("Lithium7"=1, "Proton" = 1)
	power = list(5)
//4
	products = list("Beryllium7"=1, "Proton" = 1)
	power = list(3.4)

datum/zmachine/fusion_reaction/tritium_helium3
	primary_reactant = "Tritium"
	secondary_reactant = "Helium3"
//1 57%
	products = list("Helium4"=1,"Proton"=1, "Neutron"=1)
	power = list(12.1)
//2 43%
	products = list("Helium4"=1, "Deuterium"=1)
	power = list(4.8,9.5)

datum/zmachine/fusion_reaction/tritium_tritium
	primary_reactant = "Tritium"
	secondary_reactant = "Tritium"
	products = list("Helium4"=1,"Neutron"=2)
	power = list(11.3)

datum/zmachine/fusion_reaction/helium3_helium3
	primary_reactant = "Helium3"
	secondary_reactant = "Helium3"
	products = list("Helium4"=1,"Proton"=2)
	power = list(12.9)

datum/zmachine/fusion_reaction/helium3_lithium6
	primary_reactant = "Helium3"
	secondary_reactant = "Lithium6"
	products = list("Helium4"=2, "Proton"=1)
	power = list(16.9)

datum/zmachine/fusion_reaction/helium3_neutron
	primary_reactant = "Helium3"
	secondary_reactant = "Neutron"
	products = list("Tritium"=2, "Proton"=1)
	power = list(0.8)

datum/zmachine/fusion_reaction/helium4_tritium
	primary_reactant = "Helium4"
	secondary_reactant = "Tritium"
	products = list("Lithium7"=1,"Proton"=1)
	power = list(2.4)

datum/zmachine/fusion_reaction/lithium6_proton
	primary_reactant = "Lithium6"
	secondary_reactant = "Proton"
//1
	products = list("Helium4"=1,"Helium3"=1)
	power = list(1.7, 2.3)

datum/zmachine/fusion_reaction/lithium6_neutron
	primary_reactant = "Lithium6"
	secondary_reactant = "Neutron"
//1
	products = list("Tritium"=1,"Helium4"=1)
	power = list(4.784)

datum/zmachine/fusion_reaction/lithium7_neutron
	primary_reactant = "Lithium7"
	secondary_reactant = "Neutron"
//1
	products = list("Tritium"=1, "Helium4"=1,"Neutron"=1)
	power = list(-2.467)

datum/zmachine/fusion_reaction/lithium7_proton
	primary_reactant = "Lithium7"
	secondary_reactant = "Proton"
//1
	products = list("Helium4"=2)
	power = list(0.01)
//2
	products = list("Lithium6"=1, "Deuterium"=1)
	power = list(0.01)

datum/zmachine/fusion_reaction/beryllium7_neutron
	primary_reactant = "beryllium7"
	secondary_reactant = "Neutron"
//1
	products = list("Helium4"=1,"Neutron"=1)
	power = list(0.23)

datum/zmachine/fusion_reaction/boron11_proton
	primary_reactant = "Boron11"
	secondary_reactant = "Proton"
	products = list("Helium4"=3)
	power = list(8.7)

