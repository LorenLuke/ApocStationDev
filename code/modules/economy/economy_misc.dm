
#define RIOTS 1
#define WILD_ANIMAL_ATTACK 2
#define INDUSTRIAL_ACCIDENT 3
#define BIOHAZARD_OUTBREAK 4
#define WARSHIPS_ARRIVE 5
#define PIRATES 6
#define CORPORATE_ATTACK 7
#define ALIEN_RAIDERS 8
#define AI_LIBERATION 9
#define MOURNING 10
#define CULT_CELL_REVEALED 11
#define SECURITY_BREACH 12
#define ANIMAL_RIGHTS_RAID 13
#define FESTIVAL 14

#define RESEARCH_BREAKTHROUGH 15
#define BARGAINS 16
#define SONG_DEBUT 17
#define MOVIE_RELEASE 18
#define BIG_GAME_HUNTERS 19
#define ELECTION 20
#define GOSSIP 21
#define TOURISM 22
#define CELEBRITY_DEATH 23
#define RESIGNATION 24

#define DEFAULT 1

#define ADMINISTRATIVE 2
#define CLOTHING 3
#define SECURITY 4
#define SPECIAL_SECURITY 5

#define FOOD 6
#define ANIMALS 7

#define MINERALS 8

#define EMERGENCY 9
#define GAS 10
#define MAINTENANCE 11
#define ELECTRICAL 12
#define ROBOTICS 13
#define BIOMEDICAL 14

#define GEAR_EVA 15

//---- The following corporations are friendly with NanoTrasen and loosely enable trade and travel:
//Corporation NanoTrasen - Generalised / high tech research and plasma exploitation.
//Corporation Vessel Contracting - Ship and station construction, materials research.
//Corporation Osiris Atmospherics - Atmospherics machinery construction and chemical research.
//Corporation Second Red Cross Society - 26th century Red Cross reborn as a dominating economic force in biomedical science (research and materials).
//Corporation Blue Industries - High tech and high energy research, in particular into the mysteries of bluespace manipulation and power generation.
//Corporation Kusanagi Robotics - Founded by robotics legend Kaito Kusanagi in the 2070s, they have been on the forefront of mechanical augmentation and robotics development ever since.
//Corporation Free traders - Not so much a corporation as a loose coalition of spacers, Free Traders are a roving band of smugglers, traders and fringe elements following a rigid (if informal) code of loyalty and honour. Mistrusted by most corporations, they are tolerated because of their uncanny ability to smell out a profit.

//---- Descriptions of destination types
//Space stations can be purpose built for a number of different things, but generally require regular shipments of essential supplies.
//Corvettes are small, fast warships generally assigned to border patrol or chasing down smugglers.
//Battleships are large, heavy cruisers designed for slugging it out with other heavies or razing planets.
//Yachts are fast civilian craft, often used for pleasure or smuggling.
//Destroyers are medium sized vessels, often used for escorting larger ships but able to go toe-to-toe with them if need be.
//Frigates are medium sized vessels, often used for escorting larger ships. They will rapidly find themselves outclassed if forced to face heavy warships head on.

var/global/current_date_string

var/global/datum/money_account/vendor_account
var/global/datum/money_account/station_account
var/global/list/datum/money_account/department_accounts = list()
var/global/num_financial_terminals = 1
var/global/next_account_number = 0
var/global/list/all_money_accounts = list()
var/global/list/all_money_salaries = list()
var/global/economy_init = 0

var/global/payout_interval = 900
var/global/payday_time = 0
var/global/payday_eta = 0
var/global/reduction_proportion = 0.8
var/global/pay_reduced = 0
var/global/payday_setup = 0
var/global/list/account_list
var/global/list/salary_list



/proc/setup_economy()
	if(economy_init)
		return 2

	var/datum/feed_channel/newChannel = new /datum/feed_channel
	newChannel.channel_name = "Tau Ceti Daily"
	newChannel.author = "CentComm Minister of Information"
	newChannel.locked = 1
	newChannel.is_admin_channel = 1
	news_network.network_channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "The Gibson Gazette"
	newChannel.author = "Editor Mike Hammers"
	newChannel.locked = 1
	newChannel.is_admin_channel = 1
	news_network.network_channels += newChannel

	for(var/loc_type in typesof(/datum/trade_destination) - /datum/trade_destination)
		var/datum/trade_destination/D = new loc_type
		weighted_randomevent_locations[D] = D.viable_random_events.len
		weighted_mundaneevent_locations[D] = D.viable_mundane_events.len

	create_station_account()

	for(var/department in station_departments)
		create_department_account(department)
	create_department_account("Vendor")
	vendor_account = department_accounts["Vendor"]

	current_date_string = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], 2557"

	economy_init = 1
	return 1

