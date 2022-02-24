# Miscellaneous aircraft setup
# by TheEagle

# XXX: For some reason this throws an Nasal error "too many open files" ?
#var p210nModule = modules.Module.new("p210n");
#p210nModule.setDebug(1);
#p210nModule.setFilePath(getprop("/sim/aircraft-dir") ~ "/Nasal");
#p210nModule.setMainFile("c210.nas");
#p210nModule.load();

# Livery dialog
var initLiverySystem = func {
	variant = getprop("/sim/model/variant");
	aircraft.livery.init("Models/Liveries/" ~ variant);
};
initLiverySystem();

# Save aircraft data once a minute
aircraft.data.save(1);

# Doors
var pilotDoor = aircraft.door.new("/sim/model/doors/pilot", 1);
var emergencyExit = aircraft.door.new("/sim/model/doors/emergency-exit", 2);
var baggageDoor = aircraft.door.new("/sim/model/doors/baggage", 1);

var strobeLight = aircraft.light.new("/sim/model/lights/strobe", [0.05, 0.05, 0.05, 1.85], "/controls/lighting/strobe");
var beaconLight = aircraft.light.new("/sim/model/lights/beacon", [0.2, 0.8], "/controls/lighting/beacon");

var engine = engines.createEngine();

if (getprop("/sim/presets/onground")) {
	setprop("/controls/gear/gear-down", 1);
	setprop("/fdm/jsbsim/gear/unit[0]/pos-norm", 1);
	setprop("/fdm/jsbsim/gear/unit[1]/pos-norm", 1);
	setprop("/fdm/jsbsim/gear/unit[2]/pos-norm", 1);
}
