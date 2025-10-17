function Node_Number_Simple(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name     = "Number Simple";
	color    = COLORS.node_blend_number;
	doUpdate = doUpdateLite;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Float( "Value", 0 )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Number", VALUE_TYPE.float, 0));
	
	b_advance = button(function() /*=>*/ {
		var _n = nodeBuild("Node_Number", x, y, group);
		
		if(inputs[0].value_from != noone) _n.inputs[0].setFrom(inputs[0].value_from);
		var _to = outputs[0].getJunctionTo();
		for( var i = 0, n = array_length(_to); i < n; i++ ) 
			_to[i].setFrom(outputs[0]);
		
		nodeDestroy(self, false);
		PANEL_GRAPH.setFocusingNode(_n);
	}).setText("Switch to Advance mode");
	
	input_display_list = [ 0, b_advance ];
	
	////- Node
	
	static update = function() { outputs[0].setValue(inputs[0].getValue()); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(outputs[0].getValue()));
	}
	
}