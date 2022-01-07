# XXX: For some reason this throws an Nasal error "too many open files" ?
#var p210nModule = modules.Module.new("p210n");
#p210nModule.setDebug(1);
#p210nModule.setFilePath(getprop("/sim/aircraft-dir") ~ "/Nasal");
#p210nModule.setMainFile("p210n.nas");
#p210nModule.load();

# Livery dialog
aircraft.livery.init("Aircraft/c210-family/Models/Liveries");

# Doors
var pilotDoor = aircraft.door.new("sim/model/doors/pilot", 1);
var emergencyExit = aircraft.door.new("sim/model/doors/emergency-exit", 2);
var baggageDoor = aircraft.door.new("sim/model/doors/baggage", 1);

debug.dump(utils.deleteV([1, 2], 0))#utils.addDelayed(func() { print("called"); }, 5)

