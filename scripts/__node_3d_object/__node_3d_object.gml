#region
	#macro __d3d_input_list_transform ["Transform", false], 0, 3, 1, 2
	
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_3D_Object", "Transform", "G");
		hotkeyCustom("Node_3D_Object", "Rotate",    "R");
		hotkeyCustom("Node_3D_Object", "Scale",     "S");
	});
#endregion

function Node_3D_Object(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Object";
	gizmo = new __3dGizmoAxis(.2, COLORS._main_accent);
	
	cached_object   = [];
	object_class    = noone;
	preview_channel = 0;
	apply_anchor    = false;
	
	////- Inputs
	
	newInput( 0, nodeValue_Vec3(       "Position", [0,0,0], { linkable: false }));
	newInput( 3, nodeValue_Vec3(       "Anchor",   [0,0,0], { linkable: false, 
			side_button: button(function() /*=>*/ { apply_anchor = !apply_anchor; triggerRender(); })
				.setIcon(THEME.icon_3d_anchor, [ function() /*=>*/ {return apply_anchor} ], c_white).setTooltip("Apply Position") 
		}));
	newInput( 1, nodeValue_Quaternion( "Rotation", [0,0,0,1] ));
	newInput( 2, nodeValue_Vec3(       "Scale",    [1,1,1]   ));
	in_d3d = array_length(inputs);
	
	////- Tools
	
	#region ---- tools ----
		tool_object_pos = new d3d_transform_tool_position(self);
		tool_object_rot = new d3d_transform_tool_rotation(self);
		tool_object_sca = new d3d_transform_tool_scale(self);
		tool_object_sid = new d3d_transform_tool_side(self);
	
		tool_pos  = new NodeTool( "Transform",   THEME.tools_3d_transform, "Node_3D_Object" ).setToolObject(tool_object_pos);
		tool_rot  = new NodeTool( "Rotate",      THEME.tools_3d_rotate,    "Node_3D_Object" ).setToolObject(tool_object_rot);
		tool_sca  = new NodeTool( "Scale",       THEME.tools_3d_scale,     "Node_3D_Object" ).setToolObject(tool_object_sca);
		tool_side = new NodeTool( "Side Adjust", THEME.tools_3d_side,      "Node_3D_Object" ).setToolObject(tool_object_sid);
		tools = [ tool_pos, tool_rot, tool_sca, -1, tool_side ];
		
		tool_attribute.context = 0;
		tool_axis_edit = new scrollBox([ "local", "global" ], function(val) /*=>*/ { tool_attribute.context = val; });
		tool_settings  = [ 
			[ "Axis", tool_axis_edit, "context", tool_attribute ],
		];
		
		static getToolSettings = function() /*=>*/ {return (isUsingTool("Transform") || isUsingTool("Rotate"))? tool_settings : []};
	#endregion
	
	////- Draw
	
	static drawOverlay3D = function(active, _mx, _my, _params) { 
		var object = getPreviewObjects();
		if(object == noone || array_empty(object)) return;
		object = object[0];
		
		var _rpos = inputs[0].getValue();
		var _vpos = new __vec3( _rpos[0], _rpos[1], _rpos[2] );
		
		if(isUsingTool("Transform"))   tool_object_pos.drawOverlay3D(0, object, _vpos, active, _mx, _my, _params);
		if(isUsingTool("Rotate"))      tool_object_rot.drawOverlay3D(1, object, _vpos, active, _mx, _my, _params);
		if(isUsingTool("Scale"))       tool_object_sca.drawOverlay3D(2, object, _vpos, active, _mx, _my, _params);
		if(isUsingTool("Side Adjust")) tool_object_sid.drawOverlay3D(object, active, _mx, _my, _params);
		
		onDrawOverlay3D(active, _mx, _my, _params);
	} 
	
	static onDrawOverlay3D = function(active, _mx, _my, _params) {}
	
	////- Render
	
	static setTransform = function(object, _data, _asp = 1) {
		if(object == noone) return;
		var _pos = _data[0];
		var _rot = _data[1];
		var _sca = _data[2];
		var _anc = _data[3];
		
		if(apply_anchor)
			_pos = [
				_pos[0] + _anc[0],
				_pos[1] + _anc[1],
				_pos[2] + _anc[2],
			];
		
		gizmo.transform.position.set(	_pos[0], _pos[1], _pos[2]);
		gizmo.transform.applyMatrix();
		
		object.transform.position.set(	_pos[0], _pos[1], _pos[2]);
		object.transform.anchor.set(	_anc[0], _anc[1], _anc[2]);
		object.transform.rotation.set(	_rot[0], _rot[1], _rot[2], _rot[3]);
		object.transform.scale.set(		_sca[0], _sca[1] * _asp, _sca[2]);
		object.transform.applyMatrix();
		
		return object;
	}
		
	static getObject = function(index, class = object_class) {
		var _obj = array_safe_get_fast(cached_object, index, noone);
		
		if(_obj == noone) {
			_obj = new class();
			
		} else if(!is(_obj, class)) {
			_obj.destroy();
			_obj = new class();
		}
		
		cached_object[index] = _obj;
		return _obj;
	}
	
	////- Preview
	
	static getPreviewObjects		= function() { return [ getPreviewObject(), gizmo ]; }
	static getPreviewObjectOutline  = function() { return [ getPreviewObject(), gizmo ]; }
}