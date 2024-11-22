function Node_Smoke_Render(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Render Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	use_cache = CACHE_USE.auto;
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Dimension(self));
		
	newInput(2, nodeValue_Bool("Interpolate", self, false));
		
	newInput(3, nodeValue_Bool("Draw Domain", self, false));
		
	newInput(4, nodeValue_Bool("Auto Update", self, true));
	
	input_display_list = [
		["Domain",	false], 0, 
		["Render",	false], 4, 2, 3,
	];
		
	newOutput(0, nodeValue_Output("Smoke", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Domain", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static update = function(frame = CURRENT_FRAME) {
		if(recoverCache() || !PROJECT.animator.is_playing)
			return;
		
		var _dom = getInputData(0);
		var _int = getInputData(2);
		var _drw = getInputData(3);
		var _upd = getInputData(4);
		
		SMOKE_DOMAIN_CHECK
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dom.width, _dom.height, attrDepth());
		outputs[0].setValue(_outSurf);
		
		var fSurf = _dom.sf_material;
		if(!is_surface(fSurf)) return;
		
		if(_upd) _dom.update();
		
		outputs[1].setValue(_dom.sf_world);
		
		surface_set_shader(_outSurf, sh_fd_visualize);
			gpu_set_texfilter(_int);
			draw_surface_stretched_safe(fSurf, 0, 0, _dom.width, _dom.height);
			gpu_set_texfilter(false);
			
			if(_drw) draw_surface_stretched_safe(_dom.sf_world, 0, 0, _dom.width, _dom.height);
		surface_reset_shader();
		
		cacheCurrentFrame(_outSurf);
	}
}