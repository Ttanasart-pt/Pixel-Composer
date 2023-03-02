function Node_Fluid_Render(_x, _y, _group = noone) : Node_Fluid(_x, _y, _group) constructor {
	name  = "Render Domain";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	use_cache = true;
	
	inputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2] = nodeValue("Interpolate", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 3] = nodeValue("Draw Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [
		["Domain",	false], 0, 
		["Render",	false], 1, 2, 3,
	];
		
	outputs[| 0] = nodeValue("Fluid", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(recoverCache() || !ANIMATOR.is_playing)
			return;
			
		var _dom = inputs[| 0].getValue(frame);
		var _dim = inputs[| 1].getValue(frame);
		var _int = inputs[| 2].getValue(frame);
		var _drw = inputs[| 3].getValue(frame);
		
		if(_dom == noone || !instance_exists(_dom)) return;
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		var fSurf = _dom.sf_material_0;
		if(!is_surface(fSurf)) return;
		outputs[| 1].setValue(_dom.sf_world);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			
			BLEND_OVERRIDE;
			shader_set(sh_fd_visualize_colorize_glsl);
			gpu_set_texfilter(_int);
			draw_surface_stretched(fSurf, 0, 0, _dim[0], _dim[1]);
			gpu_set_texfilter(false);
			shader_reset();
			BLEND_NORMAL;
			
			if(_drw && is_surface(_dom.sf_world)) 
				draw_surface_stretched(_dom.sf_world, 0, 0, _dim[0], _dim[1]);
		surface_reset_target();
		
		cacheCurrentFrame(_outSurf);
	}
}