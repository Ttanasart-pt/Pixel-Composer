function Node_Repeat_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Chain";
	
	newInput(17, nodeValueSeed());
	
	////- =Output
	newInput( 2, nodeValue_Dimension());
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In"     )).setRequired().setArrayDepth(1);
	newInput(22, nodeValue_EScroll( "Array Selection", 0, [ "Random", "Ordered" ] ));
	
	////- =Deform
	newInput( 9, nodeValue_Slider(  "Deform",      1 ));
	newInput(16, nodeValue_Int(     "Subdivision", 8 ));
	
	////- =Path
	newInput( 1, nodeValue_Path(    "Path"           )).setVisible(true, true).setRequired();
	newInput( 6, nodeValue_Range(   "Range",  [0,1]  ));
	newInput( 7, nodeValue_Float(   "Shift",   0     ));
	newInput( 8, nodeValue_Bool(    "Loop",    false ));
	
	////- =Repeat
	newInput( 3, nodeValue_EScroll( "Amount Type",   0, [ "Auto", "Fixed Amount", "Fixed Distance" ] ));
	newInput( 4, nodeValue_Float(   "Amount",        4 ));
	newInput( 5, nodeValue_Float(   "Distance",     16 ));
	newInput(24, nodeValue_Slider(  "Scale to Fit",  0 ));
	newInput(18, nodeValue_EScroll( "Path Overflow", 0, [ "Hide", "Scale", "Trim" ] ));
	newInput(19, nodeValue_Float(   "Gap",           0 ));
	
	////- =Rotation
	newInput(10, nodeValue_Rotation( "Rotation",         0        )).setCurvable(14, CURVE_DEF_11);
	newInput(11, nodeValue_RotRange( "Random Rotation", [0,0]     ));
	
	////- =Scale
	newInput(12, nodeValue_Vec2(     "Scale",           [1,1]     )).setCurvable(15, CURVE_DEF_11);
	newInput(13, nodeValue_Range2(   "Random Scale",    [0,0,0,0] ));
	newInput(25, nodeValue_Bool(     "Uniform Scale",   true      ));
	
	////- =Rendering
	newInput(23, nodeValue_EScroll(  "Blend Mode",      0, [ "Normal", "Additive", "Maximum" ] ));
	newInput(20, nodeValue_Gradient( "Color over Path", gra_white ));
	newInput(21, nodeValue_Gradient( "Color Random",    gra_white ));
	// 26
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 17, 
		[ "Output",    false ],  2,
		[ "Surface",   false ],  0, 22, 
		[ "Deform",    false ],  9, 16, 
		[ "Path",      false ],  1,  6,  7,  8,   
		[ "Repeat",    false ],  3,  4,  5, 24, 18, 19, 
		[ "Rotation",  false ], 10, 14, 11, 
		[ "Scale",     false ], 12, 15, 13, 25, 
		[ "Rendering", false ], 23, 20, 21, 
	];
	
	////- Nodes
	
	attribute_interpolation(true, true);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[ 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed = _data[17];
			
			var _dim  = _data[ 2];
			
			var _surf = _data[ 0];
			var _arrs = _data[22];
			var _defo = _data[ 9];
			var _reso = _data[16];
			
			var _path = _data[ 1];
			var _prng = _data[ 6];
			var _pshf = _data[ 7];
			var _plop = _data[ 8];
			
			var _atyp = _data[ 3];
			var _amou = _data[ 4];
			var _dist = _data[ 5]; _dist = max(1, _dist);
			var _sfit = _data[24]; 
			var _over = _data[18]; 
			var _gap  = _data[19]; 
			
			var _rot  = _data[10];
			var _rotC = _data[14], _rotCurve = inputs[10].attributes.curved? new curveMap(_rotC) : undefined;
			var _rotr = _data[11];
			
			var _sca  = _data[12];
			var _scaC = _data[15], _scaCurve = inputs[12].attributes.curved? new curveMap(_scaC) : undefined;
			var _scar = _data[13];
			var _suni = _data[25];
			
			var _blnd = _data[23];
			var _gpth = _data[20]; _gpth.cache();
			var _gran = _data[21]; _gran.cache();
			
			inputs[ 4].setVisible(_atyp == 1);
			inputs[ 5].setVisible(_atyp == 2);
			inputs[24].setVisible(_atyp != 0);
			inputs[18].setVisible(_atyp == 0);
			inputs[19].setVisible(_atyp == 0);
			
			if(!is_path(_path))    return _outSurf;
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		if(!is_array(_surf)) _surf = [_surf];
		if(array_empty(_surf)) return _outSurf;
		
		var _slen  = array_length(_surf);
		
		var drwDis = 0;
		var drwAmo = 0;
		var done   = false;
		
		var pthLen = _path.getLength();
		var pthInd = 0;
		
		var _prng0 = _prng[0] + _pshf;
		var _prng1 = _prng[1] + _pshf;
		
		if(!_plop) {
			_prng0 = clamp(_prng0, 0, .99);
			_prng1 = clamp(_prng1, 0, .99);
		}
		
		var pthDrwLen = pthLen * (_prng1 - _prng0);
		
		var __p  = new PathPoint();
		var __p2 = [0,0];
		
		var invReso = 1 / _reso;
		var x0, y0, x1, y1, x2, y2, x3, y3;
		
		random_set_seed(_seed);
		
		var bln = BLEND.normal;
		switch(_blnd) {
			case 0 : bln = BLEND.normal;  break;
			case 1 : bln = BLEND.add;     break;
			case 2 : bln = BLEND.maximum; break;
		}
		
		surface_set_shader(_outSurf, sh_sample_transform, true, bln);
			while(!done) {
				var __s = _surf[0];
				
				switch(_arrs) {
					case 0 : __s = array_get_random(_surf);        break;
					case 1 : __s = _surf[safe_mod(drwAmo, _slen)]; break;
				}
				
				var _sw = surface_get_width(__s);
				var _sh = surface_get_height(__s);
				
				var scax = _sca[0] + random_range(_scar[0], _scar[1]);
				var scay = _sca[1] + random_range(_scar[2], _scar[3]);
				if(_suni) scay = scax;
				
				var scac = _scaCurve? _scaCurve.get(drwDis / pthLen) : 1;
				scax *= scac;
				scay *= scac;
				
				var rot  = _rot + random_range(_rotr[0], _rotr[1]);
				    rot += _rotCurve? _rotCurve.get(drwDis / pthLen) : 0;
				shader_set_f("rotation", rot);
				
				var _sw = max(_sw * scax, 1);
				var _sh = max(_sh * scay, 1);
				
				var pthRat;
				switch(_atyp) {
					case 0 : 
						pthRat  = drwDis / pthLen; 
						
						     if(_over == 0) done = drwDis + _sw > pthDrwLen;
						else if(_over == 1) _sw = clamp(_sw, 1, pthDrwLen - drwDis);
						break;
						
					case 1 : 
						pthRat  = drwAmo / _amou;   
						_sw     = lerp(_sw, pthDrwLen / _amou, _sfit);
						break;
						
					case 2 : 
						pthRat  = drwDis / pthLen;  
						_sw     = lerp(_sw, _dist, _sfit);
						break;
				}
				
				pthRat += _prng0;
				
				if(done) break;
				
				var cc = _gpth.evalFast(clamp(pthRat, 0, 1));
				    cc = colorMultiply(cc, _gran.evalFast(random(1)));
				
				var aa = _color_get_a(cc);
				
				var _swStp = _sw / pthLen;
				var __p = _path.getPointRatio(pthRat, pthInd, __p);
				var sx  = __p.x;
				var sy  = __p.y;
				
				var __p = _path.getPointRatio(pthRat + _swStp, pthInd, __p);
				var ex  = __p.x;
				var ey  = __p.y;
				
				var _t0 = _path.getPointTangent(pthRat,          pthInd);
				var _t1 = _path.getPointTangent(pthRat + _swStp, pthInd);
				var _tc = lerp_angle_direct(_t0, _t1, .5);
				
				var _t0 = lerp(_tc, _t0, _defo);
				x0 = sx + lengthdir_x(_sh / 2, _t0 + 90);
				y0 = sy + lengthdir_y(_sh / 2, _t0 + 90);
				x1 = sx + lengthdir_x(_sh / 2, _t0 - 90);
				y1 = sy + lengthdir_y(_sh / 2, _t0 - 90);
				
				shader_set_interpolation(__s);
				draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(__s));
				
				for( var i = 1; i <= _reso; i++ ) {
					var t = i * invReso;
					var pthSufRat = pthRat + _swStp * t;
					
					if(_over == 2 && pthSufRat > _prng1) break;
					
					var __p    = _path.getPointRatio(pthSufRat, pthInd, __p);
					var _tang  = _path.getPointTangent(pthSufRat, pthInd);
					var _tang  = lerp_angle_direct(_tc, _tang, _defo);
					
					var px = __p.x;
					var py = __p.y;
					
					var dx = lerp(lerp(sx, ex, t), px, _defo);
					var dy = lerp(lerp(sy, ey, t), py, _defo);
					
					x2 = dx + lengthdir_x(_sh / 2, _tang + 90);
					y2 = dy + lengthdir_y(_sh / 2, _tang + 90);
					x3 = dx + lengthdir_x(_sh / 2, _tang - 90);
					y3 = dy + lengthdir_y(_sh / 2, _tang - 90);
					
					var u0 = invReso * (i-1);
					var u1 = invReso *  i;
					
					draw_vertex_texture_color(x0, y0, u0, 0, cc, aa);
					draw_vertex_texture_color(x2, y2, u1, 0, cc, aa);
					draw_vertex_texture_color(x1, y1, u0, 1, cc, aa);
					
					draw_vertex_texture_color(x2, y2, u1, 0, cc, aa);
					draw_vertex_texture_color(x1, y1, u0, 1, cc, aa);
					draw_vertex_texture_color(x3, y3, u1, 1, cc, aa);
					
					x0 = x2;
					y0 = y2;
					x1 = x3;
					y1 = y3;
					
				}
				
				draw_primitive_end();
				
				drwAmo++;
				switch(_atyp) {
					case 0 : drwDis += max(1, _sw + _gap); 
						     done = drwDis >= pthDrwLen; break;
						     
					case 1 : done = drwAmo >= _amou;  break;
					
					case 2 : drwDis += _dist; 
						     done = drwDis >= pthDrwLen; break;
				}
			}
		surface_reset_shader();
		
		return _outSurf; 
	}
}