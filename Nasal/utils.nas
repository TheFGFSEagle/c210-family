_delayedFunctions = [];

var addDelayed = func(function, timeDelta, args...) {
	runTime = systime() + timeDelta;
	append(_delayedFunctions, {"func": function, "args": args, "time": runTime});
}

var _runDelayedLoop = func() {
	forindex (var i; _delayedFunctions) {
		data = _delayedFunctions[i];
		if (data["time"] <= systime()) {
			data["func"](data["args"]);
			delete(_delayedFunctions, i);
		}
	}
}

_delayedFunctionsTimer = maketimer(0.1, _runDelayedLoop);
_delayedFunctionsTimer.simulatedTime = 1;
_delayedFunctionsTimer.singleShot = 0;
_delayedFunctionsTimer.start();
