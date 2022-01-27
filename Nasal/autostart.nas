var autostart = func() {
	setprop("/controls/electric/battery-switch", 1);
	setprop("/controls/engines/engine/magnetos", 3);
	setprop("/controls/engines/engine/propeller-pitch", 1);
	setprop("/controls/engines/engine/mixture", 1);
	setprop("/controls/engines/engine/cowl-flaps-norm", 1);
	var tank = getprop("/consumables/fuel/tank[0]/level-lbs") > getprop("/consumables/fuel/tank[1]/level-lbs") ? -1 : 1;
	setprop("/controls/fuel/selected-tank", tank);
	setprop("/controls/engines/engine/fuel-pump", 1);
	setprop("/controls/engines/engine/throttle", 0.25);
	setprop("/controls/engines/engine/starter", 1);
	t = maketimer(2, func() {
		setprop("/controls/engines/engine/starter", 0);
		setprop("/controls/engines/engine/fuel-pump", 0);
		setprop("/controls/engines/engine/throttle", 0);
	});
	t.simulatedTime = 1;
	t.singleShot = 1;
	t.start();
}
