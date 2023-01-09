function Node_VFX_Renderer(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Renderer";
	
	inputs[| 0] = nodeValue(0, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 1] = nodeValue(1, "Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 2] = nodeValue(2, "Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Additive" ]);
	
	data_length = 1;
	input_fix_len = ds_list_size(inputs);
		
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, "Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, noone )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
		
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
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
	
	function update(_time = ANIMATOR.current_frame) {
		var _dim	= inputs[| 0].getValue(_time);
		var _exact 	= inputs[| 1].getValue(_time);
		var _blend 	= inputs[| 2].getValue(_time);
		
		var _outSurf	= outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(c_white, 0);
			
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal :	gpu_set_blendmode(bm_normal);	break;
				case PARTICLE_BLEND_MODE.additive : gpu_set_blendmode(bm_add);		break;
			}
			
			for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
				var parts = inputs[| i].getValue(_time);
				if(!ds_exists(parts, ds_type_list)) continue;
				
				for(var j = 0; j < ds_list_size(parts); j++) {
					if(!parts[| j].active) continue;
					parts[| j].draw(_exact);
				}
			}
			
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		cacheCurrentFrame(_outSurf);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}