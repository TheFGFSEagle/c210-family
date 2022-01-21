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
		obj.sourceNode = obj.rootNode.getNode("source");
		obj.sourceKnobNode = obj.rootNode.getNode("source-switch", 1);
		obj.frequencyNode = obj.rootNode.getNode("hold-frequency-mhz", 1);
		obj.modeNode = obj.rootNode.getNode("mode", 1);
		obj.poweredNode = obj.rootNode.getNode("power-btn");
		obj.testNode = obj.rootNode.getNode("test", 1);
		obj.distanceNode = obj.rootNode.getNode("distance-nm", 1);
		obj.ttsNode = obj.rootNode.getNode("tts-min");
		obj.speedNode = obj.rootNode.getNode("groundspeed-kt", 1);
		
		obj.updateTimer = maketimer(1, func obj.update());
		obj.updateTimer.simulatedTime = 1;
		obj.updateTimer.singleShot = 0;
		obj.updateTimer.start();
		return obj;
	},
	
	sourceChanged: func() {
		newSource = me.sources[me.sourceKnobNode.getValue()];
		if (source == "NAV1") {
			me.sourceNode.setValue(me.nav1Node.getNode("frequencies/selected-mhz").getPath())
		} elsif (source == "NAV2" or source == "RNAV") {
			me.sourceNode.setValue(me.nav2Node.getNode("frequencies/selected-mhz").getPath())			
		} elsif (source == "HOLD") {
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
}

var dme = DME.new(props.globals.getNode("/instrumentation"));


var DMEDisplays = {
	new: func(instrumentationNode) {
		var obj = {
			parents: [DMEDistanceDisplay],
			_distanceCanvas: canvas.new({"size": [224, 64], "view": [224, 64]}),
			_speedTimeCanvas: canvas.new({"size": [160, 64], "view": [160, 64]}),
			rootNode: instrumentationNode.getNode("dme"),
			rnavNode: instrumentationNode.getNode("rnav"),
			placement: placement,
			displayModes: ["TTS", "GS"],
			sources: ["NAV2", "HOLD", "NAV1", "RNAV"],
		};
		
		obj.poweredNode = obj.rootNode.getNode("power-btn");
		obj.distanceNode = obj.rootNode.getNode("distance-nm", 1);
		obj.speedNode = obj.rootNode.getNode("groundspeed-kt", 1);
		obj.ttsNode = obj.rootNode.getNode("tts-min");
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
		
		me.distanceDisplay = me._canvas.createGroup();
		me.speedTimeDisplay = me._canvas.createGroup();
		
		me.distanceDisplay.text = me.display.createChild("text")
						.setTranslation(200, 32)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(60)
						.setColor(1, 0.7, 0.7);
						
		me.distanceDisplay.rnavAnnun = me.display.createChild("text")
						.setTranslation(230, 12)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("RN");
						
		me.distanceDisplay.dmeAnnun = me.display.createChild("text")
						.setTranslation(230, 52)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("NM");
		
		me.speedTimeDisplay.text = me.display.createChild("text")
						.setTranslation(120, 32)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7);
		
		me.speedTimeDisplay.ktsAnnun = me.display.createChild("text")
						.setTranslation(150, 12)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("KTS");
		
		me.speedTimeDisplay.minAnnun = me.display.createChild("text")
						.setTranslation(150, 52)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(15)
						.setColor(1, 0.7, 0.7)
						.setText("MIN");
		
		setlistener(me.poweredNode, func me.update());
		setlistener(me.distanceNode, func me.update());
		setlistener(me.speedNode, func me.update());
		setlistener(me.ttsNode, func me.update());
		setlistener(me.sourceKnobNode, func me.update());
		setlistener(me.modeNode, func me.update());
		setlistener(me.displayNode, func me.update());
		
		me.update();
	},
	
	update: func() {
		if (!me.poweredNode.getBoolValue()) {
			me.distanceDisplay.text.hide();
			me.distanceDisplay.rnavAnnun.hide();
			me.distanceDisplay.dmeAnnun.hide();
			me.speedTimeDisplay.text.hide();
			me.speedTimeDisplay.ktsAnnun.hide();
			me.speedTimeDisplay.minAnnun.hide();
		} else {
			if (me.displayModes[me.displayNode.getValue()] == "TTS") {
				me.speedTimeDisplay.minAnnun.show();
				me.speedTimeDisplay.ktsAnnun.hide();
				me.speedTimeDisplay.text.setText(me.ttsNode.getValue());
			} else {
				me.speedTimeDisplay.minAnnun.hide();
				me.speedTimeDisplay.ktsAnnun.show();
				me.speedTimeDisplay.text.setText(me.speedNode.getValue());
			}
			
			source = me.sources[me.sourceKnobNode.getValue()];
			if (source == "RNAV") {
				me.distanceDisplay.rnavAnnun.show();
			} else {
				me.distanceDisplay.rnavAnnun.hide();
			}
			me.distanceDisplay.dmeAnnun.show();
			me.distanceDisplay.text.setText(me.distanceNode.getValue());
		}
	},
};

var dmeDisplays = DMEDisplays.new(props.globals.getNode("/instrumentation"));
