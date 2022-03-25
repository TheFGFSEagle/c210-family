# Nasal code for the AstroTech LC-2 Digital clock
# by TheEagle


var Timer = {
	new: func(rootNode, callback=nil) {
		var obj = {
			parents: [Timer],
			rootNode: rootNode,
			_interval: 0.5,
			elapsed: 0,
			active: 0,
			paused: 0,
			_startTime: 0,
			_pausedTime: 0,
			_offset: 0,
		};
		
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
		if (me.active) {
			me.elapsed = int(me.simElapsedNode.getValue() - me._startTime);
			me.elapsedNode.setIntValue(me.elapsed);
		} elsif (me.paused) {
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
		if (!me.active and !me.paused) {
			me.start();
		} elsif (me.active and !me.paused) {
			me.pause();
		} elsif (!me.active and me.paused) {
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
			_colon: ":",
			_clockMode: 0,
		};
		
		obj.modeNode = obj.rootNode.getNode("mode", 1);
		obj.poweredNode = obj.rootNode.getNode("powered", 1);
		obj.mode = obj.modeNode.getValue() or "timer";
		obj.timerNode = obj.rootNode.getNode("timer", 1);
		obj.utcNode = props.globals.getNode("/sim/time/utc");
		obj.utcDayNode = obj.utcNode.getNode("day");
		obj.utcMonthNode = obj.utcNode.getNode("month");
		obj.utcHourNode = obj.utcNode.getNode("hour");
		obj.utcMinuteNode = obj.utcNode.getNode("minute");
		obj.utcSecondNode = obj.utcNode.getNode("second");
		
		obj.timer = Timer.new(obj.timerNode, callback=func obj.updateTimer());
		
		obj.clockTimer = maketimer(0.5, func obj.updateClock());
		obj.clockTimer.simulatedTime = 1;
		obj.clockTimer.singleShot = 0;
		
		obj.annunTimer = maketimer(0.5, func obj.updateAnnunciators());
		obj.annunTimer.simulatedTime = 1;
		obj.annunTimer.singleShot = 0;
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
		
		me.annunTimer.start();
	},
	
	updateAnnunciators: func() {
		if (!me.poweredNode.getBoolValue()) {
			me.timerAnnun.hide();
			me.clockAnnun.hide();
			return;
		}
		
		if (me.mode == "timer") {
			me.timerAnnun.show();
			me.clockAnnun.hide();
		} else {
			if (me._clockMode == 0) {
				me.clockAnnun.show();
			} else {
				me.clockAnnun.hide();
			}
			me.timerAnnun.hide();
		}
	},
	
	updateClock: func() {
		if (!me.poweredNode.getBoolValue()) {
			me.text.setText("");
			return;
		}
		
		if (me._clockMode >= 1) {
			me._clockMode -= 1;
			var utcDays = sprintf("%02d", me.utcDayNode.getValue());
			var utcTenDay = substr(utcDays, 0, 1);
			var utcDay = substr(utcDays, 1, 1);
			var utcMonths = sprintf("%02d", me.utcMonthNode.getValue());
			var utcTenMonth = substr(utcMonths, 0, 1);
			var utcMonth = substr(utcMonths, 1, 1);
			me.text.setText(sprintf("%1d %1d.%1d %1d", utcTenDay, utcDay, utcTenMonth, utcMonth));
		} else {
			var utcHours = sprintf("%02d", me.utcHourNode.getValue());
			var utcTenHour = substr(utcHours, 0, 1);
			var utcHour = substr(utcHours, 1, 1);
			var utcMinutes = sprintf("%02d", me.utcMinuteNode.getValue());
			var utcTenMinute = substr(utcMinutes, 0, 1);
			var utcMinute = substr(utcMinutes, 1, 1);
			me._colon = " ";
			if (math.mod(me.utcSecondNode.getValue(), 10) == 0) {
				me._colon = ":";
			}
			me.text.setText(sprintf("%1d %1d%s%1d %1d", utcTenHour, utcHour, me._colon, utcTenMinute, utcMinute));
		}
	},
	
	updateTimer: func() {
		# don't show timer time when the clock date / time is displayed
		if (!me.poweredNode.getBoolValue()) {
			me.text.setText("");
			return;
		}
		if (me.clockTimer.isRunning) {
			return;
		}
		
		var time = me.timer.elapsed;
		var displayHours = 0;
		
		# we can't show times greater than 23:59:59
		if (time > 86399) {
			time = 86399;
		}
		
		# if elapsed time is more than 59 min 59 sec, format changes from mm:ss to hh:mm
		if (time > 3599) {
			time = int(time / 60);
			displayHours = 1;
		}
		time = sprintf("%04d", time);
		
		var seconds = math.mod(time, 10);
		var tenSeconds = math.mod(int(time / 10), 6);
		var minutes = math.mod(int(time / 60), 10);
		var tenMinutes = math.mod(int(time / 600), 10);
		
		if (me.timer.active) {
			if (displayHours and seconds == 0) {
				# in hours mode, show colon every ten seconds
				me._colon = ":";
			} else {
				# in minutes mode, show colon every second
				if (me._colon == " ") {
					me._colon = ":";
				} else {
					me._colon = " ";
				}
			}
		}
		
		time = sprintf("%1d %1d%s%1d %1d", tenMinutes, minutes, me._colon, tenSeconds, seconds);
		me.text.setText(time);
	},
	
	stSpDtAvPressed: func() {
		if (!me.poweredNode.getBoolValue()) {
			return;
		}
		
		if (me.mode == "timer") {
			me.timer.cycle();
		} else {
			if (me._clockMode == 0) {
				me._clockMode = 4; # display date for 1.5 seconds
			}
		}
	},
	
	setResetPressed: func() {
		if (me.mode == "timer" and !me.timer.active and me.poweredNode.getBoolValue()) {
			me.timer.reset();
		}
	},
	
	modePressed: func() {
		if (!me.poweredNode.getBoolValue()) {
			return;
		}
		
		if (me.mode == "timer") {
			if (!me.timer.active) {
				me.mode = "clock";
				me.modeNode.setValue("clock");
				me.clockTimer.start();
			}
		} else {
			me.mode = "timer";
			me.modeNode.setValue("timer");
			me.clockTimer.stop();
			me.updateTimer();
		}
	},
};

lc2 = LC2.new(props.globals.getNode("/instrumentation"));
