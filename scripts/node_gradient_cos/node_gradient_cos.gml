function Node_Gradient_Cos(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Cos Gradient";
	
	////- Output
	newInput( 0, nodeValue_Dimension());
	newInput(22, nodeValue_Surface( "UV Map"     ));
	newInput(23, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 1, nodeValue_Surface( "Mask"       ));
	
	////- Coefficients
	newInput( 2, nodeValue_Vec3( "a",     [ .5,  .5,  .5  ] )).setMappableConst(4);
	newInput( 3, nodeValue_Vec3( "a Max", [ .5,  .5,  .5  ] ));
	
	newInput( 5, nodeValue_Vec3( "b",     [ .5,  .5,  .5  ] )).setMappableConst(7);
	newInput( 6, nodeValue_Vec3( "b Max", [ .5,  .5,  .5  ] ));
	
	newInput( 8, nodeValue_Vec3( "c",     [ .8,  .8,  .8  ] )).setMappableConst(10);
	newInput( 9, nodeValue_Vec3( "c Max", [ .8,  .8,  .8  ] ));
	
	newInput(11, nodeValue_Vec3( "d",     [ .21, .54, .88 ] )).setMappableConst(13);
	newInput(12, nodeValue_Vec3( "d Max", [ .21, .54, .88 ] ));
	
	////- Gradient
	newInput(20, nodeValue_Float(  "Shift",  0 ));
	newInput(21, nodeValue_Float(  "Scale",  1 ));
	newInput(24, nodeValue_Curve(    "Progress Remap", CURVE_DEF_01 ));
	
	////- Shape
	__gradTypes = __enum_array_gen(["Linear", "Circular", "Radial", "Diamond"], s_node_gradient_type);
	newInput(14, nodeValue_EScroll(  "Type",           0, __gradTypes));
	newInput(15, nodeValue_Rotation( "Angle",          0      )).setHotkey("R");
	newInput(16, nodeValue_Float(    "Radius",        .5      ));
	newInput(17, nodeValue_Vec2(     "Center",        [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput(18, nodeValue_Vec2(     "Shape",         [1,1]   ));
	newInput(19, nodeValue_Bool(     "Uniform ratio",  true   ));
	// inputs 25
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	b_random = button(function() /*=>*/ {return randomGradient()}).setIcon(THEME.icon_random, 0, COLORS._main_icon).iconPad();
	
	input_display_list = [
		[ "Output",		   true ], 0, 22, 23, 1, 
		[ "Coefficients", false, noone, b_random ], 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
		[ "Gradient",     false ], 20, 21, 24, 
		[ "Shape",        false ], 14, 15, 16, 17, 18, 19, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static rand3 = function() /*=>*/ {return [ random_range(0,1), random_range(0,1), random_range(0,1) ]};
	
	static randomGradient = function() {
		inputs[ 2].setValue(rand3());
		inputs[ 3].setValue(rand3());
		
		inputs[ 5].setValue(rand3());
		inputs[ 6].setValue(rand3());
		
		inputs[ 8].setValue(rand3());
		inputs[ 9].setValue(rand3());
		
		inputs[11].setValue(rand3());
		inputs[12].setValue(rand3());
		
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var  dim = getSingleValue( 0);
		var  typ = getSingleValue(14);
		var  rot = getSingleValue(15);
		var  pos = getSingleValue(17);
		
		InputDrawOverlay(inputs[17].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		var _px = _x + pos[0] * _s;
		var _py = _y + pos[1] * _s;
		InputDrawOverlay(inputs[21].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny, typ == 0? rot : 0, dim[0] / 2, 1));
		
		if(typ != 1) InputDrawOverlay(inputs[15].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		else         InputDrawOverlay(inputs[18].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny, 0, [ dim[0] / 2, dim[1] / 2 ]));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim   = _data[ 0];
			var _msk   = _data[ 1];
			
			var _a     = _data[ 2];
			var _a_max = _data[ 3]; inputs[ 3].show_in_inspector = inputs[2].isMapped();
			var _a_map = _data[ 4]; inputs[ 4].visible           = inputs[2].isMapped();
			
			var _b     = _data[ 5];
			var _b_max = _data[ 6]; inputs[ 6].show_in_inspector = inputs[5].isMapped();
			var _b_map = _data[ 7]; inputs[ 7].visible           = inputs[5].isMapped();
			
			var _c     = _data[ 8];
			var _c_max = _data[ 9]; inputs[ 9].show_in_inspector = inputs[8].isMapped();
			var _c_map = _data[10]; inputs[10].visible           = inputs[8].isMapped();
			
			var _d     = _data[11];
			var _d_max = _data[12]; inputs[12].show_in_inspector = inputs[11].isMapped();
			var _d_map = _data[13]; inputs[13].visible           = inputs[11].isMapped();
			
			var _shf   = _data[20];
			var _sca   = _data[21];
			var _crv   = _data[24];
			
			var _typ   = _data[14];
			var _ang   = _data[15];
			var _rad   = _data[16];
			var _cnt   = _data[17];
			var _sha   = _data[18];
			var _unf   = _data[19];
			
			inputs[15].setVisible(_typ != 1);
			inputs[16].setVisible(_typ == 1);
			inputs[19].setVisible(_typ);
			inputs[18].setVisible(_typ == 1);
		#endregion
		
		surface_set_shader(_outSurf, sh_gradient_cos);
			shader_set_uv(_data[22], _data[23]);
			
			shader_set_surface( "mask", _msk );
			shader_set_i( "useMask", is_surface(_msk) );
			
			shader_set_3( "co_a",           _a     );
			shader_set_3( "co_a_max",       _a_max );
			shader_set_i( "co_a_use",       inputs[2].isMapped() );
			shader_set_surface( "co_a_map", _a_map );
			
			shader_set_3( "co_b",           _b     );
			shader_set_3( "co_b_max",       _b_max );
			shader_set_i( "co_b_use",       inputs[5].isMapped() );
			shader_set_surface( "co_b_map", _b_map );
			
			shader_set_3( "co_c",           _c     );
			shader_set_3( "co_c_max",       _c_max );
			shader_set_i( "co_c_use",       inputs[8].isMapped() );
			shader_set_surface( "co_c_map", _c_map );
			
			shader_set_3( "co_d",           _d     );
			shader_set_3( "co_d_max",       _d_max );
			shader_set_i( "co_d_use",       inputs[11].isMapped() );
			shader_set_surface( "co_d_map", _d_map );
			
			shader_set_f("shift",      _shf);
			shader_set_f("scale",      _sca);
			shader_set_curve("pCurve", _crv);
			
			shader_set_2("dimension", _dim);
			shader_set_2("center",    _cnt);
			shader_set_i("type",      _typ);
			shader_set_i("uniAsp",    _unf);
			shader_set_2("cirScale",  _sha);
			shader_set_f("angle",     _ang);
			shader_set_f("radius",    _rad);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}