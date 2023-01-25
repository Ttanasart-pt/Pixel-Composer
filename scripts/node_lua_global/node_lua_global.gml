function Node_Lua_Global(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Lua Global";
	preview_channel = 1;
	previewable = false;
	
	inputs[| 0]  = nodeValue(0, "Lua code", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setDisplay(VALUE_DISPLAY.code);
		
	inputs[| 1]  = nodeValue(1, "Run order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "On start", "Every frame" ]);
	
	inputs[| 2]  = nodeValue(2, "Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone)
		.setVisible(false, true);
	
	outputs[| 0] = nodeValue(0, "Execution thread", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	input_display_list = [ 
		["Main",		false], 2, 1, 0,
	];
	
	lua_state = lua_create();
	
	compiled = false;
	
	static stepBegin = function() {
		var _type = inputs[| 1].getValue();
		
		if(ANIMATOR.frame_progress && (ANIMATOR.current_frame == 0 || _type == 1)) {
			setRenderStatus(false);
			UPDATE |= RENDER_TYPE.partial;
		}
		
		setHeight();
		doStepBegin();
		
		value_validation[VALIDATION.error] = !compiled;
	}
	
	static getState = function() {
		if(inputs[| 2].value_from == noone)
			return lua_state;
		return inputs[| 2].value_from.node.getState();
	}
	
	static onValueFromUpdate = function(index) {
		if(index == 0 || index == 2) compiled = false;
	}
	
	static onValueUpdate = function(index) {
		if(index == 0 || index == 2) compiled = false;
	}
	
	static update = function() {
		if(!compiled) return;
		
		var _code = inputs[| 0].getValue();
		
		try {
			lua_add_code(getState(), _code);
		} catch(e) {
			noti_warning(exception_print(e),, self);
		}
	}
	
	static inspectorUpdate = function() { //compile
		var _code = inputs[| 0].getValue();
		compiled = true;
		
		for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
			var _j = outputs[| 0].value_to[| i];
			if(_j.value_from != outputs[| 0]) continue;
			_j.node.inspectorUpdate();
		}
		
		doUpdate();
	}
}