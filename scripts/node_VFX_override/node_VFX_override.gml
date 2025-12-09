function Node_VFX_Override(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "VFX Override";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	setDrawIcon(s_node_vfx_override);
	
	manual_ungroupable = false;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Particle())
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool(  "Set Positions", false ));
	newInput(2, nodeValue_Enum_Button( "Mode", 0, [ "Absolute", "Relative" ])).setInternalName("Position mode");
	newInput(3, nodeValue_Vec2(  "Positions", [0, 0] ));
	
	newInput(4, nodeValue_Bool(  "Set Rotations", false ));
	newInput(5, nodeValue_Enum_Button( "Mode", 0, [ "Absolute", "Relative" ])).setInternalName("Rotation mode");
	newInput(6, nodeValue_Float(  "Rotations", 0 ));
	
	newInput(7, nodeValue_Bool(  "Set Scales", false ));
	newInput(8, nodeValue_Enum_Button( "Mode", 0, [ "Absolute", "Relative Add", "Relative Muliply" ])).setInternalName("Scale mode");
	newInput(9, nodeValue_Vec2(  "Scales", [1, 1] ));
	
	newInput(10, nodeValue_Bool( "Set Blend", false ));
	newInput(11, nodeValue_Color( "Blend", ca_black ));
	
	newInput(12, nodeValue_Bool(  "Set Alpha", false ));
	newInput(13, nodeValue_Enum_Button( "Mode", 0, [ "Absolute", "Relative" ])).setInternalName("Alpha mode");
	newInput(14, nodeValue_Float(  "Alpha", 0 ));
	
	newInput(15, nodeValue_Bool( "Set Surface", false ));
	newInput(16, nodeValue_Surface( "Surface")).setVisible(true, false);
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 0, 
		["Surface",  false, 15], 16, 
		["Position", false,  1], 2, 3, 
		["Rotation", false,  4], 5, 6, 
		["Scale",    false,  7], 8, 9, 
		["Blend",    false, 10], 11, 
		["Alpha",    false, 12], 13, 14, 
	]
	
	_self = self;
	parts = [];
	
	static update = function(frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		if(!is_array(_parts)) return;
		
		var _len   = array_length(_parts);
		    parts  = array_verify_ext(parts, max(array_length(parts), _len), function() /*=>*/ {return new __part(_self)});
		var nParts = array_verify(outputs[0].getValue(), _len);
		for( var i = 0; i < _len; i++ ) nParts[i] = parts[i].set(_parts[i]);
		
		if(getInputData(15)) { // surface
			var _surfs = getInputData(16);
			if(is_array(_surfs)) {
				var _llen = min(_len, array_length(_surfs));
				for( var i = 0; i < _llen; i++ ) nParts[i].surf = _surfs[i];
					
			} else if(is_surface(_surfs)) {
				for( var i = 0; i < _len; i++ ) nParts[i].surf = _surfs;
			}
		}
		
		if(getInputData(1)) { // positions
			var _mode = getInputData(2);
			var _posi = getInputData(3);
			var _d    = array_get_depth(_posi);
			
			if(_d == 2) {
				var _llen = min(_len, array_length(_posi));
				     if(_mode == 0) for( var i = 0; i < _llen; i++ ) { nParts[i].x  = _posi[i][0]; nParts[i].y  = _posi[i][1]; }
				else if(_mode == 1) for( var i = 0; i < _llen; i++ ) { nParts[i].x += _posi[i][0]; nParts[i].y += _posi[i][1]; }
					
			} else if(_d == 1) {
				     if(_mode == 0) for( var i = 0; i < _len; i++ ) { nParts[i].x  = _posi[0]; nParts[i].y  = _posi[1]; }
				else if(_mode == 1) for( var i = 0; i < _len; i++ ) { nParts[i].x += _posi[0]; nParts[i].y += _posi[1]; }
			}
			
		}
		
		if(getInputData(4)) { // rotation
			var _mode = getInputData(5);
			var _rots = getInputData(6);
			
			if(is_array(_rots)) {
				var _llen = min(_len, array_length(_rots));
				     if(_mode == 0) for( var i = 0; i < _llen; i++ ) { nParts[i].rot  = _rots[i]; }
				else if(_mode == 1) for( var i = 0; i < _llen; i++ ) { nParts[i].rot += _rots[i]; }
					
			} else {
				     if(_mode == 0) for( var i = 0; i < _len; i++ ) { nParts[i].rot  = _rots; }
				else if(_mode == 1) for( var i = 0; i < _len; i++ ) { nParts[i].rot += _rots; }
			}
		}
		
		if(getInputData(7)) { // scale
			var _mode = getInputData(8);
			var _scas = getInputData(9);
			var _d    = array_get_depth(_scas);
			
			if(_d == 2) {
				var _llen = min(_len, array_length(_scas));
				     if(_mode == 0) for( var i = 0; i < _llen; i++ ) { nParts[i].scx  = _scas[i][0]; nParts[i].scy  = _scas[i][1]; }
				else if(_mode == 1) for( var i = 0; i < _llen; i++ ) { nParts[i].scx += _scas[i][0]; nParts[i].scy += _scas[i][1]; }
				else if(_mode == 2) for( var i = 0; i < _llen; i++ ) { nParts[i].scx *= _scas[i][0]; nParts[i].scy *= _scas[i][1]; }
					
			} else if(_d == 1) {
				     if(_mode == 0) for( var i = 0; i < _len; i++ ) { nParts[i].scx  = _scas[0]; nParts[i].scy  = _scas[1]; }
				else if(_mode == 1) for( var i = 0; i < _len; i++ ) { nParts[i].scx += _scas[0]; nParts[i].scy += _scas[1]; }
				else if(_mode == 2) for( var i = 0; i < _len; i++ ) { nParts[i].scx *= _scas[0]; nParts[i].scy *= _scas[1]; }
			}
		}
		
		if(getInputData(10)) { // blend
			var _blns = getInputData(11);
			
			if(is_array(_blns)) {
				var _llen = min(_len, array_length(_blns));
				for( var i = 0; i < _llen; i++ ) { nParts[i].blend = _blns[i]; }
					
			} else {
				for( var i = 0; i < _len; i++ ) { nParts[i].blend = _blns; }
			}
		}
		
		if(getInputData(12)) { // alpha
			var _mode = getInputData(13);
			var _alps = getInputData(14);
			
			if(is_array(_alps)) {
				var _llen = min(_len, array_length(_alps));
				     if(_mode == 0) for( var i = 0; i < _llen; i++ ) { nParts[i].alp  = _alps[i]; }
				else if(_mode == 1) for( var i = 0; i < _llen; i++ ) { nParts[i].alp += _alps[i]; }
					
			} else {
				     if(_mode == 0) for( var i = 0; i < _len; i++ ) { nParts[i].alp  = _alps; }
				else if(_mode == 1) for( var i = 0; i < _len; i++ ) { nParts[i].alp += _alps; }
			}
		}
		
		for( var i = 0; i < _len; i++ ) parts[i].setDrawParameter();
		outputs[0].setValue(nParts);
	}
	
	static getPreviewingNode = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self; }
	static getPreviewValues  = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self; }
}