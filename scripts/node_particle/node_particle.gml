function Node_Particle(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name = "Particle";
	use_cache = CACHE_USE.auto;
	var i = input_len;
	
	////- =Output
	newInput(i+3, nodeValue_Surface( "Background" ));
	newInput(i+0, nodeValue_Dimension());
	
	////- =Render
	newInput(i+4, nodeValue_Enum_Button( "Render Type",    PARTICLE_RENDER_TYPE.surface , [ "Surface", "Line" ]));
	newInput(i+5, nodeValue_Int(         "Line Life",      4 ));
	newInput(i+1, nodeValue_Bool(        "Round Position", true, "Round position to the closest integer value to avoid jittering."));
	newInput(i+2, nodeValue_Enum_Scroll( "Blend Mode",     0, [ "Normal", "Alpha", "Additive", "Maximum" ]));
	
	//input i+6
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()}, i);
	
	array_insert( input_display_list, 1, ["Output", true], i+3, i+0);
	array_insert_after( input_display_list, 56, [
		["Render", true], i+4, i+5, 21, i+1, i+2
	]);
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation();
	
	attributes.cache = true;
	array_push(attributeEditors,   "Cache" );
	array_push(attributeEditors, [ "Cache Data", function() /*=>*/ {return attributes.cache}, new checkBox(function() /*=>*/ {return toggleAttribute("cache")}) ]);
	
	def_surface    = -1;
	curr_dimension = [ 0, 0 ];
	render_amount  = 0;
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() /*=>*/ { clearCache(); }
	
	static getDimension = function() /*=>*/ {return inputs[input_len].getValue()};
	
	static onValueUpdate = function(index = 0) {
		if(index == input_len + 0) {
			var _dim		= getInputData(input_len + 0);
			var _outSurf	= outputs[0].getValue();
			
			_outSurf = surface_verify(_outSurf, array_safe_get_fast(_dim, 0, 1), array_safe_get_fast(_dim, 1, 1), attrDepth());
			outputs[0].setValue(_outSurf);
		}
	}
	
	static reLoop = function() {
		var _loop = getInputData(21);
		var _prer = getInputData(65); if(_prer == -1) _prer = TOTAL_FRAMES;
		var _type = getInputData(input_len + 4);
		
		if(!_loop) return;
		
		for(var i = TOTAL_FRAMES - _prer; i < TOTAL_FRAMES; i++) {
			runVFX(i, _type);
			updateParticleForward();
		}
		
		seed = getInputData(32);
	}
	
	static preUpdate = function() /*=>*/ {
		var _dim = getInputData(input_len + 0);
		
		if(curr_dimension[0] != _dim[0] || curr_dimension[1] != _dim[1]) {
			clearCache();
			
			curr_dimension[0] = _dim[0];
			curr_dimension[1] = _dim[1];
		}
	}
	
	static onUpdate = function(frame = CURRENT_FRAME) {
		use_cache = attributes.cache? CACHE_USE.auto : CACHE_USE.none;
		
		var _inSurf  = getInputData(0);
		var _dim	 = getInputData(input_len + 0);
		var _bg 	 = getInputData(input_len + 3);
		var _typ     = getInputData(input_len + 4);
		var _outSurf = outputs[0].getValue();
		
		inputs[input_len + 5].setVisible(_typ == PARTICLE_RENDER_TYPE.line);
		
		if(is_surface(_bg)) _dim = surface_get_dimension(_bg)
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		render_amount = 0;		
		
		outputs[0].setValue(_outSurf);
		
		if(IS_FIRST_FRAME) { reset(); reLoop(); }
		
		runVFX(frame);
	}
	
	function render(_time = CURRENT_FRAME) {
		var _dim   = inputs[input_len + 0].getValue(_time);
		var _exact = inputs[input_len + 1].getValue(_time);
		var _blend = inputs[input_len + 2].getValue(_time);
		var _bg    = inputs[input_len + 3].getValue(_time);
		
		var _type  = inputs[input_len + 4].getValue(_time);
		var _llife = inputs[input_len + 5].getValue(_time);
		
		var _outSurf = outputs[0].getValue();
		
		if(is_surface(_bg)) _dim = surface_get_dimension(_bg)
		
		surface_set_shader(_outSurf, _type == PARTICLE_RENDER_TYPE.surface? sh_sample : noone);
			draw_surface_safe(_bg);
			
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL break;
				case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA  break;
				case PARTICLE_BLEND_MODE.additive: BLEND_ADD    break;
				case PARTICLE_BLEND_MODE.maximum:  BLEND_MAX    break;
				case PARTICLE_BLEND_MODE.minimum:  
					draw_clear_alpha(c_white, 0.);
					draw_surface_safe(_bg);
					BLEND_MIN   
					break;
			}
			
			if(_type == PARTICLE_RENDER_TYPE.surface)
				shader_set_interpolation(_outSurf);
			
			for(var i = 0; i < attributes.part_amount; i++) {
				parts[i].render_type = _type;
				parts[i].line_draw   = _llife;
				
				if(parts[i].active || _type) parts[i].draw(_exact, _dim[0], _dim[1]);
			}
			
		surface_reset_shader();	
		
		if(GLOBAL_IS_PLAYING) cacheCurrentFrame(_outSurf);
	}
	
}