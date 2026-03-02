#region create
	global.node_shape_3d_types = [ 
			"Plane", 
		-1, "Cube", "Octahedron", 
		-1, "Cylinder", "Cone", "Capsule", 
		-1, "Sphere", "Cut Sphere", "Torus",
	];
	
	global.Node_Shape_3D_alias = array_clone(global.node_shape_3d_types);
	
	global.node_shape_3d_types_map = {};
	global.node_shape_3d_types_map[$ "Plane"]      = new scrollItem("Plane",      s_node_shape_sdf,  0 );
	
	global.node_shape_3d_types_map[$ "Cube"]       = new scrollItem("Cube",       s_node_shape_sdf,  1 );
	global.node_shape_3d_types_map[$ "Octahedron"] = new scrollItem("Octahedron", s_node_shape_sdf, 18 );
	
	global.node_shape_3d_types_map[$ "Cylinder"]   = new scrollItem("Cylinder",   s_node_shape_sdf, 10 );
	global.node_shape_3d_types_map[$ "Cone"]       = new scrollItem("Cone",       s_node_shape_sdf, 13 );
	global.node_shape_3d_types_map[$ "Capsule"]    = new scrollItem("Capsule",    s_node_shape_3d_capsule, 0 );
	
	global.node_shape_3d_types_map[$ "Sphere"]     = new scrollItem("Sphere",     s_node_shape_sdf,  4 );
	global.node_shape_3d_types_map[$ "Cut Sphere"] = new scrollItem("Cut Sphere", s_node_shape_sdf,  6 );
	global.node_shape_3d_types_map[$ "Torus"]      = new scrollItem("Torus",      s_node_shape_sdf,  8 );
	
	function Node_create_Shape_3D(_x, _y, _group = noone, _param = {}) {
		var quer = _param[$ "query"]; var query = (is_struct(quer) && quer[$ "type"] == "alias"? quer[$ "value"] : "") ?? "";
		var node  = new Node_Shape_3D(_x, _y, _group);
		
		if(query != "") {
			var shp = string_titlecase(query);
			
			if(array_exists(global.node_shape_3d_types, shp))
				node.inputs[7].skipDefault().setValue(shp);
		}
		
		return node;
	}
#endregion

