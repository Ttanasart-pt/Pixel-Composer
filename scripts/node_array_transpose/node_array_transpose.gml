function Node_Array_Transpose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Transpose";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array in", self, CONNECT_TYPE.input, VALUE_TYPE.any, []))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Transposed Array", self, VALUE_TYPE.any, []));
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var arr = getInputData(0);
		
		if(!is_array(arr)) {
		    noti_warning($"{name}: Input not an array", noone, self);
		    return;
		}
		
		var _w = array_length(arr);
		if(_w == 0) return;
		
		var _h = undefined;
		
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
		    if(!is_array(arr[i])) continue;
		    
		    var _l = array_length(arr[i]);
		    _h = _h == undefined? _l : min(_h, _l);
		}
		
		var _arr = array_create(_h);
		
		for( var i = 0; i < _h; i++ ) {
		    _arr[i] = array_create(_w);
		    for( var j = 0; j < _w; j++ ) 
		        _arr[i][j] = arr[j][i];
		}
		
		outputs[0].setValue(_arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_flattern, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}