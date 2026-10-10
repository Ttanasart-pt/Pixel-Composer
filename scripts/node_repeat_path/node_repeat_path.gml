function Node_Repeat_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat Path";
	
	////- =Output
	newInput( 2, nodeValue_Dimension());
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired().setArrayDepth(1);
	newInput( 9, nodeValue_Slider(  "Deform",  1 ));
	
	////- =Path
	newInput( 1, nodeValue_Path(    "Path"          )).setVisible(true, true).setRequired();
	newInput( 6, nodeValue_Range(   "Range", [0,1]  ));
	newInput( 7, nodeValue_Float(   "Shift",  0     ));
	newInput( 8, nodeValue_Bool(    "Loop",   false ));
	
	////- =Repeat
	newInput( 3, nodeValue_EScroll( "Amount Type", 0, [ "Auto", "Fixed Amount", "Fixed Distance" ] ));
	newInput( 4, nodeValue_Float(   "Amount",      4 ));
	newInput( 5, nodeValue_Float(   "Distance",    4 ));
	
	////- =Rotation
	newInput(10, nodeValue_Rotation( "Rotation",         0        )).setCurvable(14, CURVE_DEF_11);
	newInput(11, nodeValue_RotRange( "Random Rotation", [0,0]     ));
	
	////- =Scale
	newInput(12, nodeValue_Vec2(     "Scale",           [1,1]     )).setCurvable(15, CURVE_DEF_11);
	newInput(13, nodeValue_Range2(   "Random Scale",    [0,0,0,0] ));
	// 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",   false ],  2,
		[ "Surface",  false ],  0,  9, 
		[ "Path",     false ],  1,  6,  7,  8,   
		[ "Repeat",   false ],  3,  4,  5,  
		[ "Rotation", false ], 10, 14, 11, 
		[ "Scale",    false ], 12, 15, 13, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim  = _data[ 2];
			
			var _surf = _data[ 0];
			var _defo = _data[ 9];
			
			var _path = _data[ 1];
			var _prng = _data[ 6];
			var _pshf = _data[ 7];
			var _plop = _data[ 8];
			
			var _atyp = _data[ 3];
			var _amou = _data[ 4];
			var _dist = _data[ 5];
			
			var _rot  = _data[10];
			var _rotC = _data[14], _rotCurve = inputs[10].attributes.curved? new curveMap(_rotC) : undefined;
			var _rotr = _data[11];
			
			var _sca  = _data[12];
			var _scaC = _data[15], _scaCurve = inputs[12].attributes.curved? new curveMap(_scaC) : undefined;
			var _scar = _data[13];
			
			inputs[ 4].setVIsible(_atyp == 1);
			inputs[ 5].setVIsible(_atyp == 2);
			
			if(!is_surface(_surf)) return _outSurf;
			if(!is_path(_path))    return _outSurf;
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var drwDis = 0;
		var drwAmo = 0;
		var done   = false;
		
		var pthLen = _path.getLength();
		var pthInd = 0;
		var __p = new __vec2P();
		
		surface_set_shader(_outSurf);
			while(!done) {
				var __s = _surf;
				var _sw = surface_get_width(__s);
				var _sh = surface_get_height(__s);
				
				var pthRat = (drwDis + _sw / 2) / pthLen;
				__p = _path.getPointRatio(pthRat, pthInd, __p);
				
				var _px = __p.x;
				var _py = __p.y;
				
				drwAmo++;
				switch(_atyp) {
					case 0 : 
						drwDis += _sw; 
						done = drwDis > pthLen; 
						break;
						
					case 1 : 
						done = drwAmo > _amou; 
						break;
						
					case 2 : 
						drwDis += _dist; 
						done = drwDis > pthLen; 
						break;
				}
			}
		surface_reset_shader();
		
		return _outSurf; 
	}
}