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
		
		LOG_LINE_IF(global.DEBUG_FLAG.render, "Loop begin");
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
	
	static getIterationCount = function() {
		var maxIter = inputs[| 0].getValue();
		return maxIter;
	}
	
	static iterationUpdate = function() {
		var siz = ds_list_size(outputs); // check if every output is updated
		for( var i = custom_output_index; i < siz; i++ ) {
			var _o = outputs[| i];
			if(!_o.node.rendered) return;
		}
		
		var maxIter = getIterationCount();
		iterated++;
		
		LOG_BLOCK_START();
		LOG_IF(global.DEBUG_FLAG.render, "Iteration update: " + string(iterated) + "/" + string(maxIter));
		
		if(iterated >= maxIter) {
			LOG_IF(global.DEBUG_FLAG.render, "Iteration complete");
			render_time = get_timer() - loop_start_time;
		} else {
			LOG_IF(global.DEBUG_FLAG.render, "Iteration not completed, reset render status.");
			resetRender();
		}
		
		LOG_BLOCK_END();
	}
	
	static iterationStatus = function() {
		if(iterated >= getIterationCount())
			return ITERATION_STATUS.complete;
		return ITERATION_STATUS.loop;
	}
	
	PATCH_STATIC
}