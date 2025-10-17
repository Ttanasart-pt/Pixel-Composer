#region
	// FN_NODE_CONTEXT_INVOKE {
	// 	addHotkey("", " > Set", KEY_GROUP.numeric, MOD_KEY.none, () => { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	// 	addHotkey("", " > ", "", MOD_KEY.none, () => { GRAPH_FOCUS _n.inputs[1].setValue(); });
	// 	addHotkey("", " > Toggle", "", MOD_KEY.none, () => { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	// });
#endregion

function Node_Shape_Rectangle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name     = "Rectangle";
	doUpdate = doUpdateLite;
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Transform
	newInput( 1, nodeValue_Vec2(     "Position", [.5,.5] )).setHotkey("G").setUnitRef(getDimension, VALUE_UNIT.reference);
	newInput( 2, nodeValue_Rotation( "Rotation",   0     )).setHotkey("R");
	newInput( 3, nodeValue_Vec2(     "Scale",    [.5,.5] )).setHotkey("S").setUnitRef(getDimension, VALUE_UNIT.reference);
	// 
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Transform", false ], 1, 2, 3, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		draw_set_color(c_grey);
		node_draw_transform_box(active, _x, _y, _s, _mx, _my, _snx, _sny, 1, 2, 3, true);
	}
	
	static update = function() {
		#region data
			var _dim = inputs[0].getValue();
			
			var _pos = inputs[1].getValue();
			var _rot = inputs[2].getValue();
			var _sca = inputs[3].getValue();
			
			var _outSurf = surface_verify(outputs[0].getValue(), _dim[0], _dim[1]);
			outputs[0].setValue(_outSurf);
		#endregion
	}
}
