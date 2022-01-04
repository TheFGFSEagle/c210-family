var ComNav = {
	new: func(deviceNum, instrumentationNode) {
		var obj = {
			parents: [ComNav],
		};
				
		obj.root = {
			"com": instrumentationNode.getNode("comm[" ~ deviceNum ~ "]"),
			"nav": instrumentationNode.getNode("nav[" ~ deviceNum ~ "]")
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
	}
};

comNav1 = ComNav.new(0, props.globals.getNode("/instrumentation"));
comNav2 = ComNav.new(1, props.globals.getNode("/instrumentation"));

