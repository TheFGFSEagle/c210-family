# Update splash vector in a loop in respect to current airspeed

var airspeedNode = props.getNode("/velocities/airspeed-kt");
var splashVectorXNode = props.getNode("/environment/aircraft-effects/splash-vector-x");
var splashVectorYNode = props.getNode("/environment/aircraft-effects/splash-vector-y");
var splashVectorZNode = props.getNode("/environment/aircraft-effects/splash-vector-z");
var airspeedMax = 200;

var rainSplashVectorLoop = func() {
	var airspeed = math.clamp(airspeedNode.getIntValue(), 0, airspeedMax);

	airspeed = math.sqrt(airspeed / airspeedMax);
	
	var splash_x = 0 + 5 * airspeed;
	var splash_y = 0.0;
	var splash_z = -2 + airspeed;

	splashVectorXNode.setDoubleValue(splash_x);
	splashVectorYNode.setDoubleValue(splash_y);
	splashVectorZNode.setDoubleValue(splash_z);
}

rainSplashVectorLoopTimer = maketimer(0.1, rainSplashVectorLoop);
rainSplashVectorLoopTimer.singleShot = 0;
rainSplashVectorLoopTimer.simulatedTime = 1;
rainSplashVectorLoopTimer.start();
