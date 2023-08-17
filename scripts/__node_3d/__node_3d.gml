function Node_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "3D";
	is_3D = true;
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {}
	static onDrawNode  = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
	
	static getPreviewObject = function() {
		if(ds_list_empty(outputs)) return [];
		switch(outputs[| preview_channel].type) {
			case VALUE_TYPE.d3Mesh		: 
			case VALUE_TYPE.d3Light		: 
			case VALUE_TYPE.d3Camera	: 
			case VALUE_TYPE.d3Scene		: break;
			
			default : return [];
		}
		
		var _obj = outputs[| 0].getValue();
		if(is_array(_obj))
			_obj = array_safe_get(_obj, preview_index, noone);
		
		return [ _obj ];
	}
	
	static getPreviewObjectOutline = function() { return getPreviewObject() }
}