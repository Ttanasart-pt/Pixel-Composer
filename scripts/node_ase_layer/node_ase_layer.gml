function Node_ASE_layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE Layer";
	update_on_frame = true;
	previewable = false;
	
	inputs[| 0] = nodeValue("ASE data", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, noone)
		.setVisible(false, true)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Use cel dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	layer_object = noone;
	_name = "";
	
	static onValueFromUpdate = function(index) {
		findLayer();
	}
	
	static findLayer = function() {
		var data = inputs[| 0].getValue();
		if(data == noone) return;
		
		var layer_index = 0;
		layer_object = noone;
		
		for( var i = 0; i < array_length(data.layers); i++ ) {
			if(data.layers[i].name != display_name) continue;
			
			layer_object = data.layers[i];
			break;
		}
	}
	
	static update = function(frame = ANIMATOR.current_frame) { 
		var data = inputs[| 0].getValue();
		if(data == noone) return;
		
		if(_name != display_name) {
			_name = display_name;
			findLayer();
		}
		
		if(layer_object == noone) return;
		var cel = layer_object.getCel(ANIMATOR.current_frame - data._tag_delay);
		
		var celDim = inputs[| 1].getValue();
		var ww = data.content[? "Width"];
		var hh = data.content[? "Height"];
		var cw = cel? cel.data[? "Width"] : 1;
		var ch = cel? cel.data[? "Height"] : 1;
		
		var surf = outputs[| 0].getValue();
		if(celDim)	surf = surface_verify(surf, cw, ch);
		else		surf = surface_verify(surf, ww, hh);
		outputs[| 0].setValue(surf);
		
		if(cel == 0) {
			surface_set_target(surf);
			DRAW_CLEAR
			surface_reset_target();
			return;
		}
		
		var _inSurf = cel.getSurface();
		
		var xx = celDim? 0 : cel.data[? "X"];
		var yy = celDim? 0 : cel.data[? "Y"];
		
		surface_set_target(surf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		draw_surface_safe(_inSurf, xx, yy);
		BLEND_NORMAL;
		surface_reset_target();
	}
}