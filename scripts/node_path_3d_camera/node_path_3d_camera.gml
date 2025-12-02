#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Path_3D_Camera", "Move Target", "T");
	});
#endregion

function Node_Path_3D_Camera(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Path Camera";
	setDrawIcon(s_node_path_3d_camera);
	
	object   = new __3dCamera_object();
	camera   = new __3dCamera();
	lookat   = new __3dGizmoSphere(.5, c_ltgray, .5);
	lookLine = noone;
	lookRad  = new __3dGizmoCircleZ(.5, c_yellow, .5);
	
	w = 128;
	var i = in_d3d;
	
	setDimension(96, 48);
	
	newInput(i+ 2, nodeValue_PathNode( "Path" ));
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
	
	////- =Output
	
	newInput(i+11, nodeValue_Bool( "Apply depth to weight", false    ));
	newInput(i+12, nodeValue_Vec2( "Depth range",           [.1,100] ));
	
	// input i+13
	
	in_cam = array_length(inputs);
	
	newOutput(0, nodeValue_Output("Rendered", VALUE_TYPE.pathnode, self ));
	
	input_display_list = [ i+2, i+10,
		["Transform", false], i+4, 0, 1, i+5, i+6, i+7, i+8, i+9, 
		["Camera",    false], i+1, i+0, i+3, 
		["Output",    false], i+11, i+12,
	];
	
	tool_lookat  = new NodeTool( "Move Target", THEME.tools_3d_transform_object );
	
	#region current data
		cached_pos = ds_map_create();
	
		curr_pos  = noone;
		curr_rot  = noone;
		
		curr_fov  = noone;
		curr_proj = noone;
		curr_path = noone;
		curr_orts = noone;
	    
		curr_posm = noone;
		curr_look = noone;
		curr_roll = noone;
		curr_hAng = noone;
		curr_vAng = noone;
		curr_dist = noone;
		curr_scal = [ 1, 1 ];
		curr_weig = false;
		curr_dept = [ 1, 1 ];
	    
		curr_qi1  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1, 0),  90);
		curr_qi2  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -90);
		curr_qi3  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0),  90);
	#endregion
	
	////- Preview
	
	static getToolSettings = function() { return curr_posm == 0? tool_settings : []; }
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		if(is_path(curr_path)) {
			var _nodeFrom = inputs[in_d3d + 2].value_from.node;
			if(struct_has(_nodeFrom, "drawOverlay3D"))
				_nodeFrom.drawOverlay3D(active, _mx, _my, _snx, _sny, _params);
		}
		
		var preObj = getPreviewObjects();
		if(array_empty(preObj)) return;
		preObj = preObj[0];
		
		var _pos  = inputs[0].getValue(,,, true);
		var _vpos = new __vec3( _pos[0], _pos[1], _pos[2] );
		
		if(isUsingTool("Transform"))	tool_object_pos.drawOverlay3D(0, preObj, _vpos, active, _mx, _my, _snx, _sny, _params);
		else if(isUsingTool("Rotate"))	tool_object_rot.drawOverlay3D(1, preObj, _vpos, active, _mx, _my, _snx, _sny, _params);
		else if(isUsingTool("Move Target")) {
			var _lkpos  = inputs[in_d3d + 5].getValue(,,, true);
			var _lkvpos = new __vec3( _lkpos[0], _lkpos[1], _lkpos[2] );
			
			tool_object_pos.drawOverlay3D(in_d3d + 5, noone, _lkvpos, active, _mx, _my, _snx, _sny, _params);
		}
		
	}
	
	////- Path
	
	static getLineCount    = function(   ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()     : 1};
	static getSegmentCount = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(i) : 0};
	static getLength       = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(i)       : 0};
	static getAccuLength   = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getAccuLength(i)   : []};
	static getBoundary     = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(i)     : new BoundingBox( 0, 0, 1, 1 )};
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
			return out;
		}
		
		if(!is_path(curr_path)) return out;
		
		var _p = curr_path.getPointRatio(_rat, ind);
		var _w = _p.weight;
		var _v = camera.worldPointToViewPoint(_p);
		
		out.x = _v.x * curr_scal[0] / 2;
		out.y = _v.y * curr_scal[1] / 2;
		out.weight = curr_weig? _v.z : _p.weight;
		
		cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	////- Update
	
	static onValueUpdate = function(index) { if(index == in_d3d + 4) PANEL_PREVIEW.tool_current = noone; }
	
	static step = function() {
		inputs[in_d3d + 0].setVisible(curr_proj == 0);
		inputs[in_d3d + 3].setVisible(curr_proj == 1);
		
		inputs[0].setVisible(curr_posm == 0 || curr_posm == 1);
		inputs[1].setVisible(curr_posm == 0);
		inputs[in_d3d + 5].setVisible(curr_posm == 1 || curr_posm == 2);
		inputs[in_d3d + 6].setVisible(curr_posm == 1);
		inputs[in_d3d + 7].setVisible(curr_posm == 2);
		inputs[in_d3d + 8].setVisible(curr_posm == 2);
		inputs[in_d3d + 9].setVisible(curr_posm == 2);
		
		switch(curr_posm) {
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
	}
	
	static preProcessData = function(_data) /*=>*/ {}
	static submitShadow   = function() /*=>*/ {}
	static submitShader   = function() /*=>*/ {}
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			curr_pos  = _data[0];
			curr_rot  = _data[1];
			
			curr_fov  = _data[in_d3d + 0];
			curr_proj = _data[in_d3d + 1];
			curr_path = _data[in_d3d + 2];
			curr_orts = _data[in_d3d + 3];
		    
			curr_posm = _data[in_d3d + 4];
			curr_look = _data[in_d3d + 5];
			curr_roll = _data[in_d3d + 6];
			curr_hAng = _data[in_d3d + 7];
			curr_vAng = _data[in_d3d + 8];
			curr_dist = _data[in_d3d + 9];
			curr_scal = _data[in_d3d +10];
			curr_weig = _data[in_d3d +11];
			curr_dept = _data[in_d3d +12];
		#endregion
		
		switch(curr_posm) { // ++++ camera positioning ++++
			case 0 :
				camera.useFocus = false;
				camera.position.set(curr_pos);
				camera.rotation.set(curr_rot[0], curr_rot[1], curr_rot[2], curr_rot[3]);
				break;
				
			case 1 :
				camera.useFocus = true;
				camera.position.set(curr_pos);
				camera.focus.set(curr_look);
				camera.up.set(0, 0, -1);
				
				var _for = camera.focus.subtract(camera.position);
				if(!_for.isZero()) camera.rotation = new BBMOD_Quaternion().FromLookRotation(_for, camera.up).Mul(curr_qi1).Mul(curr_qi2);
					
				lookat.transform.position.set(curr_look);
				lookat.transform.applyMatrix();
				lookLine = new __3dGizmoLineDashed(camera.position, camera.focus, 0.25, c_gray, 1);
				break;
				
			case 2 :
				camera.useFocus = true;
				camera.focus.set(curr_look);
				camera.setFocusAngle(curr_hAng, curr_vAng, curr_dist);
				camera.setCameraLookRotate();
				camera.up = camera.getUp()._multiply(-1);
				
				var _for = camera.focus.subtract(camera.position);
				if(!_for.isZero()) camera.rotation = new BBMOD_Quaternion().FromLookRotation(_for, camera.up.multiply(-1)).Mul(curr_qi1).Mul(curr_qi3);
				
				lookat.transform.position.set(curr_look);
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
			object.proj = curr_proj;
			object.fov  = curr_fov;
			object.asp  = curr_scal[0] / curr_scal[1];
			object.setMesh();
			
			object.transform.position.set(camera.position);
			object.transform.rotation = camera.rotation.Clone();
			object.transform.applyMatrix();
			
			camera.projection = curr_proj;
			camera.setViewFov(curr_fov, curr_dept[0], curr_dept[1]);
			
			if(curr_proj == 0)		camera.setViewSize(curr_scal[0], curr_scal[1]);
			else if(curr_proj == 1) camera.setViewSize(1 / curr_orts, curr_scal[0] / curr_scal[1] / curr_orts);
			
			camera.setMatrix();
		#endregion
		
		ds_map_clear(cached_pos);
		return self;
	}
	
	////- Draw
	
	static getGraphPreviewSurface = function() { return noone; }
	
	static getPreviewObject = function() { return noone; }
	
	static getPreviewObjects = function() { 
		switch(curr_posm) {
			case 0 : return [ object ];
			case 1 : return [ object, lookat, lookLine ];
			case 2 : return [ object, lookat, lookLine, lookRad ];
		}
		
		return [ object ]; 
	}
	
	static getPreviewObjectOutline = function() { return isUsingTool("Move Target")? [ lookat ] : [ object ]; }
	
}