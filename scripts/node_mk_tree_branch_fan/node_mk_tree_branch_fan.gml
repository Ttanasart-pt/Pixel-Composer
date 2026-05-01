function Node_MK_Tree_Branch_Fan(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Fan Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_branch_fan);
	setDimension(96, 48);

	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Spawning
	newInput( 2, nodeValue_SliRange( "Position", [.5,1] ));
	newInput( 9, nodeValue_Slider(   "Chance",     1    ));
	newInput( 3, nodeValue_Range(    "Amount",    [2,2] ));
	newInput( 7, nodeValue_EButton(  "Distribution",     0, [ "Random", "Uniform" ] ))
		.setCurvable( 8, CURVE_DEF_01, "Remap", "curved", THEME.mk_tree_curve_branch );
	
		////- =/Settings
	newInput(33, nodeValue_Bool( "Apply to Property Curves", false )).setTooltip("Set the 'Over Branch' property to use 'Position' range or total range.");
	
	////- =Geometry
	newInput( 4, nodeValue_Range(  "Segments",   [4,8]     ));
	
	////- =Fan
	newInput(14, nodeValue_Range(  "Fan Amount",   [6,6],   true )).setCurvable(15, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(18, nodeValue_Range(  "Aspect",       [.5,.5], true )).setCurvable(19, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
		
		////- =/Shape
	newInput(10, nodeValue_Range(  "Inner Radius", [0,0],   true )).setCurvable(11, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(12, nodeValue_Range(  "Outer Radius", [16,32], true )).setCurvable(13, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
		
		////- =/Cone
	newInput(16, nodeValue_Range(  "Cone Height",  [8,8],   true )).setCurvable(17, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(34, nodeValue_Curve(  "Cone Shape",   CURVE_DEF_01  ));
	newInput(35, nodeValue_SliRange( "Cone Trim",  [1,1]         ));
	
		////- =/Phase
	newInput(20, nodeValue_Range(  "Phase",        [0,0],   true )).setCurvable(21, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput(22, nodeValue_Bool(   "Overlap",      false         ));
	
	////- =Thickness
	newInput( 5, nodeValue_Range(    "Thickness", [2,2], true ))
		.setCurvable( 6, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
		
	////- =Rendering
	newInput(23, nodeValue_Bool(     "Draw",       true ));
	newInput(24, nodeValue_EScroll(  "Draw Mode",  0, [ "Texture", "Line" ] ));
		
		////- =/Base Color
	newInput(25, nodeValue_Slider(   "Inherit Parent Color", 0      ));
	newInput(26, nodeValue_Gradient( "Base Color",      gra_white   ));
	newInput(27, nodeValue_EButton(  "Length Blending", 0,          )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(28, nodeValue_Gradient( "Length Color",    gra_white   ));
	
		////- =/Edge Color
	newInput(29, nodeValue_EButton(  "Edge Blending",   0,          )).setChoices([ "None", "Override", "Multiply", "Screen" ]);
	newInput(30, nodeValue_Gradient( "L Edge Color",    gra_white   ));
	newInput(31, nodeValue_Gradient( "R Edge Color",    gra_white   ));
	
		////- =/Texture
	newInput(32, nodeValue_Surface(  "Texture" ));
	// 36
	
	newOutput(0, nodeValue_Output("Tree",     VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(2, nodeValue_Output("Trunk",    VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC).setVisible(false);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		[ "Spawning",        false ],  2,  9,  3,  7,  8,  
			[ "/Settings",    true ], 33, 
			
		[ "Geometry",        false ],  4, 
		[ "Fan",             false ], 14, 15, 18, 19, 
			[ "/Shape",      false ], 10, 11, 12, 13, 
			[ "/Cone",       false ], 16, 17, 34, 35, 
			[ "/Phase",      false ], 20, 21, 22, 
			
		[ "Thickness",       false ],  5,  6, 
		[ "Rendering",       false ], 23, 24, 
			[ "/Base Color", false ], 25, 26, 27, 28, 
			// [ "/Edge Color", false ], 29, 30, 31, 
			[ "/Texture",    false ], 32, 
			
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _resT = outputs[preview_channel].getValue();
		
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(1);
			var _gDir = inline_context.gravityDir;
			
			var _tree = getInputData( 0);
			
			var _oriR = getInputData( 2);
			var _chan = getInputData( 9);
			var _amoR = getInputData( 3);
			
			var _dist = getInputData( 7);
			var _disC = getInputData( 8), curve_distri = inputs[ 7].attributes.curved? new curveMap(_disC)  : undefined;
			
			var _clam = getInputData(32);
			
			var _segm = getInputData( 4);
			
			var _fan  = getInputData(14);
			var _fanC = getInputData(15), curve_fanamo = inputs[14].attributes.curved? new curveMap(_fanC)  : undefined;
			var _asp  = getInputData(18);
			var _aspC = getInputData(19), curve_aspect = inputs[18].attributes.curved? new curveMap(_aspC)  : undefined;
			
			var _lin  = getInputData(10);
			var _linC = getInputData(11), curve_lenIn  = inputs[10].attributes.curved? new curveMap(_linC)  : undefined;
			var _lot  = getInputData(12);
			var _lotC = getInputData(13), curve_lenOut = inputs[12].attributes.curved? new curveMap(_lotC)  : undefined;
			
			var _con  = getInputData(16);
			var _conC = getInputData(17), curve_cone   = inputs[16].attributes.curved? new curveMap(_conC)  : undefined;
			var _ccrv = getInputData(34), curve_cShape = new curveMap(_ccrv);
			var _trim = getInputData(35);
			
			var _phs  = getInputData(20);
			var _phsC = getInputData(21), curve_phase  = inputs[20].attributes.curved? new curveMap(_phsC)  : undefined;
			var _offs = getInputData(22);
			
			var _thk  = getInputData( 5);
			var _thkC = getInputData( 6), curve_thick  = inputs[ 5].attributes.curved? new curveMap(_thkC)  : undefined;
			
			var _draw = getInputData(23);
			var _line = getInputData(24);
			
			var _inhColor = getInputData(25);
			var _baseGrad = getInputData(26);
			var _lenc     = getInputData(27);
			var _lencGrad = getInputData(28); inputs[28].setVisible(_lenc > 0);
			
			var _edge     = getInputData(29);
			var _edgeLGrd = getInputData(30); inputs[30].setVisible(_edge > 0);
			var _edgeRGrd = getInputData(31); inputs[31].setVisible(_edge > 0);
			var _tex      = getInputData(32);
			
			inputs[27].setVisible(!_line);
			inputs[28].setVisible(!_line);
			
			inputs[29].setVisible(!_line);
			inputs[30].setVisible(!_line);
			inputs[31].setVisible(!_line);
			inputs[32].setVisible(!_line);
			
			_baseGrad.cache();
			_lencGrad.cache();
			_edgeLGrd.cache();
			_edgeRGrd.cache();
			
			random_set_seed(_seed);
		#endregion
		
		var _oriRange  = _oriR[1] - _oriR[0];
		var _branches  = [];
		var _spawnIndx = 0;
		var  bIndex    = 0;
		var ori = [0,0,0];
		var _x, _y;
		
		var _rootColor;
		
		outputs[2].setValue(_tree);
		_tree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			if(random(1) > _chan) continue;
			
			var _tr  = _tree[i];
			var _amo = irandom_range(_amoR[0], _amoR[1]);
			
			var  rat, j = 0;
			var _pos = array_create(_amo);
			repeat(_amo) {
				     if(_dist == 0) rat = random_range(_oriR[0], _oriR[1]);
				else if(_dist == 1) rat = lerp(_oriR[0], _oriR[1], _amo > 1? j / (_amo - 1) : .5);
				
				rat = curve_distri? curve_distri.get(rat) : rat;
				_pos[j++] = rat;
			}
			
			if(_dist == 0) array_sort(_pos, true);
			
			var _p  = 0;
			repeat(_amo) {
				rat = _pos[_p++];
				var crat = rat;
				if(_clam) crat = _oriRange == 0? 1 : (crat - _oriR[0]) / _oriRange;
				
				var _seg = max(1, irandom_range(_segm[0], _segm[1]));
				var _gst = 1 / _seg;
				
				var _rIn = random_range(_lin[0], _lin[1]) * (curve_lenIn?  curve_lenIn.get(crat)  : 1);
				var _rOt = random_range(_lot[0], _lot[1]) * (curve_lenOut? curve_lenOut.get(crat) : 1);
				var _fam = random_range(_fan[0], _fan[1]) * (curve_fanamo? curve_fanamo.get(crat) : 1); _fam = ceil(_fam);
				var _ast = random_range(_asp[0], _asp[1]) * (curve_aspect? curve_aspect.get(crat) : 1);
				var _cdr = random_range(_con[0], _con[1]) * (curve_cone?   curve_cone.get(crat)   : 1);
				var _pha = random_range(_phs[0], _phs[1]) * (curve_phase?  curve_phase.get(crat)  : 1);
				
				_tr.getPosition(crat, ori);
				if(_inhColor > 0) _rootColor = _tr.getColor(crat);
						
				var _fst = 360 / _fam;
				if(_offs && _p % 2) _pha += _fst / 2;
				
				for( var j = 0; j < _fam; j++ ) {
					var _hang = _pha + j * _fst;
					
					var _t = new __MK_Tree(_tr.root, ori[0], ori[1], _seed + bIndex++)
						.setDraw(_draw, _line)
						.setTexture(_tex)
						
					_t.texture       = _tex;
					_t.rootPosition  = rat;
					_t.rootDirection = ori[2];
					_t.curvPosition  = crat;
					
					var _colBase = _baseGrad.evalFast(random(1));
					if(_inhColor > 0)
						_colBase = merge_color(_colBase, colorMultiply(_colBase, _rootColor), _inhColor);
					
					var _prg    = 0;
					var _points = [];
					
					var rt = ori[2] - 90;
					
					var sx = ori[0] + lengthdir_x(_rIn, _hang);
					var sy = ori[1] + lengthdir_y(_rIn, _hang) * _ast;
					var pp = point_rotate(sx, sy, ori[0], ori[1], rt);
					sx = pp[0];
					sy = pp[1];
					
					var ex = ori[0] + lengthdir_x(_rOt, _hang);
					var ey = ori[1] + lengthdir_y(_rOt, _hang) * _ast;
					var pp = point_rotate(ex, ey, ori[0], ori[1], rt);
					ex = pp[0];
					ey = pp[1];
					
					var cx = lengthdir_x(_cdr, _gDir);
					var cy = lengthdir_y(_cdr, _gDir);
					
					var _trmRange = random_range(_trim[0], _trim[1]);
					
					for( var k = 0; k <= _seg; k++ ) {
						var _pprg = _prg * _trmRange;
						
						var _r = curve_cShape.get(_prg) * _trmRange;
						var _x = lerp(sx, ex, _r) + cx * _pprg;
						var _y = lerp(sy, ey, _r) + cy * _pprg;
						
						var _th = random_range(_thk[0], _thk[1]) * (curve_thick? curve_thick.get(_prg) : 1);
						
						var _cc = _colBase;
						switch(_lenc) {
							case 0 : _cc = _colBase;                                           break;
							case 1 : _cc = _lencGrad.evalFast(_prg);                           break;
							case 2 : _cc = colorMultiply( _lencGrad.evalFast(_prg), _colBase); break;
							case 3 : _cc = colorScreen(   _lencGrad.evalFast(_prg), _colBase); break;
						}
						
						array_push(_points, [ _x, _y, _th, _cc ]);
						_prg += _gst;
					}
					
					_t.setPoints(_points);
					
					array_push(_tr.children, _t);
					array_push(_branches,    _t);
				}
			}
		}
		
		outputs[0].setValue(_tree);
		outputs[1].setValue(_branches);
	}
}