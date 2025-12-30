function Node_Noise_Blue(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blue Noise";
	
	////- =Output
	newInput(0, nodeValue_Dimension());
	newInput(2, nodeValue_Surface("Mask"));
	
	////- =Noise
	newInput(1, nodeValueSeed());
	newInput(6, nodeValue_Slider( "Threshold",  .1 ));
	newInput(3, nodeValue_Int(    "Iteration",  64 ));
	newInput(4, nodeValue_Float(  "Radius",    .25 )).setUnitSimple();
	newInput(5, nodeValue_Float(  "Sigma",     1.9 ));
	// 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output", false ], 0, 2, 
		[ "Noise",  false ], 1, 6, 3, 4, 5,
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone, noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim = _data[0];
			
			var _sed = _data[1];
			var _thr = _data[6];
			var _itr = _data[3];
			var _rad = _data[4];
			var _sig = _data[5];
		#endregion
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
			surface_clear(temp_surface[i]);
		}
		
		////- =Initial Binary
		
		surface_set_shader(temp_surface[1], sh_noise_blue_initial);
			shader_set_2( "dimension", _dim );
			shader_set_f( "seed",      _sed );
			shader_set_f( "threshold", _thr );
			draw_empty();
		surface_reset_shader();
		
		surface_set_shader(temp_surface[0], sh_noise_blue_energy);
			shader_set_2( "dimension", _dim );
			shader_set_i( "inverted", false );
			shader_set_i( "radius",    _rad );
			shader_set_f( "sigma",     _sig );
		surface_reset_shader();
		
		repeat(_itr) {
			surface_set_target(temp_surface[0]);
			shader_set(sh_noise_blue_energy);
				draw_surface(temp_surface[1], 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(temp_surface[0]);
			
			surface_set_target(temp_surface[1]);
				draw_point_color(vc[4], vc[5], c_black);
				draw_point_color(vc[2], vc[3], c_white);
			surface_reset_target();
		}
		
		surface_set_target(temp_surface[3]);
			draw_surface(temp_surface[1], 0, 0);
		surface_reset_target();
		
		////- =Order white
		
		var _wht = surface_get_white(temp_surface[1]);
		var _max = _dim[0] * _dim[1];
		
		var _ord = _wht;
		repeat(_wht) {
			surface_set_target(temp_surface[0]);
			shader_set(sh_noise_blue_energy);
				draw_surface(temp_surface[3], 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(temp_surface[0]);
			surface_set_target(temp_surface[3]);
				draw_point_color(vc[4], vc[5], c_black);
			surface_reset_target();
			
			surface_set_target(temp_surface[2]);
				draw_point_color(vc[4], vc[5], make_color_grey(_ord / _max));
			surface_reset_target();
			_ord--;
		}
		
		////- =Order black
		
		var _ord = _wht + 1;
		repeat(_max / 2 - _wht) {
			surface_set_target(temp_surface[0]);
			shader_set(sh_noise_blue_energy);
				draw_surface(temp_surface[1], 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(temp_surface[0]);
			surface_set_target(temp_surface[1]);
				draw_point_color(vc[2], vc[3], c_white);
			surface_reset_target();
			
			surface_set_target(temp_surface[2]);
				draw_point_color(vc[2], vc[3], make_color_grey(_ord / _max));
			surface_reset_target();
			_ord++;
		}
		
		////- =Fil gaps
		
		surface_set_shader(temp_surface[0], sh_noise_blue_energy);
			shader_set_i( "inverted",  true );
		surface_reset_shader();
		
		repeat(_max / 2) {
			surface_set_target(temp_surface[0]);
			shader_set(sh_noise_blue_energy);
				draw_surface(temp_surface[1], 0, 0);
			shader_reset();
			surface_reset_target();
			
			var vc = surface_get_min_max(temp_surface[0]);
			surface_set_target(temp_surface[1]);
				draw_point_color(vc[2], vc[3], c_white);
			surface_reset_target();
			
			surface_set_target(temp_surface[2]);
				draw_point_color(vc[2], vc[3], make_color_grey(_ord / _max));
			surface_reset_target();
			
			_ord++;
		}
		
		surface_set_shader(_outSurf);
			draw_surface(temp_surface[2], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}