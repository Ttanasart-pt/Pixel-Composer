function Node_Array_Add(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Add";
	setDimension(96, 48);
	
	newInput(1, nodeValue_Bool( "Spread array", false )).rejectArray();
	newInput(0, nodeValue( "Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.any, 0));
	
	input_display_list = [ 1, 0 ];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1 )).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	
	setDynamicInput(1);
	
	////- Nodes
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var _arr = getInputData(0);
		var _spd = getInputData(1);
		if(!is_array(_arr)) return;
		
		var _out = array_clone(_arr);
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _val = getInputData(i);
			inputs[i].setType(type);
			
			if(_spd) array_append(_out, _val);
			else     array_push(_out, _val);
		}
		
		outputs[0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
		
		draw_sprite_fit(s_node_array_add, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}