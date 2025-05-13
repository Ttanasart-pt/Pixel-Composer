function Node_VFX_Renderer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Renderer";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	use_cache = CACHE_USE.auto;
	
	inline_output      = false;
	manual_ungroupable = false;
	
	newInput(0, nodeValue_Vec2("Output dimension", self, DEF_SURF ));
		
	newInput(1, nodeValue_Bool("Round position", self, true, "Round position to the closest integer value to avoid jittering."))
		.rejectArray();
	
	newInput(2, nodeValue_Enum_Button("Render Type", self,  PARTICLE_RENDER_TYPE.surface , [ "Surface", "Line" ]))
		.rejectArray();
	
	newInput(3, nodeValue_Int("Line life", self, 4 ))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		["Rendering", false], 1, 2, 3, 
	];
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static createNewInput = function(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Enum_Scroll("Blend mode", self,  0 , [ "Normal", "Alpha", "Additive" ]))
			.rejectArray();
		
		newInput(index + 1, nodeValue_Particle("Particles", self, noone ))
			.setVisible(true, true);
		
		array_push(input_display_list, ["Particle", false], inAmo + 0, inAmo + 1);
		return inputs[index + 1];
	}
	
	setDynamicInput(2, true, VALUE_TYPE.particle);
	dyna_input_check_shift = 1;
	
	attributes.cache = true;
	array_push(attributeEditors, "Cache");
	array_push(attributeEditors, [ "Cache Data", function() /*=>*/ {return attributes.cache}, new checkBox(function() /*=>*/ {return toggleAttribute("cache")}) ]);
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() /*=>*/ {return clearCache()};
	
	static step = function() {
		use_cache = attributes.cache? CACHE_USE.auto : CACHE_USE.none;
		
		var _typ = getInputData(2);
		
		inputs[3].setVisible(_typ == PARTICLE_RENDER_TYPE.line);
		
		if(previewing && is(group, Node_VFX_Group)) 
			group.preview_node = self;
	}
	
	static update = function(_time = CURRENT_FRAME) {
		var _dim   = inline_context.dimension;
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		
		var _exact = inputs[1].getValue(_time);
		var _type  = inputs[2].getValue(_time);
		var _llife = inputs[3].getValue(_time);
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[0].setValue(_outSurf);
		
		var surf_w = surface_get_width_safe(_outSurf);
		var surf_h = surface_get_height_safe(_outSurf);
		
		surface_set_shader(_outSurf, noone);
			var blend, parts, part, _part;
			
			for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
				blend = inputs[i + 0].getValue(_time);
				parts = inputs[i + 1].getValue(_time);
				
				switch(blend) {
					case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL break;
					case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA  break;
					case PARTICLE_BLEND_MODE.additive: BLEND_ADD    break;
				}
				
				if(!is_array(parts) || array_length(parts) == 0) continue;
				if(!is_array(parts[0])) parts = [ parts ];
				
				for( var j = 0, m = array_length(parts); j < m; j++ ) {
					part = parts[j];
					
					for( var k = 0, p = array_length(part); k < p; k++ ) {
						_part = part[k];
						_part.render_type = _type;
						_part.line_draw   = _llife;
						
						if(_part.active || _type) _part.draw(_exact, surf_w, surf_h);
					}
				}
			}
			
			BLEND_NORMAL
		surface_reset_shader();
		
		cacheCurrentFrame(_outSurf);
	}

	static getPreviewValues = function() {
		var val = outputs[preview_channel].getValue();
		return is_surface(val)? val : temp_surface[0];
	}
}