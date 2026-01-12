function Node_Quarternion_Lookat(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "Quaternion Lookat";
	setDrawIcon(s_node_quarternion_lookat);
	setDimension(96, 48);
	
	giz_orig = new __3dGizmoSphere(.25, c_yellow, 1);
	giz_targ = new __3dGizmoSphere(.25, c_red,    1);
	
	newInput(0, nodeValue_Vec3("Origin", [0,0,0]  ));
	newInput(1, nodeValue_Vec3("Target", [1,0,0]  ));
	newInput(2, nodeValue_Vec3("Up",     [0,0,-1] ));
	
	newOutput(0, nodeValue_Output("Rotation", VALUE_TYPE.float, [0,0,0,1])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0, 1, 2 ];
	
	////- Preview
	
	tool_lookat = new NodeTool( "Move Target", THEME.tools_3d_transform_object );
	tools       = [ tool_lookat ]; 
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		var _targ = isUsingTool("Move Target")? 1 : 0;
		var _posi = getInputSingle(_targ);
		var _vpos = new __vec3( _posi[0], _posi[1], _posi[2] );
		
		tool_object_pos.drawOverlay3D(_targ, noone, _vpos, active, _mx, _my, _snx, _sny, _params);
	}
	
	////- Nodes
	
	_qi1  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1, 0),  90);
	_qi2  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -90);
	_qi3  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0),  90);
	
	static submitShadow = function() {}
	static submitShader = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _orig = _data[0];
			var _targ = _data[1];
			var _upv  = _data[2];
			
			giz_orig.transform.position.set(_orig);
			giz_orig.transform.applyMatrix();
			
			giz_targ.transform.position.set(_targ);
			giz_targ.transform.applyMatrix();
		#endregion
				
		var _for = new BBMOD_Vec3(_targ[0] - _orig[0], _targ[1] - _orig[1], _targ[2] - _orig[2]);
		var _up  = new BBMOD_Vec3(_upv[0], _upv[1], _upv[2]);
		if(_for.Length() == 0) return [0,0,0,1];
		
		var q = new BBMOD_Quaternion().FromLookRotation(_for, _up).Mul(_qi1).Mul(_qi2).ToArray();
		return q; 
	}
	
	////- Object
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
	
	static getPreviewObject  = function() /*=>*/ {return noone};
	static getPreviewObjects = function() /*=>*/ {return [ giz_orig, giz_targ ]};
	
	static getPreviewObjectOutline = function() { return isUsingTool("Move Target")? [ giz_targ ] : [ giz_orig ]; }
	
}