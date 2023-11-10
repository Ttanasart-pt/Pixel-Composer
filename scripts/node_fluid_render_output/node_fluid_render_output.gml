function Node_Fluid_Render_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Render Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	use_cache = CACHE_USE.auto;
	
	w = 128;
	h = 128;
	min_h = h;
	previewable = true;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2] = nodeValue("Interpolate", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 3] = nodeValue("Draw Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 4] = nodeValue("Auto Update", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [
		["Domain",	false], 0, 
		["Render",	false], 4, 1, 2, 3,
	];
	
	attribute_surface_depth();
	
	onSetDisplayName = noone;
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
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
	
	static step = function() { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		outParent.name = display_name;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		
		var _dim = inputs[| 1].getValue(frame);
		var _outSurf = outParent.getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outParent.setValue(_outSurf);
		
		var _dom = inputs[| 0].getValue(frame);
		var _int = inputs[| 2].getValue(frame);
		var _drw = inputs[| 3].getValue(frame);
		var _upd = inputs[| 4].getValue(frame);
		
		FLUID_DOMAIN_CHECK
		
		var fSurf = _dom.sf_material_0;
		if(!is_surface(fSurf)) return;
		
		if(_upd) fd_rectangle_update(_dom);
		texture_set_interpolation(false);
		
		surface_set_shader(_outSurf, sh_fd_visualize_colorize_glsl);
			gpu_set_texfilter(_int);
			draw_surface_stretched_safe(fSurf, 0, 0, _dim[0], _dim[1]);
			gpu_set_texfilter(false);
			
			if(_drw && is_surface(_dom.sf_world)) 
				draw_surface_stretched_safe(_dom.sf_world, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		group.outputNode = self;
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
}