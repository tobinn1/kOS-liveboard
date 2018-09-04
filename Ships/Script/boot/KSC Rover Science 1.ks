core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
clearscreen.
brakes on.

//POIs stolen from https://github.com/tunamako/KSP-kOS-Experiments/blob/master/Ships/Script/old%20save/stuco_kscRover.ks#L47-L58
local POIs is list(
	latlng(-0.0940418247485912, 285.33598068904),//admin
	latlng(-0.107485797711095, 285.348413497517),//rnd
	latlng(-0.0844935269671136, -74.6531615639102),//astronaut complex (missed)
	latlng(-0.0811306433569743, 285.365420404629),//SPH
	latlng(-0.079855831964012, 285.383680499618),//mission control
	latlng(-0.0923318464212637, 285.383400392511),//VAB
	latlng(-0.096892580158935, 285.396274742116),//crawlerway
	latlng(-0.119820993641748, 285.396970277844),//tracking station
	latlng(-0.115673088061891, 285.412015248504),//KSC general
	latlng(-0.0972413736714619, 285.44238127157)//launchpad
).

function driveTo {
	parameter POI.

	print "Driving to POI...".
	brakes off.
	print "Steering Lock and Throttle Lock active!".
	lock wheelsteering to POI.

	until POI:distance < 5 {

		if ship:groundspeed < 3.5 {

			lock wheelthrottle to 1.
		}else{

			unlock wheelthrottle.
		}

		wait 0.
	}

	print "Arrived at POI.".
	unlock wheelsteering.
	unlock wheelthrottle.
	print "Steering Lock and Throttle Lock deactivated.".
	brakes on.
	wait 3.
	return.
}

function doScience {
	parameter experiment.

	print "Attempting experiment.".
	if experiment:inoperable {
		print "Experiment inoperable. Continuing.".
		return.
	}
	experiment:deploy().
	set timeout to 5. 
	until timeout = 0 or experiment:hasdata {
		wait 1.
		set timeout to timeout - 1.
	}
	print "Experiment attempted.".
	return.
}

function transmitScience {
	parameter experiment.

	print "Transmitting any results.".
	if not experiment:hasdata {
		print "Transmit failed: No data recorded. Continuing.".
		return.
	}
	experiment:transmit().
	wait until not experiment:hasdata.
	print "Data transmitted successfully!".
	return.
}

function resetScience {
	parameter experiment.

	print "Attempting to reset experiment.".
	if not experiment:rerunnable {
		print "Experiment is not rerunnable. Continuing.".
		return.
	}
	experiment:reset().
	wait 0.
	if experiment:deployed {
		experiment:toggle().
	}
	wait 0.
	print "Experiment has been reset.".
	return.
}

function batchScience {
	parameter experiments.

	for experiment in experiments {

		doScience(experiment).
		transmitScience(experiment).
		resetScience(experiment).
	}
	wait 5.
	return.
}

//find modules with experiments
set experiments to list().
set experimentModuleNames to list( // https://ksp-kos.github.io/KOS/addons/OrbitalScience.html#orbitalscience
	"ModuleScienceExperiment",
	"dmmodulescienceanimate"
).
for experimentModuleName in experimentModuleNames {
	set experimentModules to ship:modulesNamed(experimentModuleName).
	for experimentModule in experimentModules {
		experiments:add(experimentModule).
	}
}

batchScience(experiments).

for POI in POIs {

	driveTo(POI).
	batchScience(experiments).
}
//recover rover