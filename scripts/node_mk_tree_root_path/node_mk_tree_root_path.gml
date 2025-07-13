function Node_MK_Tree_Path_Root(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Trunk Path";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDimension(96, 48);
	
	newInput( 0, nodeValueSeed());
	
	////- =Path
	newInput( 1, nodeValue_PathNode( "Path",   noone ));
	newInput( 2, nodeValue_Int(      "Sample", 8     ));
	
	////- =Rendering
	newInput( 3, nodeValue_Range(       "Thickness",       [4,4], { linked: true } )).setCurvable(4, CURVE_DEF_11);
	newInput( 5, nodeValue_Gradient(    "Base Color",      new gradientObject(ca_white) ));
	newInput( 6, nodeValue_Enum_Button( "Render Edge",     0, [ "None", "Override", "Multiply", "Screen" ] ));
	newInput( 7, nodeValue_Gradient(    "Outer Color",     new gradientObject(ca_white) ));
	// input 8
	
	newOutput(0, nodeValue_Output("Trunk", VALUE_TYPE.struct, noone)).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		[ "Path",   false ], 1, 2, 
		[ "Render", false ], 3, 4, 5, 6, 7, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getInputData(1);
		if(has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		var _seed = inline_context.seed + getInputData(0);
		
		var _path = getInputData(1);
		var _samp = getInputData(2);
		
		var _thck     = getInputData(3);
		var _thckC    = getInputData(4), curve_thick  = inputs[ 3].attributes.curved? new curveMap(_thck)  : undefined;
		var _baseGrad = getInputData(5);
		var _edge     = getInputData(6);
		var _edgeGrad = getInputData(7);
		
		inputs[7].setVisible(_edge > 0);
		
		if(!has(_path, "getPointRatio")) return;
		
		random_set_seed(_seed);
		
		var _t = new __MK_Tree();
		var _p = new __vec2P();
		
		_p = _path.getPointRatio(0, 0, _p);
		var ox = _p.x;
		var oy = _p.y;
		var nx, ny;
		
		var _thick = random_range(_thck[0], _thck[1]);
		
		_t.x = ox;
		_t.y = oy;
		_t.segments[0] = new __MK_Tree_Segment(ox, oy, _thick * (curve_thick? curve_thick.get(0) : 1));
		
		for( var i = 1; i <= _samp; i++ ) {
			var _rat = i / _samp;
			_p = _path.getPointRatio(_rat, 0, _p);
			
			_t.segments[i] = new __MK_Tree_Segment(_p.x, _p.y, _thick * (curve_thick? curve_thick.get(_rat) : 1));
		}
		
		_t.color    = _baseGrad.eval(random(1));
		
		switch(_edge) {
			case 0 : _t.colorOut = _t.color;                  break;
			case 1 : _t.colorOut = _edgeGrad.eval(random(1)); break;
			case 2 : _t.colorOut = colorMultiply( _edgeGrad.eval(random(1)), _t.color); break;
			case 3 : _t.colorOut = colorScreen(   _edgeGrad.eval(random(1)), _t.color); break;
		}
		
		_t.amount   = array_length(_samp) + 1;
		_t.getLength();
		
		outputs[0].setValue([_t]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_mk_tree_path_root, 0, bbox);
	}
}