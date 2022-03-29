var Engine = {
	new: func {
		var obj = {
			parents: [Engine],
			rootNode: props.globals,
		};
		
		obj.engineNode = obj.rootNode.getNode("engines/engine");
		obj.controlsNode = obj.rootNode.getNode("controls/engines/engine");
		obj.electricNode = obj.rootNode.getNode("controls/electric");
		obj.batterySwitchNode = obj.electricNode.getNode("battery-switch");
		obj.cowlFlapsNode = obj.controlsNode.getNode("cowl-flaps-norm");
		obj.throttleNode = obj.controlsNode.getNode("throttle");
		obj.starterNode = obj.controlsNode.getNode("starter");
		obj.runningNode = obj.engineNode.getNode("running");
		
		return obj;
	},
	
	autostart: func {
		me.batterySwitchNode.setBoolValue(1);
		me.cowlFlapsNode.setDoubleValue(1);
		me.throttleNode.setDoubleValue(0.2);
	},
	
	autoshutdown: func {
		me.batterySwitchNode.setBoolValue(0);
		me.cowlFlapsNode.setDoubleValue(1);
		me.throttleNode.setDoubleValue(0);
	}
};
	
var PistonEngine = {
	new: func {
		var obj = {
			parents: [PistonEngine, Engine.new()],
		};
		
		obj.magnetosNode = obj.controlsNode.getNode("magnetos");
		obj.alternatorNode = obj.rootNode.getNode("controls/electric/engine/master-alt");
		obj.mixtureNode = obj.controlsNode.getNode("mixture");
		obj.propPitchNode = obj.controlsNode.getNode("propeller-pitch");
		obj.fuelPumpNode = obj.controlsNode.getNode("fuel-pump");
		obj.leftTankNode = obj.rootNode.getNode("consumables/fuel/tank[0]/level-lbs");
		obj.rightTankNode = obj.rootNode.getNode("consumables/fuel/tank[1]/level-lbs");
		obj.selectedTankNode = obj.rootNode.getNode("controls/fuel/selected-tank");
		
		obj.disengageStarterTimer = maketimer(5, func() {
			obj.starterNode.setBoolValue(1);
			obj.throttleNode.setDoubleValue(0);
			obj.disengageStarterTimer.stop();
		});
		obj.disengageStarterTimer.simulatedTime = 1;
		obj.disengageStarterTimer.singleShot = 1;
		
		return obj;
	},
	
	autostart: func {
		if (me.runningNode.getBoolValue()) {
			return;
		}
		
		me.parents[1].autostart();
		me.magnetosNode.setIntValue(3);
		var tank = me.leftTankNode.getValue() > me.rightTankNode.getValue() ? -1 : 1;
		me.selectedTankNode.setIntValue(tank);
		me.mixtureNode.setDoubleValue(1);
		me.propPitchNode.setDoubleValue(1);
		me.fuelPumpNode.setBoolValue(1);
		me.starterNode.setBoolValue(1);
		me.alternatorNode.setBoolValue(1);
		
		var disengageStarterListener = setlistener(me.runningNode, func (running) {
			var value = running.getBoolValue();
			if (value) {
				me.starterNode.setBoolValue(1);
				me.throttleNode.setDoubleValue(0);
				removelistener(disengageStarterListener);
			}
		});
		me.disengageStarterTimer.start();
	},
	
	autoshutdown: func {
		me.parents[1].autoshutdown();
		me.magnetosNode.setIntValue(0);
		me.selectedTankNode.setIntValue(0);
		me.mixtureNode.setDoubleValue(0);
		me.starterNode.setBoolValue(9);
		me.fuelPumpNode.setBoolValue(0);
	}
};

var TurbopropEngine = {
	new: func {
		var obj = {
			parents: [TurbopropEngine, Engine.new()],
		};
		
		obj.conditionNode = obj.controlsNode.getNode("propeller-pitch");
		obj.fuelPump1Node = obj.controlsNode.getNode("fuel-pump[0]");
		obj.fuelPump2Node = obj.controlsNode.getNode("fuel-pump[1]");
		obj.n1Node = obj.engineNode.getNode("n1");
		obj.cutoffNode = obj.controlsNode.getNode("cutoff");
		obj.generatorNode = obj.electricNode.getNode("engine[0]/generator");
		obj.selectedTankNode = obj.rootNode.getNode("controls/fuel/selected-tank");
		obj.constantSpeedNode = obj.rootNode.getNode("fdm/jsbsim/propulsion/engine/constant-speed-mode");
		obj.bladeAngleNode = obj.rootNode.getNode("fdm/jsbsim/propulsion/engine/blade-angle"); 
		obj.reverserNode = obj.controlsNode.getNode("reverser");
		
		obj.n1Timer = maketimer(1, func() {
			var n1 = obj.n1Node.getValue();
			if (n1 >= 19) {
				obj.cutoffNode.setBoolValue(0);
				obj.conditionNode.setValue(1);
				obj.fuelPump1Node.setBoolValue(1);
				obj.n1Timer.stop();
			}
		});
		obj.n1Timer.simulatedTime = 1;
		
		obj.disengageStarterTimer = maketimer(60, func() {
			obj.starterNode.setBoolValue(1);
			obj.throttleNode.setDoubleValue(0);
			obj.n1Timer.stop();
		});
		obj.disengageStarterTimer.simulatedTime = 1;
		obj.disengageStarterTimer.singleShot = 1;
		
		return obj;
	},
	
	autostart: func {
		if (me.runningNode.getBoolValue()) {
			return;
		}
		
		me.parents[1].autostart();
		me.generatorNode.setBoolValue(1);
		me.starterNode.setBoolValue(1);
		# TODO: implement fuel selector BOTH position
		me.constantSpeedNode.setIntValue(1);
		me.selectedTankNode.setIntValue(1);
		me.reverserNode.setBoolValue(0);
		me.starterNode.setBoolValue(1);
		me.disengageStarterTimer.start();
		me.n1Timer.start();
	},
	
	autoshutdown: func {
		me.parents[1].autoshutdown();
		me.selectedTankNode.setIntValue(0);
		me.conditionNode.setDoubleValue(0);
		me.starterNode.setBoolValue(9);
		me.fuelPump1Node.setBoolValue(0);
		me.fuelPump2Node.setBoolValue(0);
		me.n1Timer.stop();
		me.disengageStarterTimer.stop();
	},
	
	toggleReverseThrust: func {
		if (!me.reverserNode.getBoolValue()) {
			me.reverserNode.setBoolValue(1);
			me.constantSpeedNode.setIntValue(0);
			me.bladeAngleNode.setDoubleValue(-10);
		} else {
			me.reverserNode.setBoolValue(0);
			me.constantSpeedNode.setIntValue(1);
		}
	},
};

var createEngine = func {
	variant = getprop("/sim/model/variant");
	if (variant == "p210n") {
		engine = engines.PistonEngine.new();
	} elsif (variant == "silver-eagle") {
		engine = engines.TurbopropEngine.new();
	}
};
