function Node_Particle(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name = "Particle";
	use_cache = CACHE_USE.auto;

	onSurfaceSize = function() { return getInputData(input_len, DEF_SURF); };
	
	inputs[| 3] = nodeValue_Area("Spawn area", self, DEF_AREA_REF, { onSurfaceSize } )
		.rejectArray()
		.setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	
	inputs[| input_len + 0] = nodeValue_Vector("Output dimension", self, DEF_SURF);
		
	inputs[| input_len + 1] = nodeValue_Bool("Round position", self, true, "Round position to the closest integer value to avoid jittering.");
	
	inputs[| input_len + 2] = nodeValue_Enum_Scroll("Blend mode", self,  0 , [ "Normal", "Alpha", "Additive" ]);
	
	inputs[| input_len + 3] = nodeValue_Surface("Background", self);
	
	inputs[| input_len + 4] = nodeValue_Enum_Button("Render Type", self,  PARTICLE_RENDER_TYPE.surface , [ "Surface", "Line" ]);
	
	inputs[| input_len + 5] = nodeValue_Int("Line life", self, 4 );
		
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	for(var i = input_len, n = ds_list_size(inputs); i < n; i++) inputs[| i].rejectArray();
	
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
	
	static onValueUpdate = function(index = 0) {
		if(index == input_len + 0) {
			var _dim		= getInputData(input_len + 0);
			var _outSurf	= outputs[| 0].getValue();
			
			_outSurf = surface_verify(_outSurf, array_safe_get_fast(_dim, 0, 1), array_safe_get_fast(_dim, 1, 1), attrDepth());
			outputs[| 0].setValue(_outSurf);
		}
		
		if(PROJECT.animator.is_playing)
			PROJECT.animator.firstFrame();
	}
	
	static reLoop = function() {
		var _loop = getInputData(21);
		var _type = getInputData(input_len + 4);
		
		if(!_loop) return;
		
		for(var i = 0; i < TOTAL_FRAMES; i++) {
			runVFX(i, _type);
			updateParticleForward();
		}
		
		seed = getInputData(32);
	}
	
	static onStep = function() {
		var _dim = getInputData(input_len + 0);
		var _typ = getInputData(input_len + 4);
		
		inputs[| input_len + 5].setVisible(_typ == PARTICLE_RENDER_TYPE.line);
		
		if(curr_dimension[0] != _dim[0] || curr_dimension[1] != _dim[1]) {
			clearCache();
			
			curr_dimension[0] = _dim[0];
			curr_dimension[1] = _dim[1];
		}
	}
	
	static onUpdate = function(frame = CURRENT_FRAME) {
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
	}
	
	function render(_time = CURRENT_FRAME) {
		var _dim   = inputs[| input_len + 0].getValue(_time);
		var _exact = inputs[| input_len + 1].getValue(_time);
		var _blend = inputs[| input_len + 2].getValue(_time);
		var _bg    = inputs[| input_len + 3].getValue(_time);
		
		var _type  = inputs[| input_len + 4].getValue(_time);
		var _llife = inputs[| input_len + 5].getValue(_time);
		
		var _outSurf = outputs[| 0].getValue();
		
		if(is_surface(_bg)) _dim = surface_get_dimension(_bg)
		
		surface_set_shader(_outSurf, _type == PARTICLE_RENDER_TYPE.surface? sh_sample : noone);
			if(is_surface(_bg))  draw_surface_safe(_bg);
			
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
	}	
}