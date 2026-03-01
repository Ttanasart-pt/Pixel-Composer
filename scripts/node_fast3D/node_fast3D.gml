function Node_Fast3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Fast3D";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Transform
	newInput( 1, nodeValue_Vec2( "Position", [.5,.5]    )).setUnitSimple();
	newInput( 2, nodeValue_Vec3( "Rotation", [30,0,45]  ));
	newInput( 3, nodeValue_Vec3( "Scale",    [.5,.5,.5] ));
	
	////- =Rendering
	newInput( 4, nodeValue_Range( "Depth Range", [.0,.25] ));
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput( 1, nodeValue_Output("Depth",       VALUE_TYPE.surface, noone));
	newOutput( 2, nodeValue_Output("Rim Normal",  VALUE_TYPE.surface, noone));
	
	#macro FAST3D_PRE [ "Output",    false ],  0, \
		              [ "Transform", false ],  1,  2,  3, 
	
	#macro FAST3D_REN [ "Rendering", false ],  4,
	
	////- Model
	
	d3dCamera = camera_create();
	viewMat   = matrix_build_lookat(0, 1, 0, /**/ 0, 0, 0, /**/ 0, 0, -1);
	projMat   = matrix_build_projection_ortho(1, 1, 0, 10);

	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static submitObject = function(_data) {}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _dim = _data[ 0];
			
			var _pos = _data[ 1];
			var _rot = _data[ 2];
			var _sca = _data[ 3];
			
			var _dep = _data[ 4];
		#endregion
		
		var px = -(_pos[0] - _dim[0] / 2) / _dim[0];
		var py = 0;
		var pz = -(_pos[1] - _dim[1] / 2) / _dim[1];
		
		var rx =  _rot[0];
		var ry =  _rot[1];
		var rz = -_rot[2];
		
		var sx = _sca[0];
		var sy = _sca[1];
		var sz = _sca[2];
		
		matrix_stack_clear();
		matrix_stack_push(matrix_build(px, py, pz, /**/  0,  0,  0, /**/  1,  1,  1));
		matrix_stack_push(matrix_build( 0,  0,  0, /**/ rx,  0,  0, /**/  1,  1,  1));
		matrix_stack_push(matrix_build( 0,  0,  0, /**/  0, ry,  0, /**/  1,  1,  1));
		matrix_stack_push(matrix_build( 0,  0,  0, /**/  0,  0, rz, /**/  1,  1,  1));
		matrix_stack_push(matrix_build( 0,  0,  0, /**/  0,  0,  0, /**/ sx, sy, sz));
				  		  
		surface_set_shader(_outData, sh_fast3D);
			camera_set_view_mat(d3dCamera, viewMat);
			camera_set_proj_mat(d3dCamera, projMat);
			camera_apply(d3dCamera);
			
			gpu_set_cullmode(cull_counterclockwise);
			matrix_set(matrix_world, matrix_stack_top());
			
			shader_set_2("viewRange", _dep);
			submitObject(_data);
			
			gpu_set_cullmode(cull_noculling);
			camera_apply(0);
		surface_reset_shader();
		
		matrix_set(matrix_world, MATRIX_IDENTITY);
		matrix_stack_clear();
		
		return _outData; 
	}
}