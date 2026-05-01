function Node_MK_Tree_Root(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Trunk";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	parameters.inline_draw_input = true;
	setDrawIcon(s_node_mk_tree_root);
	setDimension(96, 48);
	
	/* UNUSED */ newInput( 8, nodeValue_Vec2(  "Origin Ratio",  [.5,1]      ));
	/* UNUSED */ newInput( 2, nodeValue_Vec4(  "Origin Wiggle", [0,0,0,0]   )).setUnitSimple();
	/* UNUSED */ newInput(13, nodeValue_Curve( "Length Curve", CURVE_DEF_11 ));
	
	newInput(14, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Spawning
	newInput( 1, nodeValue_Vec2(     "Position",        [.5,1]      )).setUnitSimple();
	
		////- =/Scatter
	newInput( 5, nodeValue_Range(    "Amount",          [1,1], true ));
	newInput(30, nodeValue_Vec2(     "Scatter Area",    [0,0]       )).setUnitSimple();
	newInput(31, nodeValue_EButton(  "Scatter Shape",    0, [ "Rectangle", "Ellipse" ] ));
	
	////- =Geometry
	newInput( 3, nodeValue_Range(  "Length",   [24,24], true ));
	newInput( 7, nodeValue_Range(  "Segments", [8,8],   true ));
	
	////- =Direction
	newInput( 4, nodeValue_RotRand( "Direction", [0,80,100,0,0]       ));
	newInput( 9, nodeValue_Range(   "Gravity",            [0,0], true ))
		.setCurvable(15, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
		
		////- =/Wiggle
	newInput(10, nodeValue_Range(   "Amplitude",   [0,0], true )).setInternalName("wiggle_amplitude")
		.setCurvable(34, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length )
	newInput(32, nodeValue_Range(   "Frequency",   [4,4], true )).setInternalName("wiggle_frequency");
	newInput(33, nodeValue_Range(   "Phase",       [0,0], true )).setInternalName("wiggle_phase");
	
		////- =/Spiral
	newInput(36, nodeValue_Range(   "Amplitude",   [0,0], true )).setInternalName("spiral_amplitude")
		.setCurvable(37, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length )
	newInput(22, nodeValue_Range(  "Frequency", [4,4], true )).setInternalName("spiral_frequency")
		.setCurvable(28, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	newInput(23, nodeValue_Range(  "Phase",     [0,0], true )).setInternalName("spiral_phase");
	newInput(18, nodeValue_Range(  "Wave",      [0,0], true ))
		.setCurvable(19, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	newInput(20, nodeValue_Range(  "Curl",      [0,0], true ))
		.setCurvable(21, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	
	////- =Thickness
	newInput( 6, nodeValue_Range(    "Thickness", [4,4], true ))
		.setCurvable(11, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
		
	////- =Render
	newInput(35, nodeValue_Bool(     "Draw",       true ));
	newInput(29, nodeValue_EScroll(  "Draw Mode",  0, [ "Texture", "Line" ] ));
		
		////- =/Base Color
	newInput(12, nodeValue_Gradient( "Base Color",      gra_white   ));
	newInput(24, nodeValue_EButton(  "Length Blending", 0           )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(25, nodeValue_Gradient( "Length Color",    gra_white   ));
	
		////- =/Edge Color
	newInput(16, nodeValue_EButton(  "Edge Blending",   0           )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(17, nodeValue_Gradient( "L Edge Color",    gra_white   ));
	newInput(26, nodeValue_Gradient( "R Edge Color",    gra_white   ));
	
		////- =/Texture
	newInput(27, nodeValue_Surface(  "Texture" ));
	// input 38
	
	newOutput(0, nodeValue_Output("Trunk", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 14,
		[ "Spawning",   false ],  1, 
			[ "/Scatter",true ],  5, 30, 31, 
			
		[ "Geometry",   false ],  3,  7, 
		[ "Direction",  false ],  4,  9, 15, 
			[ "/Wiggle", true ],  10, 34, 32, 33, 
			[ "/Spiral", true ],  36, 37, 22, 28, 23, 18, 19, 20, 21, 
			
		[ "Thickness",       false ],  6, 11, 
		[ "Render",      false, 35 ], 29,  
			[ "/Base Color", false ], 12, 24, 25, 
			[ "/Edge Color", false ], 16, 17, 26, 
			[ "/Texture",    false ], 27, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
		
		var _ori = getInputData( 1);
		var _siz = getInputData(30);
		var _shp = getInputData(31);
		var _px  = _x + _ori[0] * _s;
		var _py  = _y + _ori[1] * _s;
		
		var _sw  = _siz[0] * _s;
		var _sh  = _siz[1] * _s;
		draw_set_color(COLORS._main_accent);
		     if(_shp == 0) draw_rectangle_dashed(_px - _sw, _py - _sh, _px + _sw, _py + _sh);
		else if(_shp == 1) draw_ellipse_dash(_px, _py, _sw, _sh);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, 1));
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(14);
			var _gDir = inline_context.gravityDir;
			
			var _ori  = getInputData( 1);
			
			var _ramo = getInputData( 5);
			var _oriW = getInputData(30);
			var _oriS = getInputData(31);
			
			var _segs = getInputData( 7);
			var _len  = getInputData( 3);
			
			var _sprA = getInputData(36);
			var _spaC = getInputData(37),  curve_spia  = inputs[36].attributes.curved? new curveMap(_spaC)  : undefined;
			var _sprS = getInputData(22);
			var _spsC = getInputData(28),  curve_spis  = inputs[22].attributes.curved? new curveMap(_spsC)  : undefined;
			var _sprP = getInputData(23);
			var _wav  = getInputData(18);
			var _wavC = getInputData(19),  curve_wave  = inputs[18].attributes.curved? new curveMap(_wavC)  : undefined;
			
			var _cur  = getInputData(20);
			var _curC = getInputData(21),  curve_curl  = inputs[20].attributes.curved? new curveMap(_curC)  : undefined;
			
			var _ang  = getInputData( 4);
			var _grv  = getInputData( 9);
			var _grvC = getInputData(15),  curve_grav  = inputs[ 9].attributes.curved? new curveMap(_grvC)  : undefined;
			
			var _wigA = getInputData(10);
			var _wigAC= getInputData(34),  curve_wiga  = inputs[10].attributes.curved? new curveMap(_wigAC)  : undefined;
			var _wigF = getInputData(32);
			var _wigP = getInputData(33);
			
			var _draw  = getInputData(35);
			var _line  = getInputData(29);
			var _thk   = getInputData( 6);
			var _thkC  = getInputData(11), curve_thick = inputs[ 6].attributes.curved? new curveMap(_thkC) : undefined;
			
			var _baseGrad = getInputData(12);
			var _lenc     = getInputData(24);
			var _lencGrad = getInputData(25); inputs[25].setVisible(_lenc > 0);
			var _edge     = getInputData(16);
			var _edgeLGrd = getInputData(17); inputs[17].setVisible(_edge > 0);
			var _edgeRGrd = getInputData(26); inputs[26].setVisible(_edge > 0);
			var _tex      = getInputData(27);
				
			inputs[24].setVisible(!_line);
			inputs[25].setVisible(!_line);
			inputs[16].setVisible(!_line);
			inputs[17].setVisible(!_line);
			inputs[26].setVisible(!_line);
			inputs[27].setVisible(!_line);
				
			_baseGrad.cache();
			_lencGrad.cache();
			_edgeLGrd.cache();
			_edgeRGrd.cache();
			
			random_set_seed(_seed);
		#endregion
			
		var _amo     = irandom_range(_ramo[0], _ramo[1]);
		var _roots   = array_create(_amo);
		var _rootPos = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var ox = _ori[0];
			var oy = _ori[1];
			
			switch(_oriS) {
				case 0 : 
					ox += random_range(-_oriW[0], _oriW[0]);
					oy += random_range(-_oriW[1], _oriW[1]); 
					break;
			    
			    case 1 : 
			    	var dirr = random(360);
				    ox += lengthdir_x(random(_oriW[0]), dirr);
					oy += lengthdir_y(random(_oriW[1]), dirr);
					break;
			}
			
			_rootPos[i] = [ox, oy];
		}
		
		array_sort(_rootPos, function(a,b) /*=>*/ {return a[1] - b[1]});
		
		for( var i = 0; i < _amo; i++ ) {
			var _pos = _rootPos[i];
			var  ox  = _pos[0];
			var  oy  = _pos[1];
			
			var _t = new __MK_Tree(undefined, ox, oy, _seed + i)
				.setDraw(_draw, _line)
				.setTexture(_tex)
				
			var _amou   = random_range(_segs[0], _segs[1]);
			
			var _length = random_range(_len[0], _len[1]);
			var _angle  = rotation_random_eval(_ang);
			
			var _wiggA  = random_range(_wigA[0], _wigA[1]);
			var _wiggF  = random_range(_wigF[0], _wigF[1]);
			var _wiggP  = random_range(_wigP[0], _wigP[1]);
			
			var _grav   = random_range(_grv[0], _grv[1]);
			var _thick  = random_range(_thk[0], _thk[1]);
			
			var _spirA  = random_range(_sprA[0], _sprA[1]);
			var _spirS  = random_range(_sprS[0], _sprS[1]);
			var _spirP  = random_range(_sprP[0], _sprP[1]);
			var _wave   = random_range(_wav[0], _wav[1]);
			var _curl   = random_range(_cur[0], _cur[1]);
			
			var _colBase = _baseGrad.evalFast(random(1));
			
			var _growParam = {
				length : _length,
				angle  : _angle,   
				wigg   : _wiggA,   wiggC  : curve_wiga,   wiggF   : _wiggF,    wiggP : _wiggP, 
				grav   : _grav,    gravC  : curve_grav,   gravD   : _gDir, 
				thick  : _thick,   thickC : curve_thick,
				
				spirA  : _spirA,   spirAC : curve_spia, 
				spirS  : _spirS,   spirSC : curve_spis, 
				spirP  : _spirP,
				wave   : _wave,    waveC  : curve_wave, 
				curl   : _curl,    curlC  : curve_curl, 
			
				cBase  : _colBase,
				cLen   : _lenc,     cLenG  : _lencGrad,
				cEdg   : _edge,     cEdgL  : _edgeLGrd,    cEdgR  : _edgeRGrd
			}
			
			_t.grow(_amou, _growParam);
			
			_roots[i] = _t;
		}
		
		outputs[0].setValue(_roots);
		
	}
	
}