enum STAT_OPERATOR {
	_sum,
	_average,
	_median,
	_max,
	_min
}

function Node_create_Statistic(_x, _y, _param = "") {
	var node = new Node_Statistic(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	
	switch(_param) {
		case "sum" :		node.inputs[| 0].setValue(STAT_OPERATOR._sum); break;	
		case "mean" :	
		case "average" :	node.inputs[| 0].setValue(STAT_OPERATOR._average); break;	
		case "median" :		node.inputs[| 0].setValue(STAT_OPERATOR._median); break;	
		case "min" :		node.inputs[| 0].setValue(STAT_OPERATOR._min); break;	
		case "max" :		node.inputs[| 0].setValue(STAT_OPERATOR._max); break;	
	}
	
	return node;
}

function Node_Statistic(_x, _y) : Node(_x, _y) constructor {
	name = "Statistic";
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ 
			"Sum", "Mean", "Median", "Max", "Min"]);
	
	input_fix_len	= ds_list_size(inputs);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, "Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, -1 )
			.setVisible(true, true);
	}
	createNewInput();
	
	outputs[| 0] = nodeValue(0, "Statistic", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, -1);
	
	static updateValueFrom = function(index) {
		var _l = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ ) {
			_l[| i] = inputs[| i];
		}
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
			if(inputs[| i].value_from) {
				ds_list_add(_l, inputs[| i]);
			} else {
				delete inputs[| i];	
			}
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ ) {
			_l[| i].index = i;	
		}
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static update = function() {
		var type = inputs[| 0].getValue();
		var res = 0;
		
		switch(type) {
			case STAT_OPERATOR._sum : 
				for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
					var val = inputs[| i].getValue();
					res += val;
				}
				break;
			case STAT_OPERATOR._average : 
				if(ds_list_size(inputs) <= input_fix_len + 1) res = 0;
				else {
					for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
						var val = inputs[| i].getValue();
						res += val;
					}
					res /= ds_list_size(inputs) - 1 - input_fix_len;
				}
				break;
			case STAT_OPERATOR._median : 
				var len = ds_list_size(inputs) - 1 - input_fix_len;
				if(len == 0) {
					res = 0;
					break;
				}
				
				var vals = array_create(len);
				for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
					vals[i - input_fix_len] = inputs[| i].getValue();
				}
				
				if(len == 1) {
					res = vals[0];
					break;
				}
				
				array_sort(vals, true);
				if(len % 2 == 0)
					res = (vals[len / 2 - 1] + vals[len / 2]) / 2;
				else
					res = vals[(len - 1) / 2];
				break;
			case STAT_OPERATOR._min : 
				var _min = 9999999999;
				for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
					var val = inputs[| i].getValue();
					_min = min(_min, val);
				}
				res = _min;
				break;
			case STAT_OPERATOR._max : 
				var _max = -9999999999;
				for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
					var val = inputs[| i].getValue();
					_max = max(_max, val);
				}
				res = _max;
				break;
		}
		
		outputs[| 0].setValue(res);
	}
	doUpdate();
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = 0; i < ds_list_size(_inputs); i++) {
			createNewInput();
		}
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(inputs[| 0].getValue()) {
			case STAT_OPERATOR._average : str = "Avg"; break;
			case STAT_OPERATOR._sum : str = "Sum"; break;
			case STAT_OPERATOR._median : str = "Med"; break;
			case STAT_OPERATOR._min : str = "Min"; break;
			case STAT_OPERATOR._max : str = "Max"; break;
		}
		
		var _ss = min((w - 16) * _s / string_width(str), (h - 18) * _s / string_height(str));
		
		if(_s * w > 48)
			draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, _ss, _ss, 0);
		else 
			draw_text_transformed(xx + w / 2 * _s, yy + h / 2 * _s, str, _ss, _ss, 0);
	}
}