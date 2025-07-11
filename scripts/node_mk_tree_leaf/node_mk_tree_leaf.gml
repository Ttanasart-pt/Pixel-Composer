function Node_MK_Tree_Leaf(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "MK Tree Leaf";
	color = CDEF.lime;
	icon  = THEME.mkTree;
	
	newInput(0, nodeValue_Struct("Tree", noone));
	
	////- =Leaf
	newInput(0, nodeValue_Vec2(  "Position", [0,0] )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		[ "", false ], 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		var _seed = inline_context.seed;
		// var _tree = new __MK_Tree();
		
	}
	
	
}