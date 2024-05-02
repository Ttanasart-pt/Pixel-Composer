function Node_Path_Anchor(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Path Anchor";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
		
	inputs[| 0] = nodeValue("Postion", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("Control point 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -16, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2] = nodeValue("Control point 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 3] = nodeValue("Mirror control point", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	outputs[| 0] = nodeValue("Anchor", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	tools = [
		new NodeTool( "Adjust control point", THEME.path_tools_anchor ),
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pos = getInputData(0);
		var _cn1 = getInputData(1);
		var _cn2 = getInputData(2);
		var _mir = getInputData(3);
		
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		
		var c1x = px + _cn1[0] * _s;
		var c1y = py + _cn1[1] * _s;
		var c2x = _mir? px - _cn1[0] * _s : px + _cn2[0] * _s;
		var c2y = _mir? py - _cn1[1] * _s : py + _cn2[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(px, py, c1x, c1y);
		draw_line(px, py, c2x, c2y);
		
		active &= !inputs[| 0].drawOverlay(hover, !isUsingTool(0) && active, _x, _y, _s, _mx, _my, _snx, _sny);
		active &= !inputs[| 1].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
		
		if(!_mir)
			active &= !inputs[| 2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
		else
			draw_circle_prec(c2x, c2y, 4, false);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _mir = _data[3];
		
		if(_mir)
			return [_data[0][0], _data[0][1], _data[1][0], _data[1][1], -_data[1][0], -_data[1][1]];
		else	
			return [_data[0][0], _data[0][1], _data[1][0], _data[1][1], _data[2][0], _data[2][1]];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_anchor, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}