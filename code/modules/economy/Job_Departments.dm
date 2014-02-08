var/list/station_departments = list("Command", "Medical", "Engineering", "Science", "Security", "Cargo", "Civilian")
//var/list/station_department_start_pay = list(75000, 35000, 50000, 17500, 40000, 25000, 20000)
//var/list/station_department_hour_pay = list(20000, 10000, 15000, 3500, 0, 2500)

// The department the job belongs to.
/datum/job/var/department = null

// Whether this is a head position
/datum/job/var/head_position = 0

// Starting Pay
/datum/job/var/start_pay = 0

// Pay on Payday
/datum/job/var/hour_pay = 0

// Time between paydays
//15 minutes?

/datum/job/command/department = "Command"
/datum/job/command/start_pay = 75000
/datum/job/command/hour_pay = 20000

/datum/job/medical/department = "Medical"
/datum/job/medical/start_pay = 35000
/datum/job/medical/hour_pay = 10000

/datum/job/engineering/department = "Engineering"
/datum/job/engineering/start_pay = 50000
/datum/job/engineering/hour_pay = 15000

/datum/job/science/department = "Science"
/datum/job/science/start_pay = 17500
/datum/job/science/hour_pay = 5000

/datum/job/security/department = "Security"
/datum/job/security/start_pay = 30000
/datum/job/security/hour_pay = 3500

/datum/job/civilian/department = "Civilian"
/datum/job/civilian/start_pay = 40000
/datum/job/civilian/hour_pay = 2000

/datum/job/cargo/department = "Cargo"
/datum/job/cargo/start_pay = 25000
/datum/job/cargo/hour_pay = 0

/datum/job/captain/department = "Command"
/datum/job/captain/head_position = 1
/datum/job/captain/start_pay = 12000
/datum/job/captain/hour_pay = 2500

/datum/job/hop/department = "Civilian"
/datum/job/hop/head_position = 1
/datum/job/hop/start_pay = 9000
/datum/job/hop/hour_pay = 2000

/datum/job/assistant/department = "Civilian"
/datum/job/assistant/start_pay = 400
/datum/job/assistant/hour_pay = 40


/datum/job/bartender/department = "Civilian"
/datum/job/bartender/start_pay = 800
/datum/job/bartender/hour_pay = 120


/datum/job/chef/department = "Civilian"
/datum/job/chef/start_pay = 800
/datum/job/chef/hour_pay = 120


/datum/job/hydro/department = "Civilian"
/datum/job/hydro/start_pay = 600
/datum/job/hydro/hour_pay = 90


/datum/job/mining/department = "Civilian"
/datum/job/mining/start_pay = 1200
/datum/job/mining/hour_pay = 210


/datum/job/janitor/department = "Civilian"
/datum/job/janitor/start_pay = 500
/datum/job/janitor/hour_pay = 120


/datum/job/librarian/department = "Civilian"
/datum/job/librarian/start_pay = 500
/datum/job/librarian/hour_pay = 100


/datum/job/lawyer/department = "Civilian"
/datum/job/lawyer/start_pay = 2500
/datum/job/lawyer/hour_pay = 30


/datum/job/chaplain/department = "Civilian"
/datum/job/chaplain/start_pay = 100
/datum/job/chaplain/hour_pay = 10
//what man of God has need for the material things? :P -Luke


/datum/job/qm/department = "Cargo"
/datum/job/qm/head_position = 1
/datum/job/qm/start_pay = 6000
/datum/job/qm/hour_pay = 300


/datum/job/cargo_tech/department = "Cargo"
/datum/job/cargo_tech/start_pay = 1500
/datum/job/cargo_tech/hour_pay = 160


/datum/job/chief_engineer/department = "Engineering"
/datum/job/chief_engineer/head_position = 1
/datum/job/chief_engineer/start_pay = 4500
/datum/job/chief_engineer/hour_pay = 1400


/datum/job/engineer/department = "Engineering"
/datum/job/engineer/start_pay = 2500
/datum/job/engineer/hour_pay = 400


/datum/job/atmos/department = "Engineering"
/datum/job/atmos/start_pay = 2000
/datum/job/atmos/hour_pay = 350


/datum/job/cmo/department = "Medical"
/datum/job/cmo/head_position = 1
/datum/job/cmo/start_pay = 6500
/datum/job/cmo/hour_pay = 350


/datum/job/doctor/department = "Medical"
/datum/job/doctor/start_pay = 3000
/datum/job/doctor/hour_pay = 240


/datum/job/chemist/department = "Medical"
/datum/job/chemist/start_pay = 2500
/datum/job/chemist/hour_pay = 200


/datum/job/geneticist/department = "Medical"
/datum/job/geneticist/start_pay = 2000
/datum/job/geneticist/hour_pay = 180


/datum/job/psychiatrist/department = "Medical"
/datum/job/psychiatrist/start_pay = 3500
/datum/job/psychiatrist/hour_pay = 80


/datum/job/rd/department = "Science"
/datum/job/rd/head_position = 1
/datum/job/rd/start_pay = 7500
/datum/job/rd/hour_pay = 1400


/datum/job/scientist/department = "Science"
/datum/job/scientist/start_pay = 3500
/datum/job/scientist/hour_pay = 350


/datum/job/roboticist/department = "Science"
/datum/job/roboticist/start_pay = 3000
/datum/job/roboticist/hour_pay = 300


/datum/job/hos/department = "Security"
/datum/job/hos/head_position = 1
/datum/job/hos/start_pay = 4500
/datum/job/hos/hour_pay = 1800


/datum/job/warden/department = "Security"
/datum/job/warden/start_pay = 2750
/datum/job/warden/hour_pay = 575


/datum/job/detective/department = "Security"
/datum/job/detective/start_pay = 1250
/datum/job/detective/hour_pay = 450
//shit pay, relatively, but that's the life of a detective.

/datum/job/officer/department = "Security"
/datum/job/officer/start_pay = 2500
/datum/job/officer/hour_pay = 500

