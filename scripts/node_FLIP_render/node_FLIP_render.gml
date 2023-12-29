function Node_FLIP_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	input_display_list = [ 0 ];
	
	outputs[| 0] = nodeValue("Rendered", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ noone ]
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		domain.step();
		
		var _outSurf = outputs[| 0].getValue();
		var _padd    = domain.particleSize;
		var _ww = domain.width  - _padd * 2;
		var _hh = domain.height - _padd * 2;
				  
		_outSurf        = surface_verify(_outSurf,        _ww, _hh);
		temp_surface[0] = surface_verify(temp_surface[0], _ww, _hh);
		
		outputs[| 0].setValue(_outSurf);		
		
		var _rad = domain.particleRadius;
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			BLEND_ADD
			
			for( var i = 0; i < domain.numParticles; i++ ) {
				var _x = domain.particlePos[i * 2 + 0];
				var _y = domain.particlePos[i * 2 + 1];
				
				if(_x == 0 && _y == 0) continue;
				
				_x -= _padd
				_y -= _padd
				
				draw_circle_color(_x, _y, _rad * 4, c_white, c_black, false);
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_shader(_outSurf, sh_FLIP_render_threshold);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
	}
}