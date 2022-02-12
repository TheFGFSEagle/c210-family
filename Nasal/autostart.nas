var autostartP210N = func {
	setprop("/controls/engines/engine/magnetos", 3);
	var tank = getprop("/consumables/fuel/tank[0]/level-lbs") > getprop("/consumables/fuel/tank[1]/level-lbs") ? -1 : 1;
	setprop("/controls/fuel/selected-tank", tank);
	setprop("/controls/engines/engine/mixture", 1);
	setprop("/controls/engines/engine/starter", 1);
	
	t = maketimer(2, func() {
		setprop("/controls/engines/engine/starter", 0);
		setprop("/controls/engines/engine/throttle", 0);
	});
	t.simulatedTime = 1;
	t.singleShot = 1;
	t.start();
}

var autostartSilverEagle = func {
	# TODO: Implement proper fuel system for the silver eagle and add fuel selector BOTH position
	setprop("/controls/fuel/selected-tank", 1);
	setprop("/controls/electric/engine/generator", 1);
	setprop("/controls/engines/engine/cutoff", 0);
	setprop("/controls/engines/engine/starter", 1);
}

var autostart = func() {
	setprop("/controls/electric/battery-switch", 1);
	setprop("/controls/engines/engine/propeller-pitch", 1);
	setprop("/controls/engines/engine/cowl-flaps-norm", 1);
	setprop("/controls/engines/engine/fuel-pump", 1);
	setprop("/controls/engines/engine/throttle", 0.25);
	
	variant = getprop("/sim/model/variant");
	if (variant == "p210n") {
		autostartP210N();
	} elsif (variant == "silver-eagle") {
		autostartSilverEagle();
	}
}
