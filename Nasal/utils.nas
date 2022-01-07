# Miscellaneous utility functions


# Remove an item from a vector
# Synopsis:
#	deleteV(vector, index)
#		vector: Mandatory. The vector to delete an item from.
#		index: Mandatory. The index of the item to delete.
#
# Examples:
#		v = [1, 2, 3]
#		v = deleteV(v, 1);
#		debug.dump(v);
#	prints [1, 3]

var deleteV = func(vector, index) {
	s = size(vector);
	if (s == 1 or s == 0) {
		return [];
	} elsif (index + 1 == s) {
		return vector[:index - 1];
	} elsif (index == 0) {
		return vector[1:];
	}
	return vector[:index - 1, index + 1:];
};


# Create a Python-like range (a vector filled with numbers from start to stop, spaced by step)
# Synopsis:
#	range([start, ]stop[, step])
#		start=0:	Optional. An integer number specifying at which position to start.
#		stop:		Required. A number specifying at which position to stop (not included)
#		step=1:		Optional. An integer number greater 0 specifying the incrementation.
#
# Examples:
#		var r = range(5);
# 		debug.dump(r)
#	prints [0, 1, 2, 3, 4]
#
#		var r = range(2, 5);
# 		debug.dump(r)
#	prints [2, 3, 4]
#
#		var r = range(0, 10, 2);
# 		debug.dump(r)
#	prints [0, 2, 4, 6, 8]
#
#		var r = range(0, 0);
#		debug.dump(r)
#	prints []
#
#		var r = range(0, 1);
#		debug.dump(r)
#	prints [0]
#
#		var r = range(0, 0.1);
#		debug.dump(r)
#	prints [0]

var range = func(stop, args...) {
	argc = size(args);
	
	# default case: we got one argument stop, use default values for the others
	var start = 0;
	var step = 1;
	
	if (argc >= 1) {
		# we got at least one additional argument besides stop - use it as stop and stop becomes start
		start = stop;
		stop = args[0];
		
		if (argc == 2) {
			# we got a third argument - use that as step
			step = args[1]
		}
	}
	
	# safety checks
	# if the string representation of step or start includes a dot it's not an integer but a float
	if (contains(chr(step), ".")) {
		die("Bad arguments to range(): step must be an integer, got " ~ step);
	}
	if (contains(chr(start), ".")) {
		die("Bad arguments to range(): start must be an integer, got " ~ start);
	}
	# if step equals 0, we'd end up in an infinite loop - just return a vector containing one number start
	if (step == 0) {
		return [start];
	}
	
	vec = [];
	n = start;
	if (start < stop or step < 0) {
		while (n < stop) {
			append(vec, n);
			n = n + step;
		}
	} elsif (start > stop) {
		while (n > stop) {
			append(vec, n);
			n = n - step;
		}
	}
	return vec;
};

_delayedFunctions = [];

var addDelayed = func(function, timeDelta, args...) {
	runTime = systime() + timeDelta;
	append(_delayedFunctions, {"func": function, "args": args, "time": runTime});
};

var _runDelayedLoop = func() {
	forindex (var i; _delayedFunctions) {
		data = _delayedFunctions[i];
		if (data["time"] <= systime()) {
			data["func"](data["args"]);
			deleteV(_delayedFunctions, i);
		}
	}
};

_delayedFunctionsTimer = maketimer(0.1, _runDelayedLoop);
_delayedFunctionsTimer.simulatedTime = 1;
_delayedFunctionsTimer.singleShot = 0;
#_delayedFunctionsTimer.start();
