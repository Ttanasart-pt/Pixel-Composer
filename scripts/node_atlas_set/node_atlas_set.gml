function Node_Atlas_Set(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Atlas Set";
	previewable = true;
	dimension_index = -1;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Atlas("Atlas", self))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Set Surface", self, false));
	newInput(2, nodeValue_Surface("Surface", self));
	
	newInput(3, nodeValue_Bool("Set Position", self, false));
	newInput(4, nodeValue_Enum_Button("Mode", self, 0, [ "Absolute", "Relative" ])).setInternalName("Position mode");
	newInput(5, nodeValue_Vec2("Position", self, [ 0, 0 ]));
	
	newInput(6, nodeValue_Bool("Set Rotation", self, false));
	newInput(7, nodeValue_Enum_Button("Mode", self, 0, [ "Absolute", "Relative" ])).setInternalName("Rotation mode");
	newInput(8, nodeValue_Rotation("Rotation", self, 0));
	newInput(9, nodeValue_Bool("Recalculate Position", self, true));
	
	newInput(10, nodeValue_Bool("Set Scale", self, false));
	newInput(11, nodeValue_Enum_Button("Mode", self, 0, [ "Absolute", "Additive", "Multiplicative" ])).setInternalName("Scale mode");
	newInput(12, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
		
	newInput(13, nodeValue_Bool("Set Blending", self, false));
	newInput(14, nodeValue_Enum_Button("Mode", self, 0, [ "Absolute", "Multiplicative" ])).setInternalName("Blend mode");
	newInput(15, nodeValue_Color("Blend", self, ca_white));
		
	newInput(16, nodeValue_Bool("Set Alpha", self, false));
	newInput(17, nodeValue_Enum_Button("Mode", self, 0, [ "Absolute", "Additive", "Multiplicative" ])).setInternalName("Alpha mode");
	newInput(18, nodeValue_Float("Alpha", self, 1));
	
	newInput(19, nodeValue_Vec2("Anchor", self, [ 0.5, 0.5 ]));
		inputs[19].setDisplay(VALUE_DISPLAY.vector, { side_button : new buttonAnchor(inputs[19]) });
		
	newOutput(0, nodeValue_Output("Atlas", self, VALUE_TYPE.atlas, noone));
	
	input_display_list = [ 0, 
		[ "Surface",  false,  1], 2, 
		[ "Position", false,  3], 4, 5, 
		[ "Rotation", false,  6], 7, 8, 9, 
		[ "Scale",    false, 10], 11, 12, 19, 
		[ "Blend",    false, 13], 14, 15, 
		[ "Alpha",    false, 16], 17, 18, 
	];
	
	__p0 = [ 0, 0 ];
	__p1 = [ 0, 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var atl = _data[0];
		if(!is(atl, Atlas)) return _outData;
		
		var natl = [];
		
		var _newAtl = atl.clone();
		var _surf   = atl.surface.get();
		var _dim    = surface_get_dimension(_surf);
		
		if(_data[1]) _newAtl.setSurface(_data[2]);
		
		if(_data[3]) {
			var _pmode = _data[4];
			var _pos   = _data[5];
			
			_newAtl.x = _pmode? _newAtl.x + _pos[0] : _pos[0];
			_newAtl.y = _pmode? _newAtl.y + _pos[1] : _pos[1];
		}
		
		if(_data[6]) {
			var _rmode = _data[7];
			var _or    = _newAtl.rotation;
			var _nr    = _rmode? _or + _data[8] : _data[8];
			
			_newAtl.rotation = _nr;
			
			if(_data[9]) {
				var _sw = _dim[0] * _newAtl.sx;
				var _sh = _dim[1] * _newAtl.sy;
				
				var p0 = point_rotate(0, 0, _sw / 2, _sh / 2, -_or, __p0);
				var p1 = point_rotate(0, 0, _sw / 2, _sh / 2,  _nr, __p1);
				
				_newAtl.x = _newAtl.x - p0[1] + p1[0];
				_newAtl.y = _newAtl.y - p0[0] + p1[1];
			}
			
		}
		
		if(_data[10]) {
			var _smode = _data[11];
			var _sca   = _data[12];
			var _anc   = _data[19];
			
			var _ox = _newAtl.sx;
			var _oy = _newAtl.sy;
			
			switch(_smode) {
				case 0 : 
					_newAtl.sx = _sca[0];
					_newAtl.sy = _sca[1];
					break;
				
				case 1 : 
					_newAtl.sx += _sca[0];
					_newAtl.sy += _sca[1];
					break;
				
				case 2 : 
					_newAtl.sx *= _sca[0];
					_newAtl.sy *= _sca[1];
					break;
			}
			
			_newAtl.x -= (_newAtl.sx - _ox) * _dim[0] * _anc[0];
			_newAtl.y -= (_newAtl.sy - _oy) * _dim[1] * _anc[1];
		}
		
		if(_data[13]) {
			var _bmode = _data[14];
			var _blend = _data[15];
			
			_newAtl.blend =  _bmode? colorMultiply(_newAtl.blend, _blend) : _blend;
		}
		
		if(_data[16]) {
			var _amode = _data[17];
			var _alp   = _data[18];
			
			switch(_amode) {
				case 0 : _newAtl.alpha  = _alp; break;
				case 1 : _newAtl.alpha += _alp; break;
				case 2 : _newAtl.alpha *= _alp; break;
			}
		}
		
		
		return _newAtl;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_atlas_set, 0, bbox);
	}
}