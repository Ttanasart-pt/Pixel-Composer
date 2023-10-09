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
	
	inputs[| 2] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Alpha", "Additive" ])
		.rejectArray();
	
	setIsDynamicInput(1);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, noone )
			.setVisible(true, true);
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
		
	static createOutput = function(override_order = true) { #region
		if(group == noone) return;
		if(!is_struct(group)) return;
		
		if(override_order)
			attributes.input_priority = ds_list_size(group.outputs);
			
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
		var _l = ds_list_create();
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
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
		
		var _dim	= inputs[| 0].getValue(_time);
		var _exact 	= inputs[| 1].getValue(_time);
		var _blend 	= inputs[| 2].getValue(_time);
		
		var _outSurf	= outParent.getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outParent.setValue(_outSurf);
		
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
			
			for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
				var parts = inputs[| i].getValue(_time);
				
				if(!is_array(parts) || array_length(parts) == 0) continue;
				if(!is_array(parts[0])) parts = [ parts ];
				
				//var drawnParts = 0;
				
				for(var j = 0; j < array_length(parts); j++)
				for(var k = 0; k < array_length(parts[j]); k++) {
					if(!parts[j][k].active) continue;
					
					//drawnParts++;
					parts[j][k].draw(_exact, surf_w, surf_h);
				}
				
				//print($"Renderer input index {i}: {drawnParts} particles drawn.");
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