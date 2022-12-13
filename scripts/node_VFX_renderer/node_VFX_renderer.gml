function Node_VFX_Renderer(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Renderer";
	
	inputs[| 0] = nodeValue(0, "Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2] = nodeValue(2, "Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 3] = nodeValue(3, "Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Additive" ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	function update(_time = ANIMATOR.current_frame) {
		var parts	= inputs[| 0].getValue(_time);
		var _dim	= inputs[| 1].getValue(_time);
		var _exact 	= inputs[| 2].getValue(_time);
		var _blend 	= inputs[| 3].getValue(_time);
		
		var _outSurf	= outputs[| 0].getValue();
		
		if(is_surface(_outSurf)) 
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		else {
			_outSurf = surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		}
		
		surface_set_target(_outSurf);
			draw_clear_alpha(c_white, 0);
			
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal :	gpu_set_blendmode(bm_normal);	break;
				case PARTICLE_BLEND_MODE.additive : gpu_set_blendmode(bm_add);		break;
			}
			
			for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
				parts[| i].draw(_exact);
			
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		cacheCurrentFrame(_outSurf);
	}
}