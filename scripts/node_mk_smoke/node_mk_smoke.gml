function Node_MK_Smoke(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Smoke";
	update_on_frame = true;
	
	newInput( 6, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Spawn
	newInput(28, nodeValue_EScroll(  "Type",      0, [ "Area", "Path", "Map" ] ));
	newInput( 1, nodeValue_Int(      "Amount",    1                  ));
	newInput( 7, nodeValue_Area(     "Area",     [0,.5,0,0,AREA_SHAPE.rectangle,AREA_MODE.area], false )).setUnitSimple();
	newInput(29, nodeValue_Path( "Path"                          ));
	newInput(33, nodeValue_Bool(     "Loop"                          ));
	newInput(30, nodeValue_Surface(  "Map"                           ));
	newInput(31, nodeValue_Int(      "Attempt",   0                  ));
	
		////- =/Initial State
	newInput( 2, nodeValue_Range(    "Lifespan",   [64,64], true     ));
	newInput( 3, nodeValue_RotRand(  "Direction",  ROTRAN_DEF_0       ));
	
		////- =/Scaling
	newInput(32, nodeValue_SliRange( "Life Scale",  [1,1] ));
	newInput(34, nodeValue_SliRange( "Speed Scale", [1,1] ));
	
	////- =Wave
	newInput(12, nodeValue_SliRange( "Life Range", [0,.6]            ));
	newInput( 4, nodeValue_Curve(    "Wave",       CURVE_DEF_10      ));
	newInput(35, nodeValue_EScroll(  "Shape",       0, [ "Sine", "Wave", "Zigzag" ] ));
	newInput(11, nodeValue_Range(    "Phase",      [0,0], true       ));
	newInput( 8, nodeValue_Range(    "Frequency",  [4,4], true       ));
	newInput( 9, nodeValue_Range(    "Amplitude",  [2,2], true       ));
	
	////- =Spiral
	newInput(13, nodeValue_SliRange( "Life Range", [.3,1]            ));
	newInput( 5, nodeValue_Curve(    "Spiral",     CURVE_DEF_01      ));
	newInput(10, nodeValue_Range(    "Velocity",   [20,20], true     ));
	newInput(14, nodeValue_EScroll(  "Flip",        0, [ "None", "Random", "Ordered" ]  ));
	
	////- =Offset
	newInput(25, nodeValue_Range2(   "Offset",      [0,0,0,0]   )).setCurvable(26);
	
	////- =Render
	newInput(15, nodeValue_Range(   "Thickness",  [2,2], true  ))
		.setCurvable(18, CURVE_DEF_11, "Over Path", "curved"      )
		.setCurvable(23, CURVE_DEF_11, "Over Life", "curved_life" )
	newInput(22, nodeValue_EScroll( "Curve Range", 0, [ "Total", "Trim", "Trim + Clamp" ]  ));
	newInput(27, nodeValue_Bool(    "Draw SDF",    false  ));
	
		////- =/Color
	newInput(16, nodeValue_Gradient( "Base Color",      gra_white ));
	newInput(17, nodeValue_Gradient( "Color Over Life", gra_white ));
	
	////- =Animation
	newInput(21, nodeValue_Bool(    "Anim",        false        ));
	newInput(36, nodeValue_SliRange("Animation",   [0,1]        ));
	newInput(19, nodeValue_Range(   "Anim Range",  [1,1], true  ));
 	newInput(20, nodeValue_Range(   "Anim Speed",  [1,1], true  ));
	newInput(24, nodeValue_Range(   "Anim Shift",  [0,0], true  ));
	// 37
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ s_MKFX, 6, 
		[ "Output",      false     ],  0, 
		[ "Spawn",       false     ], 28,  1,  7, 29, 33, 30, 31,
			[ "/Initial State", false ],  2,  3,  
			[ "/Scaling",       false ], 32, 34,  
		
		[ "Wave",        false     ], 12,  4, 35, 11,  8,  9, 
		[ "Spiral",      false     ], 13,  5, 10, 14, 
		[ "Forces",      false     ], 25, 26, 
			
		[ "Render",      false     ], 15, 18, 23, 22, 27, 
			[ "/Color",  false     ], 16, 17, 
			
		[ "Animation",   false, 21 ], 36, 19, 20, 24, 
	];
	
	////- Nodes
	
	wave_curve   = new curveMap();
	spiral_curve = new curveMap();
	vector_curve = new curveMap();
	
	thick_path_curve = new curveMap();
	thick_life_curve = new curveMap();
	
	scatter_mapp = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _type = getInputSingle(28);
		
		switch(_type) {
			case 0 : drawOverlayInput(inputs[ 7].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my)); break;
			case 1 : drawOverlayInput(inputs[29].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my)); break;
		}
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed  = _data[ 6];
			
			var _dim   = _data[ 0];
			
			var _type  = _data[28];
			var _amo   = _data[ 1];
			var _area  = _data[ 7];
			var _path  = _data[29];
			var _pathL = _data[33];
			var _smap  = _data[30];
			var _attm  = _data[31];
			
			var _lifes = _data[ 2];
			var _dirrs = _data[ 3];
			
			var _lifeS = _data[32];
			var _moveS = _data[34];
			
			var _wLifs = _data[12];
			var _waveD = _data[ 4], _waveC = wave_curve.set(_waveD);
			var _waveP = _data[35];
			var _wPhss = _data[11];
			var _wFrqs = _data[ 8];
			var _wAmps = _data[ 9];
			
			var _sLifs = _data[13];
			var _spirD = _data[ 5], _spirC = spiral_curve.set(_spirD);
			var _sAmps = _data[10];
			var _sFlip = _data[14];
			
			var _fofft = _data[25];
			var _foffD = _data[26], _foffC = inputs[25].attributes.curved?      vector_curve.set(_foffD) : undefined;
			
			var _thks  = _data[15];
			var _thksD = _data[18], _thksC = inputs[15].attributes.curved?      thick_path_curve.set(_thksD) : undefined;
			var _thklD = _data[23], _thklC = inputs[15].attributes.curved_life? thick_life_curve.set(_thklD) : undefined;
			var _dRang = _data[22];
			var _dSDF  = _data[27];
			
			var _gBase = _data[16]; _gBase.cache();
			var _gLife = _data[17]; _gLife.cache();
			
			var _anim  = _data[21];
			var _animR = _data[36];
			var _nRang = _data[19];
			var _nSped = _data[20];
			var _nShft = _data[24];
			
			inputs[ 7].setVisible(_type == 0);
			inputs[29].setVisible(_type == 1, _type == 1);
			inputs[33].setVisible(_type == 1);
			inputs[30].setVisible(_type == 2, _type == 2);
			inputs[31].setVisible(_type == 2);
		#endregion
		
		update_on_frame = _anim;
		
		random_set_seed(_seed);
		var _spawnPoints = [];
		switch(_type) {
			case 0 :
				_spawnPoints = array_create(_amo);
				for( var i = 0, n = array_length(_spawnPoints); i < n; i++ ) {
					var sx = random_range(_area[0] - _area[2], _area[0] + _area[2]);
					var sy = random_range(_area[1] - _area[3], _area[1] + _area[3]);
					_spawnPoints[i] = [sx,sy];
				}
				break;
				
			case 1 : 
				if(!is_path(_path)) return _outSurf;
				
				__pth = _path;
				__p   = new __vec2P();
				__st  = 1 / max(1, _amo - !_pathL);
				
				_spawnPoints = array_create_ext(_amo, function(i) /*=>*/ {
					__pth.getPointRatio(i*__st, 0, __p);
					return [__p.x, __p.y];
				});
				break;
				
			case 2 : 
				if(!is_surface(_smap)) return _outSurf
				
				if(FIRST_FRAME) scatter_mapp = get_points_from_dist(_smap, _amo, _seed, _attm, scatter_mapp);
				_spawnPoints = scatter_mapp;
				break;
		}
		
		draw_set_circle_precision(8);
		surface_set_shader(_outSurf, noone);
			if(_dSDF) { BLEND_MAX    }
			else      { BLEND_NORMAL }
			
			for( var i = 0, n = array_length(_spawnPoints); i < n; i++ ) {
				random_set_seed(_seed + i * 1000);
				
				var _prog = 0, _fprog = 0;
				var _dirr = rotation_random_eval(_dirrs,, i);
				
				var ox = _spawnPoints[i][0], nx;
				var oy = _spawnPoints[i][1], ny;
				var _nwwg, ow, nw;
				
				var lscale = random_range(_lifeS[0], _lifeS[1]);
				var mscale = random_range(_moveS[0], _moveS[1]);
				
				var _life = irandom_range(_lifes[0], _lifes[1]) * lscale;
				var ilife = 1 / _life;
				
				var _wPhs = random_range(_wPhss[0], _wPhss[1]);
				var _wFrq = random_range(_wFrqs[0], _wFrqs[1]);
				var _wAmp = random_range(_wAmps[0], _wAmps[1]);
				
				var _sAmp = random_range(_sAmps[0], _sAmps[1]);
				switch(_sFlip) {
					case 1 : if(choose(0,1)) _sAmp = -_sAmp; break;
					case 2 : if(i % 2)       _sAmp = -_sAmp; break;
				}
				
				var _thk   = random_range(_thks[0], _thks[1]);
				var _cBase = _gBase.evalFast(random(1));
				var oc = _cBase, nc;
				
				var _aRang = random_range(_nRang[0], _nRang[1]);
				var _aSped = random_range(_nSped[0], _nSped[1]) / lscale;
				var _aShft = random_range(_nShft[0], _nShft[1]);
				
				var _foffX = random_range(_fofft[0], _fofft[1]);
				var _foffY = random_range(_fofft[2], _fofft[3]);
					
				var _dAnim = ((CURRENT_FRAME - _aShft) / TOTAL_FRAMES) * _aSped;
				    _dAnim = clamp(_dAnim, _animR[0], _animR[1]);
				var _dCen  = _dAnim * (1 + _aRang) - _aRang / 2;
				var _dSt   = _dCen - _aRang / 2;
				var _dEd   = _dCen + _aRang / 2;
				
				if(_dRang == 2) {
					_dSt = max(_dSt, 0);
					_dEd = min(_dEd, 1);
				}
				
				repeat(_life) {
					nx = ox;
					ny = oy;
					
					var _wave = _waveC.get((_prog - _wLifs[0]) / (_wLifs[1] - _wLifs[0]));
					switch(_waveP) {
						case 0 : _nwwg = dcos(_wPhs + _prog * 360 * _wFrq); break;
						
						case 1 : _nwwg = frac(_wPhs + _prog * _wFrq);    
						         _nwwg = frac(_nwwg + 1);
						         _nwwg = _nwwg * 2 - 1;
						         break;
						         
						case 2 : _nwwg = frac(_wPhs + _prog * _wFrq); 
						         _nwwg = frac(_nwwg + 1);
						         _nwwg = sign(_nwwg - .5);
						         break;
					}
					nw  = mscale * _nwwg * _wAmp * _wave;
					nx += lengthdir_x(nw, _dirr + 90);
					ny += lengthdir_y(nw, _dirr + 90);
					
					var _spir = _spirC.get((_prog - _sLifs[0]) / (_sLifs[1] - _sLifs[0]));
					_dirr += _sAmp * _spir / lscale;
					
					nx += lengthdir_x(mscale, _dirr);
					ny += lengthdir_y(mscale, _dirr);
					
					_fprog++;
					_prog += ilife;
					var _dProg = (_prog - _dSt) / (_dEd - _dSt);
					
					if(!_anim || (_dProg > 0 && _dProg < 1)) {
						var _cProg = (_anim && _dRang)? _dProg : _prog;
						
						var _cLife = _gLife.evalFast(random(_cProg));
						var cc = colorMultiply(_cBase, _cLife);
						
						var tt = _thk * mscale;
						if(_thksC != undefined) tt *= _thksC.get(_cProg);
						if(_thklC != undefined) tt *= _thklC.get(_dAnim);
						
						var dx = nx;
						var dy = ny;
						
						if(_anim) {
							var _offAmp = (_foffC == undefined? 1 : _foffC.get(_dAnim)) * mscale;
							dx += _foffX * _offAmp;
							dy += _foffY * _offAmp;
						}
						
						draw_set_color(cc);
						draw_set_alpha(_color_get_alpha(cc));
						if(_dSDF) draw_circle_color(dx, dy, tt/2, cc, c_black, false);
						else      draw_circle(dx, dy, tt/2, false);
					}
					
					ox = nx;
					oy = ny;
				}
			}
				
		surface_reset_shader();
		draw_set_alpha(1);
		
		return _outSurf; 
	}
}