var autostart = func() {
	setprop("/controls/electric/battery-switch", 1);
	setprop("/controls/engines/engine[0]/magnetos", 3);
	setprop("/controls/engines/engine[0]/cutoff", 0);
	setprop("/controls/engines/engine[0]/starter", 1);
	setprop("/controls/engines/engine[0]/condition", 1);
	t = maketimer(5, func() {setprop("/controls/engines/engine[0]/starter", 0); });
	t.simulatedTime = 1;
	t.singleShot = 1;
	t.start();
}
