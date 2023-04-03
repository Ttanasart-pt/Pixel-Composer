//Make an iterator_* parent???

function Node_Iterate_Filter(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name = "Filter Array";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	combine_render_time = false;
	iterated = 0;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, noone );
	
	custom_input_index = ds_list_size(inputs);
	custom_output_index = ds_list_size(inputs);
	loop_start_time = 0;
	ALWAYS_FULL = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_Iterator_Filter_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Filter_Output", 256, -32, self);
		
		output.inputs[| 0].setFrom(input.outputs[| 0]);
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
		
		var arrIn  = inputs[| 0].getValue();
		var arrOut = outputs[| 0].getValue();
		
		surface_array_free(arrOut);
		outputs[| 0].setValue([])
		
		LOG("Loop begin");
		var _val = outputs[| 0].getValue();
		LOG("Output original value " + string(_val));
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
			if(_o.node.rendered) return;
		}
		
		var maxIter = getIterationCount();
		iterated++;
		
		if(iterated >= maxIter)
			render_time = get_timer() - loop_start_time;
		else 
			resetRender();
	}
	
	static iterationStatus = function() {
		if(iterated >= getIterationCount())
			return ITERATION_STATUS.complete;
		return ITERATION_STATUS.loop;
	}
	
	PATCH_STATIC
}