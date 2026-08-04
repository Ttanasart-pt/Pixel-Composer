function Node_Path_3D_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform Path 3D";
	is_3D = NODE_3D.polygon;
	setDimension(96, 48);
	dimension_index = -1;
	setDrawIcon();
	
	////- =Path
	newInput( 0, nodeValue_Path( "Path" ));
	
	////- =Transform
	newInput( 1, nodeValue_Vec3(       "Position", [0,0,0] ));
	newInput( 2, nodeValue_Quaternion( "Rotation"          ));
	newInput( 3, nodeValue_Vec3(       "Scale",    [1,1,1] ));
	newInput( 4, nodeValue_Vec3(       "Anchor",   [0,0,0] ));
	// 5
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	b_center = button(function() /*=>*/ {return setCenter()}).setIcon(THEME.icon_center_canvas, 0, COLORS._main_icon, .5).setText("Center");
	
	input_display_list = [ 
		[ "Path",      false ], 0,  
		[ "Transform", false ], 1, 2, 3, 4, b_center, 
	]
	
	////- Tool
	
	tool_object_pos = new d3d_transform_tool_position(self);
	tool_object_rot = new d3d_transform_tool_rotation(self);
	tool_object_sca = new d3d_transform_tool_scale(self);
	
	tool_pos  = new NodeTool( "Transform",   THEME.tools_3d_transform, "Node_3D_Object" ).setToolObject(tool_object_pos);
	tool_rot  = new NodeTool( "Rotate",      THEME.tools_3d_rotate,    "Node_3D_Object" ).setToolObject(tool_object_rot);
	tool_sca  = new NodeTool( "Scale",       THEME.tools_3d_scale,     "Node_3D_Object" ).setToolObject(tool_object_sca);
	tools = [ tool_pos, tool_rot, tool_sca ];
	
	tool_attribute.context = 0;
	tool_axis_edit = new scrollBox([ "local", "global" ], function(val) /*=>*/ { tool_attribute.context = val; });
	tool_settings  = [ 
		toolSetting( "Axis", tool_axis_edit, "context", tool_attribute ),
	];
	
	static getToolSettings = function() /*=>*/ {return (isUsingTool("Transform") || isUsingTool("Rotate"))? tool_settings : []};
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {}
	
	static drawOverlay3D = function(active, _mx, _my, _params) {	
		var _path = outputs[0].getValue();
		if(!is(_path, _transformedPath3D)) return;
		
		var _qinv  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
	
		var _panel  = _params.panel;
		var _camera = _params.scene.camera;
		var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
		var ray     = _camera.viewPointToWorldRay(_mx, _my);
		
		var minx =  99999, miny =  99999, minz =  99999;
		var maxx = -99999, maxy = -99999, maxz = -99999;
			
		var _v3  = new __vec3P();
		var _res = 16;
		
		var _ox = 0, _oy = 0; 
		var _nx = 0, _ny = 0; 
		
		draw_set_color(COLORS._main_icon);
		for( var i = 0; i <= _res; i++ ) {
			var prg = i / _res;
			
			_v3 = _path.getPointRatio(prg, 0, _v3);
			
			var _posView = _camera.worldPointToViewPoint(_v3);
			_nx = _posView.x;
			_ny = _posView.y;
			
			if(i) draw_line(_ox, _oy, _nx, _ny);
			
			_ox = _nx;
			_oy = _ny;
		}
		
		var _rpos = inputs[1].getValue();
		var _vpos = new __vec3( _rpos[0], _rpos[1], _rpos[2] );
		var _qrot = _path.qrot;
		
		if(isUsingTool("Transform"))   tool_object_pos.drawOverlay3D(1, _vpos, _qrot, active, _mx, _my, _params);
		if(isUsingTool("Rotate"))      tool_object_rot.drawOverlay3D(2, _vpos, _qrot, active, _mx, _my, _params);
		if(isUsingTool("Scale"))       tool_object_sca.drawOverlay3D(3, _vpos, _qrot, active, _mx, _my, _params);
		
		return false;
	}
	
	////- Node
	
	static setCenter = function() /*=>*/ {
		var _path = getInputSingle(0);
		if(!is_path(_path)) return;
		
		var _bbox = _path.getBoundary();
		if(!is(_bbox, BoundingBox3D)) return;
		
		var cx = (_bbox.minx + _bbox.maxx) / 2;
		var cy = (_bbox.miny + _bbox.maxy) / 2;
		var cz = (_bbox.minz + _bbox.maxz) / 2;
		
		inputs[4].setValue([ cx, cy, cz ]);
	}
	
	function _transformedPath3D(_node) : Path(_node) constructor {
		path       = noone;
		cached_pos = {};
		
		pos  = [0,0,0];
		rot  = [0,0,0,0];
		qrot = undefined;
		sca  = [1,1,1];
		anc  = [0,0,0];
		p    = new __vec3P();
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {}
		
		static getLineCount 	= function()    /*=>*/ {return has(path, "getLineCount")?    path.getLineCount()     : 1};
		static getSegmentCount	= function(i=0) /*=>*/ {return has(path, "getSegmentCount")? path.getSegmentCount(i) : 0};
		static getLength		= function(i=0) /*=>*/ {return has(path, "getLength")?		 path.getLength(i)       : 0};
		static getAccuLength	= function(i=0) /*=>*/ {return has(path, "getAccuLength")?	 path.getAccuLength(i)   : []};
		
		static getBoundary = function(ind = 0) {
			if(!has(path, "getBoundary"))
				return new BoundingBox3D( 0, 0, 0, 1, 1, 1 );
				
			var b = path.getBoundary(ind).clone();
			
			b.minx = anc[0] + (b.minx - anc[0]) * sca[0] + pos[0]; 
			b.miny = anc[1] + (b.miny - anc[1]) * sca[1] + pos[1];
			b.minz = anc[2] + (b.minz - anc[2]) * sca[2] + pos[2];
			
			b.maxx = anc[0] + (b.maxx - anc[0]) * sca[0] + pos[0]; 
			b.maxy = anc[1] + (b.maxy - anc[1]) * sca[1] + pos[1];
			b.maxz = anc[2] + (b.maxz - anc[2]) * sca[2] + pos[2];
			
			var _minx = min(b.minx, b.maxx);
			var _maxx = max(b.minx, b.maxx);
			
			var _miny = min(b.miny, b.maxy);
			var _maxy = max(b.miny, b.maxy);
			
			var _minz = min(b.minz, b.maxz);
			var _maxz = max(b.minz, b.maxz);
			
			return new BoundingBox3D(_minx, _miny, _minz, _maxx, _maxy, _maxz);
		}
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			out ??= new __vec3P();
			
			var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
			if(has(cached_pos, _cKey)) {
				var _p = cached_pos[$ _cKey];
				out.x = _p.x;
				out.y = _p.y;
				out.z = _p.z;
				out.weight = _p.weight;
				return out;
			}
			
			if(is_array(path)) {
				path = array_safe_get_fast(path, ind);
				ind  = 0;
			}
			
			if(!is_path(path)) return out;
			
			var _p = path.getPointRatio(_rat, ind);
			
			_p.x -= anc[0];
			_p.y -= anc[1];
			_p.z -= anc[2];
			
			var p2 = new BBMOD_Vec3(_p.x, _p.y, _p.z);
			p2 = qrot.Rotate(p2);
			
			out.x = anc[0] + (p2.X * sca[0]) + pos[0];
			out.y = anc[1] + (p2.Y * sca[1]) + pos[1];
			out.z = anc[2] + (p2.Z * sca[2]) + pos[2];
			out.weight = _p.weight;
			
			cached_pos[$ _cKey] = new __vec3P(out.x, out.y, out.z, out.weight);
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
		
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _path = _data[ 0];
			
			var _posi = _data[ 1];
			var _rota = _data[ 2];
			var _scal = _data[ 3];
			var _anch = _data[ 4];
			
		#endregion
		
		if(!is(_outData, _transformedPath3D)) 
			_outData = new _transformedPath3D(self);
		
		_outData.cached_pos = {};
		_outData.path = _path;
		_outData.pos  = _posi;
		_outData.rot  = _rota;
		_outData.qrot = new BBMOD_Quaternion(_rota[0], _rota[1], _rota[2], _rota[3]);
		_outData.sca  = _scal;
		_outData.anc  = _anch;
		
		return _outData
		
	}
	
	////- Preview
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
	
}