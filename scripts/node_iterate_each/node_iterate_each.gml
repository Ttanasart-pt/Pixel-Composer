function Node_Iterate_Each(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name = "Loop Array";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	combine_render_time = false;
	iterated = 0;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, [] );
	
	custom_input_index = ds_list_size(inputs);
	custom_output_index = ds_list_size(inputs);
	loop_start_time = 0;
	ALWAYS_FULL = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_Iterator_Each_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Each_Output", 256, -32, self);
		
		output.inputs[| 0].setFrom(input.outputs[| 0]);
	}
	
	static getNextNodesRaw = function() {
		return __nodeLeafList(getNodeList());
	}
	
	static getNextNodes = function() {
		initLoop();
		return __nodeLeafList(getNodeList());
	}
	
	static onStep = function() {
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].type = type;
	}
	
	static initLoop = function() {
		resetRender();
		iterated = 0;
		loop_start_time = get_timer();
		
		var arrIn = inputs[| 0].getValue();
		var arrOut = outputs[| 0].getValue();
		
		if(array_length(arrOut) != array_length(arrIn)) {
			surface_array_free(arrOut);
			outputs[| 0].setValue([])
		}
		
		LOG_LINE_IF(global.FLAG.render, "Loop begin");
	}
	
	static getIterationCount = function() {
		var arrIn = inputs[| 0].getValue();
		var maxIter = is_array(arrIn)? array_length(arrIn) : 0;
		if(!is_real(maxIter)) maxIter = 1;
		
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
		LOG_IF(global.FLAG.render, "Iteration update: " + string(iterated) + "/" + string(maxIter));
		
		if(iterated >= maxIter) {
			LOG_IF(global.FLAG.render, "Iteration complete");
			render_time = get_timer() - loop_start_time;
		} else {
			LOG_IF(global.FLAG.render, "Iteration not completed, reset render status.");
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