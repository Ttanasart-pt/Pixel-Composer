function Node_3D_Transform_Image(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Transform Image 3D";
	
	preview_channel = 1;
	object          = new __3dPlane();
	objectPreview   = new __3dPlane();
	materialPreview = new __d3dMaterial();
	
	object.checkParameter({ normal: 2 });
	objectPreview.checkParameter({ normal: 2 });
	objectPreview.materials[0] = materialPreview;
	
	camGizmo  = new __3dCamera_object();
	d3_camera = new __3dCamera();
	
	////- =Material
	var i = in_mesh;
	newInput(i+0, nodeValue_Surface( "Surface" )).setVisible(true, true);
	newInput(i+3, nodeValue_Vec2(    "Texture Tiling", [1,1] ));
	
	////- =Camera
	newInput(i+1, nodeValue_EButton( "Projection",  1, [ "Perspective", "Orthographic" ] ));
	newInput(i+2, nodeValue_Float(   "FOV",        45        ));
	newInput(i+4, nodeValue_Vec2(    "View Range", [.001,10] ));
	
	////- =Render
	newInput(i+5, nodeValue_Vec2( "Depth Range", [0,1] ));
	// i+6
	
	outputs[0].setVisible(false);
	newOutput(1, nodeValue_Output("Rendered", VALUE_TYPE.surface, noone ));
	newOutput(2, nodeValue_Output("Depth",    VALUE_TYPE.surface, noone ));
	
	input_display_list = [
		["Material", false], i+0, i+3, 
		__d3d_input_list_transform,
		["Camera",	 false], i+1, i+2, i+4, 
		["Render",	 false], i+5, 
	]
	
	output_display_list = [ 1, 2 ]
	
	////- Node
	
	attribute_interpolation();
	
	static onDrawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		var _outSurf = outputs[1].getValue();
		if(is_array(_outSurf)) _outSurf = array_safe_get_fast(_outSurf, preview_index);
		if(!is_surface(_outSurf)) return;
		
		var _panel = _params.panel;
		var _w  = _panel.w;
		var _h  = _panel.h - _panel.toolbar_height;
		var _pw = surface_get_width_safe(_outSurf);
		var _ph = surface_get_height_safe(_outSurf);
		var _ps = min(128 / _ph, 160 / _pw);
	
		var _pws = _pw * _ps;
		var _phs = _ph * _ps;
	
		var _px = _w - 16 - _pws;
		var _py = _h - 16 - _phs;
	
		draw_surface_ext_safe(_outSurf, _px, _py, _ps, _ps);
		draw_set_color(COLORS._main_icon);
		draw_rectangle(_px, _py, _px + _pws, _py + _phs, true);
	}
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var i = in_mesh;
			var _surf = _data[i+0];
			var _proj = _data[i+1];
			var _fov  = _data[i+2];
			var _tile = _data[i+3];
			var _view = _data[i+4];
			var _dept = _data[i+5];
			
			inputs[i+2].setVisible(_proj == 0);
		#endregion
		
		if(!is_surface(_surf)) return noone;
		
		var _dim = surface_get_dimension(_surf);
		var _asp = _dim[0] / _dim[1];
		
		#region gizmo 
			camGizmo.transform.position.set(new __vec3(0, 0, 2));
			camGizmo.transform.rotation = new BBMOD_Quaternion().FromEuler(0, -90, 180);
			camGizmo.transform.scale.set(.5, .5, .5);
			camGizmo.transform.applyMatrix();
			
			camGizmo.proj = _proj;
			camGizmo.fov  = _fov;
			camGizmo.asp  = _asp;
			camGizmo.setMesh();
		#endregion
		
		object.materials = [ new __d3dMaterial(_surf) ];
		setTransform(object, _data, _proj == CAMERA_PROJECTION.perspective? _asp : 1);
		
		if(_array_index == preview_index) {
			materialPreview.surface = _surf;
			setTransform(objectPreview, _data);
		}
		
		#region camera
			d3_camera.projection = _proj;
			d3_camera.setViewFov(_fov, _view[0], _view[1]);
			if(_proj == CAMERA_PROJECTION.perspective)
				 d3_camera.setViewSize(_dim[0], _dim[1]);
			else d3_camera.setViewSize(1, 1);
			
			d3_camera.setMatrix();
			d3_camera.viewMat.setRaw(matrix_build_lookat(0, 0, 1, /**/ 0, 0, 0, /**/ 1, 0, 0));
			
		#endregion
		
		var _outSurf = surface_verify(_outData[1], _dim[0], _dim[1]);
		var _dptSurf = surface_verify(_outData[2], _dim[0], _dim[1]);
		
		surface_set_target_ext(0, _outSurf);
		surface_set_target_ext(1, _dptSurf);
		shader_set(sh_d3d_3d_transform);
		DRAW_CLEAR
		BLEND_OVERRIDE
			shader_set_2("tiling",    _tile);
			shader_set_f("viewPlane", _dept);
			
			d3_camera.applyCamera();
			gpu_set_texfilter(getAttribute("interpolate") > 1);
			
			object.transform.submitMatrix();
			matrix_set(matrix_world, matrix_stack_top());
			vertex_submit(object.VB[0], pr_trianglelist, surface_get_texture(_surf));
			
			object.transform.clearMatrix();
			matrix_set(matrix_world, matrix_build_identity());
			camera_apply(0);
			
		BLEND_NORMAL
		gpu_set_texfilter(false);
		surface_reset_target();
	
		return [ object, _outSurf, _dptSurf ];
	}
	
	////- =Preview
	
	static getPreviewObject  = function() /*=>*/ {return objectPreview};
	static getPreviewObjects = function() /*=>*/ {return [ camGizmo, objectPreview ]};
	static getPreviewValues  = function() /*=>*/ {return outputs[1].getValue()};
	
	static getGraphPreviewSurface = function() /*=>*/ {return getSingleValue(1, preview_index, true)};
	
	// static onDrawNode = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {
	// 	if(!previewable) return;
		
	// 	var _surf = outputs[1].getValue();
	// 	if(is_array(_surf)) _surf = array_safe_get_fast(_surf, preview_index);
	// 	if(!is_surface(_surf)) return;
		
	// 	var bbox = drawGetBbox(xx, yy, _s);
	// 	var aa   = 0.5 + 0.5 * renderActive;
	// 	if(!isHighlightingInGraph()) aa *= 0.25;
		
	// 	draw_surface_bbox(_surf, bbox,, aa);
	// }
}