function Node_3DSurf(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "3DSurf";
	cached_object = [];
	object_class  = dynaSurf_3d;
	
	inputs[| 0] = nodeValue("Scene", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Scene, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Base Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Vertical Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 45 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 1] });
	
	inputs[| 3] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 );
	
	outputs[| 0] = nodeValue("3DSurf", self, JUNCTION_CONNECT.output, VALUE_TYPE.dynaSurface, noone);
	
	input_display_list = [ 0,
		["Camera", false], 1, 2, 3, 
	];
	
	static getObject = function(index, class = object_class) { #region
		var _obj = array_safe_get(cached_object, index, noone);
		if(_obj == noone) {
			_obj = new class();
		} else if(!is_instanceof(_obj, class)) {
			_obj.destroy();
			_obj = new class();
		}
		
		cached_object[index] = _obj;
		return _obj;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _sobj = _data[0];
		var _dim  = _data[1];
		var _vang = _data[2];
		var _dist = _data[3];
		
		if(_sobj == noone) return noone;
		
		var _scn  = getObject(_array_index);
		_scn.object = _sobj;
		_scn.w      = _dim[0];
		_scn.h      = _dim[1];
		
		_scn.camera_ay         = _vang;
		_scn.camera.focus_dist = _dist;
		
		return _scn;
	}
}