function Node_Atlas_Set(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Atlas Set";
	previewable = true;
	
	newInput(0, nodeValue_Surface("Atlas", self))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Surface("Surface", self));
	
	newInput(2, nodeValue_Vec2("Position", self, [ 0, 0 ]));
	
	newInput(3, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(4, nodeValue_Vec2("Scale", self, [ 0, 0 ]));
		
	newInput(5, nodeValue_Color("Blend", self, c_white));
		
	newInput(6, nodeValue_Float("Alpha", self, 1));
	
	newInput(7, nodeValue_Bool("Recalculate Position", self, true));
	
	outputs[0] = nodeValue_Output("Atlas", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		0, 1, 2, 3, 7, 4, 5, 6, 
	];
	
	static update = function(frame = CURRENT_FRAME) {
		var atl = getInputData(0);
		
		if(atl == noone) return;
		
		if(!is_array(atl)) atl = [ atl ];
		if(array_empty(atl)) return;
		
		var _rot = getInputData(7);
		
		var use  = array_create(6);
		var len  = array_create(6);
		var val  = array_create(6);
		
		for( var i = 0; i < 7; i++ ) {
			val[i] = getInputData(i);
			len[i] = is_array(val[i])? array_length(val[i]) : 0;
			use[i] = inputs[i].value_from != noone;
		}
		
		var n    = array_length(atl);
		var natl = [];
		var _ind = 0;
		var _at, _newAtl, _surf, _val;
		
		for( var i = 0; i < n; i++ ) {
			_at = atl[i];
			if(!is_instanceof(_at, SurfaceAtlas)) continue;
			
			_newAtl = _at.clone();
			_surf   = _at.surface.get();
			
			if(use[1] && (len[1] == 0 || i < len[1])) {
				_val = len[1] == 0? val[1] : val[1][i];
				
				_newAtl.setSurface(_val);
			}
			
			if(use[2] && (len[2] == 0 || i < len[2])) {
				_val = len[2] == 0? val[2] : val[2][i];
				
				_newAtl.x = array_safe_get_fast(_val, 0);
				_newAtl.y = array_safe_get_fast(_val, 1);
			}
			
			if(use[3] && (len[3] == 0 || i < len[3])) {
				_val = len[3] == 0? val[3] : val[3][i];
				
				var _or = _newAtl.rotation;
				var _nr = _val;
				
				_newAtl.rotation = _nr;
				
				if(_rot) {
					var _sw = surface_get_width_safe(_surf)  * _newAtl.sx;
					var _sh = surface_get_height_safe(_surf) * _newAtl.sy;
					
					var p0 = point_rotate(0, 0, _sw / 2, _sh / 2, -_or);
					var p1 = point_rotate(0, 0, _sw / 2, _sh / 2,  _nr);
					
					_newAtl.x = _newAtl.x - p0[1] + p1[0];
					_newAtl.y = _newAtl.y - p0[0] + p1[1];
				}
				
			}
			
			if(use[4] && (len[4] == 0 || i < len[4])) {
				_val = len[4] == 0? val[4] : val[4][i];
				
				_newAtl.sx = array_safe_get_fast(_val, 0, 1);
				_newAtl.sy = array_safe_get_fast(_val, 1, 1);
			}
			
			if(use[5] && (len[5] == 0 || i < len[5])) {
				_val = len[5] == 0? val[5] : val[5][i];
				
				_newAtl.blend    =  _val;
			}
			
			if(use[6] && (len[6] == 0 || i < len[6])) {
				_val = len[6] == 0? val[6] : val[6][i];
				
				_newAtl.alpha    =  _val;
			}
			
			natl[_ind] = _newAtl;
			_ind++;
		}
		
		array_resize(natl, _ind);
		outputs[0].setValue(natl);
	}
}