/proc/create_station_account()
	if(!station_account)
		next_account_number = rand(111111, 999999)

		station_account = new()
		station_account.owner_name = "[station_name()] Station Account"
		station_account.account_number = rand(111111, 999999)
		station_account.remote_access_pin = rand(1111, 111111)
		station_account.money = 750000
		station_account.security_level = 0

		//create an entry in the account transaction log for when it was created
		var/datum/transaction/T = new()
		T.target_name = station_account.owner_name
		T.purpose = "Account creation"
		T.amount = 750000
		T.date = "2nd April, 2555"
		T.time = "11:24"
		T.source_terminal = "Biesel GalaxyNet Terminal #277"

		//add the account
		station_account.transaction_log.Add(T)
		all_money_accounts.Add(station_account)

/proc/create_department_account(department)
	next_account_number = rand(111111, 999999)
	var/datum/money_account/department_account = new()
	department_account.owner_name = "[department] Account"
	department_account.account_number = rand(111111, 999999)
	department_account.remote_access_pin = rand(1111, 111111)
//	var/index = 0
//	index= station_departments.Find(department)
//	department_account.money = station_department_start_pay[index]
//	department_account.hour_pay = station_department_hour_pay[index]
	department_account.money = 25000
	department_account.hour_pay = 0
	department_account.security_level = 0


	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = department_account.owner_name
	T.purpose = "Account creation"
	T.amount = department_account.money
	T.date = "2nd April, 2555"
	T.time = "11:24"
	T.source_terminal = "Biesel GalaxyNet Terminal #277"

	//add the account
	department_account.transaction_log.Add(T)
	all_money_accounts.Add(department_account)

	department_accounts[department] = department_account

proc/payday_start()
	captain_announce("NanoTrasen automated quarter-hourly payday system initiated, your next paycheck will be in [round(payout_interval/60)] minutes.")
	if (!payday_setup)
		payday_setup = 1
		spawn(10) payday_load()

proc/payday_load()
	payday_time = (world.timeofday + (payout_interval*10))
	account_list = list()
	salary_list= list()
	var/list/tempaccounts = new()
	var/list/tempsalaries = new()
	for(var/i=1, i<=all_money_accounts.len, i++)
		var/datum/money_account/tempaccount = all_money_accounts[i]
		var/tempsalary = tempaccount.hour_pay
		tempaccounts += tempaccount
		tempsalaries += tempsalary
	account_list = tempaccounts
	salary_list = tempsalaries
	payday_process()

proc/payday_process()
	var/ticksleft = (payday_time - world.timeofday)
	payday_eta = "[num2text(round(ticksleft / 600))]:[(round((ticksleft % 600)/10)<10)? "0" : ""][num2text(round((ticksleft % 600)/10))]"
	if(ticksleft>(payout_interval*10))
		ticksleft = (payout_interval*10)
	if(ticksleft > 0)
		spawn(10)
			payday_process()
	else
		payday_payout()
		payday_load()

proc/payday_payout()
	if (pay_reduced == 0)
		captain_announce("Your regular quarter-hour salaries have been paid out, your next paycheck will be in [round(payout_interval/60)] minutes. Please check your bank accounts to verify that you have received your funds.")
	else
		captain_announce("Your regular quarter-hour salaries have been paid out, at a reduced rate of [round(100*(reduction_proportion ** pay_reduced))] percent due to your incompetence. Your next paycheck will be in [round(payout_interval/60)] minutes. Please check your bank accounts to verify that you have received your funds.")
		pay_reduced = 0
	var/proportion = payout_interval/3600
	var/datum/money_account/test_account
	var/pay
	for (var/i = 1; i<=account_list.len, i++)
		test_account = account_list[i]
		pay = salary_list[i]
		var/amount = round(pay*proportion)
		if(!test_account.suspended)
			test_account.money += amount

proc/payday_reducepay()
	var/list/reduced_salary_list = new()
	for (var/i = 1; i<=account_list.len, i++)
		var/pay = salary_list[i]
		var/new_pay = pay * reduction_proportion
		reduced_salary_list += new_pay
	salary_list = reduced_salary_list
	pay_reduced += 1

