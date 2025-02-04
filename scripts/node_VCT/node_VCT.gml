function Node_VCT(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "VCT";
	icon   = THEME.vct;
	color  = COLORS.node_blend_vct;
	vct    = new VCT(self);
	
	newInput(0, nodeValue_Int("Editor", self, 0))
		.setDisplay(VALUE_DISPLAY.button, { name: "Editor", onClick: function() {
			vct.createDialog();
		} });
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
		
	input_display_list = [ 0, 
		["Automations", false], 
	];

	static createNewInput = function(key = "") {
		var index = array_length(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		var name  = string_title(string_replace_all(key, "_", " "));
		
		var _var  = vct[$ key];
		
		newInput(index, nodeValue(name, self, CONNECT_TYPE.input, _var.type, 0))
			.setDisplay(_var.disp, _var.disp_data);
		inputs[index].attributes.key = key;
		
		array_append(input_display_list, [ index ]);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		for( var i = 1; i < array_length(_data); i++ )
			vct[$ inputs[i].attributes.key].setDirect(_data[i]);
			
		var params = {
			frame: CURRENT_FRAME
		};
		
		return vct.process(params);
	}
	
	static onDoubleClick = function(panel) {
		vct.createDialog();
	}
	
	static doSerialize = function(_map) {
		_map.vct = vct.serialize();
	}
	
	static postDeserialize = function() {
		vct.deserialize(load_map.vct);
	}
}