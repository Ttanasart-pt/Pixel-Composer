function Node_MK_Tree_Leaf_Particle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Leaves Particle";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon(s_node_mk_tree_leaf_particle);
	setDimension(96, 48);
	
	newInput(18, nodeValue_Bool( "Active", true ));
	newInput( 1, nodeValueSeed());
	
	////- =Leaves
	newInput( 0, nodeValue_Struct( "Leaves")).setVisible(true, true).setCustomData(global.MKTREE_LEAVES_JUNC);
	newInput(13, nodeValue_Range(  "Lifespan", [0,0], true )).setTooltip("Only use for the 'Over Life' properties. Leaf wont disappear after lifespan is zero.");
	
	////- =Fall
	newInput( 2, nodeValue_Range(   "Fall Time",      [ 0,10], false    )).setMappableConst(3);
	newInput(10, nodeValue_Range(   "Fall Speed",     [ 0, 0],  true    ));
	newInput(11, nodeValue_RotRand( "Fall Direction", [ 0,-90,-90,0,0 ] ));
	
	////- =Rotation
	newInput( 4, nodeValue_Range( "Rotate Speed",     [0,0], true ));
	newInput( 5, nodeValue_Bool(  "Random Direction", false       ));
	
	////- =Scale
	newInput(19, nodeValue_Curve( "Scale Over Life", CURVE_DEF_11 ));
	
	////- =Colors
	newInput(14, nodeValue_EScroll(  "Blendmode", 1, [ "Override", "Multiply", "Screen" ] ));
	newInput(12, nodeValue_Gradient( "Color Over Life [live]", gra_white ));
	newInput(15, nodeValue_Gradient( "Color Over Life [fall]", gra_white ));
	
	////- =Physics
	newInput( 6, nodeValue_Range(    "Gravity",         [.25,.25], true  ));
	newInput( 7, nodeValue_Rotation( "Grav. Direction", -90              ));
	newInput(16, nodeValue_Range(    "Swing Speed",     [0,0],     true  ));
	newInput(17, nodeValue_Range(    "Swing Amplitude", [0,0],     true  ));
	
	////- =Ground
	newInput( 8, nodeValue_Bool(  "Ground",       false  ));
	newInput( 9, nodeValue_Range( "Ground Range", [.9,1] ));
	// 20
	
	newOutput(0, nodeValue_Output("Leaves", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_LEAVES_JUNC);
	
	input_display_list = [ 18, 1, 
		[ "Leaves",   false ],  0, 13, 
		[ "Fall",     false ],  2,  3, 10, 11, 
		[ "Rotation", false ],  4,  5, 
		[ "Scale",    false ], 19, 
		[ "Colors",   false ], 14, 12, 15, 
		[ "Physics",  false ],  6,  7, 16, 17, 
		[ "Ground",   false, 8 ],   9, 
	];
	
	////- Nodes
	
	leaves   = undefined;
	__prevac = false;
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : [1,1]};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static reset = function() {
		var _leav = getInputData( 0);
		leaves    = undefined;
		
		if(!is_array(_leav) || array_empty(_leav)) return;
		if(!is(_leav[0], __MK_Tree_Leaf))          return;
		
		var len = array_length(_leav);
		leaves = array_create(len);
		
		for( var i = 0, n = len; i < n; i++ ) {
			var _l = _leav[i].clone();
			leaves[i] = _l;
			
			_l.fall     = false;
			_l.ground   = false;
			_l.life     = 0;
			_l.lifeFall = 0;
			
			_l.px = _l.x;
			_l.py = _l.y;
			
			_l.vx = 0;
			_l.vy = 0;
			
			_l.colorBase  = _l.color;
			_l.colorEBase = _l.colorE;
			_l.colorUBase = _l.colorU;
		}
	}
	
	static onAnimationStart = function() {
		if(use_cache == CACHE_USE.auto && !isAllCached()) clearCache();
		__prevac = false;
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _dim  = getDimension();
			
			var _actv = getInputData(18);
			var _seed = getInputData( 1);
			
			var _leav = getInputData( 0);
			var _life = getInputData(13);
			
			var _fall  = getInputData( 2), _fallMap = getInputData( 3);
			var _fallM = inputs[2].attributes.mapped && is_surface(_fallMap);
			
			var _flsp = getInputData(10);
			var _fldr = getInputData(11);
			
			var _dirr = getInputData( 4);
			var _dirf = getInputData( 5);
			
			var _scal = getInputData(19), curve_scal = new curveMap(_scal);
			
			var _blnd = getInputData(14);
			var _clif = getInputData(12); _clif.cache();
			var _cfal = getInputData(15); _cfal.cache();
			
			var _grav = getInputData( 6);
			var _gdir = getInputData( 7);
			var _swsp = getInputData(16);
			var _swam = getInputData(17);
			
			var _grnd = getInputData( 8);
			var _grrn = getInputData( 9);
		#endregion
		
		if((!__prevac && _actv) || (!inputs[18].is_anim && IS_FIRST_FRAME))
			reset();
		__prevac = _actv;
		
		if(!_actv) { outputs[0].setValue(_leav); return; }
		if(leaves == undefined) return;
		outputs[0].setValue(leaves);
		
		var _fallSamp  = _fallM? new Surface_Sampler_Grey(_fallMap) : undefined;
		var _blendColor = undefined;
		var _gx = lengthdir_x(1, _gdir);
		var _gy = lengthdir_y(1, _gdir);
		
		for( var i = 0, n = array_length(leaves); i < n; i++ ) {
			var _l = leaves[i];
			var _iseed = _seed + i;
			random_set_seed(_iseed);
			
			if(!_l.fall) {
				var _falt = random_range(_fall[0], _fall[1]);
				var _falm = _fallM? _fallSamp.getPixelDirectClamp(round(_l.x), round(_l.y)) : 1;
			    _falt *= _falm;
				
				var _prg = _falt <= 1? 0 : _l.life / (_falt - 1);
				
				if(_l.life >= _falt) {
					_l.fall = true;
					
					var _fallSpeed = random_range(_flsp[0], _flsp[1]);
					var _fallDirr  = rotation_random_eval(_fldr, _iseed);
					
					_l.vx = lengthdir_x(_fallSpeed, _fallDirr);
					_l.vy = lengthdir_y(_fallSpeed, _fallDirr);
				}
				
				_blendColor = _clif.evalFast(clamp(_prg, 0, 1));
				
				_l.life++;
				
			} else {
				var _lifespan = random_range(_life[0], _life[1]);
				var _grny     = random_range(_grrn[0], _grrn[1]) * _dim[1];
				var _gamp     = random_range(_grav[0], _grav[1]);
				var _swingSp  = random_range(_swsp[0], _swsp[1]);
				var _swingAm  = random_range(_swam[0], _swam[1]);
				
				var _prg  = _lifespan <= 0? 0 : _l.lifeFall / _lifespan;
				
				_l.vx += _gx * _gamp;
				_l.vy += _gy * _gamp;
				
				var _vdis = point_distance(  0, 0, _l.vx, _l.vy );
				var _vdir = point_direction( 0, 0, _l.vx, _l.vy );
				_vdir += sin(_l.life + _l.lifeFall * _swingSp) * _swingAm;
				
				_l.vx = lengthdir_x(_vdis, _vdir);
				_l.vy = lengthdir_y(_vdis, _vdir);
				
				if(!_l.ground) {
					_l.x += _l.vx;
					_l.y += _l.vy;
				}
				
				if(_grnd) {
					_l.ground = _l.ground || _l.y >= _grny;
					_l.y = min(_l.y, _grny);
				}
				
				var _sca  = curve_scal.get(_prg);
				_l.scale = _sca;
				
				_blendColor = _cfal.evalFast(clamp(_prg, 0, 1));
				
				_l.lifeFall++;
				
				_l.vx = _l.x - _l.px; // gen
				_l.vy = _l.y - _l.py; // gen
				
				_l.px = _l.x;         // gen
				_l.py = _l.y;         // gen
				
			}
			
			switch(_blnd) {
				case 0 : 
					_l.color  = _l.color  == undefined? undefined : merge_color(   _l.colorBase,  _blendColor, _prg ); 
					_l.colorE = _l.colorE == undefined? undefined : merge_color(   _l.colorEBase, _blendColor, _prg ); 
					_l.colorU = _l.colorU == undefined? undefined : merge_color(   _l.colorUBase, _blendColor, _prg ); 
					break;
					
				case 1 : 
					_l.color  = _l.color  == undefined? undefined : merge_color(   _l.colorBase,  colorMultiply( _l.colorBase,  _blendColor ), _prg); 
					_l.colorE = _l.colorE == undefined? undefined : merge_color(   _l.colorEBase, colorMultiply( _l.colorEBase, _blendColor ), _prg); 
					_l.colorU = _l.colorU == undefined? undefined : merge_color(   _l.colorUBase, colorMultiply( _l.colorUBase, _blendColor ), _prg); 
					break;
					
				case 2 : 
					_l.color  = _l.color  == undefined? undefined : merge_color(   _l.colorBase,  colorScreen(   _l.colorBase,  _blendColor ), _prg); 
					_l.colorE = _l.colorE == undefined? undefined : merge_color(   _l.colorEBase, colorScreen(   _l.colorEBase, _blendColor ), _prg); 
					_l.colorU = _l.colorU == undefined? undefined : merge_color(   _l.colorUBase, colorScreen(   _l.colorUBase, _blendColor ), _prg); 
					break;
					
			}
			
			var _moved = (_l.vx * _l.vx + _l.vy * _l.vy) > 0;
			if(_moved) {
				var _rots = random_range(_dirr[0], _dirr[1]) * (_dirf? choose(-1, 1) : 1);
				
				_l.dir += _rots;
				_l.recalDir();
			}
		}
	}
}
