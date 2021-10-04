var rainSplashVectorLoop = func(){
	var airspeed = getprop("/velocities/airspeed-kt");

	var airspeed_max = 203;

	if (airspeed > airspeed_max) {
		airspeed = airspeed_max;
	}

	airspeed = math.sqrt(airspeed / airspeed_max);

	var splash_x = -0.1 - 3.0 * airspeed;
	var splash_y = 0.0;
	var splash_z = 1.0 - 1.35 * airspeed;

	setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
	setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
	setprop("/environment/aircraft-effects/splash-vector-z", splash_z);

	settimer(func(){
		rainSplashVectorLoop();
	}, 1);
}

rainSplashVectorLoop();
