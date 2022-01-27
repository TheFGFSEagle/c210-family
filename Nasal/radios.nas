# Nasal implementations of the Cessna 400 COM/NAV, DME, RNAV and ADF radios and their displays, the Cessna 400 audio panel and the Cessna 400 transponder
# by TheEagle

var instrumentationNode = props.globals.getNode("/instrumentation");

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

var comNav1 = ComNav.new(0, instrumentationNode);
var comNav2 = ComNav.new(1, instrumentationNode);

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

var audioControl = AudioControl.new(instrumentationNode);


var DME = {
	new: func(instrumentationNode) {
		var obj = {
			parents: [DME],
			sources: ["NAV2", "HOLD", "NAV1", "RNAV"],
			modes: ["OFF", "ON", "TEST"],
		};
		
		obj.rootNode = instrumentationNode.getNode("dme");
		obj.nav1Node = instrumentationNode.getNode("nav");
		obj.nav2Node = instrumentationNode.getNode("nav[1]");
		obj.rnavNode = instrumentationNode.getNode("rnav", 1);
		obj.sourceNode = obj.rootNode.getNode("frequencies/source");
		obj.sourceKnobNode = obj.rootNode.getNode("source-knob", 1);
		obj.frequencyNode = obj.rootNode.getNode("frequencies/hold-mhz", 1);
		obj.modeNode = obj.rootNode.getNode("mode", 1);
		obj.poweredNode = obj.rootNode.getNode("power-btn");
		obj.testNode = obj.rootNode.getNode("test", 1);
		obj.distanceNode = obj.rootNode.getNode("indicated-distance-nm", 1);
		obj.timeNode = obj.rootNode.getNode("indicated-time-min");
		obj.speedNode = obj.rootNode.getNode("indicated-groundspeed-kt", 1);
		
		return obj;
	},
	
	sourceChanged: func() {
		newSource = me.sources[me.sourceKnobNode.getValue()];
		if (newSource == "NAV1") {
			me.sourceNode.setValue(me.nav1Node.getNode("frequencies/selected-mhz").getPath());
		} elsif (newSource == "NAV2" or newSource == "RNAV") {
			me.sourceNode.setValue(me.nav2Node.getNode("frequencies/selected-mhz").getPath());			
		} elsif (newSource == "HOLD") {
			me.frequencyNode.setValue(props.globals.getNode(me.sourceNode.getValue()).getValue());
			me.sourceNode.setValue(me.frequencyNode.getPath());
		}
	},
	
	modeChanged: func() {
		mode = me.modes[me.modeNode.getValue()];
		if (mode == "OFF") {
			me.poweredNode.setBoolValue(0);
		} elsif (mode == "ON") {
			me.poweredNode.setBoolValue(1);
			me.testNode.setBoolValue(0);
		} else {
			me.testNode.setBoolValue(1);
		}
	},
};

var dme = DME.new(instrumentationNode);


