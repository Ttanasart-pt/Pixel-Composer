function Node_MK_GodRay(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK GodRay";
	
	newActiveInput( 2);
	newInput(16, nodeValueSeed());
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Background" ));
	newInput( 1, nodeValue_Surface( "Ray Mask"   ));
	
	////- =Light
	newInput( 3, nodeValue_EScroll( "Type",     0, [ "Point", "Sun" ] ));
	newInput( 4, nodeValue_Vec2(    "Origin", [.5,.5] )).setUnitSimple();
	newInput( 5, nodeValue_Float(   "Range",    1     )).setUnitSimple().setMappable(18);
	newInput(13, nodeValue_Float(   "Spread",   4     ));
	newInput(14, nodeValue_EScroll( "Attenuation", 0, [ "Linear", "Quadratic", "Inv. Quadratic" ] ));
	newInput(17, nodeValue_Slider(  "Brightness", .0  ));
	
	////- =Solid
	newInput(11, nodeValue_EScroll( "Empty Mode",  0, [ "Color", "Point Sample" ] ));
	newInput(12, nodeValue_Color(   "Empty Color", cola(c_black, 0)    ));
	newInput(15, nodeValue_Slider(  "Air Density",.0 , [ 0, .1, .01 ]  )).setMappable(19);
	newInput( 8, nodeValue_Slider(  "Density",    .02, [ 0, .1, .01 ]  )).setMappable(20);
	newInput( 9, nodeValue_Slider(  "Diffuse",    .1                   )).setMappable(21);
	
	////- =Rendering
	newInput( 6, nodeValue_Float(   "Subdivision", 2         ));
	newInput(10, nodeValue_Gradient("Base Color",  gra_white ));
	newInput( 7, nodeValue_Float(   "Intensity",   16        )).setMappable(22);
	// 23
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Ray Only",    VALUE_TYPE.surface, noone ));
	
	input_display_list = [ s_MKFX,  2, 16, 
		[ "Surfaces",  false ],  0,  1, 
		[ "Light",     false ],  3,  4,  5, 18, 13, 14, 17, 
		[ "Solid",     false ], 11, 12, 15, 19,  8, 20,  9, 21, 
		[ "Rendering", false ],  6, 10,  7, 22, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _pos = getInputSingle( 4);
		var _rad = getInputSingle( 5);
		
		var _px  = _x + _pos[0] * _s;
		var _py  = _y + _pos[1] * _s;
		var _rr = _rad * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle_dash(_px, _py, _rr);
		
		drawOverlayInput(inputs[ 4].drawOverlay(w_hoverable, active, _x,  _y,  _s, _mx, _my));
		drawOverlayInput(inputs[ 5].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my));
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed  = _data[16];
			
			var _surf  = _data[ 0];
			var _mask  = _data[ 1];
			
			var _type  = _data[ 3];
			var _orig  = _data[ 4];
			var _range = _data[ 5];
			var _sprd  = _data[13];
			var _lattn = _data[14];
			var _brigh = _data[17];
			
			var _emMod = _data[11];
			var _emCol = _data[12];
			var _emDen = _data[15];
			var _densi = _data[ 8];
			var _diffu = _data[ 9];
			
			var _subd  = _data[ 6];
			var _lCol  = _data[10];
			var _inten = _data[ 7];
			
			inputs[12].setVisible(_emMod == 0);
			
			if(!is_surface(_surf)) return _outData;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], attrDepth());
		
		_outData[0] = surface_verify(_outData[0], _dim[0], _dim[1], attrDepth());
		_outData[1] = surface_verify(_outData[1], _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(temp_surface[0], sh_mk_godray_shine);
			gpu_set_tex_filter(true);
			shader_set_f( "seed",         _seed  );
			
			shader_set_2( "dimension",    _dim   );
			shader_set_s( "mask",         _mask  );
			shader_set_i( "useMask",      is_surface(_mask) );
			
			shader_set_i( "type",         _type  );
			shader_set_2( "origin",       _orig  );
			shader_set_m( "range",        _range, _data[18], inputs[ 5] );
			
			shader_set_i( "emptyMode",    _emMod );
			shader_set_c( "emptyColor",   _emCol );
			
			shader_set_m( "airDensity",   _emDen, _data[19], inputs[15] );
			shader_set_m( "solidDensity", _densi, _data[20], inputs[ 8] );
			shader_set_m( "solidDiffuse", _diffu, _data[21], inputs[ 9] );
			
			shader_set_i( "lightAttn",    _lattn );
			shader_set_gradient(          _lCol  );
			shader_set_f( "brightness",   _brigh );
			shader_set_f( "subdiv",       _subd  );
			
			draw_surface( _surf, 0, 0 );
			gpu_set_tex_filter(false);
		surface_reset_shader();
		
		surface_set_shader(_outData[1], sh_mk_godray_blur);
			gpu_set_tex_filter(true);
			shader_set_2( "dimension", _dim   );
			
			shader_set_i( "type",      _type  );
			shader_set_2( "origin",    _orig  );
			shader_set_f( "range",     _range );
			
			shader_set_f( "spread",    _sprd  );
			
			draw_surface( temp_surface[0], 0, 0 );
			gpu_set_tex_filter(false);
		surface_reset_shader();
		
		surface_set_shader(_outData[0], sh_mk_godray_apply);
			shader_set_2( "dimension",  _dim   );
			shader_set_s( "raySurface", _outData[1] );
			
			shader_set_m( "intensity",  _inten, _data[22], inputs[ 7] );
			draw_surface( _surf, 0, 0 );
		surface_reset_shader();
		
		return _outData;
	}
}