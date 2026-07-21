function Node_MK_Blast_Smoke(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Smoke";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 2, nodeValueSeed());
	
	////- =Blast
	newInput( 0, nodeValue_Struct( "Blast" )).setCustomData(global.MKBLAST_JUNC).setVisible(true, true);
	
	////- =Spawning
	newInput( 5, nodeValue_Range( "Amount",       [1,1] ));
	newInput(18, nodeValue_Range( "Scatter",      [0,0] ));
	
		////- =/Lifespan
	newInput( 1, nodeValue_Range( "Life Offset",  [2,4]   ));
	newInput( 6, nodeValue_Range( "Life Scale",   [.75,1] ));
	
	////- =Movement
	newInput( 7, nodeValue_Range( "Speed Offset",     [-.2,.2] ));
	
		////- =/Direction
	newInput(14, nodeValue_Bool(  "Direction Override", 0 ));
	newInput( 9, nodeValue_Range( "Direction Offset", [-15,15] ));
	
	////- =Rotation
	newInput(15, nodeValue_Range(   "Rotate",      [0,0] ));
	newInput(16, nodeValue_Bool(    "Flip Rotate", false ));
	
	////- =Size
	newInput( 8, nodeValue_Range( "Scale Offset", [.75,1] ));
	newInput(19, nodeValue_Range( "Spawn Size",   [.5,.5] ));
	newInput(31, nodeValue_Vec2_Range( "Aspect Ratio", [1,1,1,1] ));
	
	////- =Spiral
	newInput(20, nodeValue_Bool(    "Spiral Use", false   ));
	newInput(25, nodeValue_Range(   "Phase",      [0,0]   ));
	newInput(21, nodeValue_Range(   "Size",       [4,4]   ));
	newInput(22, nodeValue_Range(   "Intensity",  [.5,.5] ));
	newInput(24, nodeValue_Range(   "Rotation",   [5,5]   ));
	newInput(23, nodeValue_Bool(    "Multiply",   true    ));
	
	////- =Decay
	newInput(13, nodeValue_Bool(    "Do Decay",     true  ));
	newInput(17, nodeValue_Range(   "Decay",        [4,6] ));
	
	////- =Render
	newInput( 4, nodeValue_Bool(    "Overlay",  false ));
	newInput(11, nodeValue_Surface( "Texture"  ));
	newInput(32, nodeValue_Float(   "Depth", 0 ));
	
		////- =/Shape
	newInput(12, nodeValue_EScroll( "Shape", 0, [ "Circle", "Arrow", "Line", "Path" ] ));
	newInput(26, nodeValue_Range(   "Arrow Offset", [0,0] ));
	newInput(27, nodeValue_Path("Path"                ));
	newInput(28, nodeValue_Int(     "Path Sample",   8    ));
	newInput(29, nodeValue_Range(   "Thickness",    [2,2] ));
	newInput(30, nodeValue_Curve(   "Shape",        CURVE_DEF_11 ));
	
		////- =/Color
	newInput( 3, nodeValue_Gradient( "Color", gra_black_white )).addShift(33);
	newInput(10, nodeValue_Range(    "Level", [0,1]  ));
	// 34
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	newOutput( 1, nodeValue_Output( "Smoke", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX, 2,  
		[ "Blast",         false ],  0,  
		[ "Spawning",      false ],  5, 18, 
			[ "/Lifespan", false ],  1,  6, 
		
		[ "Movement",      false ],  7, 
			[ "/Direction",false ], 14,  9, 
			
		[ "Rotation",      false ], 15, 16, 
		[ "Size",          false ],  8, 31, 
		
		[ "Spiral",    false, 20 ], 25, 21, 22, 24, 23, 
		[ "Decay",     false, 13 ], 17, 
		[ "Render",        false ],  4, 11, 32, 
			[ "/Shape",    false ], 12, 26, 27, 28, 29, 30, 
			[ "/Color",    false ], [3, true], 33, -1, 10, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data
			var _dim  = getDimension();
			var _seed = inline_context.seed + getInputData(2);
			
			var _flameLayer = getInputData( 0);
			
			var _amount     = getInputData( 5);
			var _scatt      = getInputData(18);
			
			var _lifeOffset = getInputData( 1);
			var _lifeScale  = getInputData( 6);
			
			var _speedOf    = getInputData( 7);
			
			var _dirrOver   = getInputData(14);
			var _dirrOf     = getInputData( 9);
			
			var _rotat      = getInputData(15);
			var _rotaFl     = getInputData(16);
			
			var _scalOf     = getInputData( 8);
			var _sizeRat    = getInputData(19);
			var _aspects    = getInputData(31);
			
			var _spiUse     = getInputData(20);
			var _spiPhs     = getInputData(25);
			var _spiSiz     = getInputData(21);
			var _spiInt     = getInputData(22);
			var _spiRot     = getInputData(24);
			var _spiMul     = getInputData(23);
			
			var _ddecay     = getInputData(13);
			var _decay      = getInputData(17);
			
			var _overl      = getInputData( 4);
			var _text       = getInputData(11);
			var _depth      = getInputData(32);
			
			var _shape      = getInputData(12);
			var _arrowO     = getInputData(26);
			var _path       = getInputData(27);
			var _pathD      = getInputData(28);
			var _lineW      = getInputData(29);
			var _lineS      = getInputData(30), _lineData  = new curveMap(_lineS, 32);
			
			var _color      = getInputData( 3);
			var _colorShf   = getInputData(33);
			var _level      = getInputData(10);
			
			random_set_seed(_seed);
			
			inputs[26].setVisible(_shape == 1);
			
			inputs[27].setVisible(_shape == 3, _shape == 3);
			inputs[28].setVisible(_shape == 3);
			inputs[29].setVisible(_shape == 2 || _shape == 3);
			inputs[30].setVisible(_shape == 2 || _shape == 3);
		#endregion
		
		var _smokeLayer = [];
		var _smokeOrder = [];
		
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
		
		for( var i = 0, n = array_length(_flameLayer); i < n; i++ ) {
			var _l = _flameLayer[i];
			
			var _layer  = new MKBlast_Layer();
			_layer.colorize   = _color;
			_layer.color_shft = _colorShf;
			
			for( var j = 0, m = array_length(_l.flames); j < m; j++ ) {
				var _flm = _l.flames[j];
				if(!is(_flm, MKBlast_Element))        continue;
				if(!(_flm.mask & MKBlast_Mask.flame)) continue;
				
				var _amo = irandom_range(_amount[0], _amount[1]);
				repeat(_amo) {
					var _an = _flm.animCurve;
					_flm.animCurve = undefined;
					
					var _smk = variable_clone(_flm);
					
					var _scLen = random_range(_scatt[0], _scatt[1]);
					var _scDir = random(360);
					
					_smk.sx += lengthdir_x(_scLen, _scDir);
					_smk.sy += lengthdir_y(_scLen, _scDir);
					
					_flm.animCurve = _an;
					_smk.animCurve = _an;
					
					_smk.mask    = MKBlast_Mask.smoke;
					_smk.discard = true;
					
					_smk.speed     += random_range(_speedOf[0], _speedOf[1]);
					
					var _dirr = random_range(_dirrOf[0], _dirrOf[1]);
					_smk.direction  = _dirrOver? _dirr : _smk.direction + _dirr;
					
					_smk.rotate     = random_range(_rotat[0], _rotat[1]);
					if(_rotaFl && choose(0,1)) _smk.rotate = -_smk.rotate;
				
					var ss = random_range(_scalOf[0], _scalOf[1]);
					_smk.aspect[0]  = random_range(_aspects[0], _aspects[1]);
					_smk.aspect[1]  = random_range(_aspects[2], _aspects[3]);
					_smk.size[0]   *= ss;
					_smk.size[1]   *= ss;
					
					_smk.life      -= random_range(_lifeOffset[0], _lifeOffset[1]);
					_smk.lifeTotal *= random_range(_lifeScale[0],  _lifeScale[1]);
					
					_smk.texture   = _text;
					_smk.shape     = _shape;
					_smk.pathData  = _pathData;
					
					_smk.arrowSize     = random_range(_arrowO[0], _arrowO[1]);
					_smk.lineThickness = random_range(_lineW[0], _lineW[1]);
					_smk.lineShape     = _lineData.map;
					
					_smk.spiralSize      = _spiUse? random_range(_spiSiz[0], _spiSiz[1]) : 0;
					_smk.spiralPhase     = random_range(_spiPhs[0], _spiPhs[1]);
					_smk.spiralIntensity = random_range(_spiInt[0], _spiInt[1]);
					_smk.spiralRotation  = random_range(_spiRot[0], _spiRot[1]);
					_smk.spiralMultiply  = _spiMul;
					
					_smk.decay      = random_range(_decay[0], _decay[1]);
					_smk.doDecay    = _ddecay;
					
					_smk.level      = _level;
					_smk.depth      = _depth;
					
					_smk.step();
					
					array_push(_layer.flames, _smk);
				}
			}
			
			if(array_empty(_layer.flames)) continue;
			
			array_push(_smokeLayer, _layer);
			array_push(_smokeOrder, i + _overl);
		}
		
		for( var i = array_length(_smokeLayer) - 1; i >= 0; i-- )
			array_insert(_flameLayer, _smokeOrder[i], _smokeLayer[i]);
		
		outputs[0].setValue(_flameLayer);
		outputs[1].setValue(_smokeLayer);
	}
}