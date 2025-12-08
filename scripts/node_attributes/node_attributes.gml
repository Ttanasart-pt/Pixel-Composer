#region data
	global.SURFACE_INTERPOLATION = [
		new scrollItem("Group").setTooltip("Inherit from parent group.").setActive(false),
		new scrollItem("Pixel"),
		new scrollItem("Bilinear"),
		new scrollItem("Bicubic"),
		new scrollItem("Lanczos3"),
	];
	
	global.SURFACE_OVERSAMPLE = [
		new scrollItem("Group").setTooltip("Inherit from parent group.").setActive(false),
		new scrollItem("Empty"), 
		new scrollItem("Clamp"), 
		new scrollItem("Repeat"),
		new scrollItem("Black"),
	];
	
	function __initSurfaceFormat() {
		var _surface_format = [
			-1,
			-2,
			surface_rgba4unorm,
			surface_rgba8unorm,
			surface_rgba16float,
			surface_rgba32float,
			surface_r8unorm,
			surface_r16float,
			surface_r32float,
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
		global.SURFACE_FORMAT_SUPP  = []; 
	
		for( var i = 0, n = array_length(_surface_format); i < n; i++ ) {
			var _form = _surface_format[i];
			var _supp = _form < 0 || surface_format_is_supported(_form);
			
			array_push(global.SURFACE_FORMAT,      _form);
			array_push(global.SURFACE_FORMAT_NAME, surface_format_name[i]);
			array_push(global.SURFACE_FORMAT_SUPP, _supp);
			
			if(!_supp) {
				log_message("WARNING", $"Surface format [{surface_format_name[i].name}] not supported on this device.");
				surface_format_name[i].setActive(false);
			}
		}
	}
#endregion
	
#region attribute
	function attribute_property(_editor) constructor {
		name       = _editor[0];
		getter     = _editor[1];
		editWidget = _editor[2];
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
		attributes.color_depth = PREFERENCES.node_default_depth;
		
		attr_depth_array = variable_clone(global.SURFACE_FORMAT_NAME);
		attr_depth_array[0].setActive(!array_empty(inputs) && inputs[0].type == VALUE_TYPE.surface);
		
		color_depth_selector = new scrollBox(attr_depth_array, function(val) /*=>*/ { attribute_set("color_depth", val); }, false);
		color_depth_editor   = [ "Color depth", function() /*=>*/ {return attributes.color_depth}, color_depth_selector ];
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, color_depth_editor);
		checkGroupAttribute(color_depth_editor);
		
		array_push(attributes_properties, new attribute_property(color_depth_editor));
	}
	
	function attribute_interpolation(label = false) {
		attributes.interpolate = PREFERENCES.node_default_interpolation;
		attributes.oversample  = PREFERENCES.node_default_oversample;
		
		attr_interpolate_array = variable_clone(global.SURFACE_INTERPOLATION);
		
		interpolate_selector   = new scrollBox(attr_interpolate_array, function(val) /*=>*/ { attribute_set("interpolate", val); }, false);
		interpolate_editor     = [ "Texture interpolation", function() /*=>*/ {return attributes.interpolate}, interpolate_selector, new KeyCombination("I", MOD_KEY.alt) ];
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, interpolate_editor);
		checkGroupAttribute(interpolate_editor);
		
		array_push(attributes_properties, new attribute_property(interpolate_editor));
	}
	
	function attribute_oversample(label = false) {
		attributes.interpolate = PREFERENCES.node_default_interpolation;
		attributes.oversample  = PREFERENCES.node_default_oversample;
		
		attr_oversample_array  = variable_clone(global.SURFACE_OVERSAMPLE);
		oversample_selector    = new scrollBox(attr_oversample_array, function(val) /*=>*/ { attribute_set("oversample", val); }, false);
		oversample_editor      = [ "Oversample", function() /*=>*/ {return attributes.oversample}, oversample_selector, new KeyCombination("O", MOD_KEY.alt) ];
		
		if(label) array_push(attributeEditors, "Surface");
		array_push(attributeEditors, oversample_editor);
		checkGroupAttribute(oversample_editor);
		
		array_push(attributes_properties, new attribute_property(oversample_editor));
	}
	
	function attribute_auto_execute(label = false) {
		attributes.auto_exe = false;
		
		if(label) array_push(attributeEditors, "Node");
		array_push(attributeEditors, ["Auto execute", function() /*=>*/ {return attributes.auto_exe}, 
			new checkBox(function() /*=>*/ { attribute_set("auto_exe", !attributes.auto_exe); })]);
	}
	
	function attribute_drawOverlay(hover, active) {
		if(has(self, "interpolate_editor") && interpolate_editor[3].isPressing()) {
			attributes.interpolate = (attributes.interpolate + 1) % array_length(global.SURFACE_INTERPOLATION);
			triggerRender();
			
			PANEL_PREVIEW.setActionTooltip($"Set Interpolate: {global.SURFACE_INTERPOLATION[attributes.interpolate].name}");
		}
		
		if(has(self, "oversample_editor") && oversample_editor[3].isPressing()) {
			attributes.oversample = (attributes.oversample + 1) % array_length(global.SURFACE_OVERSAMPLE);
			triggerRender();
			
			PANEL_PREVIEW.setActionTooltip($"Set Oversample: {global.SURFACE_OVERSAMPLE[attributes.oversample].name}");
		}
		
	}
	
#endregion