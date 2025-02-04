#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Pixel_Math", "Operator > Add",      "A", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[7].setValue(array_find(global.node_math_names, "Add")); });
		addHotkey("Node_Pixel_Math", "Operator > Subtract", "S", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[7].setValue(array_find(global.node_math_names, "Subtract")); });
		addHotkey("Node_Pixel_Math", "Operator > Multiply", "M", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[7].setValue(array_find(global.node_math_names, "Multiply")); });
		addHotkey("Node_Pixel_Math", "Operator > Divide",   "D", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[7].setValue(array_find(global.node_math_names, "Divide")); });
		
		addHotkey("Node_Pixel_Math", "Operand Type > Toggle", "O", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[10].setValue(!_n.inputs[10].getValue()); });
	});

	function Node_create_Pixel_Math(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Pixel_Math(_x, _y, _group);
		node.skipDefault();
	
		var ind = array_find(global.node_math_keys, query);
		if(ind != -1) node.inputs[7].setValue(global.node_math_keys_map[ind]);
	
		return node;
	}
#endregion


function Node_Pixel_Math(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Math";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 5, 6, 
	
	_scroll = array_clone(global.node_math_scroll, 1);
	array_append(_scroll, ["Less than", "Less than equal", "Greater than", "Greater than equal"]);
	newInput(7, nodeValue_Enum_Scroll("Operator", self, 0, _scroll));
	
	newInput(8, nodeValue_Vec4("Operand", self, [ 0, 0, 0, 0 ]));
	
	newInput(9, nodeValue_Vec2("Range", self, [ 0, 0 ]));
	
	newInput(10, nodeValue_Enum_Button("Operand Type", self, 0, [ "Vec4", "Surface" ]));
	
	newInput(11, nodeValue_Surface("Operand Surface", self));
	
	newInput(12, nodeValue_Float("Mix", self, .5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 4, 
		["Surfaces",  false], 0, 2, 3, 5, 6, 
		["Operation", false], 7, 10, 8, 9, 12, 11, 
	]
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var type   = _data[7];
		var op4    = _data[8];
		var op2    = _data[9];
		var opType = _data[10];
		var opS    = _data[11];
		var mixAmo = _data[12];
		
		var _oprand = type < array_length(global.node_math_names)? global.node_math_names[type] : _scroll[type];
		setDisplayName(_oprand);
		
		inputs[ 8].setVisible(false);
		inputs[ 9].setVisible(false);
		inputs[11].setVisible(opType, opType);
		inputs[12].setVisible(type == MATH_OPERATOR.lerp);
		
		if(opType == 0) {
			switch(type) {
				case MATH_OPERATOR.add        :
				case MATH_OPERATOR.subtract   :
				case MATH_OPERATOR.multiply   :
				case MATH_OPERATOR.divide     :
				case MATH_OPERATOR.power      :
				case MATH_OPERATOR.root       :
				case MATH_OPERATOR.modulo     :
				case MATH_OPERATOR.snap       :
				case MATH_OPERATOR.length + 1 :
				case MATH_OPERATOR.length + 2 :
					inputs[8].setVisible( true);
					break;
					
				case MATH_OPERATOR.clamp :
					inputs[9].setVisible( true);
					break;
					
			}
		}
		
		surface_set_shader(_outSurf, sh_pixel_math, true, BLEND.over);
			shader_set_i("operator", type);
			
			shader_set_i("operandType", opType );
			shader_set_f("mixAmount",   mixAmo );
			shader_set_surface("operandSurf", opS );
			shader_set_4("operand",  _oprand == "Clamp"? [ op2[0], op2[1], 0, 0]  : op4 );
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}