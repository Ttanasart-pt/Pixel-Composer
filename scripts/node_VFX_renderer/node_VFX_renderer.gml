function Node_VFX_Renderer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Renderer";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	
	use_cache = true;
	
	inputs[| 0] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Round position to the closest integer value to avoid jittering.")
		.rejectArray();
	
	inputs[| 2] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Alpha", "Additive" ])
		.rejectArray();
	
	setIsDynamicInput(1);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, noone )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static step = function() {
		var _dim		= getInputData(0);
		var _outSurf	= outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[| 0].setValue(_outSurf);
	}
	
	static update = function(_time = PROJECT.animator.current_frame) {
		if(!PROJECT.animator.is_playing) {
			recoverCache();
			return;
		}
		
		var _dim	= inputs[| 0].getValue(_time);
		var _exact 	= inputs[| 1].getValue(_time);
		var _blend 	= inputs[| 2].getValue(_time);
		
		var _outSurf	= outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[| 0].setValue(_outSurf);
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_outSurf);
		
			if(_blend == PARTICLE_BLEND_MODE.normal)
				BLEND_NORMAL;
			else if(_blend == PARTICLE_BLEND_MODE.alpha) 
				BLEND_ALPHA;
			else if(_blend == PARTICLE_BLEND_MODE.additive) 
				BLEND_ADD;
			
			var surf_w = surface_get_width_safe(_outSurf);
			var surf_h = surface_get_height_safe(_outSurf);
			
			for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
				var parts = inputs[| i].getValue(_time);
				
				if(!is_array(parts) || array_length(parts) == 0) continue;
				if(!is_array(parts[0])) parts = [ parts ];
				
				for(var j = 0; j < array_length(parts); j++)
				for(var k = 0; k < array_length(parts[j]); k++) {
					if(!parts[j][k].active) continue;
					parts[j][k].draw(_exact, surf_w, surf_h);
				}
			}
			
			BLEND_NORMAL;
		surface_reset_shader();
		
		cacheCurrentFrame(_outSurf);
	}
}