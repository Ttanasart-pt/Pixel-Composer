function Node_Smoke_Render(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Render Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	parameters.inline_draw_output = true;
	// setCacheAuto();
	
	inline_output      = false;
	manual_ungroupable = false;
	
	/*UNUSED*/ newInput( 1, nodeValue_Dimension());
	/*UNUSED*/ newInput( 2, nodeValue_Bool( "Interpolate", false ));
	
	////- =Domain
	newInput( 0, nodeValue_Sdomain());
	newInput( 4, nodeValue_Bool( "Auto Update", true ));
	newInput( 5, nodeValue_Int(  "Update Step", 1    ));
	newInput( 3, nodeValue_Bool( "Draw Domain Collision", false ));
	
	////- =Render
	newInput( 6, nodeValue_Gradient( "Volume Color",  gra_black_white ));
	newInput( 7, nodeValue_Curve(    "Density Remap", CURVE_DEF_01    ));
	// input 8
	
	newOutput(0, nodeValue_Output( "Smoke",  VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Domain", VALUE_TYPE.surface, noone ));
	
	input_display_list = [
		[ "Domain", false ],  0,  4,  5,  3, 
		[ "Render", false ],  6,  7, 
	];
		
	////- Node
		
	attribute_surface_depth();
	temp_surface = [ noone ];
	
	static update = function(frame = CURRENT_FRAME) {
		if(!PROJECT.animator.is_playing && recoverCache()) return;
		
		#region data
			var _dom = getInputData(0);
			var _upd = getInputData(4);
			var _ups = getInputData(5);
			var _drw = getInputData(3);
			
			var _gra = getInputData(6);
			var _den = getInputData(7);
			
			SMOKE_DOMAIN_CHECK
			
			temp_surface[0] = surface_verify(temp_surface[0], _dom.width, _dom.height, attrDepth());
		#endregion
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dom.width, _dom.height, attrDepth());
		outputs[0].setValue(_outSurf);
		
		var fSurf = _dom.sf_material;
		if(!is_surface(fSurf)) return;
		
		if(_upd) { repeat(_ups) _dom.update(); }
		
		outputs[1].setValue(_dom.sf_world);
		
		surface_set_shader(temp_surface[0], sh_fd_visualize);
			shader_set_gradient(_gra);
			shader_set_curve("densityMap", _den);
			
			gpu_set_texfilter(true);
			draw_surface_stretched_safe(fSurf, 0, 0, _dom.width, _dom.height);
			gpu_set_texfilter(false);
		surface_reset_shader();
		
		surface_set_shader(_outSurf);
			draw_surface(temp_surface[0], 0, 0);
			if(_drw) draw_surface_stretched_safe(_dom.sf_world, 0, 0, _dom.width, _dom.height);
		surface_reset_shader();
		
		cacheCurrentFrame(_outSurf);
	}
	
	static getPreviewingNode = function() /*=>*/ {return self};
	static getPreviewValues  = function() /*=>*/ {
		var val = outputs[preview_channel].getValue();
		return is_surface(val)? val : temp_surface[0];
	}
}