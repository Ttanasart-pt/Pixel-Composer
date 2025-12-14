function Node_Particle(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name      = "Particle";
	setCacheAuto();
	var i = input_len;
	
	////- =Output
	newInput(i+3, nodeValue_Surface( "Background" ));
	newInput(i+0, nodeValue_Dimension());
	
	////- =Render
	newInput(i+4, nodeValue_Enum_Button( "Render Type",    PARTICLE_RENDER_TYPE.surface , [ "Surface", "Line" ] ));
	newInput(i+5, nodeValue_Int(         "Line Life",      4 ));
	newInput(i+1, nodeValue_Bool(        "Round Position", true, "Round position to the closest integer value to avoid jittering." ));
	newInput(i+2, nodeValue_Enum_Scroll( "Blend Mode",     0, [ "Normal", "Alpha", "Additive", "Maximum" ] ));
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
	// array_push(attributeEditors, [ "Cache Data", () => attributes.cache, new checkBox(() => toggleAttribute("cache", true)) ]);
	
	def_surface    = -1;
	curr_dimension = [0,0];
	render_amount  = 0;
	render_frame   = 0;
	
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
		var _dim = inputs[input_len + 0].getValue();
		
		if(curr_dimension[0] != _dim[0] || curr_dimension[1] != _dim[1]) {
			clearCache();
			
			curr_dimension[0] = _dim[0];
			curr_dimension[1] = _dim[1];
		}
	}
	
	static onUpdate = function(frame = CURRENT_FRAME) {
		if(frame != render_frame && !IS_FIRST_FRAME) return;
		
		var _inSurf  = getInputData(0);
		var _dim	 = getInputData(input_len + 0);
		var _bg 	 = getInputData(input_len + 3);
		var _typ     = getInputData(input_len + 4);
		var _outSurf = outputs[0].getValue();
		
		inputs[input_len + 5].setVisible(_typ == PARTICLE_RENDER_TYPE.line);
		
		if(is_surface(_bg)) _dim = surface_get_dimension(_bg);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		render_amount = 0;
		
		outputs[0].setValue(_outSurf);
		
		__dim = _dim;
		array_foreach(parts, function(p) /*=>*/ { p.bound_w = __dim[0]; p.bound_h = __dim[1]; });
		
		if(IS_FIRST_FRAME) { 
			reset(); 
			if(IS_PLAYING) reLoop();
			render_frame = 0;
		}
		
		runVFX(frame);
		render_frame++;
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
	}
	
}