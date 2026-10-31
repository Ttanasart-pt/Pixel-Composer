function Node_Lookat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Lookat";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_Vec2( "From", [0,0] )).setUnitSimple().setVisible(true, true);
	newInput( 1, nodeValue_Vec2( "To",   [1,1] )).setUnitSimple().setVisible(true, true);
	// 2
	
	newOutput(0, nodeValue_Output("Direction", VALUE_TYPE.float, 0));
	
	inputs_display_list = [ 0, 1 ]
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[ 0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		drawOverlayInput(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _from = _data[0];
		var _to   = _data[1];
		
		var _ang = point_direction(_from[0], _from[1], _to[0], _to[1]);
		return _ang;
	}
	
}