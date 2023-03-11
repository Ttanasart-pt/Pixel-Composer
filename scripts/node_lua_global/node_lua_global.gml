function Node_Lua_Global(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Global";
	preview_channel = 1;
	previewable = false;
	
	inputs[| 0]  = nodeValue("Lua code", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", o_dialog_lua_reference)
		.setDisplay(VALUE_DISPLAY.code);
		
	inputs[| 1]  = nodeValue("Run order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "On start", "Every frame" ]);
	
	inputs[| 2]  = nodeValue("Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone)
		.setVisible(false, true);
	
	outputs[| 0] = nodeValue("Execution thread", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	input_display_list = [ 
		["Main",		false], 2, 1, 0,
	];
	
	lua_state = lua_create();
	lua_error_handler = _lua_error;
	
	is_beginning = false;
	error_notification = noone;
	compiled = false;
	
	static stepBegin = function() {
		var _type = inputs[| 1].getValue();
		
		if(ANIMATOR.is_playing && ANIMATOR.frame_progress && (ANIMATOR.current_frame == 0 || _type == 1))
			setRenderStatus(false);
		
		setHeight();
		doStepBegin();
		
		value_validation[VALIDATION.error] = !compiled;
		if(!compiled && error_notification == noone) {
			error_notification = noti_error("Lua node [" + string(name) + "] not compiled.");
			error_notification.onClick = function() { PANEL_GRAPH.focusNode(self); };
		}
				
		if(compiled && error_notification != noone) {
			noti_remove(error_notification);
			error_notification = noone;
		}
	}
	
	static getState = function() {
		if(inputs[| 2].value_from == noone) return lua_state;
		return inputs[| 2].value_from.node.getState();
	}
	
	static onValueFromUpdate = function(index) {
		if(index == 0 || index == 2) compiled = false;
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 0 || index == 2) compiled = false;
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(!compiled) return;
		if(!ANIMATOR.is_playing || !ANIMATOR.frame_progress) return;
		
		var _code = inputs[| 0].getValue();
		var _type = inputs[| 1].getValue();
		
		//if(ANIMATOR.current_frame == 0) { //rerfesh state on the first frame
		//	lua_state_destroy(lua_state);
		//	lua_state = lua_create();
		//	addCode();
		//}
		
		lua_projectData(getState());
		
		if(ANIMATOR.current_frame == 0 || _type == 1) {
			try		 lua_add_code(getState(), _code);
			catch(e) noti_warning(exception_print(e),, self);
		}
	}
	
	static onInspectorUpdate = function() { //compile
		var _code = inputs[| 0].getValue();
		compiled = true;
		
		for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
			var _j = outputs[| 0].value_to[| i];
			if(_j.value_from != outputs[| 0]) continue;
			_j.node.inspectorUpdate();
		}
		
		doUpdate();
	}
	
	static onDestroy = function() {
		lua_state_destroy(lua_state);
		if(error_notification != noone)
			noti_remove(error_notification);
	}
}