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
			"com": obj.root["com"].getNode("powered"),
			"nav": obj.root["nav"].getNode("powered")
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
			"nav": obj.root["com"].getNode("frequencies/selected-mhz")
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
		n = n - 1;
		if (n == me.currentMemory[device].getIntValue()) {
			me.memory[device][n].setDoubleValue(me.selected[device].getDoubleValue());
		} else {
			me.selected[device].setDoubleValue(me.memory[device][n].getDoubleValue());
		}
		me.currentMemory[device].setIntValue(n);
	},
	
	cyclePressed: func() {
		foreach (var device; ["com", "nav"]) {
			var (mhz, khz) = split(".", me.selected[device].getValue());
			var (hundreds, tenths, units) = khz;
			if (num(tenths) == 0 or num(tenths) == 5) {
				tenths = tenths + 2;
				units = "5";
			} else {
				tenths = tenths - 2;
				units = "0";
			}
			khz = hundreds ~ tenths ~ units;
			me.selected[device].setDoubleValue(mhz ~ "." ~ khz);
		}
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
