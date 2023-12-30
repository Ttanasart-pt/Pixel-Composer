function Node_FLIP_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Blending", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue("Vaporize", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	input_display_list = [ 0, 
		["Rendering", false], 1, 2, 
	];
	
	outputs[| 0] = nodeValue("Rendered", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ noone ]
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		if(IS_PLAYING) domain.step();
		
		var _bln = getInputData(1);
		var _vap = getInputData(2);
		
		var _outSurf = outputs[| 0].getValue();
		var _padd    = domain.particleSize;
		var _ww = domain.width  - _padd * 2;
		var _hh = domain.height - _padd * 2;
				  
		_outSurf        = surface_verify(_outSurf,        _ww, _hh);
		temp_surface[0] = surface_verify(temp_surface[0], _ww, _hh);
		
		outputs[| 0].setValue(_outSurf);		
		
		var _x, _y, _r, _l;
		var _rad = domain.particleRadius;
		var _mx  = min(array_length(domain.particlePos) / 2 - 1, domain.numParticles);
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			BLEND_ADD
			
			for( var i = 0; i < _mx; i++ ) {
				_x = domain.particlePos[i * 2 + 0];
				_y = domain.particlePos[i * 2 + 1];
				_l = domain.particleLife[i];
				
				if(_x == 0 && _y == 0) continue;
				
				_x -= _padd;
				_y -= _padd;
				_r  = _rad * 4;
				
				if(_vap) {
					var _r = (_vap - _l) / _vap * _rad * 4;
					if(_r < 0) continue;
				}
				
				draw_circle_color(_x, _y, _r, c_white, c_black, false);
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_shader(_outSurf, sh_FLIP_render_threshold);
			shader_set_f("threshold", 1 - _bln);
			
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
	}
	
}