function Node_Array_Add(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Add";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_Any(  "Array" )).setVisible(true, true);
	newInput( 1, nodeValue_Bool( "Spread array", false )).rejectArray();
	// 2
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.any, 0));
	
	input_display_list = [ 
		[ "Array", false ],  0,  1,
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Any( "Value" )).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		postCreateNewInput(index);
		return inputs[index];
	} 
	
	setDynamicInput(1);
	
	////- Nodes
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr = getInputData(0);
			var _spd = getInputData(1);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			if(!is_array(_arr)) return;
		#endregion
		
		var _out = array_clone(_arr);
		var  sig = array_clone(isig);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _val = getInputData(i);
			var _sig = inputs[i].getTypeSignature();
			
			inputs[i].setType(type);
			
			if(_spd) {
				array_append(_out, _val);
				array_append( sig, array_create(array_safe_length(_val), _sig));
				
			} else {
				array_push(_out, _val);
				array_push( sig, _sig);
			}
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
		
	}
}