function Node_ASE_layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE Layer";
	
	newInput(0, nodeValue("ASE data", self, CONNECT_TYPE.input, VALUE_TYPE.object, noone))
		.setIcon(s_junc_aseprite, c_white)
		.setVisible(false, true)
		.rejectArray();
	
	newInput(1, nodeValue_Bool("Crop Output", self, false))
		.rejectArray();
	
	newInput(2, nodeValue_Text("Layer name", self, ""))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Layer name", self, VALUE_TYPE.text, ""));
	
	input_display_list = [
		0, 2, 1, 
	];
	
	layer_object = noone;
	_name = "";
	
	static onValueFromUpdate = function(index) { findLayer(); }
	
	static findLayer = function() {
		layer_object = noone;
		
		var data = getInputDataForce(0);
		if(data == noone) return;
		
		var name = getInputData(2);
		setDisplayName(name);
		
		for( var i = 0, n = array_length(data.layers); i < n; i++ ) {
			if(data.layers[i].name == name) 
				layer_object = data.layers[i];
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		findLayer();
		if(layer_object == noone) return;
		
		var data = getInputData(0);
		var cel  = layer_object.getCel(CURRENT_FRAME - data._tag_delay);
		
		var celDim = getInputData(1);
		var name   = getInputData(2);
		
		var ww = data.content[$ "Width"];
		var hh = data.content[$ "Height"];
		var cw = cel? cel.data[$ "Width"]  : 1;
		var ch = cel? cel.data[$ "Height"] : 1;
		
		var surf = outputs[0].getValue();
		if(celDim)	surf = surface_verify(surf, cw, ch);
		else		surf = surface_verify(surf, ww, hh);
		outputs[0].setValue(surf);
		outputs[1].setValue(name);
		
		if(cel == 0) { surface_clear(surf); return; }
		
		var _inSurf = cel.getSurface();
		var xx = celDim? 0 : cel.data[$ "X"];
		var yy = celDim? 0 : cel.data[$ "Y"];
		
		surface_set_shader(surf, noone);
			draw_surface_safe(_inSurf, xx, yy);
		surface_reset_shader();
	}
}