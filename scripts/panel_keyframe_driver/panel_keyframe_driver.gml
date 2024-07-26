function Panel_Keyframe_Driver(key) : Panel_Linear_Setting() constructor {
	title    = __txtx("driver_settings", "Driver Settings");
	self.key = key;
	
	w = ui(380);
	
	#region data
		prop_default = [
			new __Panel_Linear_Setting_Item(
				__txtx("driver_type", "Type"),
				new scrollBox( [ "None", "Linear", "Wiggle", "Sine" ], function(val) { key.drivers.type = val; setProp(); }),
				function() { return key.drivers.type; }
			),
		];
		
		prop_linear = [
			new __Panel_Linear_Setting_Item(
				__txt("Speed"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.speed = val; }),
				function() { return key.drivers.speed; }
			),
		];
		
		prop_wiggle = [
			new __Panel_Linear_Setting_Item(
				__txt("Seed"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.seed = val; }),
				function() { return key.drivers.seed; }
			),
			new __Panel_Linear_Setting_Item(
				__txt("Sync axis"),
				new checkBox( function() { key.drivers.axis_sync = !key.drivers.axis_sync; }),
				function() { return key.drivers.axis_sync }
			),
			new __Panel_Linear_Setting_Item(
				__txt("Frequency"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.frequency = val; }),
				function() { return key.drivers.frequency; }
			),
			new __Panel_Linear_Setting_Item(
				__txt("Amplitude"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.amplitude = val; }),
				function() { return key.drivers.amplitude; }
			),
			new __Panel_Linear_Setting_Item(
				__txt("Octave"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.octave = val; }),
				function() { return key.drivers.octave; }
			),
		];
		
		prop_sine = [
			new __Panel_Linear_Setting_Item(
				__txt("Sync axis"),
				new checkBox( function() { key.drivers.axis_sync = !key.drivers.axis_sync; }),
				function() { return key.drivers.axis_sync }
			),
			new __Panel_Linear_Setting_Item(
				__txt("Frequency"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.frequency = val; }),
				function() { return key.drivers.frequency; }
			),
			new __Panel_Linear_Setting_Item(
				__txt("Amplitude"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.amplitude = val; }),
				function() { return key.drivers.amplitude; }
			),
			new __Panel_Linear_Setting_Item(
				__txt("Phase"),
				new textBox( TEXTBOX_INPUT.number, function(val) { key.drivers.phase = val; }),
				function() { return key.drivers.phase ; }
			),
		];
	#endregion
	
	static setProp = function() { 
		properties = [];
		
		array_append(properties, prop_default);
		
		switch(key.drivers.type) {
			case DRIVER_TYPE.linear : array_append(properties, prop_linear); break;
			case DRIVER_TYPE.wiggle : array_append(properties, prop_wiggle); break;
			case DRIVER_TYPE.sine   : array_append(properties, prop_sine);   break;
		}
		
		setHeight();
		panel.contentResize();
	}
	
	run_in(1, function() { setProp(); });
}