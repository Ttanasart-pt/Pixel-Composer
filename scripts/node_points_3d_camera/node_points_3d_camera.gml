#region
	FN_NODE_TOOL_INVOKE {
		
	});
#endregion

function Node_Point_3D_Camera(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Point Camera";
	
	object   = new __3dCamera_object();
	camera   = new __3dCamera();
	lookat   = new __3dGizmoSphere(.5, c_ltgray, .5);
	lookLine = noone;
	lookRad  = new __3dGizmoCircleZ(.5, c_yellow, .5);
	
	w = 128;
	var i = in_d3d;
	
	setDimension(96, 48);
	
	newInput(i+ 2, nodeValue_Vec3( "Points" )).setVisible(true, true).setArrayDepth(1);
	newInput(i+10, nodeValue_Dimension());
	
	////- =Transform
	
	newInput(i+ 4, nodeValue_Enum_Scroll( "Postioning Mode",  2, [ "Position + Rotation", "Position + Lookat", "Lookat + Rotation" ] ));
	newInput(i+ 5, nodeValue_Vec3(        "Lookat Position", [0,0,0]           ));
	newInput(i+ 6, nodeValue_Rotation(    "Roll",             0                ));
	newInput(i+ 7, nodeValue_Rotation(    "Horizontal Angle", 45               ));
	newInput(i+ 8, nodeValue_Slider(      "Vertical Angle",   30, [0, 90, 0.1] ));
	newInput(i+ 9, nodeValue_Float(       "Distance",         4                ));
	
	////- =Camera
	
	newInput(i+ 1, nodeValue_Enum_Button( "Projection",          1 , [ "Perspective", "Orthographic" ]));
	newInput(i+ 0, nodeValue_ISlider(     "FOV",                 60, [  10, 90, .1  ] ));
	newInput(i+ 3, nodeValue_Slider(      "Orthographic Scale", .5,  [ .01,  4, .01 ] ));
	
	////- =Remap Range
	
	newInput(i+13, nodeValue_Vec2( "Range From",  [0,1] ));
	newInput(i+14, nodeValue_Vec2( "Range To",    [0,1] ));
	newInput(i+11, nodeValue_Vec2( "Depth From",  [0,1] ));
	newInput(i+12, nodeValue_Vec2( "Depth To",    [0,1] ));
	
	// input i+16
	
	in_cam = array_length(inputs);
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [ 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(1);
	
	input_display_list = [ i+2, i+10,
		["Transform",   false], i+4, 0, 1, i+5, i+6, i+7, i+8, i+9, 
		["Camera",      false], i+1, i+0, i+3, 
		["Remap Range", false], i+13, i+14, i+11, i+12,
	];
	
	tool_lookat  = new NodeTool( "Move Target", THEME.tools_3d_transform_object );
	
	////- Preview
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {

		if(inputs[in_d3d + 2].value_from) {
			var _nodeFrom = inputs[in_d3d + 2].value_from.node;
			if(struct_has(_nodeFrom, "drawOverlay3D"))
				_nodeFrom.drawOverlay3D(active, _mx, _my, _snx, _sny, _params);
		}
		
		var preObj = getPreviewObjects();
		if(array_empty(preObj)) return;
		preObj = preObj[0];
		
		var _pos  = inputs[0].getValue(,,, true);
		var _vpos = new __vec3( _pos[0], _pos[1], _pos[2] );
		
		if(isUsingTool("Transform"))	tool_pos_object.drawOverlay3D(0, preObj, _vpos, active, _mx, _my, _snx, _sny, _params);
		else if(isUsingTool("Rotate"))	tool_object_rot.drawOverlay3D(1, preObj, _vpos, active, _mx, _my, _snx, _sny, _params);
		else if(isUsingTool("Move Target")) {
			var _lkpos  = inputs[in_d3d + 5].getValue(,,, true);
			var _lkvpos = new __vec3( _lkpos[0], _lkpos[1], _lkpos[2] );
			
			tool_pos_object.drawOverlay3D(in_d3d + 5, noone, _lkvpos, active, _mx, _my, _snx, _sny, _params);
		}
		
		if(drag_axis != noone && mouse_release(mb_left)) {
			drag_axis = noone;
			UNDO_HOLDING = false;
		}
	}
	
	static onValueUpdate = function(index) { if(index == in_d3d + 4) PANEL_PREVIEW.tool_current = noone; }
	
	static preProcessData = function(_data) /*=>*/ {}
	static submitShadow   = function() /*=>*/ {}
	static submitShader   = function() /*=>*/ {}
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var _pnts = _data[in_d3d + 2];
			var _scal = _data[in_d3d +10];
			
			var _posm = _data[in_d3d + 4];
			var _pos  = _data[0];
			var _rot  = _data[1];
			var _look = _data[in_d3d + 5];
			var _roll = _data[in_d3d + 6];
			var _hAng = _data[in_d3d + 7];
			var _vAng = _data[in_d3d + 8];
			var _dist = _data[in_d3d + 9];
			
			var _proj = _data[in_d3d + 1];
			var _fov  = _data[in_d3d + 0];
			var _orts = _data[in_d3d + 3];
		    
			var _rngF = _data[in_d3d +13];
			var _rngT = _data[in_d3d +14];
			
			var _depF = _data[in_d3d +11];
			var _depT = _data[in_d3d +12];
			
			inputs[in_d3d + 0].setVisible(_proj == 0);
			inputs[in_d3d + 3].setVisible(_proj == 1);
			
			inputs[0].setVisible(_posm == 0 || _posm == 1);
			inputs[1].setVisible(_posm == 0);
			inputs[in_d3d + 5].setVisible(_posm == 1 || _posm == 2);
			inputs[in_d3d + 6].setVisible(_posm == 1);
			inputs[in_d3d + 7].setVisible(_posm == 2);
			inputs[in_d3d + 8].setVisible(_posm == 2);
			inputs[in_d3d + 9].setVisible(_posm == 2);
			
			switch(_posm) {
				case 0 : 
					tools = [ tool_pos, tool_rot ]; 
					break;
					
				case 1 : 
					tools = [ tool_pos, tool_lookat ]; 
					tool_attribute.context = 1;
					break;
					
				case 2 : 
					tools = [ tool_lookat ]; 
					tool_attribute.context = 1;
					break;
			}
			
			var _qi1  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1, 0),  90);
			var _qi2  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -90);
			var _qi3  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0),  90);
		#endregion
		
		switch(_posm) { // ++++ camera positioning ++++
			case 0 :
				camera.useFocus = false;
				camera.position.set(_pos);
				camera.rotation.set(_rot[0], _rot[1], _rot[2], _rot[3]);
				break;
				
			case 1 :
				camera.useFocus = true;
				camera.position.set(_pos);
				camera.focus.set(_look);
				camera.up.set(0, 0, -1);
				
				var _for = camera.focus.subtract(camera.position);
				if(!_for.isZero()) camera.rotation = new BBMOD_Quaternion().FromLookRotation(_for, camera.up).Mul(_qi1).Mul(_qi2);
					
				lookat.transform.position.set(_look);
				lookat.transform.applyMatrix();
				lookLine = new __3dGizmoLineDashed(camera.position, camera.focus, 0.25, c_gray, 1);
				break;
				
			case 2 :
				camera.useFocus = true;
				camera.focus.set(_look);
				camera.setFocusAngle(_hAng, _vAng, _dist);
				camera.setCameraLookRotate();
				camera.up = camera.getUp()._multiply(-1);
				
				var _for = camera.focus.subtract(camera.position);
				if(!_for.isZero()) camera.rotation = new BBMOD_Quaternion().FromLookRotation(_for, camera.up.multiply(-1)).Mul(_qi1).Mul(_qi3);
				
				lookat.transform.position.set(_look);
				lookat.transform.applyMatrix();
				lookLine = new __3dGizmoLineDashed(camera.position, camera.focus, 0.25, c_gray, 1);
				
				var _camRad = camera.position.subtract(camera.focus);
				var _rad = point_distance(0, 0, _camRad.x, _camRad.y) * 2;
				lookRad.transform.scale.set(_rad, _rad, 1);
				lookRad.transform.position.set(new __vec3(camera.focus.x, camera.focus.y, camera.position.z));
				lookRad.transform.applyMatrix();
				break;
		}
		
		#region camera view project
			object.transform.position.set(camera.position);
			object.transform.rotation = camera.rotation.Clone();
			object.transform.applyMatrix();
			
			camera.projection = _proj;
			camera.setViewFov(_fov, _depF[0], _depF[1]);
			
			if(_proj == 0)		camera.setViewSize(_scal[0], _scal[1]);
			else if(_proj == 1) camera.setViewSize(1 / _orts, _scal[0] / _scal[1] / _orts);
			
			camera.setMatrix();
		#endregion
		
		var _amo    = array_length(_pnts);
		var _points = array_create(_amo);
		var _p      = new __vec3();
		
		var _rngFs  = _rngF[1] - _rngF[0];
		var _depFs  = _depF[1] - _depF[0];
		
		for( var i = 0; i < _amo; i++ ) {
			var _point = _pnts[i];
			if(!is_array(_point)) continue;
			
			_p.x = _point[0];
			_p.y = _point[1];
			_p.z = _point[2];
			
			var _v = camera.worldPointToViewPoint(_p);
			
			var _x = lerp(_rngT[0], _rngT[1], (_v.x - _rngF[0]) / _rngFs);
			var _y = lerp(_rngT[0], _rngT[1], (_v.y - _rngF[0]) / _rngFs);
			var _z = lerp(_depT[0], _depT[1], (_v.z - _depF[0]) / _depFs);
			
			_points[i] = [ _x, _y, _z ];
		}
		
		return _points;
	}
	
	////- Draw
	
	static getGraphPreviewSurface = function() { return noone; }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_path_3d_camera, 0, bbox);
	}
	
	static getPreviewObject = function() { return noone; }
	
	static getPreviewObjects = function() { 
		var _posm = getSingleValue(in_d3d + 4);
		switch(_posm) {
			case 0 : return [ object ];
			case 1 : return [ object, lookat, lookLine ];
			case 2 : return [ object, lookat, lookLine, lookRad ];
		}
		
		return [ object ]; 
	}
	
	static getPreviewObjectOutline = function() { return isUsingTool("Move Target")? [ lookat ] : [ object ]; }
	
}