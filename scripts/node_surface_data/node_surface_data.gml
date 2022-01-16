function Node_create_Surface_data(_x, _y) {
	var node = new Node_Surface_data(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Surface_data(_x, _y) : Node(_x, _y) constructor {
	name	= "Surface data";
	color	= c_ui_cyan;
	previewable = false;
	
	inputs[| 0] = nodeValue(0, "Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	outputs[| 1] = nodeValue(1, "Array length", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	min_h = 0;
	w = 96;
	
	function update() {
		var _insurf	= inputs[| 0].getValue();
		if(is_array(_insurf)) {
			var len = array_length(_insurf);
			var _dim = array_create(len);
			
			for( var i = 0; i < len; i++ )  {
				_dim[i][0] = surface_get_width(_insurf[i]);
				_dim[i][1] = surface_get_height(_insurf[i]);
			}
			
			outputs[| 0].setValue(_dim);
			outputs[| 1].setValue(len);
			return;
		}
		
		if(!_insurf || !surface_exists(_insurf)) return;
		
		outputs[| 0].setValue([ surface_get_width(_insurf), surface_get_height(_insurf) ]);
	}
	update();
}