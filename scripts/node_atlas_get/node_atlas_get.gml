function Node_Atlas_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Atlas Get";
	previewable = true;
	
	inputs[| 0] = nodeValue("Atlas", self, JUNCTION_CONNECT.input, VALUE_TYPE.atlas, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	outputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
	
	outputs[| 2] = nodeValue("Rotation", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	outputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
		
	outputs[| 4] = nodeValue("Blend", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setArrayDepth(1);
		
	outputs[| 5] = nodeValue("Alpha", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var atl = inputs[| 0].getValue();
		
		if(atl == noone) return;
		if(is_array(atl) && array_length(atl) == 0) return;
		
		if(!is_array(atl))
			atl = [ atl ];
		
		var surf = [];
		var posi = [];
		var rota = [];
		var scal = [];
		var blns = [];
		var alph = [];
		
		for( var i = 0; i < array_length(atl); i++ ) {
			surf[i] = atl[i].surface.get();
			posi[i] = atl[i].position;
			rota[i] = atl[i].rotation;
			scal[i] = atl[i].scale;
			blns[i] = atl[i].blend;
			alph[i] = atl[i].alpha;
		}
		
		outputs[| 0].setValue(surf);
		outputs[| 1].setValue(posi);
		outputs[| 2].setValue(rota);
		outputs[| 3].setValue(scal);
		outputs[| 4].setValue(blns);
		outputs[| 5].setValue(alph);
	}
}