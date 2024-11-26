function Node_VFX_Renderer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Renderer";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	use_cache = CACHE_USE.auto;
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue_Vec2("Output dimension", self, DEF_SURF ));
		
	newInput(1, nodeValue_Bool("Round position", self, true, "Round position to the closest integer value to avoid jittering."))
		.rejectArray();
	
	newInput(2, nodeValue_Enum_Button("Render Type", self,  PARTICLE_RENDER_TYPE.surface , [ "Surface", "Line" ]))
		.rejectArray();
	
	newInput(3, nodeValue_Int("Line life", self, 4 ))
		.rejectArray();
		
	input_display_list = [ 
		["Output",    false], 0, 
		["Rendering", false], 1, 2, 3, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static createNewInput = function() {
		var index = array_length(inputs);
		
		newInput(index + 0, nodeValue_Enum_Scroll("Blend mode", self,  0 , [ "Normal", "Alpha", "Additive" ]))
			.rejectArray();
		
		newInput(index + 1, nodeValue_Particle("Particles", self, noone ))
			.setVisible(true, true);
		
		array_push(input_display_list, ["Particle", false], index + 0, index + 1);
		
		return inputs[index + 1];
	} 
	
	setDynamicInput(2, true, VALUE_TYPE.particle);
	dyna_input_check_shift = 1;
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() { clearCache(); }
	
	static step = function() { #region
		var _typ = getInputData(2);
		
		inputs[3].setVisible(_typ == PARTICLE_RENDER_TYPE.line);
		
		if(previewing && is_instanceof(group, Node_VFX_Group)) 
			group.preview_node = self;
	} #endregion
	
	static update = function(_time = CURRENT_FRAME) { #region
		if(!IS_PLAYING) {
			recoverCache();
			return;
		}
		
		var _dim   = inputs[0].getValue(_time);
		var _exact = inputs[1].getValue(_time);
		var _type  = inputs[2].getValue(_time);
		var _llife = inputs[3].getValue(_time);
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[0].setValue(_outSurf);
		
		var surf_w = surface_get_width_safe(_outSurf);
		var surf_h = surface_get_height_safe(_outSurf);
		
		surface_set_shader(_outSurf, _type == PARTICLE_RENDER_TYPE.surface? sh_sample : noone);
		if(_type == PARTICLE_RENDER_TYPE.surface)
			shader_set_interpolation(_outSurf);
			
			for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
				var blend = inputs[i + 0].getValue(_time);
				var parts = inputs[i + 1].getValue(_time);
				
				switch(blend) {
					case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL; break;
					case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA;  break;
					case PARTICLE_BLEND_MODE.additive: BLEND_ADD;    break;
				}
				
				if(!is_array(parts) || array_length(parts) == 0) continue;
				if(!is_array(parts[0])) parts = [ parts ];
				
				for(var j = 0; j < array_length(parts); j++) {
					var part = parts[j];
					
					for(var k = 0; k < array_length(part); k++) {
						var _part = part[k];
						
						_part.render_type = _type;
						_part.line_draw   = _llife;
						
						if(_part.active || _type) _part.draw(_exact, surf_w, surf_h);
					}
				}
			}
			
			BLEND_NORMAL;
		surface_reset_shader();
		
		cacheCurrentFrame(_outSurf);
	} #endregion
		
	getPreviewingNode = VFX_PREVIEW_NODE;
}