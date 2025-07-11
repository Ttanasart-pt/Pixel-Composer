function Node_MK_Tree_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "MK Tree Branch";
	color = CDEF.lime;
	icon  = THEME.mkTree;
	
	newInput(0, nodeValue_Struct("Tree", noone));
	
	////- =Branch
	newInput(5, nodeValue_Range(      "Branch",        [1,1], { linked: true } ));
	newInput(1, nodeValue_Vec2(       "Origin",        [.5,1]    )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Vec2_Range( "Origin Wiggle", [0,0,0,0] )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	////- =Segment
	newInput(7, nodeValue_Range(           "Segments", [4,8]          ));
	newInput(3, nodeValue_Range(           "Length",   [4,8]          ));
	newInput(4, nodeValue_Rotation_Random( "Angle",    [0,80,100,0,0] ));
	
	////- =Rendering
	newInput(6, nodeValue_Slider_Range( "Thickness", [.5,1] ));
	// input 8
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		[ "Branch",    false ], 5, 1, 2, 
		[ "Segment",   false ], 7, 3, 4, 
		[ "Rendering", false ], 6, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		var _seed = inline_context.seed + internalSeed;
		
		var _tree = getInputData(0);
		
		var _bran = getInputData(5);
		var _ori  = getInputData(1);
		var _oriW = getInputData(2);
		
		var _segs = getInputData(7);
		var _len  = getInputData(3);
		var _ang  = getInputData(4);
		
		var _thck = getInputData(6);
		
		var _root = _tree == noone;
		
		inputs[1].setVisible( _root);
		inputs[2].setVisible( _root);
		
		random_set_seed(_seed);
		
		var _amo  = irandom_range(_bran[0], _bran[1]);
		
		if(_root) {
			var _roots = array_create(_amo);
			for( var i = 0; i < _amo; i++ ) {
				var _t = new __MK_Tree();
				
				var ox = _ori[0] + random_range(_oriW[0], _oriW[1]);
				var oy = _ori[1] + random_range(_oriW[2], _oriW[3]);
				
				_t.x = ox;
				_t.y = oy;
				_t.amount = random_range(_segs[0], _segs[1]);
				_t.length = _len;
				_t.angle  = _ang;
				_t.thick  = _thck;
				
				_t.grow();
				
				_roots[i] = _t;
			}
			
			outputs[0].setValue(_roots);
			return;
			
		} 
		
		var _branches = [];
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			
			
		}
		
		outputs[0].setValue(_branches);
	}
	
	
}