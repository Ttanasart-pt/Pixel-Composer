#region
	FN_NODE_CONTEXT_INVOKE {
		
	});
#endregion

function Node_Scatter_Points_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Scatter Points 3D";
	color = COLORS.node_blend_number;
	is_3D = NODE_3D.polygon;
	setDimension(96, 48);
	
	////- =Base
	
	newInput(0, nodeValueSeed()).rejectArray();
	
	////- =Scatter
	
	newInput(4, nodeValue_Enum_Scroll( "Amount",    0       )).setChoices([ "Cube", "Sphere" ]);
	newInput(3, nodeValue_Int(         "Amount",    8       ));
	newInput(1, nodeValue_Vec3(        "Center",    [0,0,0] ));
	newInput(2, nodeValue_Vec3(        "Half-Size", [1,1,1] ));
	
	// inputs 5
	
	input_display_list = [ 
		["Base",    false], 0, 
		["Scatter", false], 4, 3, 1, 2, 
	];
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [ 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(1);
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		var ansize = array_length(inputs) - input_fix_len;
		var edited = false;
		var _qinv  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
	
		var _camera = _params.scene.camera;
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
	
	////- Update
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed   = _data[0];
			
			var _shape  = _data[4];
			var _amount = _data[3];
			var _center = _data[1];
			var _hsize  = _data[2];
		#endregion
		
		random_set_seed(_seed);
		
		var pos = array_create(_amount);
		
		var _rngX = [_center[0] - _hsize[0], _center[0] + _hsize[0]];
		var _rngY = [_center[1] - _hsize[1], _center[1] + _hsize[1]];
		var _rngZ = [_center[2] - _hsize[2], _center[2] + _hsize[2]];
		
		for( var i = 0; i < _amount; i++ ) {
			var _p = [ 0, 0, 0 ];
			
			switch(_shape) {
				case 0 :
					_p[0] = random_range( _rngX[0], _rngX[1] );
					_p[1] = random_range( _rngY[0], _rngY[1] );
					_p[2] = random_range( _rngZ[0], _rngZ[1] );
					break;
				
				case 1 :
					var _rx = random_range(-1, 1);
					var _ry = random_range(-1, 1);
					var _rz = random_range(-1, 1);
					var dst = sqrt(_rx * _rx + _ry * _ry + _rz * _rz);
					
					if(dst != 0) {
						_rx /= dst;
						_ry /= dst;
						_rz /= dst;
						
						var _d = sqrt(random(1));
						
						_p[0] = _center[0] + _rx * _d * _hsize[0];
						_p[1] = _center[1] + _ry * _d * _hsize[1];
						_p[2] = _center[2] + _rz * _d * _hsize[2];
					}
					break;
			}
			
			pos[i] = _p;
		}
		
		return pos;
	}
	
	////- Preview
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_scatter_points_3d, 0, bbox);
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
}