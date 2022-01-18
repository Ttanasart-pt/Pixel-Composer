function Node_create_Color(_x, _y) {
	var node = new Node_Color(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Color(_x, _y) : Node(_x, _y) constructor {
	name		= "Color";
	previewable = false;
	
	min_h = 0;
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setVisible(false);
	
	outputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, []);
	
	static update = function() {
		outputs[| 0].setValue(inputs[| 0].getValue());
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var x0 = xx + 8 * _s;
		var x1 = xx + (w - 8) * _s;
		var y0 = yy + 20 + 8 * _s;
		var y1 = yy + (h - 8) * _s;
		
		if(y1 > y0) {
			draw_set_color(inputs[| 0].getValue());
			draw_rectangle(x0, y0, x1, y1, 0);
		}
	}
	
	doUpdate();
}