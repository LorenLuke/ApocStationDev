/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/infiltraitors = list()

/datum/game_mode/infiltraitor
	name = "Sleeper Agent"
	config_tag = "Sleeper Agent"
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "AI", "Clown", "Mime")//AI", Currently out of the list as malf does not work for shit
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4


	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/agents_possible = 5 //hard limit on traitors if scaling is turned off
	var/const/agent_scaling_coeff = 4.0 //how much does the amount of players get divided by to determine traitors


/datum/game_mode/infiltraitor/announce()
	world << "<B>The current game mode is - InfilTraitor!</B>"
	world << "<B>There is at least one syndicate sleeper agent on the station, with intent to destroy it. Do not let them succeed!</B>"

/datum/game_mode/infiltraitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_agents = get_players_for_role(BE_OPERATIVE)

	if(!possible_agents.len)
		return 0

	var/num_agents = 1

	if(config.traitor_scaling)
		num_agents = max(1, round((num_players())/(agent_scaling_coeff)))
	else
		num_agents = max(1, min(num_players(), agents_possible))

	for(var/datum/mind/player in possible_agents)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_agents -= player

	for(var/j = 0, j < num_agents, j++)
		if (!possible_agents.len)
			break
		var/datum/mind/infiltraitor = pick(possible_agents)
		infiltraitors += infiltraitor
		infiltraitor.special_role = "agent"
		possible_agents.Remove(infiltraitor)

	if(!infiltraitors.len)
		return 0
	return 1


/datum/game_mode/proc/forge_infiltraitor_objectives(var/datum/mind/infiltraitor)
	var/datum/objective/infiltraitor/syndobj = new
	infiltraitor.owner = syndicate
	infiltraitor.objectives += syndobj

/datum/game_mode/proc/greet_inifiltraitor(var/datum/mind/infiltraitor)
	traitor.current << "<B><font size=3 color=red>You are the syndicate sleeper agent!</font></B>"
	var/obj_count = 1
	for(var/datum/objective/objective in infiltraitor.objectives)
		infiltraitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return
