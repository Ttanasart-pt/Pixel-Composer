#region attribute
	global.SURFACE_INTERPOLATION = [
		new scrollItem("Group").setTooltip("Inherit from parent group.").setActive(false),
		new scrollItem("Pixel"),
		new scrollItem("Bilinear"),
		new scrollItem("Bicubic"),
		new scrollItem("radSin"),
	];
	
	global.SURFACE_OVERSAMPLE = [
		new scrollItem("Group").setTooltip("Inherit from parent group.").setActive(false),
		new scrollItem("Empty"), 
		new scrollItem("Clamp"), 
		new scrollItem("Repeat"),
		new scrollItem("Black"),
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
			new scrollItem("Input"           ).setTooltip("Inherit from input surface.").setActive(false),
			new scrollItem("Group"           ).setTooltip("Inherit from parent group.").setActive(false),
			new scrollItem("4 bit RGBA"      ).setTooltip("Normalized 4 bit, 4 channels RGBA"), 
			new scrollItem("8 bit RGBA"      ).setTooltip("Normalized 8 bit, 4 channels RGBA"), 
			new scrollItem("16 bit RGBA"     ).setTooltip("16 bit float, 4 channels RGBA"), 
			new scrollItem("32 bit RGBA"     ).setTooltip("32 bit float, 4 channels RGBA"), 
			new scrollItem("8 bit Greyscale" ).setTooltip("Normalized 8 bit, single channel"), 
			new scrollItem("16 bit Greyscale").setTooltip("16 bit float, single channel"), 
			new scrollItem("32 bit Greyscale").setTooltip("32 bit float, single channel"),
		];
	
		global.SURFACE_FORMAT		= [];
		global.SURFACE_FORMAT_NAME  = []; 
	
		for( var i = 0, n = array_length(surface_format); i < n; i++ ) {
			var _form = surface_format[i];
			var _supp = _form < 0 || surface_format_is_supported(_form);
			
			array_push(global.SURFACE_FORMAT, _form);
			array_push(global.SURFACE_FORMAT_NAME, surface_format_name[i]);
			
			if(!_supp) {
				log_message("WARNING", $"Surface format [{surface_format_name[i].name}] not supported in this device.");
				surface_format_name[i].setActive(false);
			}
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
		attr_depth_array = variable_clone(global.SURFACE_FORMAT_NAME);
		attr_depth_array[0].setActive(!array_empty(inputs) && inputs[0].type == VALUE_TYPE.surface);
		attributes.color_depth = 3;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Color depth", function() /*=>*/ {return attributes.color_depth}, 
			new scrollBox(attr_depth_array, function(val) /*=>*/ { attribute_set("color_depth", val); }, false), "color_depth"]);
	}
	
	function attribute_interpolation(label = false) {
		attr_interpolate_array = variable_clone(global.SURFACE_INTERPOLATION);
		attributes.interpolate = 1;
		attributes.oversample  = 1;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Texture interpolation", function() /*=>*/ {return attributes.interpolate}, 
			new scrollBox(attr_interpolate_array, function(val) /*=>*/ { attribute_set("interpolate", val); }, false), "interpolate"]);
	}
	
	function attribute_oversample(label = false) {
		attr_oversample_array = variable_clone(global.SURFACE_OVERSAMPLE);
		attributes.interpolate = 1;
		attributes.oversample  = 1;
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, ["Oversample", function() /*=>*/ {return attributes.oversample}, 
			new scrollBox(attr_oversample_array, function(val) /*=>*/ { attribute_set("oversample", val); }, false), "oversample"]);
	}
	
	function attribute_auto_execute(label = false) {
		attributes.auto_exe = false;
		
		if(label) array_push(attributeEditors, "Node");
		array_push(attributeEditors, ["Auto execute", function() /*=>*/ {return attributes.auto_exe}, 
			new checkBox(function() /*=>*/ { attribute_set("auto_exe", !attributes.auto_exe); })]);
	}
#endregion