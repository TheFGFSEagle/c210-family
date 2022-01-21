# Nasal code for the AstroTech LC-2 Digital clock
# by TheEagle


var Timer = {
	new: func(root, callback=nil) {
		var obj = {
			parents: [Timer],
			_interval: 0.5,
			elapsed: 0,
			active: 0,
			paused: 0,
			_startTime: 0,
			_pausedTime: 0,
			_offset: 0,
		};
		
		if (isa(root, props.Node)) {
			obj.rootNode = root;
		} else {
			obj.rootNode = props.getNode(root);
		}
		
		obj.callback = callback;
		if (callback == nil) {
			obj.callback = func {};
		}
		
		obj.elapsedNode = obj.rootNode.getNode("timer-elapsed", 1);
		obj.simElapsedNode = props.globals.getNode("/sim/time/elapsed-sec");
		obj.activeNode = obj.rootNode.getNode("active", 1);
		
		obj._timer = maketimer(obj._interval, func obj._timerFunc());
		obj._timer.simulatedTime = 1;
		obj._timer.singleShot = 0;
		obj._timer.start();
		
		return obj;
	},
	
	_timerFunc: func {
		if (me.active == 1) {
			me.elapsed = int(me.simElapsedNode.getValue() - me._startTime);
			me.elapsedNode.setIntValue(me.elapsed);
		} elsif (me.paused == 1) {
			me._offset = me.simElapsedNode.getValue() - me._pausedTime;
		}
		me.callback();
	},
	
	start: func {
		me._startTime = me.simElapsedNode.getValue();
		me.active = 1;
		me.activeNode.setBoolValue(1);
	},
	
	pause: func {
		me._pausedTime = me.simElapsedNode.getValue();
		me.active = 0;
		me.activeNode.setBoolValue(0);
		me.paused = 1;
	},
	
	unpause: func {
		me._startTime = me._startTime + me._offset;
		me.active = 1;
		me.activeNode.setBoolValue(1);
		me.paused = 0;
		me._pausedTime = 0;
	},
	
	cycle: func {
		if (me.active == 0 and me.paused == 0) {
			me.start();
		} elsif (me.active == 1 and me.paused == 0) {
			me.pause();
		} elsif (me.active == 0 and me.paused == 1) {
			me.unpause();
		}
	},
	
	reset: func() {
		me.active = 0;
		me.activeNode.setBoolValue(0);
		me.paused = 0;
		me._offset = 0;
		me.elapsed = 0;
		me.elapsedNode.setIntValue(0);
		me._startTime = me.simElapsedNode.getValue();
	}
};

var LC2 = {
	new: func(instrumentationNode) {
		var obj = {
			parents: [LC2],
			_canvas: canvas.new({"size": [256, 90], "view": [256, 90]}),
			rootNode: instrumentationNode.getNode("clock", 1),
		};
		
		obj.modeNode = obj.rootNode.getNode("mode", 1);
		obj.mode = obj.modeNode.getValue() or "timer";
		obj.timerNode = obj.rootNode.getNode("timer", 1);
		obj.timer = Timer.new(obj.timerNode, callback=func obj.updateTimer());
		obj.clockTimer = maketimer(1, func obj.updateClock());
		obj.clockTimer.simulatedTime = 1;
		obj.clockTimer.singleShot = 0;
		obj.init();
		
		return obj;
	},
	
	init: func {
		me._canvas.addPlacement({"node": "ChronoDisplay"});
		me._canvas.setColorBackground(0.3, 0.4, 0.3, 1);
		me.display = me._canvas.createGroup();
		
		me.timerAnnun = me.display.createChild("text")
						.setTranslation(64, 82)
						.setAlignment("center-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(80)
						.setColor(0, 0, 0)
						.setText(".");
		
		me.clockAnnun = me.display.createChild("text")
						.setTranslation(192, 82)
						.setAlignment("center-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Regular.ttf")
						.setFontSize(80)
						.setColor(0, 0, 0)
						.setText(".");
		
		me.text = me.display.createChild("text")
						.setTranslation(256, 45)
						.setAlignment("right-center")
						.setFont("DSEG/DSEG7/Classic-MINI/DSEG7ClassicMini-Bold.ttf")
						.setFontSize(66)
						.setColor(0, 0, 0)
						.setText("0 0:0 0");
	},
	
	updateClock: func() {
	},
	
	updateTimer: func() {
		var time = me.timer.elapsed;
		
		# we can't show times greater than 23:59:59
		if (time > 86399) {
			me.timer.reset();
			time = me.timer.elapsed;
		}
		
		# if elapsed time is more than 59 min 59 sec, format changes from mm:ss to hh:mm
		if (time > 3599) {
			time = int(time / 60);
		}
		time = sprintf("%04d", time);
		
		var seconds = math.mod(time, 10);
		var tenSeconds = math.mod(int(time / 10), 6);
		var minutes = math.mod(int(time / 60), 10);
		var tenMinutes = math.mod(int(time / 600), 10);
		
		time = sprintf("%1d %1d:%1d %1d", tenMinutes, minutes, tenSeconds, seconds);
		me.text.setText(time);
	},
	
	startStopPressed: func() {
		if (me.mode == "timer") {
			me.timer.cycle();
		}
	},
	
	setResetPressed: func() {
		if (me.mode == "timer" and me.timer.active == 0) {
			me.timer.reset();
		}
	},
	
	modePressed: func() {
		if (me.mode == "timer" and me.timer.active == 0) {
			me.mode = "clock";
			me.modeNode.setValue("clock");
			me.timer.stop();
			me.clockTimer.start();
		} else {
			me.mode = "timer";
			me.modeNode.setValue("timer");
			me.clockTimer.stop();
			me.updateTimer();
		}
	},
};

lc2 = LC2.new(props.globals.getNode("/instrumentation"));
