function Node_Extends(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Extends";
	
	newActiveInput(1);
	newInput(2, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 3, nodeValue_Surface( "Mask"      ));
	newInput( 4, nodeValue_Slider(  "Mix", 1    ));
	__init_mask_modifier(3, 5); // inputs 5, 6 
	
	////- =Select
	newInput( 7, nodeValue_EScroll(  "Type",        0, [ "Line", "Point", "Path" ] ));
	newInput( 8, nodeValue_Vec2(     "Point 1",   [.5,0] )).setUnitSimple();
	newInput( 9, nodeValue_Vec2(     "Point 2",   [.5,1] )).setUnitSimple();
	newInput(13, nodeValue_PathNode( "Path"              ));
	newInput(14, nodeValue_Int(      "Path Sample", 16   ));
	
	////- =Extends
	newInput(10, nodeValue_Float(    "Length",    .25    )).setUnitSimple();
	newInput(15, nodeValue_Bool(     "Use normal", false ));
	newInput(11, nodeValue_Rotation( "Direction",   0    ));
	newInput(12, nodeValue_Bool(     "Extends",    true  ));
	newInput(16, nodeValue_Bool(     "Both Side",  false ));
	// input 17
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 2,
		[ "Surfaces", false ],  0,  3,  4,  5,  6, 
		[ "Select",   false ],  7,  8,  9, 13, 14, 
		[ "Extends",  false ], 10, 15, 11, 12, 16, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _type = getInputSingle(7);
		
		if(_type == 0) {
			var _pnt1 = getInputSingle( 8);
			var _pnt2 = getInputSingle( 9);
			var _dirr = getInputSingle(11);
			var _norm = getInputSingle(15);
			
			var px0 = _x + _pnt1[0] * _s;
			var py0 = _y + _pnt1[1] * _s;
			var px1 = _x + _pnt2[0] * _s;
			var py1 = _y + _pnt2[1] * _s;
			
			var cx = (px0 + px1) / 2;
			var cy = (py0 + py1) / 2;
			
			var dr = _norm? point_direction(px0, py0, px1, py1) + 90 : _dirr;
			
			draw_set_color(COLORS._main_accent);
			draw_line_dashed( px0, py0, px1, py1 );
			
			InputDrawOverlay(inputs[ 8].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my ));
			InputDrawOverlay(inputs[ 9].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my ));
			InputDrawOverlay(inputs[10].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my, dr, 1, 1 ));
			
			if(!_norm)
				InputDrawOverlay(inputs[11].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my ));
			
		} else if(_type == 1) {
			var _pnt1 = getInputSingle( 8);
			var _dirr = getInputSingle(11);
			
			var cx = _x + _pnt1[0] * _s;
			var cy = _y + _pnt1[1] * _s;
			
			InputDrawOverlay(inputs[ 8].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my ));
			InputDrawOverlay(inputs[10].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my, _dirr, 1, 1 ));
			InputDrawOverlay(inputs[11].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my ));
		
		} else if(_type == 2) {
			var _norm = getInputSingle(15);
			
			if(!_norm)
				InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my ));
		}
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _type = _data[ 7];
			var _pnt1 = _data[ 8];
			var _pnt2 = _data[ 9];
			var _path = _data[13];
			var _psam = _data[14];
			
			var _leng = _data[10];
			var _norm = _data[15];
			var _dirr = _data[11];
			var _extn = _data[12];
			var _both = _data[16];
			
			inputs[ 8].setVisible(_type == 0 || _type == 1);
			inputs[ 9].setVisible(_type == 0);
			inputs[13].setVisible(_type == 2);
			inputs[14].setVisible(_type == 2);
			
			inputs[15].setVisible(_type == 0 || _type == 2);
			// inputs[12].setVisible(_type == 0);
		#endregion
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _dim  = surface_get_dimension(_surf);
		var _pnts = [];
		
		if(_type == 2) {
			_pnts = array_create((_psam + 1) * 2);
			
			if(is_path(_path)) {
				var _astep = 1 / _psam;
				var _prg   = 0;
				var _p     = new __vec2P();
				var i = 0;
				
				repeat(_psam + 1) {
					_p    = _path.getPointRatio(_prg, 0, _p);
					_prg += _astep;
					
					_pnts[i++] = _p.x;
					_pnts[i++] = _p.y;
				}
			}
		}
		
		surface_set_shader( _outSurf, sh_extends );
			shader_set_2( "dimension",  _dim  );
			
			shader_set_i( "type",       _type );
			shader_set_2( "point1",     _pnt1 );
			shader_set_2( "point2",     _pnt2 );
			shader_set_f( "pathData",   _pnts );
			shader_set_f( "pathSample", _psam );
			
			shader_set_f( "exLength",   _leng );
			shader_set_f( "direction",  _dirr );
			shader_set_i( "useNormal",  _norm );
			shader_set_i( "extends",    _extn );
			shader_set_i( "bothSide",   _both );
			
			draw_surface( _surf, 0, 0 );
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[2]);
		return _outSurf; 
	}
}