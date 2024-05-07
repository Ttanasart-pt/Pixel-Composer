function Node_Atlas_Set(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Atlas Set";
	previewable = true;
	
	inputs[| 0] = nodeValue("Atlas", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
	
	inputs[| 3] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
		
	inputs[| 5] = nodeValue("Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [])
		.setArrayDepth(1);
		
	inputs[| 6] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	inputs[| 7] = nodeValue("Recalculate Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue("Atlas", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		0, 1, 2, 3, 7, 4, 5, 6, 
	];
	
	static update = function(frame = CURRENT_FRAME) {
		var atl = getInputData(0);
		
		if(atl == noone) return;
		
		if(!is_array(atl)) atl = [ atl ];
		if(array_empty(atl)) return;
		
		var surf = getInputData(1);
		var posi = getInputData(2);
		var rota = getInputData(3);
		var scal = getInputData(4);
		var blns = getInputData(5);
		var alph = getInputData(6);
		var _rot = getInputData(7);
		
		var use  = array_create(7);
		for( var i = 1; i < 7; i++ ) use[i] = inputs[| i].value_from != noone;
		
		var n = array_length(atl);
		var natl = array_create(n);
		
		for( var i = 0; i < n; i++ ) {
			var _at = atl[i];
			if(!is_instanceof(_at, SurfaceAtlas)) continue;
			
			natl[i] = _at.clone();
			
			var _surf = _at.surface.get();
			
			if(use[1]) natl[i].setSurface(array_safe_get_fast(surf, i));
			
			if(use[2]) {
				var pos = array_safe_get_fast(posi, i);
				natl[i].x = array_safe_get_fast(pos, 0);
				natl[i].y = array_safe_get_fast(pos, 1);
			}
			
			if(use[3]) {
				var _or = natl[i].rotation;
				var _nr = array_safe_get_fast(rota, i);
				
				natl[i].rotation = _nr;
				
				if(_rot) {
					var _sw = surface_get_width_safe(_surf)  * natl[i].sx;
					var _sh = surface_get_height_safe(_surf) * natl[i].sy;
					
					var p0 = point_rotate(0, 0, _sw / 2, _sh / 2, -_or);
					var p1 = point_rotate(0, 0, _sw / 2, _sh / 2,  _nr);
					
					natl[i].x = natl[i].x - p0[1] + p1[0];
					natl[i].y = natl[i].y - p0[0] + p1[1];
				}
				
			}
			
			if(use[4]) {
				var sca = array_safe_get_fast(scal, i);
				natl[i].sx = array_safe_get_fast(sca, 0, 1);
				natl[i].sy = array_safe_get_fast(sca, 1, 1);
			}
			
			if(use[5]) natl[i].blend    =  array_safe_get_fast(blns, i);
			
			if(use[6]) natl[i].alpha    =  array_safe_get_fast(alph, i);
		}
		
		outputs[| 0].setValue(natl);
	}
}