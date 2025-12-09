#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Path_Anchor", "Adjust control point", "A");
	});
#endregion

function Node_Path_Anchor(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Path Anchor";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	setDrawIcon(s_node_path_anchor);
		
	newInput(0, nodeValue_Vec2( "Postion",              [0,0]   )).setHotkey("G").setVisible(true, true);
	newInput(1, nodeValue_Vec2( "Control point 1",      [-16,0] ));
	newInput(2, nodeValue_Vec2( "Control point 2",      [ 16,0] ));
	newInput(3, nodeValue_Bool( "Mirror control point",  true   ));
	// input 4
	
	newOutput(0, nodeValue_Output("Anchor", VALUE_TYPE.float, [ 0, 0, 0, 0, 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	tools = [
		new NodeTool( "Adjust control point", THEME.path_tools_anchor ),
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _pos = current_data[0];
		var _cn1 = current_data[1];
		var _cn2 = current_data[2];
		var _mir = current_data[3];
		
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		
		var c1x = px + _cn1[0] * _s;
		var c1y = py + _cn1[1] * _s;
		var c2x = _mir? px - _cn1[0] * _s : px + _cn2[0] * _s;
		var c2y = _mir? py - _cn1[1] * _s : py + _cn2[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(px, py, c1x, c1y);
		draw_line(px, py, c2x, c2y);
		
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, !isUsingTool(0) && active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		if(!_mir) InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		else      draw_circle_prec(c2x, c2y, 4, false);
		
		return w_hovering;
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _mir = _data[3];
		
		if(_mir)
			return [_data[0][0], _data[0][1], _data[1][0], _data[1][1], -_data[1][0], -_data[1][1]];
		else	
			return [_data[0][0], _data[0][1], _data[1][0], _data[1][1], _data[2][0], _data[2][1]];
	}
}