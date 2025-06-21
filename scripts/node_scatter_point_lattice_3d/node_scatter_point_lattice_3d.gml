#region
	FN_NODE_CONTEXT_INVOKE {
		
	});
#endregion

function Node_Scatter_Point_Lattice_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Lattice Point 3D";
	color = COLORS.node_blend_number;
	is_3D = NODE_3D.polygon;
	setDimension(96, 48);
	
	////- =Base
	
	newInput(0, nodeValueSeed()).rejectArray();
	
	////- =Scatter
	
	onSurfaceSize = function() /*=>*/ {return DEF_SURF}; 
	newInput( 1, nodeValue_Vec3(  "Center",      [0,0,0] ));
	newInput( 2, nodeValue_Vec3(  "Half-Size",   [1,1,1] ));
	newInput( 3, nodeValue_IVec3( "Subdivision", [2,2,2] ));
	// inputs 3
	
	input_display_list = [ 
		["Lattice", false], 1, 2, 3, 
	];
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [ 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(1);
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {
		var ansize = array_length(inputs) - input_fix_len;
		var edited = false;
		var _qinv  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
	
		var _camera = params.camera;
		var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
		
		////////////////////////////////////////////////// DRAW POINTS //////////////////////////////////////////////////
		
		var _center = getSingleValue(1);
		var _hsize  = getSingleValue(2);
		var _points = getSingleValue(0, preview_index, true);
		
		var _v3 = new __vec3();
		draw_set_circle_precision(32);
		
		for( var i = 0, n = array_length(_points); i < n; i++ ) {
			var _p = _points[i];
			if(!is_array(_p)) continue;
			
			_v3.x = _p[0];
			_v3.y = _p[1];
			_v3.z = _p[2];
			
			var _posView = _camera.worldPointToViewPoint(_v3);
			var _x = _posView.x;
			var _y = _posView.y;
				
			draw_set_color(COLORS._main_accent);
			draw_circle(_x, _y, 4, false);
		}
		
		var _rngX = [_center[0] - _hsize[0], _center[0] + _hsize[0]];
		var _rngY = [_center[1] - _hsize[1], _center[1] + _hsize[1]];
		var _rngZ = [_center[2] - _hsize[2], _center[2] + _hsize[2]];
		
		draw_set_color(COLORS._main_icon);
		
		var _v00 = new __vec3(_rngX[0], _rngY[0], _rngZ[0]);
		var _p00 = _camera.worldPointToViewPoint(_v00);
		
		var _v01 = new __vec3(_rngX[0], _rngY[1], _rngZ[0]);
		var _p01 = _camera.worldPointToViewPoint(_v01);
		
		var _v02 = new __vec3(_rngX[0], _rngY[1], _rngZ[1]);
		var _p02 = _camera.worldPointToViewPoint(_v02);
		
		var _v03 = new __vec3(_rngX[0], _rngY[0], _rngZ[1]);
		var _p03 = _camera.worldPointToViewPoint(_v03);
		
		var _v10 = new __vec3(_rngX[1], _rngY[0], _rngZ[0]);
		var _p10 = _camera.worldPointToViewPoint(_v10);
		
		var _v11 = new __vec3(_rngX[1], _rngY[1], _rngZ[0]);
		var _p11 = _camera.worldPointToViewPoint(_v11);
		
		var _v12 = new __vec3(_rngX[1], _rngY[1], _rngZ[1]);
		var _p12 = _camera.worldPointToViewPoint(_v12);
		
		var _v13 = new __vec3(_rngX[1], _rngY[0], _rngZ[1]);
		var _p13 = _camera.worldPointToViewPoint(_v13);
		
		draw_line(_p00.x, _p00.y, _p01.x, _p01.y);
		draw_line(_p01.x, _p01.y, _p02.x, _p02.y);
		draw_line(_p02.x, _p02.y, _p03.x, _p03.y);
		draw_line(_p03.x, _p03.y, _p00.x, _p00.y);
		
		draw_line(_p10.x, _p10.y, _p11.x, _p11.y);
		draw_line(_p11.x, _p11.y, _p12.x, _p12.y);
		draw_line(_p12.x, _p12.y, _p13.x, _p13.y);
		draw_line(_p13.x, _p13.y, _p10.x, _p10.y);
		
		draw_line(_p00.x, _p00.y, _p10.x, _p10.y);
		draw_line(_p01.x, _p01.y, _p11.x, _p11.y);
		draw_line(_p02.x, _p02.y, _p12.x, _p12.y);
		draw_line(_p03.x, _p03.y, _p13.x, _p13.y);
	}
	
	////- Nodes
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed = _data[0];
			var _cent = _data[1];
			var _half = _data[2];
			var _subd = _data[3];
		#endregion
		
		random_set_seed(_seed);
		
		var subx = max(_subd[0] + 1, 2);
		var suby = max(_subd[1] + 1, 2);
		var subz = max(_subd[2] + 1, 2);
		
		var amo = subx * suby * subz;
		var pos = array_create(amo);
		
		var x0 = _cent[0] - _half[0], x1 = _cent[0] + _half[0];
		var y0 = _cent[1] - _half[1], y1 = _cent[1] + _half[1];
		var z0 = _cent[2] - _half[2], z1 = _cent[2] + _half[2];
		
		var ww = x1 - x0;
		var hh = y1 - y0;
		var dd = z1 - z0;
		
		var lay = subx * suby;
		
		for( var i = 0; i < amo; i++ ) {
			var _i   = i;
			var _dep = floor(_i / lay);
			
			    _i  -= _dep * lay;
			var _row = floor(_i / subx);
			
			    _i  -= _row * subx;
			var _col = _i;
			
			var _x = lerp(x0, x1, _col / (subx - 1));
			var _y = lerp(y0, y1, _row / (suby - 1));
			var _z = lerp(z0, z1, _dep / (subz - 1));
			
			pos[i] = [ _x, _y, _z ];
		}
		
		return pos;
	}
	
	////- Preview
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_scatter_point_lattice_3d, 0, bbox);
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
}