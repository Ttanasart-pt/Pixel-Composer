function Node_Normal_to_Height(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal to Height";
	
	////- =Surface
	newInput( 0, nodeValue_Surface("Normal In"));
	
	////- =Normal
	newInput( 1, nodeValue_Float(  "Normal Height",  1 ));
	newInput( 3, nodeValue_Slider( "Base Height",    0 ));
	newInput( 2, nodeValue_Int(    "Max Itr.",      -1 ));
	
	////- =Algorithm
	newInput( 4, nodeValue_Toggle( "Sweep Direction", 0b0001, [ "T", "L", "B", "R" ] ));
	// 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface",    false ],  0, 
		[ "Normal",     false ],  1,  3,  2,
		[ "Algorithm",  false ],  4, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	// TODO: Make it runs in O(log(n))
	
	temp_surface = [ noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _norm = _data[ 0];
			
			var _nint = _data[ 1];
			var _base = _data[ 3];
			var _maxi = _data[ 2];
			
			var _swep = _data[ 4];
			
			if(!is_surface(_norm)) return _outSurf;
		#endregion
		
		var _dim = surface_get_dimension(_norm);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_r16float);
			surface_set_target(temp_surface[i]);
				draw_clear(make_color_grey(_base));
			surface_reset_target();
		}
		
		var bg    = 0;
		var _step = 1;
		var _loop = 0;
		
		// var _rep  = ceil(log2(max(_dim[0], _dim[1])));
		var _rep  = _maxi == -1? max(_dim[0], _dim[1]) * 2 : _maxi;
		
		shader_set(sh_normal_to_height);
			shader_set_2("dimension", _dim  );
			shader_set_s("normal",    _norm );
			
			shader_set_f("intensity", _nint );
			shader_set_f("totalStep", _rep  );
				
			shader_set_i("sweepT",  bool(_swep & 0b0001) );
			shader_set_i("sweepL",  bool(_swep & 0b0010) );
			shader_set_i("sweepB",  bool(_swep & 0b0100) );
			shader_set_i("sweepR",  bool(_swep & 0b1000) );
		shader_reset();
		
		repeat(_rep) {
			surface_set_shader(temp_surface[bg], sh_normal_to_height);
				shader_set_f("stepSize",  _step );
				shader_set_f("currLoop",  _loop );
				
				draw_surface(temp_surface[!bg], 0, 0);
			surface_reset_shader();
			
			// _step *= 2;
			// _step++;
			
			// _loop *= 2;
			_loop++;
			
			bg = !bg;
		}
		
		surface_set_shader(_outSurf, sh_draw_r16);
			draw_surface(temp_surface[!bg], 0, 0);
		surface_reset_shader();
		
		return _outSurf; 
	}
}