var DMEDisplays = {
	new: func(instrumentationNode) {
		var obj = {
			parents: [DMEDisplays],
			_distanceCanvas: canvas.new({"size": [224, 64], "view": [224, 64], "name": "DMEDistanceDisplay"}),
			_speedTimeCanvas: canvas.new({"size": [160, 64], "view": [160, 64], "name": "DMESpeedTimeDisplay"}),
			rootNode: instrumentationNode.getNode("dme"),
			rnavNode: instrumentationNode.getNode("rnav"),
			displayModes: ["TTS", "GS"],
			sources: ["NAV2", "HOLD", "NAV1", "RNAV"],
		};
		
		obj.poweredNode = obj.rootNode.getNode("power-btn", 1);
		obj.distanceNode = obj.rootNode.getNode("KDI572-574/nm", 1);
		obj.speedNode = obj.rootNode.getNode("KDI572-574/kt", 1);
		obj.timeNode = obj.rootNode.getNode("KDI572-574/min", 1);
		obj.sourceKnobNode = obj.rootNode.getNode("source-knob", 1);
		obj.modeNode = obj.rootNode.getNode("mode", 1);
		obj.displayNode = obj.rootNode.getNode("display-mode", 1);
		obj.testNode = obj.rootNode.getNode("test", 1);
		
		obj.init();
		return obj;
	},
	
	init: func() {
		me._distanceCanvas.addPlacement({"node": "DMEDistanceDisplay"});
		me._speedTimeCanvas.addPlacement({"node": "DMESpeedTimeDisplay"});
		
		me.distanceDisplay = me._distanceCanvas.createGroup();
		me.speedTimeDisplay = me._speedTimeCanvas.createGroup();
		
		me.distanceDisplay.text = me.distanceDisplay.createChild("text")
						.setTranslation(170, 32)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(40)
						.setColor(1, 0.7, 0.7);
						
		me.distanceDisplay.rnavAnnun = me.distanceDisplay.createChild("text")
						.setTranslation(205, 20)
						.setAlignment("right-center")
						.setFont("LiberationFonts/LiberationMono-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("RN");
						
		me.distanceDisplay.dmeAnnun = me.distanceDisplay.createChild("text")
						.setTranslation(205, 44)
						.setAlignment("right-center")
						.setFont("LiberationFonts/LiberationMono-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("NM");
		
		
		me.speedTimeDisplay.text = me.speedTimeDisplay.createChild("text")
						.setTranslation(115, 32)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(40)
						.setColor(1, 0.7, 0.7);
		
		me.speedTimeDisplay.ktsAnnun = me.speedTimeDisplay.createChild("text")
						.setTranslation(155, 20)
						.setAlignment("right-center")
						.setFont("LiberationFonts/LiberationMono-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("KTS");
		
		me.speedTimeDisplay.minAnnun = me.speedTimeDisplay.createChild("text")
						.setTranslation(155, 44)
						.setAlignment("right-center")
						.setFont("LiberationFonts/LiberationMono-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("MIN");
		
		setlistener(me.poweredNode, func me.update());
		setlistener(me.distanceNode, func me.update());
		setlistener(me.speedNode, func me.update());
		setlistener(me.timeNode, func me.update());
		setlistener(me.sourceKnobNode, func me.update());
		setlistener(me.modeNode, func me.update());
		setlistener(me.displayNode, func me.update());
		
		me.update();
	},
	
	update: func() {
		if (!me.poweredNode.getBoolValue()) {
			# we have no power - don't display anything
			me.distanceDisplay.text.hide();
			me.distanceDisplay.rnavAnnun.hide();
			me.distanceDisplay.dmeAnnun.hide();
			me.speedTimeDisplay.text.hide();
			me.speedTimeDisplay.ktsAnnun.hide();
			me.speedTimeDisplay.minAnnun.hide();
		} elsif (me.testNode.getValue()) {
			# test mode - display all anunciators and numbers
			me.distanceDisplay.rnavAnnun.show();
			me.distanceDisplay.dmeAnnun.show();
			me.speedTimeDisplay.ktsAnnun.show();
			me.speedTimeDisplay.minAnnun.show();
			
			me.distanceDisplay.text.setText("000.0");
			me.distanceDisplay.text.show();
			me.speedTimeDisplay.text.setText("000.0");
			me.speedTimeDisplay.text.show();
		} else {
			# normal operation
			if (me.displayModes[me.displayNode.getValue() or 0] == "TTS") {
				me.speedTimeDisplay.minAnnun.show();
				me.speedTimeDisplay.ktsAnnun.hide();
				me.speedTimeDisplay.text.setText(me.timeNode.getValue());
			} else {
				me.speedTimeDisplay.minAnnun.hide();
				me.speedTimeDisplay.ktsAnnun.show();
				me.speedTimeDisplay.text.setText(me.speedNode.getValue());
			}
			me.speedTimeDisplay.text.show();
			
			source = me.sources[me.sourceKnobNode.getValue() or 0];
			if (source == "RNAV") {
				me.distanceDisplay.rnavAnnun.show();
			} else {
				me.distanceDisplay.rnavAnnun.hide();
			}
			me.distanceDisplay.dmeAnnun.show();
			me.distanceDisplay.text.setText(me.distanceNode.getValue());
			me.distanceDisplay.text.show();
		}
	},
};

var dmeDisplays = DMEDisplays.new(instrumentationNode);


# RNAV. Only setting of distance and bearing and transfer of those nto the waypoints is managed here
# VOR needle deflection etc. will be calculated by a property rules file because they need to be calculated very frequently
# as they are neededby the autopilot - running a Nasal loop at 120 Hz is not very resource-friendly.
var RNAV = {
	new: func(instrumentationNode) {
		var obj = {
			parents: [RNAV],
			rootNode: instrumentationNode.getNode("rnav"),
			# RNAV is coupled to the no. 2 NAV
			navNode: instrumentationNode.getNode("nav[1]"),
		};
		
		obj.selectedDistanceNode = obj.rootNode.getNode("selected-distance-nm", 1);
		obj.selectedDistanceHundredsNode = obj.rootNode.getNode("selected-distance-nm-hundreds", 1);
		obj.selectedDistanceTenthsNode = obj.rootNode.getNode("selected-distance-nm-tenths", 1);
		obj.selectedDistanceUnitsNode = obj.rootNode.getNode("selected-distance-nm-units", 1);
		obj.selectedDistanceDecimalsNode = obj.rootNode.getNode("selected-distance-nm-decimals", 1);
		
		obj.selectedBearingNode = obj.rootNode.getNode("selected-bearing-deg", 1);
		obj.selectedBearingHundredsNode = obj.rootNode.getNode("selected-bearing-deg-hundreds", 1);
		obj.selectedBearingTenthsNode = obj.rootNode.getNode("selected-bearing-deg-tenths", 1);
		obj.selectedBearingUnitsNode = obj.rootNode.getNode("selected-bearing-deg-units", 1);
		obj.selectedBearingDecimalsNode = obj.rootNode.getNode("selected-bearing-deg-decimals", 1);
		
		obj.waypoint1Node = obj.rootNode.getNode("waypoint[0]", 1);
		obj.waypoint1BearingNode = obj.waypoint1Node.getNode("bearing-deg");
		obj.waypoint1DistanceNode = obj.waypoint1Node.getNode("distance-nm");
		obj.waypoint2Node = obj.rootNode.getNode("waypoint[1]", 1);
		obj.waypoint2BearingNode = obj.waypoint2Node.getNode("bearing-deg");
		obj.waypoint2DistanceNode = obj.waypoint2Node.getNode("distance-nm");
		
		obj.displayWaypointNode = obj.rootNode.getNode("display-waypoint", 1);
		obj.flyWaypointNode = obj.rootNode.getNode("fly-waypoint", 1);
		
		return obj;
	},
	
	updateBearing: func {
		hundreds = me.selectedBearingHundredsNode.getValue();
		tenths = me.selectedBearingTenthsNode.getValue();
		units = me.selectedBearingUnitsNode.getValue();
		decimals = me.selectedBearingDecimalsNode.getValue();
		# limit bearing selection to 359.9 degrees
		if (hundreds == 3 and tenths > 5) {
			tenths = 5;
			me.selectedBearingTenthsNode.setIntValue(tenths);
		}
		me.selectedBearingNode.setDoubleValue(hundreds * 100 + tenths * 10 + units + decimals / 10);
	},
	
	updateDistance: func {
		hundreds = me.selectedDistanceHundredsNode.getValue();
		tenths = me.selectedDistanceTenthsNode.getValue();
		units = me.selectedDistanceUnitsNode.getValue();
		decimals = me.selectedDistanceDecimalsNode.getValue();
		if (hundreds == 2) {
			if (tenths > 0) {
				tenths = 0;
				me.selectedDistanceTenthsNode.setIntValue(tenths);
			}
			if (units > 0) {
				units = 0;
				me.selectedDistanceUnitsNode.setIntValue(units);
			}
			if (decimals > 0) {
				decimals = 0;
				me.selectedDistanceDecimalsNode.setIntValue(units);
			}
		}
		me.selectedDistanceNode.setDoubleValue(hundreds * 100 + tenths * 10 + units + decimals / 10);
	},
	
	transferPressed: func {
		displayWaypoint = me.displayWaypointNode.getValue();
		bearing = me.selectedBearingNode.getValue();
		distance = me.selectedDistanceNode.getValue();
		if (displayWaypoint == 1) {
			me.waypoint1BearingNode.setDoubleValue(bearing);
			me.waypoint1DistanceNode.setDoubleValue(distance);
		} elsif (displayWaypoint == 2) {
			me.waypoint2BearingNode.setDoubleValue(bearing);
			me.waypoint2DistanceNode.setDoubleValue(distance);
		}
	}
};

var rnav = RNAV.new(instrumentationNode);

var RNAVDisplay = {
	new: func(instrumentationNode, numberPath, placement) {
		var obj = {
			parents: [RNAVDisplay],
			_canvas: canvas.new({"size": [160, 80], "view": [160, 80]}),
			rootNode: instrumentationNode.getNode("rnav", 1),
			poweredNode: instrumentationNode.getNode("nav[1]/power-btn", 1),
			placement: placement,
		};
		
		obj.number1Node = obj.rootNode.getNode("waypoint[0]/" ~ numberPath, 1);
		obj.number2Node = obj.rootNode.getNode("waypoint[1]/" ~ numberPath, 1);
		obj.displayWaypointNode = obj.rootNode.getNode("display-waypoint");
		
		obj.init();
		return obj;
	},
	
	init: func() {
		me._canvas.addPlacement({"node": me.placement});
		
		me.display = me._canvas.createGroup();
		
		me.display.text = me.display.createChild("text")
						.setTranslation(160, 48)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(48)
						.setColor(1, 0.7, 0.7);
		
		setlistener(me.poweredNode, func me.update());
		setlistener(me.number1Node, func me.update());
		setlistener(me.number2Node, func me.update());
		setlistener(me.displayWaypointNode, func me.update());
		
		me.update();
	},
	
	update: func() {
		if (me.poweredNode.getBoolValue()) {
			me.display.text.show();
		} else {
			me.display.text.hide();
		}
		
		if (me.displayWaypointNode.getValue() == 1) {
			me.display.text.setText(sprintf("%3.1f", me.number1Node.getValue()));
		} else {
			me.display.text.setText(sprintf("%3.1f", me.number2Node.getValue()));
		}
	},
};

var RNAVBearingDisplay = RNAVDisplay.new(instrumentationNode, "bearing-deg", "RNAVBearingDisplay");
var RNAVDistanceDisplay = RNAVDisplay.new(instrumentationNode, "distance-nm", "RNAVDistanceDisplay");

