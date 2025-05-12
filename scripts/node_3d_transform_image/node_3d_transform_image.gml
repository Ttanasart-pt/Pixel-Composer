function Node_3D_Transform_Image(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Transform 3D";
	
	preview_channel = 1;
	object          = new __3dPlane();
	objectPreview   = new __3dPlane();
	materialPreview = new __d3dMaterial();
	
	object.checkParameter({ normal: 2 });
	objectPreview.checkParameter({ normal: 2 });
	objectPreview.materials[0] = materialPreview;
	
	camObj  = new __3dCamera_object();
	camera  = camera_create();
	
	newInput(in_mesh + 0, nodeValue_Surface("Surface", self))
		.setVisible(true, true);
	
	newInput(in_mesh + 1, nodeValue_Enum_Button("Projection", self, 0, [ "Orthographic", "Perspective" ]));
	
	newInput(in_mesh + 2, nodeValue_Float("FOV", self, 45));
	
	newInput(in_mesh + 3, nodeValue_Vec2("Texture Tiling", self, [ 1, 1 ]));
	
	newInput(in_mesh + 4, nodeValue_Vec2("View Range", self, [ 0.001, 10 ]));
	
	newInput(in_mesh + 5, nodeValue_Vec2("Depth Range", self, [ 0, 1 ]));
	
	input_display_list = [
		["Material", false], in_mesh + 0, in_mesh + 3, 
		__d3d_input_list_transform,
		["Camera",	 false], in_mesh + 1, in_mesh + 2, in_mesh + 4, 
		["Render",	 false], in_mesh + 5, 
	]
	
	outputs[0].setVisible(false);
	
	newOutput(1, nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone));
	
	newOutput(2, nodeValue_Output("Depth", self, VALUE_TYPE.surface, noone));
	
	output_display_list = [ 1, 2 ]
	
	attribute_interpolation();
	
	static onDrawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {
		var _outSurf = outputs[1].getValue();
		if(is_array(_outSurf)) _outSurf = array_safe_get_fast(_outSurf, preview_index);
		if(!is_surface(_outSurf)) return;
	
		var _w = _panel.w;
		var _h = _panel.h - _panel.toolbar_height;
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
		var _surf = _data[in_mesh + 0];
		var _proj = _data[in_mesh + 1];
		var _fov  = _data[in_mesh + 2];
		var _tile = _data[in_mesh + 3];
		var _view = _data[in_mesh + 4];
		var _dept = _data[in_mesh + 5];
		
		camObj.transform.position.set(new __vec3(0, 0, 2));
		camObj.transform.rotation = new BBMOD_Quaternion().FromEuler(0, -90, 180);
		camObj.transform.scale.set(.5, .5, .5);
		
		if(!is_surface(_surf)) return noone;
		
		object.materials = [ new __d3dMaterial(_surf) ];
		setTransform(object, _data);
		
		if(_array_index == preview_index) {
			materialPreview.surface = _surf;
			setTransform(objectPreview, _data);
		}
		
		var _dim    = surface_get_dimension(_surf);
		var projMat = _proj? matrix_build_projection_perspective_fov(_fov, _dim[0] / _dim[1], _view[0], _view[1]) : matrix_build_projection_ortho(1, 1, _view[0], _view[1]);
		var viewMat = matrix_build_lookat(0, 0, 1, 
                            		      0, 0, 0,
									      1, 0, 0);
		
		var _outSurf = surface_verify(_outData[1], _dim[0], _dim[1]);
		var _dptSurf = surface_verify(_outData[2], _dim[0], _dim[1]);
		
		surface_set_target_ext(0, _outSurf);
		surface_set_target_ext(1, _dptSurf);
		shader_set(sh_d3d_3d_transform);
		DRAW_CLEAR
		BLEND_OVERRIDE
		
			shader_set_2("tiling",    _tile);
			shader_set_f("viewPlane", _dept);
			
			camera_set_view_mat(camera, viewMat);
			camera_set_proj_mat(camera, projMat);
			camera_apply(camera);
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
	
	static getPreviewObject  = function() { return objectPreview; }
	static getPreviewObjects = function() { return [ camObj, objectPreview ]; }
	static getPreviewValues  = function() { return outputs[1].getValue(); }
	
	static getGraphPreviewSurface = function() { return getSingleValue(1, preview_index, true); }
	
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