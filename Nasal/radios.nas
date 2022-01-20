# Classes to handle COM/NAV/DME/ADF radios and displays and audio panel
# by TheEagle

var ComNav = {
	new: func(deviceNum, instrumentationNode) {
		var obj = {
			parents: [ComNav],
		};
				
		obj.root = {
			"com": instrumentationNode.getNode("comm[" ~ deviceNum ~ "]"),
			"nav": instrumentationNode.getNode("nav[" ~ deviceNum ~ "]")
		};
		
		obj.powered = {
			"com": obj.root["com"].getNode("power-btn"),
			"nav": obj.root["nav"].getNode("power-btn")
		};
		obj.volume = {
			"com": obj.root["com"].getNode("volume"),
			"nav": obj.root["nav"].getNode("volume")
		};
		obj.currentMemory = {
			"com": obj.root["com"].getNode("frequencies/current-memory"),
			"nav": obj.root["nav"].getNode("frequencies/current-memory")
		};
		obj.selected = {
			"com": obj.root["com"].getNode("frequencies/selected-mhz"),
			"nav": obj.root["nav"].getNode("frequencies/selected-mhz")
		};
		obj.memory = {
			"com": [],
			"nav": []
		};
		
		for (var i = 0; i < 3; i = i + 1) {
			append(obj.memory["com"], obj.root["com"].getNode("frequencies/memory[" ~ i ~ "]"));
		}
		for (var i = 0; i < 3; i = i + 1) {
			append(obj.memory["nav"], obj.root["nav"].getNode("frequencies/memory[" ~ i ~ "]"));
		}
		
		return obj;
	},
	
	memoryPressed: func(device, n) {
		if (n == me.currentMemory[device].getIntValue()) {
			me.memory[device][n - 1].setDoubleValue(me.selected[device].getDoubleValue());
		} else {
			me.selected[device].setDoubleValue(me.memory[device][n - 1].getDoubleValue());
		}
		me.currentMemory[device].setIntValue(n);
	},
	
	# cycle selected COM frequency's last two decimal places between 0 <-> 25 and 5 <-> 75
	cyclePressed: func() {
		var (mhz, khz) = split(".", me.selected["com"].getValue());
		var (hundreds, tenths, units) = [substr(khz, 0, 1), substr(khz, 1, 1), substr(khz, 2, 1)];
		if (num(tenths) == 0 or num(tenths) == 5) {
			tenths = tenths + 2;
			units = "5";
		} else {
			tenths = tenths - 2;
			units = "0";
		}
		khz = hundreds ~ tenths ~ units;
		me.selected["com"].setDoubleValue(mhz ~ "." ~ khz);
	},
	
	adjustComVolume: func() {
		if (me.volume["com"].getDoubleValue() == 0) {
			me.powered["com"].setBoolValue(0);
			me.powered["nav"].setBoolValue(0);
		} else {
			me.powered["com"].setBoolValue(1);
			me.powered["nav"].setBoolValue(1);
		}
	}
};

var comNav1 = ComNav.new(0, props.globals.getNode("/instrumentation"));
var comNav2 = ComNav.new(1, props.globals.getNode("/instrumentation"));

var ComNavFreqDisplay = {
	new: func(deviceNode, placement) {
		var obj = {
			parents: [ComNavFreqDisplay],
			_canvas: canvas.new({"size": [256, 80], "view": [256, 80]}),
			poweredNode: deviceNode.getNode("power-btn"),
			selectedMhzFmtNode: deviceNode.getNode("frequencies/selected-mhz-fmt"),
			placement: placement,
		};
		
		obj.init();
		return obj;
	},
	
	init: func() {
		me._canvas.addPlacement({"node": me.placement});
		
		me.display = me._canvas.createGroup();
		
		me.display.text = me.display.createChild("text")
						.setTranslation(248, 48)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(48)
						.setColor(1, 0.7, 0.7);
		
		setlistener(me.poweredNode, func me.update());
		setlistener(me.selectedMhzFmtNode, func me.update());
		
		me.update();
	},
	
	update: func() {
		if (me.poweredNode.getBoolValue()) {
			me.display.text.show();
		} else {
			me.display.text.hide();
		}
		
		# don't show the last decimal place
		var shortMhz = substr(me.selectedMhzFmtNode.getValue(), 0, 6);
		# and the dot
		me.display.text.setText(string.replace(shortMhz, ".", " "));
	},
};

var com1FreqDisplay = ComNavFreqDisplay.new(props.globals.getNode("/instrumentation/comm[0]"), "COM1FreqDisplay");
var com2FreqDisplay = ComNavFreqDisplay.new(props.globals.getNode("/instrumentation/comm[1]"), "COM2FreqDisplay");
var nav1FreqDisplay = ComNavFreqDisplay.new(props.globals.getNode("/instrumentation/nav[0]"), "NAV1FreqDisplay");
var nav2FreqDisplay = ComNavFreqDisplay.new(props.globals.getNode("/instrumentation/nav[1]"), "NAV2FreqDisplay");

var AudioControl = {
	new: func(instrumentationNode) {
		var obj = {
			parents: [AudioControl],
		};
				
		obj.root = instrumentationNode.getNode("audio-control", 1);
		obj.markerBeaconBrightness = obj.root.getNode("marker-beacon-brightness", );
		
		obj.markerBeacon = instrumentationNode.getNode("marker-beacon");
		obj.markerBeaconOuterBrightness = obj.markerBeacon.getNode("outer-brightness", 1);
		obj.markerBeaconMiddleBrightness = obj.markerBeacon.getNode("middle-brightness", 1);
		obj.markerBeaconInnerBrightness = obj.markerBeacon.getNode("inner-brightness", 1);
		obj.markerBeaconTest = obj.markerBeacon.getNode("test", 1);
		
		return obj;
	},
	adjustMarkerBeaconBrightness: func() {
		pos = me.markerBeaconBrightness.getDoubleValue();
		if (pos == 0) { # pos ==  DAY
			me.markerBeaconOuterBrightness.setIntValue(1);
			me.markerBeaconMiddleBrightness.setIntValue(1);
			me.markerBeaconInnerBrightness.setIntValue(1);
			me.markerBeaconTest.setBoolValue(0);
		} elsif (pos == 1) { # pos == NITE
			me.markerBeaconOuterBrightness.setIntValue(0.5);
			me.markerBeaconMiddleBrightness.setIntValue(0.5);
			me.markerBeaconInnerBrightness.setIntValue(0.5);
			me.markerBeaconTest.setBoolValue(0);
		} else { # pos == TEST
			me.markerBeaconTest.setBoolValue(1);
		}
	}
};

var audioControl = AudioControl.new(props.globals.getNode("/instrumentation"))
