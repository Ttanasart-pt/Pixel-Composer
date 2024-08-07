function Node_Atlas_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Atlas Get";
	previewable = true;
	
	inputs[| 0] = nodeValue_Surface("Atlas", self)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue_Output("Surface", self, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	outputs[| 1] = nodeValue_Output("Position", self, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
	
	outputs[| 2] = nodeValue_Output("Rotation", self, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	outputs[| 3] = nodeValue_Output("Scale", self, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
		
	outputs[| 4] = nodeValue_Output("Blend", self, VALUE_TYPE.color, [])
		.setArrayDepth(1);
		
	outputs[| 5] = nodeValue_Output("Alpha", self, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	static update = function(frame = CURRENT_FRAME) {
		var atl = getInputData(0);
		
		if(atl == noone) return;
		
		if(!is_array(atl)) atl = [ atl ];
		if(array_empty(atl)) return;
		
		var n = array_length(atl);
		var surf = array_create(n);
		var posi = array_create(n);
		var rota = array_create(n);
		var scal = array_create(n);
		var blns = array_create(n);
		var alph = array_create(n);
		
		for( var i = 0; i < n; i++ ) {
			var _at = atl[i];
			if(!is_instanceof(_at, SurfaceAtlas)) continue;
			
			surf[i] = _at.getSurface();
			posi[i] = [ _at.x, _at.y ];
			rota[i] = _at.rotation;
			scal[i] = [ _at.sx, _at.sy ];
			blns[i] = _at.blend;
			alph[i] = _at.alpha;
		}
		
		outputs[| 0].setValue(surf);
		outputs[| 1].setValue(posi);
		outputs[| 2].setValue(rota);
		outputs[| 3].setValue(scal);
		outputs[| 4].setValue(blns);
		outputs[| 5].setValue(alph);
	}
}