enum ITERATION_STATUS {
	not_ready,
	loop,
	complete,
}

function Node_Iterate(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name = "Loop";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	combine_render_time = false;
	iterated = 0;
	
	inputs[| 0] = nodeValue("Repeat", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
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
		resetRender();
		
		iterated = 0;
		loop_start_time = get_timer();
		var node_list   = getNodeList();
		
		for( var i = 0; i < ds_list_size(node_list); i++ ) {
			var n = node_list[| i];
			if(variable_struct_exists(n, "initLoop"))
				n.initLoop();
		}
		
		LOG_LINE_IF(global.RENDER_LOG, "Loop begin");
	}
	
	static getNextNodes = function() {
		var allReady = true;
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].from;
			if(!_in.renderActive) continue;
			
			allReady &= _in.isRenderable()
		}
			
		if(!allReady) return [];
		
		initLoop();
		return __nodeLeafList(getNodeList());
	}
	
	static iterationStatus = function() {
		var iter = true;
		var maxIter = inputs[| 0].getValue();
		if(!is_real(maxIter)) maxIter = 1;
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			var _out = outputs[| i].from;
			iter &= _out.rendered;
		}
		
		if(iter) {
			iterated++;
			
			if(iterated >= maxIter) {
				render_time = get_timer() - loop_start_time;
				iterated = 0;
				return ITERATION_STATUS.complete;
			} 
			
			resetRender();
			return ITERATION_STATUS.loop;
		}
		
		return ITERATION_STATUS.not_ready;
	}
	
	PATCH_STATIC
}