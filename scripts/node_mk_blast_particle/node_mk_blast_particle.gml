function Node_MK_Blast_Particle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Particle";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon(s_node_mk_blast_particle);
	setDimension(96, 48);
	
	newInput( 0, nodeValueSeed());
	
	////- =Settings
	newInput( 1, nodeValue_Curve( "Group Intpolation", CURVE_DEF_01 ));
	newInput( 2, nodeValue_Curve( "Anim Intpolation",  CURVE_DEF_01 ));
	
	////- =Spawning
	newInput( 4, nodeValue_Float( "Amount",   1    ));
	newInput(23, nodeValue_Range( "Scatter", [0,0] ));
	
	newInput( 5, nodeValue_Float( "Period",   2    ));
	newInput( 6, nodeValue_Range( "Frame",   [0,0] ));
	
		////- =/Lifespan
	newInput( 7, nodeValue_Range( "Lifespan", [0,0] ));
		
	////- =Particle
	newInput( 3, nodeValue_Particle( "Particle" )).setVisible(true, true);
	
	////- =Movement
	newInput( 8, nodeValue_Range(   "Speed",     [0,0]       ));
	newInput( 9, nodeValue_Range(   "Friction",  [0,0]       ));
	newInput(10, nodeValue_RotRand( "Direction", [0,0,0,0,0] ));
	newInput(11, nodeValue_Range(   "Gravity",   [0,0]       ));
	
	////- =Rotation
	newInput(21, nodeValue_Range(   "Rotate",      [0,0] ));
	newInput(22, nodeValue_Bool(    "Flip Rotate", false ));
	
	////- =Size
	newInput(12, nodeValue_Range(      "Size",         [6,10]    ));
	newInput(24, nodeValue_Range(      "Spawn Size",   [.5,.5]   ));
	newInput(36, nodeValue_Vec2_Range( "Aspect Ratio", [1,1,1,1] ));
	
	////- =Spiral
	newInput(25, nodeValue_Bool(    "Spiral Use", false   ));
	newInput(30, nodeValue_Range(   "Phase",      [0,0]   ));
	newInput(26, nodeValue_Range(   "Size",       [4,4]   ));
	newInput(27, nodeValue_Range(   "Intensity",  [.5,.5] ));
	newInput(29, nodeValue_Range(   "Rotation",   [5,5]   ));
	newInput(28, nodeValue_Bool(    "Multiply",   true    ));
	
	////- =Decay
	newInput(13, nodeValue_Bool(    "Do Decay", true  ));
	newInput(14, nodeValue_Range(   "Decay",    [4,6] ));
	
	////- =Render
	newInput(16, nodeValue_Surface( "Texture" ));
	
		////- =/Shape
	newInput(15, nodeValue_EScroll( "Shape", 0, [ "Circle", "Arrow", "Line", "Path" ] ));
	newInput(31, nodeValue_Range(   "Arrow Offset", [0,0] ));
	newInput(32, nodeValue_PathNode("Path"                ));
	newInput(33, nodeValue_Int(     "Path Sample",   8    ));
	newInput(34, nodeValue_Range(   "Thickness",    [2,2] ));
	newInput(35, nodeValue_Curve(   "Shape",        CURVE_DEF_11 ));
	
		////- =/Color
	newInput(17, nodeValue_Gradient( "Color", gra_black_white ));
	newInput(18, nodeValue_Range(    "Level", [0,1]  ));
	
		////- =/Perspective
	newInput(19, nodeValue_Vec2(  "View Origin", [.5,.5] )).setUnitSimple();
	newInput(20, nodeValue_Range( "Perspective", [2,2]   ));
	// 37
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX, 0,  
		[ "Settings",       true ],  1,  2, 
		[ "Spawning",      false ],  4, 23,  5,  6,  
			[ "/Lifespan", false ],  7, 
			
		[ "Particle",      false ],  3, 
		[ "Movement",      false ],  8,  9, 10, 11, 
		[ "Rotation",      false ], 21, 22, 
		[ "Size",          false ], 12, 24, 36, 
		
		[ "Spiral",    false, 25 ], 30, 26, 27, 29, 28, 
		[ "Decay",     false, 13 ], 14, 
		
		[ "Render",           false ], 16, 
			[ "/Shape",       false ], 15, 31, 32, 33, 34, 35, 
			[ "/Color",       false ], 17, 18, 
			[ "/Perspective", false ], 20, 21, 
	];
	
	////- Nodes
	
	mainLayer = new MKBlast_Layer();
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[19].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, 1));
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data 
			var _dim     = getDimension();
			var _seed    = inline_context.seed + getInputData(0);
			var _gDir    = inline_context.gravityDir;
			
			var _grInt   = getInputData( 1), curve_grInt = new curveMap(_grInt);
			var _anInt   = getInputData( 2), curve_anInt = new curveMap(_anInt);
			
			var _amount  = getInputData( 4);
			var _scatt   = getInputData(23);
			
			var _period  = getInputData( 5);
			var _frames  = getInputData( 6);
			
			var _lifes   = getInputData( 7);
			
			var _parts   = getInputData( 3);
			
			var _speed   = getInputData( 8);
			var _fract   = getInputData( 9);
			var _direct  = getInputData(10);
			var _gravity = getInputData(11);
			
			var _rotat   = getInputData(21);
			var _rotaFl  = getInputData(22);
			
			var _sizes   = getInputData(12);
			var _sizeRat = getInputData(24);
			var _aspects = getInputData(36);
			
			var _spiUse  = getInputData(25);
			var _spiPhs  = getInputData(30);
			var _spiSiz  = getInputData(26);
			var _spiInt  = getInputData(27);
			var _spiRot  = getInputData(29);
			var _spiMul  = getInputData(28);
			
			var _ddecay  = getInputData(13);
			var _decay   = getInputData(14);
			
			var _texture = getInputData(16);
			
			var _shape   = getInputData(15);
			var _arrowO  = getInputData(31);
			var _path    = getInputData(32);
			var _pathD   = getInputData(33);
			var _lineW   = getInputData(34);
			var _lineS   = getInputData(35), _lineData  = new curveMap(_lineS, 32);
			
			var _color   = getInputData(17);
			var _level   = getInputData(18);
			
			var _vieworg = getInputData(19);
			var _perspec = getInputData(20);
			
			random_set_seed(_seed + _frame);
			
			inputs[31].setVisible(_shape == 1);
			
			inputs[32].setVisible(_shape == 3, _shape == 3);
			inputs[33].setVisible(_shape == 3);
			inputs[34].setVisible(_shape == 2 || _shape == 3);
			inputs[35].setVisible(_shape == 2 || _shape == 3);
		#endregion
		
		var _pathData = [];
		if(_shape == 3 && is_path(_path)) {
			_pathData = array_create(_pathD);
			var _siz = 1 / (_pathD - 1);
			var __p  = new __vec2();
			
			for( var i = 0; i < _pathD; i++ ) {
				__p = _path.getPointRatio(i * _siz, 0, __p);
				_pathData[i] = [__p.x, __p.y]
			}
		}
		
		if(IS_FIRST_FRAME) mainLayer = new MKBlast_Layer();
		mainLayer.colorize  = _color;
		
		for( var i = 0, n = array_length(mainLayer.flames); i < n; i++ )
			mainLayer.flames[i].life++;
		
		for( var i = 0, n = array_length(_parts); i < n; i++ ) {
			var _part = _parts[i];
			if(!_part.active) continue;
			if(_part.life % _period != 0) continue;
			
			var _gro  = _amount;
			
			for( var g = 0; g < _gro; g++ ) {
				var _flm = new MKBlast_Element();
				
				_flm.texture = _texture;
				_flm.mask    = MKBlast_Mask.flame;
					
				_flm.origin    = _vieworg;
				_flm.originDim = _dim;
				
				var _scLen = random_range(_scatt[0], _scatt[1]);
				var _scDir = random(360);
				
				_flm.sx = _part.x + lengthdir_x(_scLen, _scDir);
				_flm.sy = _part.y + lengthdir_y(_scLen, _scDir);
				
				var _life = irandom_range(_lifes[0], _lifes[1]);
				var _fram = irandom_range(_frames[0], _frames[1]);
				_flm.life      = -_fram;
				_flm.lifeTotal = _part.life_total + _life;
				
				_flm.speed     = random_range(_speed[0], _speed[1]);
				_flm.friction  = random_range(_fract[0], _fract[1]);
				_flm.direction = _part.phyDirr + rotation_random_eval(_direct);
				
				_flm.gravity    = random_range(_gravity[0], _gravity[1]);
				_flm.gravityDir = _gDir;
				
				_flm.rotate     = random_range(_rotat[0], _rotat[1]);
				if(_rotaFl && choose(0,1)) _flm.rotate = -_flm.rotate;
				
				var _siz = random_range(_sizes[0], _sizes[1]);
				_flm.aspect[0] = random_range(_aspects[0], _aspects[1]);
				_flm.aspect[1] = random_range(_aspects[2], _aspects[3]);
				_flm.size[0]   = _siz * random_range(_sizeRat[0], _sizeRat[1]);
				_flm.size[1]   = _siz;
				
				_flm.shape     = _shape;
				_flm.pathData  = _pathData;
				
				_flm.arrowSize     = random_range(_arrowO[0], _arrowO[1]);
				_flm.lineThickness = random_range(_lineW[0], _lineW[1]);
				_flm.lineShape     = _lineData.map;
				
				_flm.spiralSize      = _spiUse? random_range(_spiSiz[0], _spiSiz[1]) : 0;
				_flm.spiralPhase     = random_range(_spiPhs[0], _spiPhs[1]);
				_flm.spiralIntensity = random_range(_spiInt[0], _spiInt[1]);
				_flm.spiralRotation  = random_range(_spiRot[0], _spiRot[1]);
				_flm.spiralMultiply  = _spiMul;
				
				_flm.doDecay   = _ddecay;
				_flm.decay     = random_range(_decay[0], _decay[1]);
				
				_flm.perspective = random_range(_perspec[0], _perspec[1]);
				_flm.animCurve   = curve_anInt;
				
				_flm.level     = _level;
				
				array_push(mainLayer.flames, _flm);
			}
		}
		
		for( var i = 0, n = array_length(mainLayer.flames); i < n; i++ )
			mainLayer.flames[i].step();
		
		_flameLayer = [ mainLayer ];
		outputs[0].setValue(_flameLayer);
	}
}