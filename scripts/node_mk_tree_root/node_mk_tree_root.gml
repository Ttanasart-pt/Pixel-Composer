function Node_MK_Tree_Root(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Trunk";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	// renderAll = true;
	setDimension(96, 48);
	
	newInput(14, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	////- =Origin
	newInput( 5, nodeValue_Range(        "Amount",          [1,1], { linked: true } ));
	newInput( 8, nodeValue_Slider_Range( "Origin Ratio",    [.5,1]    ));
	newInput( 1, nodeValue_Vec2(         "Origin Position", [.5,1]    )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput( 2, nodeValue_Vec2_Range(   "Origin Wiggle",   [0,0,0,0] )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	////- =Segment
	newInput( 7, nodeValue_Range(  "Segments",           [4,8]        ));
	newInput( 3, nodeValue_Range(  "Length",             [16,32]      ));
	/* UNUSED */ newInput(13, nodeValue_Curve(  "Length Curve",       CURVE_DEF_11 ));
	
	////- =Direction
	newInput( 4, nodeValue_Rotation_Random( "Direction", [0,80,100,0,0] ));
	newInput(10, nodeValue_Range(  "Direction Wiggle",   [0,0], { linked: true } ));
	newInput( 9, nodeValue_Range(  "Gravity",            [0,0] )).setCurvable(15, CURVE_DEF_11);
	
	////- =Rendering
	newInput( 6, nodeValue_Range(       "Thickness",        [4,4] )).setCurvable(11, CURVE_DEF_11);
	newInput(12, nodeValue_Gradient(    "Base Color",       new gradientObject(ca_white) ));
	newInput(16, nodeValue_Enum_Button( "Render Edge",      0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput(17, nodeValue_Gradient(    "Outer Color",      new gradientObject(ca_white) ));
	// input 18
	
	newOutput(0, nodeValue_Output("Trunk", VALUE_TYPE.struct, noone)).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 14,
		[ "Origin",    false ], 5, 1, 2, 
		[ "Segment",   false ], 7, 3, 
		[ "Direction", false ], 4, 10, 9, 15, 
		[ "Render",    false ], 6, 11, 12, 16, 17, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
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
		
		var _seed = inline_context.seed + getInputData(14);
		
		var _bran = getInputData( 5);
		var _ori  = getInputData( 1);
		var _oriW = getInputData( 2);
		
		var _segs = getInputData( 7);
		var _len  = getInputData( 3);
		
		var _ang  = getInputData( 4);
		var _angW = getInputData(10);
		var _grv  = getInputData( 9);
		var _grvC = getInputData(15),     curve_grav  = inputs[ 9].attributes.curved? new curveMap(_grvC)  : undefined;
		
		var _thck     = getInputData( 6);
		var _thckC    = getInputData(11), curve_thick = inputs[ 6].attributes.curved? new curveMap(_thckC) : undefined;
		var _baseGrad = getInputData(12);
		var _edge     = getInputData(16);
		var _edgeGrad = getInputData(17);
		
		inputs[17].setVisible(_edge > 0);
		
		random_set_seed(_seed);
		
		var _amo   = irandom_range(_bran[0], _bran[1]);
		var _roots = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var _t = new __MK_Tree();
			
			var ox = _ori[0] + random_range(_oriW[0], _oriW[1]);
			var oy = _ori[1] + random_range(_oriW[2], _oriW[3]);
			
			_t.x = ox;
			_t.y = oy;
			_t.amount = random_range(_segs[0], _segs[1]);
			
			var _length = random_range(_len[0], _len[1]);
			var _angle  = rotation_random_eval(_ang);
			
			var _grav   = random_range(_grv[0], _grv[1]);
			var _thick  = random_range(_thck[0], _thck[1]);
			
			_t.grow(_length, _angle, _angW, _grav, curve_grav, _thick, curve_thick);
			_t.color    = _baseGrad.eval(random(1));
			
			switch(_edge) {
				case 0 : _t.colorOut = _t.color;                  break;
				case 1 : _t.colorOut = _edgeGrad.eval(random(1)); break;
				case 2 : _t.colorOut = colorMultiply( _edgeGrad.eval(random(1)), _t.color); break;
				case 3 : _t.colorOut = colorScreen(   _edgeGrad.eval(random(1)), _t.color); break;
			}
			
			_roots[i] = _t;
		}
		
		outputs[0].setValue(_roots);
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_mk_tree_root, 0, bbox);
	}
}