enum ITERATION_STATUS {
	not_ready,
	loop,
	complete,
}

function Node_Iterate(_x, _y, _group = -1) : Node_Collection(_x, _y, _group) constructor {
	name = "Loop";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	iterated = 0;
	
	inputs[| 0] = nodeValue( 0, "Repeat", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	custom_input_index = ds_list_size(inputs);
	loop_start_time = 0;
	ALWAYS_FULL = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_Iterator_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Output", 256, -32, self);
		
		input.inputs[| 2].setValue(4);
		output.inputs[| 2].setFrom(input.outputs[| 1]);
	}
	
	static initLoop = function() {
		iterated = 0;
		loop_start_time = get_timer();
		
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			var n = nodes[| i];
			if(variable_struct_exists(n, "initLoop"))
				n.initLoop();
		}
		
		printIf(global.RENDER_LOG, "LOOP INIT");
	}
	
	static getNextNodes = function() {
		var allReady = true;
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].from;
			allReady &= _in.isUpdateReady()
		}
			
		if(!allReady) return;
		
		__nodeLeafList(nodes, RENDER_QUEUE);
		initLoop();
	}
	
	static iterationStatus = function() {
		var iter = true;
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			var _out = outputs[| i].from;
			iter &= _out.rendered;
		}
		
		if(iter) {
			iterated++;
			
			if(iterated == inputs[| 0].getValue()) {
				render_time = get_timer() - loop_start_time;
				return ITERATION_STATUS.complete;
			} else if(iterated > inputs[| 0].getValue())
				return ITERATION_STATUS.complete;
			
			resetAllRenderStatus();
			return ITERATION_STATUS.loop;
		}
		
		return ITERATION_STATUS.not_ready;
	}
}