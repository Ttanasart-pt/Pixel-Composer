#region attribute
	global.SURFACE_INTERPOLATION = [
		"Pixel", 
		"Bilinear", 
		"Bicubic", 
		"radSin"
	];
	
	global.SURFACE_OVERSAMPLE = [
		"Empty", 
		"Clamp", 
		"Repeat"
	];
	
	function __initSurfaceFormat() {
		var surface_format = [
			surface_rgba4unorm,
			surface_rgba8unorm,
			surface_rgba16float,
			surface_rgba32float,
			surface_r8unorm,
			surface_r16float,
			surface_r32float
		];
	
		var surface_format_name = [
			"4 bit RGBA", 
			"8 bit RGBA", 
			"16 bit RGBA", 
			"32 bit RGBA", 
			"8 bit Greyscale", 
			"16 bit Greyscale", 
			"32 bit Greyscale"
		];
	
		global.SURFACE_FORMAT		= [];
		global.SURFACE_FORMAT_NAME  = []; 
	
		for( var i = 0, n = array_length(surface_format); i < n; i++ ) {
			var sup = surface_format_is_supported(surface_format[i]);
			array_push(global.SURFACE_FORMAT, surface_format[i]);
			array_push(global.SURFACE_FORMAT_NAME, (sup? "" : "-") + surface_format_name[i]);
			
			if(!sup) log_message("WARNING", "Surface format [" + surface_format_name[i] + "] not supported in this device.");
		}
		
		global.SURFACE_FORMAT_NAME_PROCESS = [ "Input" ];
		global.SURFACE_FORMAT_NAME_PROCESS = array_append(global.SURFACE_FORMAT_NAME_PROCESS, global.SURFACE_FORMAT_NAME);
	}
	
	function attribute_surface_depth(label = true) {
		var depth_array = inputs[| 0].type == VALUE_TYPE.surface? global.SURFACE_FORMAT_NAME_PROCESS : global.SURFACE_FORMAT_NAME;
		attributes.color_depth = array_find(depth_array, "8 bit RGBA");
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Color depth", function() { return attributes.color_depth; }, 
			new scrollBox(depth_array, function(val) { 
				attributes.color_depth = val;
				triggerRender();
			}, false)]);
	}
	
	function attribute_interpolation(label = false) {
		attributes.interpolation = 0;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Texture interpolation", function() { return attributes.interpolation; }, 
			new scrollBox(global.SURFACE_INTERPOLATION, function(val) { 
				attributes.interpolation = val;
				triggerRender();
			}, false)]);
	}
	
	function attribute_oversample(label = false) {
		attributes.oversample = 0;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Oversample", function() { return attributes.oversample; }, 
			new scrollBox(global.SURFACE_OVERSAMPLE, function(val) { 
				attributes.oversample = val;
				triggerRender();
			}, false)]);
	}
	
	function attribute_auto_execute(label = false) {
		attributes.auto_exe = false;
		if(label) array_push(attributeEditors, "Node");
		array_push(attributeEditors, ["Auto execute", function() { return attributes.auto_exe; }, 
		new checkBox(function() { 
			attributes.auto_exe = !attributes.auto_exe;
		})]);
	}
#endregion