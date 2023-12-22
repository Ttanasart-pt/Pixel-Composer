function Node_Fluid_Render(_x, _y, _group = noone) : Node_Fluid(_x, _y, _group) constructor {
	name  = "Render Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	use_cache = CACHE_USE.auto;
	
	manual_ungroupable	 = false;
	
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
		
	outputs[| 0] = nodeValue("Smoke", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static step = function() {
		var _dim = getInputData(1);
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create_valid(_dim[0], _dim[1], attrDepth());
			outputs[| 0].setValue(_outSurf);
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(recoverCache() || !PROJECT.animator.is_playing)
			return;
		
		var _dim = inputs[| 1].getValue(frame);
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[| 0].setValue(_outSurf);
		
		var _dom = inputs[| 0].getValue(frame);
		var _int = inputs[| 2].getValue(frame);
		var _drw = inputs[| 3].getValue(frame);
		var _upd = inputs[| 4].getValue(frame);
		
		FLUID_DOMAIN_CHECK
		
		var fSurf = _dom.sf_material_0;
		if(!is_surface(fSurf)) return;
		
		if(_upd) fd_rectangle_update(_dom);
		texture_set_interpolation(false);
		
		outputs[| 1].setValue(_dom.sf_world);
		
		surface_set_shader(_outSurf, sh_fd_visualize_colorize_glsl);
			gpu_set_texfilter(_int);
			draw_surface_stretched_safe(fSurf, 0, 0, _dim[0], _dim[1]);
			gpu_set_texfilter(false);
			
			if(_drw && is_surface(_dom.sf_world)) 
				draw_surface_stretched_safe(_dom.sf_world, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		var frm = cacheCurrentFrame(_outSurf);
	}
}