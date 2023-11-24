function Node_Particle(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name = "Particle";
	use_cache = CACHE_USE.auto;

	onSurfaceSize = function() { return getInputData(input_len, DEF_SURF); };
	inputs[| 3].setDisplay(VALUE_DISPLAY.area, { onSurfaceSize });
	
	inputs[| 22].setDisplay(VALUE_DISPLAY.enum_scroll, [ "Random", "Order", "Animation", "Array" ]);
		
	inputs[| input_len + 0] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| input_len + 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Round position to the closest integer value to avoid jittering.")
		.rejectArray();
	
	inputs[| input_len + 2] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Alpha", "Additive" ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	array_insert(input_display_list, 0, ["Output", true], input_len + 0);
	array_push(input_display_list, input_len + 1, input_len + 2);
	
	def_surface   = -1;
	render_amount = 0;
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static onValueUpdate = function(index = 0) { #region
		if(index == input_len + 0) {
			var _dim		= getInputData(input_len + 0);
			var _outSurf	= outputs[| 0].getValue();
			
			_outSurf = surface_verify(_outSurf, array_safe_get(_dim, 0, 1), array_safe_get(_dim, 1, 1), attrDepth());
			outputs[| 0].setValue(_outSurf);
		}
		
		if(PROJECT.animator.is_playing)
			PROJECT.animator.setFrame(-1);
	} #endregion
	
	static reLoop = function() { #region
		var _loop = getInputData(21);
		if(!_loop) return;
		
		for(var i = 0; i < TOTAL_FRAMES; i++) {
			runVFX(i, false);
			updateParticleForward();
		}
		
		seed = getInputData(32);
	} #endregion
	
	static onUpdate = function(frame = CURRENT_FRAME) { #region
		var _inSurf   = getInputData(0);
		var _arr_type = getInputData(22);
		var _dim	  = getInputData(input_len + 0);
		var _outSurf  = outputs[| 0].getValue();
		
		if(is_array(_inSurf) && _arr_type == 3) {
			var _len = array_length(_inSurf);
			if(!is_array(_outSurf)) 
				_outSurf = array_create(_len);
			else if(array_length(_outSurf) != _len) 
				array_resize(_outSurf, _len);
				
			for( var i = 0; i < _len; i++ )
				_outSurf[i] = surface_verify(_outSurf[i], _dim[0], _dim[1], attrDepth());
			render_amount = _len;
		} else {
			_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			render_amount = 0;		
		}
		
		outputs[| 0].setValue(_outSurf);
		
		if(CURRENT_FRAME == 0) {
			reset();
			reLoop();
		}
		
		if(IS_PLAYING) runVFX(frame);
	} #endregion
	
	function render(_time = CURRENT_FRAME) { #region
		var _dim		= inputs[| input_len + 0].getValue(_time);
		var _exact 		= inputs[| input_len + 1].getValue(_time);
		var _blend 		= inputs[| input_len + 2].getValue(_time);
		var _outSurf	= outputs[| 0].getValue();
		
		if(render_amount == 0) {
			surface_set_shader(_outSurf);
			
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL; break;
				case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA;  break;
				case PARTICLE_BLEND_MODE.additive: BLEND_ADD;    break;
			}
		
			shader_set_interpolation(_outSurf);
				for(var i = 0; i < attributes.part_amount; i++)
					if(parts[i].active) parts[i].draw(_exact, _dim[0], _dim[1]);
			surface_reset_shader();	
		} else if(is_array(_outSurf)) {
			for( var o = 0, n = array_length(_outSurf); o < n; o++ ) {
				surface_set_shader(_outSurf[o]);
				
				switch(_blend) {
					case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL; break;
					case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA;  break;
					case PARTICLE_BLEND_MODE.additive: BLEND_ADD;    break;
				}
		
				shader_set_interpolation(_outSurf[o]);
					for(var i = 0; i < attributes.part_amount; i++)
						if(parts[i].active) parts[i].draw(_exact, _dim[0], _dim[1], o);
				surface_reset_shader();
			}
		}
		
		BLEND_NORMAL
		
		if(PROJECT.animator.is_playing)
			cacheCurrentFrame(_outSurf);
	} #endregion	
}