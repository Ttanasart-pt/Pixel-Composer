function Node_MK_Tree_Root(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Trunk";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_root);
	setDimension(96, 48);
	
	newInput(14, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Origin
	newInput( 5, nodeValue_Range(        "Amount",          [1,1], true ));
	newInput( 8, nodeValue_Slider_Range( "Origin Ratio",    [.5,1]      ));
	newInput( 1, nodeValue_Vec2(         "Origin Position", [.5,1]      )).setUnitSimple();
	newInput( 2, nodeValue_Vec2_Range(   "Origin Wiggle",   [0,0,0,0]   )).setUnitSimple();
	
	////- =Segment
	newInput( 7, nodeValue_Range(  "Segments", [8,8],   true ));
	newInput( 3, nodeValue_Range(  "Length",   [24,24], true ));
	/* UNUSED */ newInput(13, nodeValue_Curve(  "Length Curve", CURVE_DEF_11 ));
	
	////- =Direction
	newInput( 4, nodeValue_RotRand( "Direction", [0,80,100,0,0]       ));
	newInput(10, nodeValue_Range(   "Direction Wiggle",   [0,0], true ));
	newInput( 9, nodeValue_Range(   "Gravity",            [0,0], true )).setCurvable(15, CURVE_DEF_11);
	
	////- =Spiral
	newInput(22, nodeValue_Range(  "Frequency", [4,4], true ));
	newInput(23, nodeValue_Range(  "Phase",     [0,0], true ));
	newInput(18, nodeValue_Range(  "Wave",      [0,0], true )).setCurvable(19, CURVE_DEF_11);
	newInput(20, nodeValue_Range(  "Curl",      [0,0], true )).setCurvable(21, CURVE_DEF_11);
	
	////- =Rendering
	newInput( 6, nodeValue_Range(    "Thickness",       [4,4], true )).setCurvable(11, CURVE_DEF_11);
	newInput(12, nodeValue_Gradient( "Base Color",      gra_white   ));
	newInput(24, nodeValue_EButton(  "Length Blending", 0           )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(25, nodeValue_Gradient( "Length Color",    gra_white   ));
	newInput(16, nodeValue_EButton(  "Edge Blending",   0           )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(17, nodeValue_Gradient( "L Edge Color",    gra_white   ));
	newInput(26, nodeValue_Gradient( "R Edge Color",    gra_white   ));
	newInput(27, nodeValue_Surface(  "Texture" ));
	// input 28
	
	newOutput(0, nodeValue_Output("Trunk", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 14,
		[ "Origin",    false ], 5, 1, 2, 
		[ "Segment",   false ], 7, 3, 
		[ "Direction", false ], 4, 10, 9, 15, 
		[ "Spiral",    false ], 22, 23, 18, 19, 20, 21, 
		[ "Render",    false ], 6, 11, 12, 24, 25, 16, 17, 26, 27, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : [1,1]};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(14);
			var _gDir = inline_context.gravityDir;
			
			var _bran = getInputData( 5);
			var _ori  = getInputData( 1);
			var _oriW = getInputData( 2);
			
			var _segs = getInputData( 7);
			var _len  = getInputData( 3);
			
			var _sprS = getInputData(22);
			var _sprP = getInputData(23);
			var _wav  = getInputData(18);
			var _wavC = getInputData(19),     curve_wave  = inputs[18].attributes.curved? new curveMap(_wavC)  : undefined;
			
			var _cur  = getInputData(20);
			var _curC = getInputData(21),     curve_curl  = inputs[20].attributes.curved? new curveMap(_curC)  : undefined;
			
			var _ang  = getInputData( 4);
			var _angW = getInputData(10);
			var _grv  = getInputData( 9);
			var _grvC = getInputData(15),     curve_grav  = inputs[ 9].attributes.curved? new curveMap(_grvC)  : undefined;
			
			var _thk      = getInputData( 6);
			var _thkC     = getInputData(11), curve_thick = inputs[ 6].attributes.curved? new curveMap(_thkC) : undefined;
			
			var _baseGrad = getInputData(12);
			var _lenc     = getInputData(24);
			var _lencGrad = getInputData(25); inputs[25].setVisible(_lenc > 0);
			var _edge     = getInputData(16);
			var _edgeLGrd = getInputData(17); inputs[17].setVisible(_edge > 0);
			var _edgeRGrd = getInputData(26); inputs[26].setVisible(_edge > 0);
			var _tex      = getInputData(27);
				
			_baseGrad.cache();
			_lencGrad.cache();
			_edgeLGrd.cache();
			_edgeRGrd.cache();
			
			random_set_seed(_seed);
		#endregion
			
		var _amo   = irandom_range(_bran[0], _bran[1]);
		var _roots = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var _t = new __MK_Tree();
			
			var ox = _ori[0] + random_range(_oriW[0], _oriW[1]);
			var oy = _ori[1] + random_range(_oriW[2], _oriW[3]);
			
			_t.x = ox;
			_t.y = oy;
			_t.amount  = random_range(_segs[0], _segs[1]);
			_t.texture = _tex;
			
			var _length = random_range(_len[0], _len[1]);
			var _angle  = rotation_random_eval(_ang);
			
			var _grav   = random_range(_grv[0], _grv[1]);
			var _thick  = random_range(_thk[0], _thk[1]);
			
			var _spirS  = random_range(_sprS[0], _sprS[1]);
			var _spirP  = random_range(_sprP[0], _sprP[1]);
			var _wave   = random_range(_wav[0], _wav[1]);
			var _curl   = random_range(_cur[0], _cur[1]);
			
			var _growParam = {
				length : _length,
				angle  : _angle,   angleW : _angW,
				grav   : _grav,    gravC  : curve_grav,    gravD : _gDir, 
				thick  : _thick,   thickC : curve_thick,
				
				spirS  : _spirS,   spirP  : _spirP,
				wave   : _wave,    waveC  : curve_wave, 
				curl   : _curl,    curlC  : curve_curl, 
			
				cBase  : _baseGrad,
				cLen   : _lenc,     cLenG  : _lencGrad,
				cEdg   : _edge,     cEdgL  : _edgeLGrd,    cEdgR  : _edgeRGrd
			}
			
			_t.grow(_growParam);
			
			_roots[i] = _t;
		}
		
		outputs[0].setValue(_roots);
		
	}
	
}