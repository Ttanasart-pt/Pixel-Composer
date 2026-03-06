function Node_Tile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Tile";
	
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 9, nodeValue_Surface( "UV Map"     ));
	newInput(10, nodeValue_Slider(  "UV Mix", 1  ));
	
	////- =Output
	newInput( 1, nodeValue_Enum_Scroll( "Scaling Type", 0, [ "Fix Dimension", "Relative To Input" ] ));
	newInput( 2, nodeValue_Dimension());
	newInput( 3, nodeValue_Vec2( "Amount", [2,2] ));
	
	////- =Tiling
	newInput( 5, nodeValue_Vec2(     "Spacing", [0,0] )).setUnitSimple();
	
	////- =Transform
	newInput( 4, nodeValue_Vec2(     "Posiiton", [0,0] )).setUnitSimple();
	newInput( 6, nodeValue_EButton(  "Shift Axis", 0, ["X", "Y"] ));
	newInput( 7, nodeValue_Slider(   "Shift",      0   ));
	newInput( 8, nodeValue_Rotation( "Rotation",   0   ));
	// input 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	 
	input_display_list = [
		[ "Surfaces",   true ],  0,  9, 10, 
		[ "Output",    false ],  1,  2,  3, 
		[ "Tiling",    false ],  5,
		[ "Transform", false ],  4,  6,  7,  8, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static getDimension = function() {
		var _type = getInputSingle(1);
		
		if(_type == 0) return getInputSingle(2);
		
		var _surf = getInputSingle(0);
		if(!is_surface(_surf)) return [1,1];
		
		var _amo  = getInputSingle(3);
		var _idim = surface_get_dimension(_surf);
		_sw = _idim[0] * _amo[0];
		_sh = _idim[1] * _amo[1];
		
		return [ _sw, _sh ];
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		InputDrawOverlay(inputs[ 4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			var _type = _data[ 1];
			var _dim  = _data[ 2];
			var _amo  = _data[ 3];
			
			var _spc  = _data[ 5];
			
			var _pos  = _data[ 4];
			var _shfA = _data[ 6];
			var _shf  = _data[ 7];
			var _rot  = _data[ 8];
			
			inputs[2].setVisible(_type == 0);
			inputs[3].setVisible(_type == 1);
		#endregion
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _idim = surface_get_dimension(_surf);
		var _sw = _dim[0];
		var _sh = _dim[1];
		
		if(_type == 1) {
			_sw = _idim[0] * _amo[0];
			_sh = _idim[1] * _amo[1];
		}
		
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		surface_set_shader(_outSurf, sh_tile_ext);
			shader_set_uv(_data[9], _data[10]);
			shader_set_2("dimension",     [_sw, _sh] );
			shader_set_2("surfDimension", _idim      );
			
			shader_set_2("spacing",   _spc  );
			
			shader_set_2("position",  _pos  );
			shader_set_f("rotation",  degtorad(_rot));
			shader_set_i("shiftAxis", _shfA );
			shader_set_f("shiftAlt",  _shf  );
			
			draw_surface_stretched(_surf, 0, 0, _sw, _sh);
		surface_reset_shader();
		
		return _outSurf;
	}
}