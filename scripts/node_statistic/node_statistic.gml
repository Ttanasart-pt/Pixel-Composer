#region create 
	enum STAT_OPERATOR {
		_sum,
		_average,
		_median,
		_max,
		_min
	}

	global.node_statistic_keys = [ "sum", "mean", "median", "max", "min" ];
	array_append(global.node_statistic_keys, [ "average" ]);
	
	function Node_create_Statistic(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Statistic(_x, _y, _group);
		node.skipDefault();
		
		var ind   = -1;
		
		switch(query) {
			default : ind = array_find(global.node_statistic_keys, query);
		}
		
		if(ind >= 0) node.inputs[0].skipDefault().setValue(ind);
	
		return node;
	}
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Statistic", "Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue((_n.inputs[0].getValue() + 1) % 2); });
		addHotkey("Node_Statistic", "Type > Sum",    "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(0); });
		addHotkey("Node_Statistic", "Type > Mean",   "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(1); });
	});
#endregion

function Node_Statistic(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Statistic";
	
	setDimension(96, 48);
	
	_type_arr      = [ "Sum", "Mean", "Median", "Max", "Min" ];
	_type_disp_arr = [ "Sum", "Avg",  "Med",    "Max", "Min" ];
	
	newInput(0, nodeValue_Enum_Scroll("Type", 0, _type_arr )).rejectArray();
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Float("Input", -1 )).setVisible(false, true);
			
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.float);
	
	newOutput(0, nodeValue_Output("Statistic", VALUE_TYPE.float, -1));
	
	////- Nodes
	
	static onValueUpdate = function(index = 0) {
		if(index != 0) return;
		
		var _type = inputs[0].getValue();
		setDisplayName(array_safe_get(_type_arr, _type), false);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var type = getInputData(0);
		var res  = 0;
		
		var _val = [];
		for( var i = input_fix_len; i < array_length(inputs); i++ ) 
			_val = array_append(_val, getInputData(i));
		var  amo = array_length(_val);
		
		switch(type) {
			case STAT_OPERATOR._sum : res = array_sum(_val); break;
			case STAT_OPERATOR._min : res = array_min(_val); break;
			case STAT_OPERATOR._max : res = array_max(_val); break;
				
			case STAT_OPERATOR._average : 
				var sum = array_sum(_val); 
				res = amo == 0? 0 : sum / amo;
				break;
				
			case STAT_OPERATOR._median : 
				if(amo == 0) { res = 0;       break; }
				if(amo == 1) { res = _val[0]; break; }
				
				array_sort(_val, true);
				var i = (amo - 1) / 2;
				
				if(frac(i) == 0) res = _val[i];
				else res = (_val[floor(i)] + _val[floor(i) + 1]) / 2;
				break;
				
		}
		
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = array_safe_get(_type_disp_arr, getInputData(0));
		
		var bbox = draw_bbox;
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}