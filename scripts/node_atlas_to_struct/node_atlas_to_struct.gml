function Node_Atlas_Struct(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Atlas to Struct";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Surface("Atlas", self))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Struct", self, VALUE_TYPE.struct, []))
		.setArrayDepth(1);
		
	static update = function(frame = CURRENT_FRAME) {
		var atl = getInputData(0);
		
		if(atl == noone) return;
		
		if(!is_array(atl)) atl = [ atl ];
		if(array_empty(atl)) return;
		
		var n   = array_length(atl);
		var str = [];
		var ind = 0;
		
		for( var i = 0; i < n; i++ ) {
			var _at = atl[i];
			if(!is_instanceof(_at, SurfaceAtlas)) continue;
			
			str[ind++] = {
				surface:  _at.surface,
				size:     surface_get_dimension(_at.getSurface()),
				position: [ _at.x, _at.y ],
				rotation: _at.rotation,
				scale:    [ _at.sx, _at.sy ],
				blend:    _at.blend,
				alpha:    _at.alpha,
			}
		}
		
		outputs[0].setValue(str);
	}
}