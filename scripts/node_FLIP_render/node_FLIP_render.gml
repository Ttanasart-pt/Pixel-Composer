function Node_FLIP_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Merge threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue("Vaporize", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 3] = nodeValue("Particle expansion", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 8);
	
	inputs[| 4] = nodeValue("Draw obstracles", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [ 0, 
		["Effect",    false], 2, 
		["Rendering", false], 3, 1, 4, 
	];
	
	outputs[| 0] = nodeValue("Rendered", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ noone ]
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		if(IS_PLAYING) domain.step();
		
		var _bln = getInputData(1);
		var _vap = getInputData(2);
		var _exp = getInputData(3);
		var _obs = getInputData(4);
		
		var _outSurf = outputs[| 0].getValue();
		var _padd    = domain.particleSize;
		var _ww = domain.width  - _padd * 2;
		var _hh = domain.height - _padd * 2;
				  
		_outSurf        = surface_verify(_outSurf,        _ww, _hh);
		temp_surface[0] = surface_verify(temp_surface[0], _ww, _hh);
		
		outputs[| 0].setValue(_outSurf);		
		
		var _x, _y, _r, _l;
		var _rad = domain.particleRadius * _exp;
		var _mx  = min(array_length(domain.particlePos) / 2 - 1, domain.numParticles);
		
		surface_set_shader(temp_surface[0], sh_FLIP_draw_droplet);
			BLEND_ADD
			
			for( var i = 0; i < _mx; i++ ) {
				_x = domain.particlePos[i * 2 + 0];
				_y = domain.particlePos[i * 2 + 1];
				_l = domain.particleLife[i];
				
				if(_x == 0 && _y == 0) continue;
				
				_x -= _padd;
				_y -= _padd;
				_r  = _rad;
				
				if(_vap) {
					_r = (_vap - _l) / _vap * _rad;
					if(_r < 0) continue;
				}
				
				draw_circle_color(_x, _y, _r, c_white, c_black, false);
			}
			
			BLEND_NORMAL
		surface_reset_shader();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			shader_set(sh_FLIP_render_threshold);
				shader_set_f("threshold", 1 - _bln);
				draw_surface(temp_surface[0], 0, 0);
			shader_reset();
			
			if(_obs)
			for( var i = 0, n = array_length(domain.obstracles); i < n; i++ )
				domain.obstracles[i].draw();
		surface_reset_target();
	}
	
}