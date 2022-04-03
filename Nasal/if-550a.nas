# Nasal code for the IF-550A autopilot
# by TheEagle

# placeholder for later easy implementation of dual-control - then it can be changed to point to /ai/models/multiplayer[n]
var treeRoot = props.globals;

var instrumentationNode = treeRoot.getNode("instrumentation", 1);

var apNode = treeRoot.getNode("autopilot/if-550a", 1);
var engagedNode = apNode.getNode("engaged", 1);
var flightDirectorNode = apNode.getNode("flight-director", 1);
var disconnectWarnHornNode = apNode.getNode("disconnect-warn-horn", 1);
var disconnectWarnLightNode = apNode.getNode("disconnect-warn-light", 1);
var navSourceNode = apNode.getNode("nav-source", 1);

# Internal stuff
var internalNode = apNode.getNode("internal", 1);
var gSwitchNode = internalNode.getNode("g-switch", 1);

# Modes
var modesNode = apNode.getNode("modes", 1);
# Lateral modess
var rollModeNode = modesNode.getNode("roll", 1);
var headingModeNode = modesNode.getNode("heading", 1);
var navModeNode = modesNode.getNode("nav", 1);
var backcourseModeNode = modesNode.getNode("backcourse", 1);
# Vertical modes
var pitchModeNode = modesNode.getNode("pitch", 1);
var altModeNode = modesNode.getNode("altitude", 1);
var goAroundModeNode = modesNode.getNode("go-around", 1);


# Helpers
var disengageLateralModes = func {
	rollModeNode.setBoolValue(0);
	navModeNode.setBoolValue(0);
	headingModeNode.setBoolValue(0);
};
var disengageVerticalModes = func {
	pitchModeNode.setBoolValue(0);
	altModeNode.setBoolValue(0);
};

var resetDisconnectWarnHornTimer = maketimer(2, func {
	disconnectWarnHornNode.setBoolValue(1);
});
resetDisconnectWarnHornTimer.singleShot = 1;
resetDisconnectWarnHornTimer.simulatedTime = 1;

var disconnect = func {
	if (!engagedNode.getBoolValue()) {
		return;
	}
	disengageLateralModes();
	disengageVerticalModes();
	engagedNode.setBoolValue(0);
	disconnectWarnHornNode.setBoolValue(1);
	disconnectWarnLightNode.setBoolValue(1);
	resetDisconnectWarnHornTimer.start();
}

setlistener(gSwitchNode, disconnect);

var disengage = func {
	disengageLateralModes();
	disengageVerticalModes();
	engagedNode.setBoolValue(0);
	disconnectWarnLightNode.setBoolValue(0);
}

# Mode managing functions

var toggleEngaged = func {
	var engaged = engagedNode.getBoolValue();
	print("engaged: ", engaged);
	if (engaged) {
		disengage();
	} else {
		engagedNode.setBoolValue(1);
		rollModeNode.setBoolValue(1);
		pitchModeNode.setBoolValue(1);
	}
};

var toggleFlightDirector = func {
	var active = flightDirectorNode.getBoolValue();
	print("flight director: ", active);
	flightDirectorNode.setBoolValue(1 - active);
};

var goAroundMode = func {
	var apActive = engagedNode.getBoolValue();
	var fdActive = flightDirectorNode.getBoolValue();
	print("go around - ap: ", apActive, " fd: ", fdActive);
	
	if (apActive) {
		engagedNode.setBoolValue(0);
		flightDirectorNode.setBoolValue(1);
		fdActive = 1;
		disconnectWarnNode.setBoolValue(1);
		resetDisconnectWarnHornTimer.start();
	}
	
	if (fdActive) {
		disengageLateralModes();
		disengageVerticalModes();
		goAroundModeNode.setBoolValue(1);
		rollModeNode.setBoolValue(1);
		pitchModeNode.setBoolValue(1);
	}
};

var toggleNavSource = func {
	var nav = navSourceNode.getValue();
	print("nav source: ", nav);
	navSourceNode.setIntValue(1 - nav);
};

var toggleHeadingMode = func {
	if (!(engagedNode.getBoolValue() or flightDirectorNode.getBoolValue())) {
		return;
	}
	var active = headingModeNode.getBoolValue();
	print("heading: ", active);
	disengageLateralModes();
	if (active) {
		rollModeNode.setBoolValue(1);
	} else {
		headingModeNode.setBoolValue(1);
	}
};

var toggleNavMode = func {
	if (!(engagedNode.getBoolValue() or flightDirectorNode.getBoolValue())) {
		return;
	}
	var active = navModeNode.getBoolValue();
	print("nav: ", active);
	disengageLateralModes();
	if (active) {
		rollModeNode.setBoolValue(1);
	} else {
		navModeNode.setBoolValue(1);
	}
};

var toggleBackcourseMode = func {
	var active = backcourseModeNode.getBoolValue();
	print("backcourse: ", active);
	if (navModeNode.getBoolValue()) {
		backcourseModeNode.setBoolValue(1 - active);
	}
};

var toggleAltMode = func {
	if (!(engagedNode.getBoolValue() or flightDirectorNode.getBoolValue())) {
		return;
	}
	var active = altModeNode.getBoolValue();
	print("alt: ", active);
	pitchModeNode.setBoolValue(active);
	altModeNode.setBoolValue(1 - active);
};


var test = func {
	gSwitchNode.setBoolValue(1);
};

