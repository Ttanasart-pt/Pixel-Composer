function Node_Particle(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name = "Particle";
	use_cache = CACHE_USE.auto;

	onSurfaceSize = function() { return getInputData(input_len, DEF_SURF); };
	inputs[| 3].setDisplay(VALUE_DISPLAY.area, { onSurfaceSize });
	
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
	
	def_surface = -1;
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static onValueUpdate = function(index = 0) { #region
		if(index == input_len + 0) {
			var _dim		= getInputData(input_len + 0);
			var _outSurf	= outputs[| 0].getValue();
			
			_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			outputs[| 0].setValue(_outSurf);
		}
		
		if(PROJECT.animator.is_playing)
			PROJECT.animator.setFrame(-1);
	} #endregion
	
	static onStep = function() { #region
		var _dim		= getInputData(input_len + 0);
		var _outSurf	= outputs[| 0].getValue();
			
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[| 0].setValue(_outSurf);
	} #endregion
	
	static onUpdate = function() { #region
		if(ANIMATION_STATIC) {
			if(!recoverCache()) {
				var _dim		= getInputData(input_len + 0);
				var _outSurf	= outputs[| 0].getValue();
				_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
				outputs[| 0].setValue(_outSurf);
			}
			return;
		}
		
		if(recoverCache())
			return;
		
		if(PROJECT.animator.current_frame == 0)
			reset();
		runVFX(PROJECT.animator.current_frame);
	} #endregion
	
	function render(_time = PROJECT.animator.current_frame) { #region
		var _dim		= inputs[| input_len + 0].getValue(_time);
		var _exact 		= inputs[| input_len + 1].getValue(_time);
		var _blend 		= inputs[| input_len + 2].getValue(_time);
		
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
			
			//print($"===== Drawing frame {_time} =====");
			for(var i = 0; i < attributes.part_amount; i++) {
				if(!parts[i].active) continue;
				//print($"    > Draw part {i} = ({parts[i].x}, {parts[i].y})");
				parts[i].draw(_exact, surf_w, surf_h);
			}
			
			BLEND_NORMAL;
		surface_reset_shader();
		
		if(PROJECT.animator.is_playing) {
			//print($"Cache frame {PROJECT.animator.current_frame}");
			cacheCurrentFrame(_outSurf);
		}
	} #endregion
		
	
}