function Node_Lua_Global(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Global";
	preview_channel = 1;
	previewable = false;
	
	inputs[| 0]  = nodeValue("Lua code", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", o_dialog_lua_reference)
		.setDisplay(VALUE_DISPLAY.codeLUA);
		
	inputs[| 1]  = nodeValue("Run order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "On start", "Every frame" ]);
	
	inputs[| 2]  = nodeValue("Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone)
		.setVisible(false, true);
	
	outputs[| 0] = nodeValue("Execution thread", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	input_display_list = [ 
		["Main",		false], 2, 1, 0,
	];
	
	lua_state = lua_create();
	
	is_beginning = false;
	error_notification = noone;
	compiled = false;
	
	static stepBegin = function() {
		var _type = getInputData(1);
		
		if(PROJECT.animator.is_playing && PROJECT.animator.frame_progress && (CURRENT_FRAME == 0 || _type == 1))
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
	
	static update = function(frame = CURRENT_FRAME) {
		if(!compiled) return;
		//if(!PROJECT.animator.is_playing || !PROJECT.animator.frame_progress) return;
		
		var _code = getInputData(0);
		var _type = getInputData(1);
		
		//if(CURRENT_FRAME == 0) { //rerfesh state on the first frame
		//	lua_state_destroy(lua_state);
		//	lua_state = lua_create();
		//	addCode();
		//}
		
		lua_projectData(getState());
		
		if(CURRENT_FRAME == 0 || _type == 1) {
			try		 { lua_add_code(getState(), _code); }
			catch(e) { noti_warning(exception_print(e),, self); }
		}
	}
	
	static onInspector1Update = function() { //compile
		var thrd = inputs[| 2].value_from;
		if(thrd == noone) {
			doCompile();
			return;
		}
		
		thrd.node.onInspector1Update();
	}
	
	static doCompile = function() {
		compiled = true;
		
		for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
			var _j = outputs[| 0].value_to[| i];
			if(_j.value_from != outputs[| 0]) continue;
			_j.node.doCompile();
		}
		
		doUpdate();
	}
	
	static onDestroy = function() {
		lua_state_destroy(lua_state);
		if(error_notification != noone)
			noti_remove(error_notification);
	}
}