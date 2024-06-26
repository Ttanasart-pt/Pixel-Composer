function Node_3D_Mesh_Path_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "Path Extrude";
	
	object_class = __3dPathExtrude;
	
	inputs[| in_mesh + 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone )
		.setVisible(true, true);
	
	inputs[| in_mesh + 1] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8 )
		.setValidator(VV_min(2));
	
	inputs[| in_mesh + 2] = nodeValue("Material Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 3] = nodeValue("Material Cap", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 4] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_mesh + 5] = nodeValue("End caps", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| in_mesh + 6] = nodeValue("Subdivision", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8 )
		.setValidator(VV_min(2));
	
	inputs[| in_mesh + 7] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.25 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| in_mesh + 8] = nodeValue("Radius Over Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| in_mesh + 9] = nodeValue("Texture Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 6, in_mesh + 1, in_mesh + 7, in_mesh + 8, in_mesh + 5, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 4, in_mesh + 2, in_mesh + 3, in_mesh + 9, 
	]
	
	static step = function() { #region
		var _caps = getInputData(in_mesh + 5);
		
		inputs[| in_mesh + 3].setVisible(_caps, _caps);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _path    = _data[in_mesh + 0];
		var _sides   = _data[in_mesh + 1];
		var _mat_sid = _data[in_mesh + 2];
		var _mat_cap = _data[in_mesh + 3];
		var _smt     = _data[in_mesh + 4];
		var _caps    = _data[in_mesh + 5];
		var _samp    = _data[in_mesh + 6];
		var _rad     = _data[in_mesh + 7];
		var _radOv   = _data[in_mesh + 8];
		var _uvScale = _data[in_mesh + 9];
		
		if(_path == noone) return noone;
		
		var _points  = array_create(_samp * 3);
		var _radPath = array_create(_samp);
		var _uvProg  = array_create(_samp);
		
		var _stp = 1 / (_samp - 1);
		var _p = new __vec3();
		var _distTotal = 0;
		
		for(var i = 0; i < _samp; i++) {
			var _prg = _stp * i;
			_p = _path.getPointRatio(_prg, 0, _p);
			
			_points[i * 3 + 0] = _p.x;
			_points[i * 3 + 1] = _p.y;
			_points[i * 3 + 2] = _p.z;
			
			_radPath[i] = eval_curve_x(_radOv, _prg);
			
			if(i) {
				var _d = point_distance_3d(_points[i * 3 - 3 + 0], _points[i * 3 - 3 + 1], _points[i * 3 - 3 + 2], 
				                           _points[i * 3 + 0], _points[i * 3 + 1], _points[i * 3 + 2]);
				_distTotal += _d;
				_uvProg[i]  = _distTotal;
			}
		}
		
		for (var i = 0; i < _samp; i++) 
			_uvProg[i] /= _distTotal;
		_uvProg[_samp] = 1;
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			sides  : _sides, 
			endCap : _caps,
			smooth : _smt, 
			points : _points, 
			radius : _rad, 
			radiusOverPath: _radPath, 
			
			uvProg  : _uvProg, 
			uvScale : _uvScale,
		});
		
		object.materials = _caps? [ _mat_sid, _mat_cap, _mat_cap ] : [ _mat_sid ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 2, noone); }
}