function Node_MK_Tree_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	// renderAll = true;
	setDimension(96, 48);
	
	newInput(14, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Origin
	newInput( 5, nodeValue_Range(        "Amount",          [4,8]     ));
	newInput(19, nodeValue_Enum_Button(  "Distribution",     0,       )).setChoices([ "Random", "Uniform" ]);
	newInput( 8, nodeValue_Slider_Range( "Origin Ratio",    [.5,1]    ));
	/* UNUSED */ newInput( 1, nodeValue_Vec2(         "Origin Position", [.5,1]    ));
	/* UNUSED */ newInput( 2, nodeValue_Vec2_Range(   "Origin Wiggle",   [0,0,0,0] ));
	
	////- =Segment
	newInput( 7, nodeValue_Range(  "Segments",   [4,8]     ));
	newInput( 3, nodeValue_Range(  "Length",     [16,32]   )).setCurvable(13, CURVE_DEF_11);
	
	////- =Direction
	newInput( 4, nodeValue_Rotation_Random( "Direction",        [0,80,100,0,0] ));
	newInput(10, nodeValue_Range(           "Direction Wiggle", [0,0], true    ));
	newInput(15, nodeValue_Enum_Scroll(     "Reflect",           0,            )).setChoices([ "None", "Randomize", "Ordered" ]);
	newInput( 9, nodeValue_Range(           "Gravity",          [0,0], true    )).setCurvable(16, CURVE_DEF_11);
	
	////- =Spiral
	newInput(25, nodeValue_Range(  "Frequency", [4,4], true ));
	newInput(26, nodeValue_Range(  "Phase",     [0,0], true ));
	newInput(21, nodeValue_Range(  "Wave",      [0,0], true )).setCurvable(22, CURVE_DEF_11);
	newInput(23, nodeValue_Range(  "Curl",      [0,0], true )).setCurvable(24, CURVE_DEF_11);
	
	////- =Rendering
	newInput( 6, nodeValue_Range(       "Thickness",       [2,2] )).setCurvable(11, CURVE_DEF_11);
	newInput(12, nodeValue_Gradient(    "Base Color",      new gradientObject(ca_white) ));
	newInput(27, nodeValue_Enum_Button( "Length Blending", 0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(28, nodeValue_Gradient(    "Length Color",    new gradientObject(ca_white) ));
	newInput(17, nodeValue_Enum_Button( "Edge Blending",   0,   )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(18, nodeValue_Gradient(    "Edge Color",      new gradientObject(ca_white) ));
	
	////- =Growth
	newInput(20, nodeValue_Range( "Grow Delay", [0,0], true ));
	// input 29
	
	newOutput(0, nodeValue_Output("Trunk",    VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 14, 0, 
		[ "Origin",    false ], 5, 19, 8, 
		[ "Segment",   false ], 7, 3, 13, 
		[ "Direction", false ], 4, 10, 15, 9, 16, 
		[ "Spiral",    false ], 25, 26, 21, 22, 23, 24, 
		[ "Rendering", false ], 6, 11, 12, 27, 28, 17, 18, 
		[ "Growth",    false ], 20, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		var _seed = inline_context.seed + getInputData(14);
		var _gDir = inline_context.gravityDir;
		
		var _tree = getInputData(0);
		
		var _bran = getInputData( 5);
		var _dist = getInputData(19);
		var _oriR = getInputData( 8);
		
		var _segs = getInputData( 7);
		var _len  = getInputData( 3);
		var _lenC = getInputData(13),     curve_length = inputs[ 3].attributes.curved? new curveMap(_lenC)  : undefined;
		
		var _sprS = getInputData(25);
		var _sprP = getInputData(26);
		var _wav  = getInputData(21);
		var _wavC = getInputData(22),     curve_wave  = inputs[21].attributes.curved? new curveMap(_wavC)  : undefined;
		
		var _cur  = getInputData(23);
		var _curC = getInputData(24),     curve_curl  = inputs[23].attributes.curved? new curveMap(_curC)  : undefined;
		
		var _ang  = getInputData( 4);
		var _angW = getInputData(10);
		var _refl = getInputData(15);
		var _grv  = getInputData( 9);
		var _grvC = getInputData(16),     curve_grav   = inputs[ 9].attributes.curved? new curveMap(_grvC)  : undefined;
		
		var _thk      = getInputData( 6);
		var _thkC     = getInputData(11), curve_thick  = inputs[ 6].attributes.curved? new curveMap(_thkC) : undefined;
		
		var _baseGrad = getInputData(12);
		var _lenc     = getInputData(27);
		var _lencGrad = getInputData(28); inputs[28].setVisible(_lenc > 0);
		var _edge     = getInputData(17);
		var _edgeGrad = getInputData(18); inputs[18].setVisible(_edge > 0);
		
		var _grow = getInputData(20);
		
		_baseGrad.cache();
		_lencGrad.cache();
		_edgeGrad.cache();
		
		random_set_seed(_seed);
		
		var _branches  = [];
		var _spawnIndx = 0;
		_tree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			var _tr  = _tree[i];
			var _amo = irandom_range(_bran[0], _bran[1]);
			var  rat, j = 0;
			
			repeat(_amo) {
				if(_dist == 0)
					rat = random_range(_oriR[0], _oriR[1]);
				else if(_dist == 1)	
					rat = lerp(_oriR[0], _oriR[1], j / _amo);
				
				var ori = [0,0,0];
				
				_tr.getPosition(rat, ori);
				
				var _t = new __MK_Tree();
				_t.root = _tr.root;
				_t.x = ori[0];
				_t.y = ori[1];
				_t.amount = random_range(_segs[0], _segs[1]);
				_t.rootPosition = rat;
				
				var _baseDir = ori[2];
				var _length  = random_range(_len[0], _len[1]) * (curve_length? curve_length.get(rat) : 1);
				var _angle   = rotation_random_eval(_ang);
				
				switch(_refl) {
					case 1 : if(choose(0, 1))   _angle = _baseDir + angle_difference(_baseDir, _angle); break;
					case 2 : if(_spawnIndx % 2) _angle = _baseDir + angle_difference(_baseDir, _angle); break;
				}
				
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
					cEdg   : _edge,     cEdgG  : _edgeGrad,
				}
				
				_t.grow(_growParam);
			    _t.growShift = random_range(_grow[0], _grow[1]);
				
				array_push(_tr.children, _t);
				array_push(_branches,    _t);
				
				_spawnIndx++;
				j++;
			}
		}
		
		outputs[0].setValue(_tree);
		outputs[1].setValue(_branches);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_mk_tree_branch, 0, bbox);
	}
}