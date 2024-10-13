function Node_Pixel_Math(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Math";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 5, 6, 
	
	oprList = [ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", "Sin", "Cos", "Tan", "Modulo", 
				"Floor", "Ceil", "Round", "Abs", "Clamp" ];
	newInput(7, nodeValue_Enum_Scroll("Operator", self, 0, oprList));
	
	newInput(8, nodeValue_Vec4("Operand", self, [ 0, 0, 0, 0 ]));
	
	newInput(9, nodeValue_Vec2("Range", self, [ 0, 0 ]));
	
	newInput(10, nodeValue_Enum_Button("Operand type", self, 0, [ "Vec4", "Surface" ]));
	
	newInput(11, nodeValue_Surface("Mask", self));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 4, 
		["Surfaces",  false], 0, 2, 3, 5, 6, 
		["Operation", false], 7, 10, 8, 9, 11, 
	]
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var type = _data[7];
		var op4  = _data[8];
		var op2  = _data[9];
		var opType = _data[10];
		var opS    = _data[11];
		
		var _oprand = oprList[type];
		setDisplayName(_oprand);
		
		if(opType == 0) {
			switch(_oprand) {
				case "Add" :
				case "Subtract" :
				case "Multiply" :
				case "Divide" :
				case "Power" :
				case "Root" :
				case "Modulo" :
					inputs[8].setVisible( true);
					inputs[9].setVisible(false);
					break;
					
				case "Sin" :
				case "Cos" :
				case "Tan" :
				
				case "Floor" :
				case "Ceil" :
				case "Round" :
				case "Abs" :
					inputs[8].setVisible(false);
					inputs[9].setVisible(false);
					break;
					
				case "Clamp" :
					inputs[8].setVisible(false);
					inputs[9].setVisible( true);
					break;
					
			}
			
			inputs[11].setVisible(false, false);
			
		} else {
			inputs[ 8].setVisible(false);
			inputs[ 9].setVisible(false);
			inputs[11].setVisible(true, true);
		}
		
		surface_set_shader(_outSurf, sh_pixel_math);
			shader_set_i("operator", type);
			
			shader_set_i("operandType", opType );
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