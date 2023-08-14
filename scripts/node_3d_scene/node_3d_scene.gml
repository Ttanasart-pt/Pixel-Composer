function Node_3D_Scene(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "3D Scene";
	
	//inputs[| 0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [])
	//	.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Scene, self);
	
	setIsDynamicInput(1);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, noone )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)	
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static submitSel = function(params = {}) { 
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			var _obj = inputs[| i].getValue();
			if(_obj == noone) continue;
			
			_obj.submitSel(params);
		}
	}
	
	static submitUI = function(params = {}, shader = noone) { 
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			var _obj = inputs[| i].getValue();
			if(_obj == noone) continue;
			
			_obj.submitUI(params, shader);
		}
	}
	
	static submit = function(params = {}, shader = noone) { 
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			var _obj = inputs[| i].getValue();
			if(_obj == noone) continue;
			
			_obj.submit(params, shader);
		}
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
}