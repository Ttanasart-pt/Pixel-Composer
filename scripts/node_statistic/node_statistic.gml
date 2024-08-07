enum STAT_OPERATOR {
	_sum,
	_average,
	_median,
	_max,
	_min
}

#region create 
	global.node_statistic_keys = [ "sum", "mean", "median", "min", "max" ];
	array_append(global.node_statistic_keys, [ "average" ]);
	
	function Node_create_Statistic(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Statistic(_x, _y, _group).skipDefault();
		var ind   = -1;
		
		switch(query) {
			default : ind = array_find(global.node_statistic_keys, query);
		}
		
		if(ind >= 0) node.inputs[| 0].setValue(ind);
	
		return node;
	}
#endregion

function Node_Statistic(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Statistic";
	
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue_Enum_Scroll("Type", self,  0, [ "Sum", "Mean", "Median", "Max", "Min" ])
		.rejectArray();
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, -1 )
			.setVisible(false, true);
			
		return inputs[| index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.float);
	
	outputs[| 0] = nodeValue("Statistic", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, -1);
	
	static update = function(frame = CURRENT_FRAME) { #region
		var type = getInputData(0);
		var res = 0;
		
		switch(type) {
			case STAT_OPERATOR._sum : 
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var val = getInputData(i);
					if(is_array(val)) {
						for( var j = 0; j < array_length(val); j++ )
							res += val[j];
					} else
						res += val;
				}
				break;
			case STAT_OPERATOR._average : 
				if(ds_list_size(inputs) <= input_fix_len + 1) {
					res = 0;
					break;
				}
				
				var amo = 0;
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var val = getInputData(i);
					if(is_array(val)) {
						for( var j = 0; j < array_length(val); j++ ) {
							res += val[j];
							amo++;
						}
					} else {
						res += val;
						amo++;
					}
				}
				res /= amo;
				break;
			case STAT_OPERATOR._median : 
				if(ds_list_size(inputs) - input_fix_len == 0) {
					res = 0;
					break;
				}
				
				var vals = [];
				var amo = 0;
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var val = getInputData(i);
					if(is_array(val)) {
						for( var j = 0; j < array_length(val); j++ ) {
							array_push(vals, val[j]);
							amo++;
						}
					} else {
						array_push(vals, val);
						amo++;
					}
				}
				
				if(amo == 1) {
					res = vals[0];
					break;
				}
				
				array_sort(vals, true);
				if(amo % 2 == 0)
					res = (vals[amo / 2 - 1] + vals[amo / 2]) / 2;
				else
					res = vals[(amo - 1) / 2];
				break;
			case STAT_OPERATOR._min : 
				var _min = 9999999999;
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var val = getInputData(i);
					if(is_array(val)) {
						for( var j = 0; j < array_length(val); j++ )
							_min = min(_min, val[j]);
					} else
						_min = min(_min, val);
				}
				res = _min;
				break;
			case STAT_OPERATOR._max : 
				var _max = -9999999999;
				
				for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
					var val = getInputData(i);
					if(is_array(val)) {
						for( var j = 0; j < array_length(val); j++ )
							_max = max(_max, val[j]);
					} else
						_max = max(_max, val);
				}
				res = _max;
				break;
		}
		
		outputs[| 0].setValue(res);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(getInputData(0)) {
			case STAT_OPERATOR._average : str = "Avg"; break;
			case STAT_OPERATOR._sum : str = "Sum"; break;
			case STAT_OPERATOR._median : str = "Med"; break;
			case STAT_OPERATOR._min : str = "Min"; break;
			case STAT_OPERATOR._max : str = "Max"; break;
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
}