function Node_Iterate_Sort(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Sort Array";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	reset_all_child     = true;
	managedRenderOrder  = true;
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, [] ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, noone ));
	
	topoList = [];
	
	custom_input_index  = array_length(inputs);
	custom_output_index = array_length(inputs);
	loop_start_time     = 0;
	
	inputNodes = [ noone, noone ];
	outputNode = noone;
	nodeValid  = false;
	
	if(NODE_NEW_MANUAL) { #region
		var input0 = nodeBuild("Node_Iterator_Sort_Input", -256, -64, self);
		input0.setDisplayName("Value 1", false);
		input0.attributes.sort_inputs = 1;
		
		var input1 = nodeBuild("Node_Iterator_Sort_Input", -256,  64, self);
		input1.setDisplayName("Value 2", false);
		input1.attributes.sort_inputs = 2;
		
		var output = nodeBuild("Node_Iterator_Sort_Output", 256, -32, self);
		output.attributes.sort_inputs = 9;
	} #endregion
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) { #region
		for( var i = 0, n = array_length(nodes); i < n; i++ )
			if(nodes[i].isActiveDynamic(frame)) return true;
		
		return false;
	} #endregion
	
	static getNextNodes = function(checkLoop = false) { return getNextNodesExternal(); }
	
	static onStep = function() { #region
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(IS_FIRST_FRAME) {
			topoList = NodeListSort(nodes);
			
			inputNodes     = [ noone, noone ];
			outputNode     = noone;
			var inputReady = 0;
			
			if(inputs[0].value_from) {
				inputs[0].setType(inputs[0].value_from.type);
				outputs[0].setType(inputs[0].value_from.type);
			}
		
			var _typ = inputs[0].type;
		
			for( var i = 0; i < array_length(nodes); i++ ) {
				var _n = nodes[i];
				if(!struct_has(_n.attributes, "sort_inputs")) continue;
				
				switch(_n.attributes.sort_inputs) {
					case 1 : 
						inputNodes[0] = _n.inputs[0];
						
						_n.inputs[0].setType( _typ);
						_n.outputs[0].setType(_typ);
						inputReady += 1;
						break;
					case 2 : 
						inputNodes[1] = _n.inputs[0];
						
						_n.inputs[0].setType( _typ);
						_n.outputs[0].setType(_typ);
						inputReady += 2;
						break;
					case 9 : 
						outputNode = nodes[i].inputs[0];
						inputReady += 4;
						break;
				}
			}
		
			nodeValid = inputReady == 0b111;
			if(!nodeValid) {
				noti_warning($"Array sort: Missing inputs or output, need 2 inputs and 1 output for comparison [{inputReady}].", noone, self);
				return;
			}
		}
		
		if(nodeValid) sortArray();
	} #endregion
	
	static swap = function(arr, a, b) { #region
		var temp = arr[a];
		arr[@ a] = arr[b];
		arr[@ b] = temp;
	} #endregion
	
	static compareValue = function(val1, val2) { #region
		if(!nodeValid) return 0;
		inputNodes[0].setValue(val1,,, false);
		inputNodes[1].setValue(val2,,, false);
		
		resetRender(true);
		RenderList(topoList);
		
		var res = outputNode.getValue();
		LOG_IF(global.FLAG.render == 1, $"Iterating | Comparing {val1}, {val2} = {res}");
		return res;
	} #endregion
	
	static partition = function(arr, low, high) { #region
		var pv = arr[high]; 
		var i  = low - 1;
		
		for(var j = low; j < high; j++) {
			if(compareValue(arr[j], pv)) continue;
			
			i++;
			swap(arr, i, j);
		}
		
		swap(arr, i + 1, high);
		return i + 1;
	} #endregion
	
	static quickSort = function(arr, low, high) { #region
		if(low >= high) return;
		
		var p = partition(arr, low, high);
		
		quickSort(arr, low, p - 1);
		quickSort(arr, p + 1, high);
	} #endregion
	
	static sortArray = function() { #region
		iterated = 0;
		loop_start_time = get_timer();
		
		var arrIn  = getInputData(0);
		var arrOut = outputs[0].getValue();
		
		if(inputs[0].type == VALUE_TYPE.surface) {
			surface_array_free(arrOut);
			arrOut = surface_array_clone(arrIn);
		} else
			arrOut = array_clone(arrIn);
		
		quickSort(arrOut, 0, array_length(arrOut) - 1);
		outputs[0].setValue(arrOut);
	} #endregion
}