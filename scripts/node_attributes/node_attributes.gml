#region attribute
	global.SURFACE_INTERPOLATION = [
		"-Group",
		"Pixel", 
		"Bilinear", 
		"Bicubic", 
		"radSin"
	];
	
	global.SURFACE_OVERSAMPLE = [
		"-Group",
		"Empty", 
		"Clamp", 
		"Repeat",
		"Black"
	];
	
	function __initSurfaceFormat() {
		var surface_format = [
			-1,
			-2,
			surface_rgba4unorm,
			surface_rgba8unorm,
			surface_rgba16float,
			surface_rgba32float,
			surface_r8unorm,
			surface_r16float,
			surface_r32float
		];
	
		var surface_format_name = [
			"-Input",
			"-Group",
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
			var _form = surface_format[i];
			var _supp = _form < 0 || surface_format_is_supported(_form);
			
			array_push(global.SURFACE_FORMAT, _form);
			array_push(global.SURFACE_FORMAT_NAME, (_supp? "" : "-") + surface_format_name[i]);
			
			if(!_supp) log_message("WARNING", $"Surface format [{surface_format_name[i]}] not supported in this device.");
		}
	}
	
	function __attribute_set(node, key, value) {
		node.attributes[$ key] = value;
		node.triggerRender();
	}
	
	function attribute_set(key, value) {
		if(PANEL_INSPECTOR == noone) return;
		
		if(PANEL_INSPECTOR.inspecting)
			__attribute_set(PANEL_INSPECTOR.inspecting, key, value);
		
		if(PANEL_INSPECTOR.inspectGroup == 1)
		for( var i = 0, n = array_length(PANEL_INSPECTOR.inspectings); i < n; i++ ) 
			__attribute_set(PANEL_INSPECTOR.inspectings[i], key, value);
	}
	
	function attribute_surface_depth(label = true) {
		attr_depth_array = global.SURFACE_FORMAT_NAME;
		if(!array_empty(inputs) && inputs[0].type == VALUE_TYPE.surface)
			attr_depth_array[0] = "Input";
		
		attributes.color_depth = 3;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Color depth", function() /*=>*/ {return attributes.color_depth}, 
			new scrollBox(attr_depth_array, function(val) /*=>*/ { attribute_set("color_depth", val); }, false), "color_depth"]);
	}
	
	function attribute_interpolation(label = false) {
		attributes.interpolate = 1;
		attributes.oversample  = 1;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Texture interpolation", function() /*=>*/ {return attributes.interpolate}, 
			new scrollBox(global.SURFACE_INTERPOLATION, function(val) /*=>*/ { attribute_set("interpolate", val); }, false), "interpolate"]);
	}
	
	function attribute_oversample(label = false) {
		attributes.interpolate = 1;
		attributes.oversample  = 1;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Oversample", function() /*=>*/ {return attributes.oversample}, 
			new scrollBox(global.SURFACE_OVERSAMPLE, function(val) /*=>*/ { attribute_set("oversample", val); }, false), "oversample"]);
	}
	
	function attribute_auto_execute(label = false) {
		attributes.auto_exe = false;
		
		if(label) array_push(attributeEditors, "Node");
		array_push(attributeEditors, ["Auto execute", function() /*=>*/ {return attributes.auto_exe}, 
			new checkBox(function() /*=>*/ { attribute_set("auto_exe", !attributes.auto_exe); })]);
	}
#endregion