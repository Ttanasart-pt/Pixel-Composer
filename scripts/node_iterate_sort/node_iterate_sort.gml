function Node_Iterate_Sort(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name = "Sort Array";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	combine_render_time = false;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, noone );
	
	custom_input_index = ds_list_size(inputs);
	custom_output_index = ds_list_size(inputs);
	loop_start_time = 0;
	ALWAYS_FULL = true;
	
	inputNodes = [];
	outputNode = noone;
	nodeValid  = false;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input0 = nodeBuild("Node_Iterator_Sort_Input", -256, -64, self);
		input0.display_name = "Value 1";
		
		var input1 = nodeBuild("Node_Iterator_Sort_Input", -256,  64, self);
		input1.display_name = "Value 2";
		
		var output = nodeBuild("Node_Iterator_Sort_Output", 256, -32, self);
	}
	
	static getNextNodes = function() {
		initLoop();
		return __nodeLeafList(getNodeList());
	}
	
	static onStep = function() {
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].type = type;
	}
	
	static swap = function(arr, a, b) {
		var temp = arr[a];
		arr[@ a] = arr[b];
		arr[@ b] = temp;
	}
	
	static partition = function(arr, low, high) { 
		var pv = arr[high]; 
		var i  = low - 1;
		
		for(var j = low; j < high; j++) {
			if(compareValue(arr[j], pv)) continue;
			
			i++;
			swap(arr, i, j);
		}
		
		swap(arr, i + 1, high);
		return i + 1;
	}
	
	static quickSort = function(arr, low, high) { 
		if(!nodeValid)  return;
		if(low >= high) return;
		
		var p = partition(arr, low, high);
		
		quickSort(arr, low, p - 1);
		quickSort(arr, p + 1, high);
	}
	
	static compareValue = function(val1, val2) { 
		if(!nodeValid) return 0;
		inputNodes[0].setValue(val1);
		inputNodes[1].setValue(val2);
		
		RenderList(nodes);
		var res = outputNode.getValue();
		//print("Comparing " + string(val1) + ", " + string(val2) + ": " + string(res));
		return res;
	}
	
	static initLoop = function() {
		if(inputs[| 0].value_from) {
			inputs[| 0].type  = inputs[| 0].value_from.type;
			outputs[| 0].type = inputs[| 0].value_from.type;
		}
		
		resetRender();
		iterated = 0;
		loop_start_time = get_timer();
		
		inputNodes = [ 0, 0 ];
		outputNode = noone;
		var inputReady = 0;
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			if(nodes[| i].display_name == "Value 1") {
				inputNodes[0] = nodes[| i].inputs[| 0];
				inputNodes[0].type = inputs[| 0].type;
				inputReady++;
			} else if(nodes[| i].display_name == "Value 2") {
				inputNodes[1] = nodes[| i].inputs[| 0];
				inputNodes[1].type = inputs[| 0].type;
				inputReady++;
			} else if(nodes[| i].name == "Swap result") {
				outputNode = nodes[| i].inputs[| 0];
				inputReady++;
			}
		}
		
		nodeValid = inputReady == 3;
		if(!nodeValid) {
			noti_warning("Sort: Missing inputs or output, need 2 inputs and 1 output for comparison.");
			return;
		}
		
		var arrIn  = inputs[| 0].getValue();
		var arrOut = outputs[| 0].getValue();
		
		if(inputs[| 0].type == VALUE_TYPE.surface) {
			surface_array_free(arrOut);
			arrOut = surface_array_clone(arrIn);
		} else
			arrOut = array_clone(arrIn);
		
		quickSort(arrOut, 0, array_length(arrOut) - 1);
		outputs[| 0].setValue(arrOut);
	}
	
	PATCH_STATIC
}