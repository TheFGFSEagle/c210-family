# Nasal stuff for the AA-801A altitude alerter
# by TheEagle

var treeRoot = props.globals;

var rootNode = treeRoot.getNode("alt-alert", 1);
var selectedAltitudeNode = rootNode.getNode("selected-altitude-ft", 1);
var selectedAltitudeTenthousandsNode = rootNode.getNode("selected-altitude-ft-tenthousands", 1);
var selectedAltitudeThousandsNode = rootNode.getNode("selected-altitude-ft-thousands", 1);
var selectedAltitudeHundredsNode = rootNode.getNode("selected-altitude-ft-hundreds", 1);
var armedNode = rootNode.getNode("armed", 1);

var autopilotNode = rootNode.getNode("autopilot/if-550a", 1);
var altitudeModeNode = autopilotNode.getNode("modes/altitude", 1);
var gsCapturedNode = autopilotNode.getNode("internal/gs-captured", 1);
var targetAltitudeNode = autopilotNode.getNode("internal/target-altitude-ft", 1);


var updateSelectedAltitude = func {
	var tenthousands = selectedAltitudeTenthousandsNode.getValue();
	var thousands = selectedAltitudeThousandsNode.getValue();
	var hundreds = selectedAltitudeHundredsNode.getValue();
	var altitude = tenthousands * 10000 + thousands * 1000 + hundreds * 100;
	selectedAltitudeNode.setIntValue(altitude);
	armedNode.setBoolValue(0);
}

var armButtonPressed = func {
	if (!altitudeModeNode.getBoolValue() and !gsCapturedNode.getBoolValue()) {
		armedNode.setBoolValue(1);
		targetAltitudeNode.setDoubleValue(selectedAltitudeNode.getValue());
	}
}

aircraft.data.add(
	selectedAltitudeHundredsNode,
	selectedAltitudeThousandsNode,
	selectedAltitudeTenthousandsNode,
	selectedAltitudeNode,
);

