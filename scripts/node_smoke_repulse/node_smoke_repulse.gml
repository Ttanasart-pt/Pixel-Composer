function Node_Smoke_Repulse(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Repulse";
	setDimension(96, 96);
	setDrawIcon(s_node_smoke_repulse);
	manual_ungroupable	 = false;
	
	////- =Domain
	newInput( 0, nodeValue_Sdomain());
	
	////- =Repulse
	newInput( 1, nodeValue_Vec2(     "Position",  [.5,.5] )).setUnitSimple().setHotkey("G");
	newInput( 2, nodeValue_Float(    "Radius",     .25    )).setUnitSimple().setHotkey("S");
	newInput( 3, nodeValue_Slider(   "Strength",   0.10, [-8, 8, 0.01] ));
	
	////- =Spokes
	newInput( 4, nodeValue_Float(    "Spokes",     0      ));
	newInput( 5, nodeValue_Rotation( "Twist",      0      ));
	// input 6
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	input_display_list = [ 
		[ "Domain",  false ], 0, 
		[ "Repulse", false ], 1, 2, 3,
		[ "Spokes",  false ], 4, 5, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	
	SMOKE_DOMAIN_DIMENSION
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = getInputData(1);
		var _rad = getInputData(2);
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle_prec(px, py, _rad * _s, true);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _dom = getInputData(0);
			
			var _pos = getInputData(1);
			var _rad = getInputData(2);
			var _str = getInputData(3);
			
			var _spk   = getInputData(4);
			var _spk_r = getInputData(5);
		#endregion
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		_rad = max(_rad, 1);
		temp_surface[0] = surface_verify(temp_surface[0], _dom.width, _dom.height, surface_rgba32float);
		
		surface_set_shader(temp_surface[0], sh_fd_repulse);
			shader_set_f("strength", _str);
			shader_set_f("spokes",   _spk);
			shader_set_f("rotate",   degtorad(_spk_r));
			shader_set_f("radius",   max(_rad /_dom.width, _rad / _dom.height));
			shader_set_f("center",   _pos[0] / _dom.width, _pos[1] / _dom.height);
			draw_empty();
		surface_reset_shader();
		
		_dom.addVelocity(temp_surface[0]);
	}
	
}