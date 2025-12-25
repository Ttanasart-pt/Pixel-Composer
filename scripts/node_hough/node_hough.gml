function Node_Hough_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Hough Transform";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 1, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =Hough
	newInput(12, nodeValue_EScroll( "Shape",      0, [ "Linear", "Circle" ]  ));
	newInput(13, nodeValue_Slider(  "Radius",    .5   ));
	newInput( 8, nodeValue_Float(   "Intensity",  256 ));
	newInput( 7, nodeValue_Slider(  "Threshold", .25  ));
	newInput(15, nodeValue_Float(   "Max Range",  0   )).setUnitSimple();
	newInput(17, nodeValue_Float(   "Snap Angle", 0   ));
	
	////- =Rendering
	newInput( 9, nodeValue_Slider( "Line Threshold", .99  ));
	newInput(11, nodeValue_Float(  "Thickness",      .1   ));
	newInput(10, nodeValue_Color(  "Color",          cola(c_white, .6) ));
	newInput(14, nodeValue_Slider( "Line Fade",      0    ));
	newInput(16, nodeValue_Bool(   "Draw Original",  true ));
	// inputs 18
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Hough Space", VALUE_TYPE.surface, noone)).skipVerify();
	
	input_display_list = [ 5, 6, 
		[ "Surface",   false ],  0,  1,  2,  3,  4, 
		[ "Hough",     false ], 12, 13,  8,  7, 15, 
		[ "Rendering", false ],  9, 11, 10, 14, 16, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[0];
			
			var _type = _data[12];
			var _rad  = _data[13];
			var _int  = _data[ 8];
			var _thr  = _data[ 7];
			var _rrad = _data[15];
			var _rsnp = _data[17];
			
			var _dthr  = _data[ 9];
			var _lineD = _data[11];
			var _colr  = _data[10];
			var _fade  = _data[14];
			var _bg    = _data[16];
			
			inputs[13].setVisible(_type == 1);
			inputs[17].setVisible(_type == 0);
			
			inputs[14].setVisible(_type == 0);
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		
		var _outSpac = surface_verify(_outData[1], _dim[0], _dim[1], surface_r32float);
		_outData[1]  = _outSpac;
		
		surface_set_shader(_outSpac, sh_hough_process);
			shader_set_2("dimension",    _dim  );
			shader_set_i("type",         _type );
			shader_set_i("scanRadius",   _rrad );
			
			shader_set_f("threshold",    _thr  );
			shader_set_f("intensity",    _int  );
			shader_set_f("targetRadius", _rad  );
			shader_set_f("angleSnap",    _rsnp );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var _outSurf = _outData[0];
		surface_set_shader(_outSurf, sh_hough_draw);
			shader_set_2("dimension",  _dim    );
			shader_set_i("type",       _type   );
			shader_set_i("scanRadius", _rrad   );
			
			shader_set_s("hough",     _outSpac );
			shader_set_f("threshold", _dthr    );
			shader_set_f("intensity", _int     );
			shader_set_c("lineColor", _colr    );
			shader_set_f("lineDist",  _lineD   );
			shader_set_f("fadeDistance", _fade );
			
			if(_bg) draw_surface_safe(_surf);
			else    draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_black);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outData; 
	}
}