function Node_Interpret_Matrix(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interpret Matrix";
	dimension_index = 6;
	
	////- =Surface
	newInput( 6, nodeValue_Dimension());
	
	////- =Matrix
	newInput( 0, nodeValue_Matrix( "Matrix" )).setVisible(true, true);
	newInput( 8, nodeValue_IVec2(  "Offset", [0,0] ));
	
	////- =Interpret
	newInput( 1, nodeValue_EButton(  "Mode",      0, [ "Greyscale", "Palette", "Gradient" ] ));
	newInput( 2, nodeValue_Range(    "Range",    [0,1]     ));
	newInput( 7, nodeValue_Palette(  "Palette"             ));
	newInput( 3, nodeValue_Gradient( "Gradient", gra_white )).setMappable(4);
	// input 9
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface",   false ], 6, 
		[ "Matrix",    false ], 0, 8, 
		[ "Interpret", false ], 1, 2, 7, 3, 4, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, getDimension()));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			static BATCH_SIZE = 128;
			
			var _dim = _data[6];
			
			var _mat = _data[0];
			var _off = _data[8];
			
			var _mod = _data[1];
			var _ran = _data[2];
			var _pal = _data[7];
			
			inputs[2].setVisible(_mod != 2);
			inputs[7].setVisible(_mod == 1);
			inputs[3].setVisible(_mod == 2);
		#endregion
		
		var _num = _mat.raw;
		var _siz = _mat.size;
		
		surface_set_shader( _outSurf, sh_interpret_matrix );
			shader_set_2( "dimension", _dim );
			
			shader_set_f( "matrix", _num );
			shader_set_2( "size",   _siz );
			shader_set_2( "offset", _off );
			
			shader_set_i( "mode",   _mod );
			shader_set_f( "range",  _ran );
			shader_set_palette(_pal);
			shader_set_gradient(_data[3], _data[4], _data[5], inputs[3]);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}