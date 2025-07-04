function Node_Smoke_Render(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Render Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	use_cache = CACHE_USE.auto;
	
	inline_output      = false;
	manual_ungroupable = false;
	
	////- =Domain
	newInput(0, nodeValue(      "Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone)).setVisible(true, true);
	newInput(4, nodeValue_Bool( "Auto Update", true ));
	newInput(5, nodeValue_Int(  "Update Step", 1    ));
	newInput(1, nodeValue_Dimension());
	
	////- =Render
	newInput(2, nodeValue_Bool( "Interpolate", false ));
	newInput(3, nodeValue_Bool( "Draw Domain", false ));
	// input 6
	
	newOutput(0, nodeValue_Output( "Smoke",  VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Domain", VALUE_TYPE.surface, noone ));
	
	input_display_list = [
		["Domain",	false], 0, 4, 5, 
		["Render",	false], 2, 3,
	];
		
	attribute_surface_depth();
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	temp_surface = [ noone ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = getInputData(0);
		if(is(_dom, smokeSim_Domain))
			temp_surface[0] = surface_verify(temp_surface[0], _dom.width, _dom.height, attrDepth());
		
		if(!PROJECT.animator.is_playing && recoverCache()) return;
		
		var _int = getInputData(2);
		var _drw = getInputData(3);
		
		var _upd = getInputData(4);
		var _ups = getInputData(5);
		
		SMOKE_DOMAIN_CHECK
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dom.width, _dom.height, attrDepth());
		outputs[0].setValue(_outSurf);
		
		var fSurf = _dom.sf_material;
		if(!is_surface(fSurf)) return;
		
		if(_upd) { repeat(_ups) _dom.update(); }
		
		outputs[1].setValue(_dom.sf_world);
		
		surface_set_shader(_outSurf, sh_fd_visualize);
			gpu_set_texfilter(_int);
			draw_surface_stretched_safe(fSurf, 0, 0, _dom.width, _dom.height);
			gpu_set_texfilter(false);
			
			if(_drw) draw_surface_stretched_safe(_dom.sf_world, 0, 0, _dom.width, _dom.height);
		surface_reset_shader();
		
		cacheCurrentFrame(_outSurf);
	}
	
	static getPreviewingNode = function() { return self; }
	
	static getPreviewValues = function() {
		var val = outputs[preview_channel].getValue();
		return is_surface(val)? val : temp_surface[0];
	}
}