function Node_MK_Tree_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_branch);
	setDimension(96, 48);
	
	newInput(14, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Origin
	newInput( 5, nodeValue_Range(        "Amount",          [4,8]     ));
	newInput(19, nodeValue_EButton(      "Distribution",     0,       )).setChoices([ "Random", "Uniform" ]);
	newInput( 8, nodeValue_Slider_Range( "Origin Ratio",    [.5,1]    ));
	newInput(32, nodeValue_Bool( "Apply to Property Curves", false )).setTooltip("Set the 'Over Branch' property to use 'Leaf Position' range or total range.");
	/* UNUSED */ newInput( 1, nodeValue_Vec2(       "Origin Position", [.5,1]    ));
	/* UNUSED */ newInput( 2, nodeValue_Vec2_Range( "Origin Wiggle",   [0,0,0,0] ));
	
	////- =Segment
	newInput( 7, nodeValue_Range(  "Segments",   [4,8]     ));
	newInput( 3, nodeValue_Range(  "Length",     [16,32]   ))
		.setCurvable(13, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	
	////- =Direction
	newInput(31, nodeValue_EButton( "Direction Type",  0, [ "Random", "Uniform" ] ));
	newInput( 4, nodeValue_RotRand( "Direction",      [0,80,100,0,0] ));
	newInput(10, nodeValue_Range(   "Dir. Wiggle",    [0,0], true    ))
		.setCurvable( 34, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
		.setCurvable( 35, CURVE_DEF_11, "Over Branch", "curved_branch", THEME.mk_tree_curve_branch )
		
	newInput(15, nodeValue_EScroll( "Reflect",           0,            )).setChoices([ "None", "Randomize", "Ordered" ]);
	newInput( 9, nodeValue_Range(   "Gravity",          [0,0], true    ))
		.setCurvable( 16, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
		.setCurvable( 33, CURVE_DEF_11, "Over Branch", "curved_branch", THEME.mk_tree_curve_branch )
	
	////- =Spiral
	newInput(25, nodeValue_Range(   "Frequency", [4,4], true ))
		.setCurvable(38, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	newInput(26, nodeValue_Range(   "Phase",     [0,0], true ));
	newInput(21, nodeValue_Range(   "Wave",      [0,0], true ))
		.setCurvable(22, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	newInput(23, nodeValue_Range(   "Curl",      [0,0], true ))
		.setCurvable(24, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	
	////- =Rendering
	newInput( 6, nodeValue_Range(    "Thickness",       [2,2], true ))
		.setCurvable( 11, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
		.setCurvable( 36, CURVE_DEF_11, "Over Branch", "curved_branch", THEME.mk_tree_curve_branch )
		
	newInput(37, nodeValue_Slider(   "Inherit Parent Color", 0      ));
	newInput(12, nodeValue_Gradient( "Base Color",      gra_white   ));
	newInput(27, nodeValue_EButton(  "Length Blending", 0,          )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(28, nodeValue_Gradient( "Length Color",    gra_white   ));
	newInput(17, nodeValue_EButton(  "Edge Blending",   0,          )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(18, nodeValue_Gradient( "L Edge Color",    gra_white   ));
	newInput(29, nodeValue_Gradient( "R Edge Color",    gra_white   ));
	newInput(30, nodeValue_Surface(  "Texture" ));
	
	////- =Growth
	newInput(20, nodeValue_Range( "Grow Delay", [0,0], true ));
	// input 39
	
	newOutput(0, nodeValue_Output("Trunk",    VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 14, 0, 
		[ "Origin",    false ],  5, 19,  8, 32, 
		[ "Segment",   false ],  7,  3, 13, 
		[ "Direction", false ], 31,  4, 10, 34, 35, 15,  9, 16, 33, 
		[ "Spiral",    false ], 25, 38, 26, 21, 22, 23, 24, 
		[ "Rendering", false ],  6, 11, 36, 37, 12, 27, 28, 17, 18, 29, 30, 
		[ "Growth",    false ], 20, 
	];
	
	amountUnitTooltip = new tooltipSelector("Unit", [ "Fixed Amount", "Branch Distance" ]);
	amountUnitToggle  = button(function() /*=>*/ { inputs[5].attributes.unit = !inputs[5].attributes.unit; triggerRender(); })
		.setIcon(THEME.mk_tree_leaf_unit).iconPad()
		.setTooltip(amountUnitTooltip, function() /*=>*/ {return inputs[5].attributes.unit});
	
	inputs[5].attributes.unit = VALUE_UNIT.constant;
	inputs[5].getEditWidget().setSideButton(amountUnitToggle);
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : [1,1]};
	
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
		
		#region data
			var _seed = inline_context.seed + getInputData(14);
			var _gDir = inline_context.gravityDir;
			
			var _tree = getInputData(0);
			
			var _bran = getInputData( 5);
			var _auni = inputs[5].attributes.unit;
			inputs[5].setName(_auni? "Distance" : "Amount");
			amountUnitToggle.icon_index = _auni;
			
			var _dist = getInputData(19);
			var _oriR = getInputData( 8);
			var _clam = getInputData(32);
			
			var _segs = getInputData( 7);
			var _len  = getInputData( 3);
			var _lenC = getInputData(13),     curve_length = inputs[ 3].attributes.curved? new curveMap(_lenC)  : undefined;
			
			var _sprS = getInputData(25);
			var _spsC = getInputData(38),     curve_spis   = inputs[25].attributes.curved? new curveMap(_spsC)  : undefined;
			var _sprP = getInputData(26);
			var _wav  = getInputData(21);
			var _wavC = getInputData(22),     curve_wave  = inputs[21].attributes.curved? new curveMap(_wavC)  : undefined;
			
			var _cur  = getInputData(23);
			var _curC = getInputData(24),     curve_curl  = inputs[23].attributes.curved? new curveMap(_curC)  : undefined;
			
			var _angT  = getInputData(31);
			var _ang   = getInputData( 4);
			var _anw   = getInputData(10);
			var _anwC  = getInputData(34),     curve_angw   = inputs[10].attributes.curved?        new curveMap(_anwC)  : undefined;
			var _anwCR = getInputData(35),     curve_angw_r = inputs[10].attributes.curved_branch? new curveMap(_anwCR) : undefined;
			
			var _refl  = getInputData(15);
			var _grv   = getInputData( 9);
			var _grvC  = getInputData(16),     curve_grav   = inputs[ 9].attributes.curved?        new curveMap(_grvC)  : undefined;
			var _grvCR = getInputData(33),     curve_grav_r = inputs[ 9].attributes.curved_branch? new curveMap(_grvCR) : undefined;
			
			var _thk   = getInputData( 6);
			var _thkC  = getInputData(11),     curve_thick   = inputs[ 6].attributes.curved?        new curveMap(_thkC)  : undefined;
			var _thkCR = getInputData(36),     curve_thick_r = inputs[ 6].attributes.curved_branch? new curveMap(_thkCR) : undefined;
			
			var _inhColor = getInputData(37);
			var _baseGrad = getInputData(12);
			var _lenc     = getInputData(27);
			var _lencGrad = getInputData(28); inputs[28].setVisible(_lenc > 0);
			var _edge     = getInputData(17);
			var _edgeLGrd = getInputData(18); inputs[18].setVisible(_edge > 0);
			var _edgeRGrd = getInputData(29); inputs[29].setVisible(_edge > 0);
			var _tex      = getInputData(30);
				
			var _grow = getInputData(20);
		
			_baseGrad.cache();
			_lencGrad.cache();
			_edgeLGrd.cache();
			_edgeRGrd.cache();
			
			random_set_seed(_seed);
		#endregion
		
		var _branches  = [];
		var _spawnIndx = 0;
		var _oriRange  = _oriR[1] - _oriR[0];
		_tree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			var _tr  = _tree[i];
			var _amo = irandom_range(_bran[0], _bran[1]);
			if(_auni) _amo = _tr.totalLength / _amo; // density
			
			var  rat, j = 0;
			
			repeat(_amo) {
				     if(_dist == 0) rat = random_range(_oriR[0], _oriR[1]);
				else if(_dist == 1) rat = lerp(_oriR[0], _oriR[1], j / _amo);
				
				var ori  = [0,0,0];
				var crat = rat;
				if(_clam) crat = _oriRange == 0? 1 : (crat - _oriR[0]) / _oriRange;
				
				_tr.getPosition(rat, ori);
				
				var _t = new __MK_Tree();
				_t.root = _tr.root;
				_t.x = ori[0];
				_t.y = ori[1];
				
				_t.amount       = random_range(_segs[0], _segs[1]);
				_t.texture      = _tex;
				_t.rootPosition =  rat;
				_t.curvPosition = crat;
				
				var _baseDir = ori[2];
				var _length  = random_range(_len[0], _len[1]) * (curve_length? curve_length.get(crat) : 1);
				var _angle   = _angT == 0? rotation_random_eval(_ang) : rotation_random_eval_uniform(_ang, j / (_amo - 1));
				
				switch(_refl) {
					case 1 : if(choose(0, 1))   _angle = _baseDir + angle_difference(_baseDir, _angle); break;
					case 2 : if(_spawnIndx % 2) _angle = _baseDir + angle_difference(_baseDir, _angle); break;
				}
				
				var _grav   = random_range(_grv[0], _grv[1]);
				    _grav  *= curve_grav_r? curve_grav_r.get(crat)   : 1;
				    
				var _angw     = [_anw[0], _anw[1]];
				    _angw[0] *= curve_angw_r? curve_angw_r.get(crat) : 1;
				    _angw[1] *= curve_angw_r? curve_angw_r.get(crat) : 1;
				    
				var _thick  = random_range(_thk[0], _thk[1]);
				    _thick *= curve_thick_r? curve_thick_r.get(crat) : 1;
				
				var _spirS  = random_range(_sprS[0], _sprS[1]);
				var _spirP  = random_range(_sprP[0], _sprP[1]);
				var _wave   = random_range(_wav[0], _wav[1]);
				var _curl   = random_range(_cur[0], _cur[1]);
				
				var _colBase = _baseGrad.evalFast(random(1));
				if(_inhColor > 0) {
					var _rootColor = _tr.getColor(rat);
					_colBase = merge_color(_colBase, colorMultiply(_colBase, _rootColor), _inhColor);
				}
				
				var _growParam = {
					length : _length,
					angle  : _angle,   angleW : _angw,         angleWC : curve_angw,
					grav   : _grav,    gravC  : curve_grav,    gravD   : _gDir, 
					thick  : _thick,   thickC : curve_thick,
					
					spirS  : _spirS,   spirSC : curve_spis, 
					spirP  : _spirP,
					wave   : _wave,    waveC  : curve_wave, 
					curl   : _curl,    curlC  : curve_curl,
					
					cBase  : _colBase,
					cLen   : _lenc,     cLenG  : _lencGrad,
					cEdg   : _edge,     cEdgL  : _edgeLGrd,    cEdgR  : _edgeRGrd
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
	
}