function Node_Shape_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Shape 3D";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Transform
	newInput( 1, nodeValue_Vec2( "Position", [.5,.5]    )).setUnitSimple();
	newInput( 2, nodeValue_Vec3( "Rotation", [30,0,45]  ));
	newInput( 3, nodeValue_Vec3( "Scale",    [.5,.5,.5] ));
	
	////- =Shape
	newInput( 7, nodeValue_EString( "Shape", "Cube", { 
		data       : global.node_shape_3d_types, 
		display    : global.node_shape_3d_types_map, 
		horizontal : 1, 
		text_pad   : ui(16) 
	} ));
	
	newInput( 8, nodeValue_Int(    "Side",      8      ));
	newInput( 9, nodeValue_Bool(   "Caps",   true      ));
	newInput(13, nodeValue_Vec2(   "Radius", [.75,.25] ));
	newInput(12, nodeValue_IVec2(  "Side",   [16,8]    ));
	newInput(14, nodeValue_Slider( "Ratio",    .5      ));
	newInput(15, nodeValue_Float(  "Height",   .5      ));
	
	////- =Texturing
	newInput( 5, nodeValue_Palette( "Colors", [ ca_white ] ));
	newInput( 6, nodeValue_Surface( "Texture"              ));
	newInput(10, nodeValue_Float(   "Side Scale", 2        ));
	newInput(11, nodeValue_Bool(    "Smooth",     0        ));
	
	////- =Rendering
	newInput( 4, nodeValue_Range( "Depth Range", [.0,.25] ));
	// 16
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput( 1, nodeValue_Output("Depth",       VALUE_TYPE.surface, noone));
	newOutput( 2, nodeValue_Output("Rim Normal",  VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output",    false ],  0,
		[ "Transform", false ],  1,  2,  3, 
		[ "Shape",     false ],  7,  8,  9, 13, 12, 14, 15, 
		[ "Texturing", false ],  5,  6, 10, 11, 
		[ "Rendering", false ],  4,
	];
	
	////- Model
	
	d3dCamera = camera_create();
	viewMat   = matrix_build_lookat(0, 1, 0, /**/ 0, 0, 0, /**/ 0, 0, -1);
	projMat   = matrix_build_projection_ortho(1, 1, 0, 10);
	
	objectCache = {};
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _dim   = _data[ 0];
			
			var _pos   = _data[ 1];
			var _rot   = _data[ 2];
			var _sca   = _data[ 3];
			
			var _shape = _data[ 7];
			var _side  = _data[ 8];
			var _caps  = _data[ 9];
			var _rrad  = _data[13];
			var _sside = _data[12];
			var _ratio = _data[14];
			var _heigh = _data[15];
			
			var _color = _data[ 5];
			var _textr = _data[ 6];
			var _uvsca = _data[10];
			var _smt   = _data[11];
			
			var _depth = _data[ 4];
			
			inputs[ 8].setVisible(false);
			inputs[ 9].setVisible(false);
			inputs[13].setVisible(false);
			inputs[12].setVisible(false);
			inputs[14].setVisible(false);
			inputs[15].setVisible(false);
			
			inputs[10].setVisible(false);
			inputs[11].setVisible(false);
		#endregion
		
		#region transform
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
		#endregion
		  
		#region shape
			var vbObject = objectCache[$ _shape];
			
			switch(_shape) {
				case "Plane"    : if(vbObject == undefined) vbObject = new __3dPlane(2); 
					break;
					
				case "Cube"     : 
					if(vbObject == undefined) {
						vbObject = new __3dCube(true); 
						var v = vbObject.VB;
						vbObject.VB = [ v[1], v[3], v[5], v[0], v[2], v[4] ];
					}
					break;
				
				case "Octahedron" : if(vbObject == undefined) vbObject = new __3dOctahedron(); 
					break;
					
				case "Cylinder" : if(vbObject == undefined) vbObject = new __3dCylinder(); 
					inputs[ 8].setVisible(true);
					inputs[ 9].setVisible(true);
					
					inputs[10].setVisible(true);
					inputs[11].setVisible(true);
					
					vbObject.checkParameter({ 
						sides : _side, 
						caps  : _caps,
						
						uvScale_side : _uvsca, 
						smooth       : _smt, 
					});
					break;
					
				case "Cone"     : if(vbObject == undefined) vbObject = new __3dCone(); 
					inputs[ 8].setVisible(true);
					inputs[ 9].setVisible(true);
					
					inputs[10].setVisible(true);
					inputs[11].setVisible(true);
					
					vbObject.checkParameter({ 
						sides : _side, 
						caps  : _caps,
						
						uvScale_side : _uvsca, 
						smooth       : _smt, 
					});
					break;
					
				case "Capsule" : if(vbObject == undefined) vbObject = new __3dCapsule(); 
					inputs[ 8].setVisible(true);
					
					inputs[10].setVisible(true);
					inputs[11].setVisible(true);
					inputs[15].setVisible(true);
					
					vbObject.checkParameter({ 
						sides        : _side,
						height       : _heigh,
						
						uvScale_side : _uvsca, 
						smooth       : _smt, 
					});
					break;
					
				case "Sphere"   : if(vbObject == undefined) vbObject = new __3dUVSphere(); 
					inputs[12].setVisible(true);
				
					inputs[10].setVisible(true);
					inputs[11].setVisible(true);
					
					vbObject.checkParameter({ 
						hori  : _sside[0], 
						vert  : _sside[1], 
						uvsca : _uvsca, 
						
						smooth: _smt, 
					});
					break;
				
				case "Cut Sphere"   : if(vbObject == undefined) vbObject = new __3dUVSphereCut(); 
					inputs[12].setVisible(true);
					inputs[14].setVisible(true);
					
					inputs[10].setVisible(true);
					inputs[11].setVisible(true);
					
					vbObject.checkParameter({ 
						hori  : _sside[0], 
						vert  : _sside[1], 
						ratio : _ratio,
						uvsca : _uvsca, 
						
						smooth: _smt, 
					});
					break;
				
				case "Torus"    : if(vbObject == undefined) vbObject = new __3dTorus(); 
					inputs[13].setVisible(true);
					inputs[12].setVisible(true);
				
					inputs[10].setVisible(true);
					inputs[11].setVisible(true);
					
					vbObject.checkParameter({ 
						hori  : _sside[0], 
						vert  : _sside[1], 
						radT  : _rrad[0],
						radP  : _rrad[1],
						
						uvsca : _uvsca, 
						smooth: _smt, 
					});
					break;
			}
			
		#endregion
		
		if(vbObject == undefined) return _outData;
		
		objectCache[$ _shape] = vbObject;
		var VB = vbObject.VB;
		
		surface_set_shader(_outData, sh_fast3D);
			camera_set_view_mat(d3dCamera, viewMat);
			camera_set_proj_mat(d3dCamera, projMat);
			camera_apply(d3dCamera);
			
			gpu_set_cullmode(cull_counterclockwise);
			matrix_set(matrix_world, matrix_stack_top());
			
			shader_set_2("viewRange", _depth);
			
			var _clen = array_length(_color);
			var _ttex = is_surface(_textr)? surface_get_texture(_textr) : -1;
			
			for( var i = 0, n = array_length(VB); i < n; i++ ) {
				if(VB[i] == noone) continue;
				
				shader_set_c("color", _color[i % _clen]);
				vertex_submit(VB[i], pr_trianglelist, _ttex);
			}
			
			gpu_set_cullmode(cull_noculling);
			camera_apply(0);
		surface_reset_shader();
		
		matrix_set(matrix_world, MATRIX_IDENTITY);
		matrix_stack_clear();
		
		return _outData; 
	}
}