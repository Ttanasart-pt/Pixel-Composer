function Node_MK_Flake(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Flake";
	
	newInput( 2, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Background" ));
	
	////- =Flakes
	newInput( 3, nodeValue_Slider(   "Size",          .7      ));
	newInput( 4, nodeValue_Range(    "Branches",      [3,5]   ));
	newInput( 5, nodeValue_RotRange( "Branch Angle",  [15,75] ));
	newInput( 6, nodeValue_Range(    "Branch Length", [3,8]   ));
	
	////- =Render
	newInput( 7, nodeValue_Range(    "Thickness", [2,2], true ));
	newInput( 8, nodeValue_Gradient( "Colors",    gra_white   ));
	// 9
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ s_MKFX, 2, 
		[ "Output", false ],  0,  1, 
		[ "Flakes", false ],  3,  4,  5,  6,  
		[ "Render", false ],  7,  8, 
	];
	
	////- Nodes
	
	temp_surface = [ 0 ]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed   = _data[ 2];
			
			var _dim    = _data[ 0];
			var _bgSurf = _data[ 1];
			
			var _size   = _data[ 3];
			var _brAmo  = _data[ 4];
			var _brAng  = _data[ 5];
			var _brLen  = _data[ 6];
			
			var _thcks  = _data[ 7];
			var _colrs  = _data[ 8];
		#endregion
		
		var cx = _dim[0] / 2 - 1;
		var cy = _dim[1] / 2;
		
		random_set_seed(_seed);
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			
			draw_set_color(c_white);
			var _len = _dim[1] * .5 * _size;
			draw_line_width(cx, cy, cx, cy - _len, 2);
			
			var brn = irandom_range(_brAmo[0], _brAmo[1]);
			
			repeat(brn) {
				var ofs = irandom_range(2, _len);
				var dir = random_range(_brAng[0], _brAng[1]);
				var len = random_range(_brLen[0], _brLen[1]);
				
				var bx = cx;
				var by = cy - ofs;
				
				var thk = random_range(_thcks[0], _thcks[1]);
				var clr = _colrs.eval(random(1));
				
				draw_set_color(clr);
				draw_line_width(bx, by, bx + lengthdir_x(len, dir), by + lengthdir_y(len, dir), thk);
			}
		surface_reset_target();
		
		surface_set_shader(_outSurf, sh_mk_flake);
			shader_set_2("sampleDimension", _dim);
			
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf; 
	}
}