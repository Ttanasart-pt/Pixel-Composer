function Node_create_Gradient_Out(_x, _y) {
	var node = new Node_Gradient_Out(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Gradient_Out(_x, _y) : Node(_x, _y) constructor {
	name		= "Gradient";
	previewable = false;
	
	min_h = 0;
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 1] = nodeValue(1, "Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, []);
	
	outputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	_pal = -1;
	static update = function() {
		var pal = inputs[| 0].getValue();
		var pos = inputs[| 1].getValue();
		
		if(pal != _pal) {
			_pal = pal;
			outputs[| 0].setValue(pal);
		}
		
		outputs[| 1].setValue(gradient_eval(pal, pos));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var x0 = xx + 8 * _s;
		var x1 = xx + (w - 8) * _s;
		var y0 = yy + 20 + 8 * _s;
		var y1 = yy + (h - 8) * _s;
		
		if(y1 > y0)
			draw_gradient(x0, y0, x1 - x0, y1 - y0, inputs[| 0].getValue(), inputs[| 0].extra_data[| 0]);
	}
	doUpdate();
}