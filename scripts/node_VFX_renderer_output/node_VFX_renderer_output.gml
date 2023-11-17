function Node_VFX_Renderer_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name = "Renderer";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	use_cache = CACHE_USE.auto;
	
	w = 128;
	h = 128;
	min_h = h;
	previewable = true;
	
	inputs[| 0] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Round position to the closest integer value to avoid jittering.")
		.rejectArray();
	
	input_display_list = [ 0, 1 ];
	
	setIsDynamicInput(2);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		
		inputs[| index + 0] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
			.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Alpha", "Additive" ])
			.rejectArray();
		
		inputs[| index + 1] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, noone )
			.setVisible(true, true);
			
		array_push(input_display_list, ["Particle", false], index + 0, index + 1);
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
		
	static createOutput = function() { #region
		if(group == noone) return;
		if(!is_struct(group)) return;
			
		if(!is_undefined(outParent))
			ds_list_remove(group.outputs, outParent);
			
		outParent = nodeValue("Rendered", group, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone)
			.uncache()
			.setVisible(true, true);
		outParent.from = self;
		
		ds_list_add(group.outputs, outParent);
		group.setHeight();
		group.sortIO();
	} if(!LOADING && !APPENDING) createOutput(); #endregion
	
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
		var _outSurf	= outParent.getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outParent.setValue(_outSurf);
		
		if(previewing && is_instanceof(group, Node_VFX_Group)) 
			group.preview_node = self;
	} #endregion
	
	static update = function(_time = CURRENT_FRAME) { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		if(!IS_PLAYING) {
			recoverCache();
			return;
		}
		
		var _dim	= inputs[| 0].getValue(_time);
		var _exact 	= inputs[| 1].getValue(_time);
		
		var _outSurf	= outParent.getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outParent.setValue(_outSurf);
		
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
		
	static recoverCache = function(frame = CURRENT_FRAME) { #region
		if(!is_instanceof(outParent, NodeValue)) return false;
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[CURRENT_FRAME];
		outParent.setValue(_s);
			
		return true;
	} #endregion
	
	static getGraphPreviewSurface = function() { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	} #endregion
	
	static getPreviewValues = function() { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	} #endregion
		
	getPreviewingNode = VFX_PREVIEW_NODE;
}