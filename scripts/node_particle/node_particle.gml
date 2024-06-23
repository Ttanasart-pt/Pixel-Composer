function Node_Particle(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name = "Particle";
	use_cache = CACHE_USE.auto;

	onSurfaceSize = function() { return getInputData(input_len, DEF_SURF); };
	
	inputs[| 3] = nodeValue("Spawn area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_AREA_REF )
		.rejectArray()
		.setUnitRef(onSurfaceSize, VALUE_UNIT.reference)
		.setDisplay(VALUE_DISPLAY.area, { onSurfaceSize });
	
	inputs[| input_len + 0] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| input_len + 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Round position to the closest integer value to avoid jittering.")
		.rejectArray();
	
	inputs[| input_len + 2] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Alpha", "Additive" ]);
	
	inputs[| input_len + 3] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.rejectArray();
	
	inputs[| input_len + 4] = nodeValue("Render Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, PARTICLE_RENDER_TYPE.surface )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Surface", "Line" ])
		.rejectArray();
	
	inputs[| input_len + 5] = nodeValue("Line life", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 )
		.rejectArray()
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	array_insert(        input_display_list, 0,  ["Output", true], input_len + 3, input_len + 0);
	array_push(          input_display_list,     input_len + 1, input_len + 2);
	array_insert_before( input_display_list, 21, [ input_len + 4, input_len + 5 ]);
	
	def_surface    = -1;
	curr_dimension = [ 0, 0 ];
	render_amount  = 0;
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static onValueUpdate = function(index = 0) { #region
		if(index == input_len + 0) {
			var _dim		= getInputData(input_len + 0);
			var _outSurf	= outputs[| 0].getValue();
			
			_outSurf = surface_verify(_outSurf, array_safe_get_fast(_dim, 0, 1), array_safe_get_fast(_dim, 1, 1), attrDepth());
			outputs[| 0].setValue(_outSurf);
		}
		
		if(PROJECT.animator.is_playing)
			PROJECT.animator.firstFrame();
	} #endregion
	
	static reLoop = function() { #region
		var _loop = getInputData(21);
		var _type = getInputData(input_len + 4);
		
		if(!_loop) return;
		
		for(var i = 0; i < TOTAL_FRAMES; i++) {
			runVFX(i, _type);
			updateParticleForward();
		}
		
		seed = getInputData(32);
	} #endregion
	
	static onStep = function() { #region
		var _dim = getInputData(input_len + 0);
		var _typ = getInputData(input_len + 4);
		
		inputs[| input_len + 5].setVisible(_typ == PARTICLE_RENDER_TYPE.line);
		
		if(curr_dimension[0] != _dim[0] || curr_dimension[1] != _dim[1]) {
			clearCache();
			
			curr_dimension[0] = _dim[0];
			curr_dimension[1] = _dim[1];
		}
	} #endregion
	
	static onUpdate = function(frame = CURRENT_FRAME) { #region
		var _inSurf   = getInputData(0);
		var _dim	  = getInputData(input_len + 0);
		var _bg 	  = getInputData(input_len + 3);
		
		var _outSurf  = outputs[| 0].getValue();
		
		if(is_surface(_bg)) _dim = surface_get_dimension(_bg)
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		render_amount = 0;		
		
		outputs[| 0].setValue(_outSurf);
		
		if(IS_FIRST_FRAME) {
			reset();
			if(IS_PLAYING) reLoop();
		}
		
		if(IS_PLAYING) runVFX(frame);
	} #endregion
	
	function render(_time = CURRENT_FRAME) { #region
		var _dim   = inputs[| input_len + 0].getValue(_time);
		var _exact = inputs[| input_len + 1].getValue(_time);
		var _blend = inputs[| input_len + 2].getValue(_time);
		var _bg    = inputs[| input_len + 3].getValue(_time);
		
		var _type  = inputs[| input_len + 4].getValue(_time);
		var _llife = inputs[| input_len + 5].getValue(_time);
		
		var _outSurf = outputs[| 0].getValue();
		
		if(is_surface(_bg)) _dim = surface_get_dimension(_bg)
		
		surface_set_shader(_outSurf, _type == PARTICLE_RENDER_TYPE.surface? sh_sample : noone);
			if(is_surface(_bg))  draw_surface(_bg, 0, 0);
			
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL; break;
				case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA;  break;
				case PARTICLE_BLEND_MODE.additive: BLEND_ADD;    break;
			}
			
			if(_type == PARTICLE_RENDER_TYPE.surface)
				shader_set_interpolation(_outSurf);
			
			for(var i = 0; i < attributes.part_amount; i++) {
				parts[i].render_type = _type;
				parts[i].line_draw   = _llife;
				
				if(parts[i].active || _type) parts[i].draw(_exact, _dim[0], _dim[1]);
			}
		surface_reset_shader();	
		
		if(PROJECT.animator.is_playing)
			cacheCurrentFrame(_outSurf);
	} #endregion	
}