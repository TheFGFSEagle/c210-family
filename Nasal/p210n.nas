# XXX: For some reason this throws an Nasal error "too many open files" ?
#var p210nModule = modules.Module.new("p210n");
#p210nModule.setDebug(1);
#p210nModule.setFilePath(getprop("/sim/aircraft-dir") ~ "/Nasal");
#p210nModule.setMainFile("p210n.nas");
#p210nModule.load();

# Livery dialog
aircraft.livery.init("Models/Liveries");
aircraft.data.save(1);

# Doors
var pilotDoor = aircraft.door.new("/sim/model/doors/pilot", 1);
var emergencyExit = aircraft.door.new("/sim/model/doors/emergency-exit", 2);
var baggageDoor = aircraft.door.new("/sim/model/doors/baggage", 1);

var strobeLight = aircraft.light.new("/sim/model/lights/strobe", [0.05, 0.05, 0.05, 1.85], "/controls/lighting/strobe");
