function Node_VFX_Renderer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Renderer";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	
	use_cache = CACHE_USE.auto;
	
	inputs[| 0] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Round position to the closest integer value to avoid jittering.")
		.rejectArray();
	
	input_display_list = [ 0, 1 ];
	
	setIsDynamicInput(2);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		
		inputs[| index + 0] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
			.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Alpha", "Additive" ])
			.rejectArray();
		
		inputs[| index + 1] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, noone )
			.setVisible(true, true);
		
		array_push(input_display_list, ["Particle", false], index + 0, index + 1);
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static refreshDynamicInput = function() { #region
		var _l    = ds_list_create();
		var _disp = [];
		
		for( var i = 0; i < input_fix_len ; i ++ ) {
			ds_list_add(_l, inputs[| i]);
			array_push(_disp, i);
		}
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(!inputs[| i + 1].value_from) continue;
			
			ds_list_add(_l, inputs[| i + 0]);
			ds_list_add(_l, inputs[| i + 1]);
			
			array_push(_disp, ["Particle", false], i + 0, i + 1);
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		input_display_list = _disp;
		
		createNewInput();
	} #endregion
	
	static onValueFromUpdate = function(index) { #region
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	} #endregion
	
	static step = function() { #region
		var _dim		= getInputData(0);
		var _outSurf	= outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[| 0].setValue(_outSurf);
		
		if(previewing && is_instanceof(group, Node_VFX_Group)) 
			group.preview_node = self;
	} #endregion
	
	static update = function(_time = CURRENT_FRAME) { #region
		if(!IS_PLAYING) {
			recoverCache();
			return;
		}
		
		var _dim	= inputs[| 0].getValue(_time);
		var _exact 	= inputs[| 1].getValue(_time);
		
		var _outSurf	= outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[| 0].setValue(_outSurf);
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_outSurf);
			var surf_w = surface_get_width_safe(_outSurf);
			var surf_h = surface_get_height_safe(_outSurf);
			
			for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
				var blend = inputs[| i + 0].getValue(_time);
				var parts = inputs[| i + 1].getValue(_time);
				
				switch(blend) {
					case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL; break;
					case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA;  break;
					case PARTICLE_BLEND_MODE.additive: BLEND_ADD;    break;
				}
				
				if(!is_array(parts) || array_length(parts) == 0) continue;
				if(!is_array(parts[0])) parts = [ parts ];
				
				for(var j = 0; j < array_length(parts); j++)
				for(var k = 0; k < array_length(parts[j]); k++) {
					if(!parts[j][k].active) continue;
					parts[j][k].draw(_exact, surf_w, surf_h);
				}
			}
			
			BLEND_NORMAL;
		surface_reset_shader();
		
		cacheCurrentFrame(_outSurf);
	} #endregion
		
	getPreviewingNode = VFX_PREVIEW_NODE;
}