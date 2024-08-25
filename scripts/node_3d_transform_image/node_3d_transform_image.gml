function Node_3D_Transform_Image(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Transform 3D";
	batch_output = false;
	
	preview_channel = 1;
	object          = new __3dPlane();
	object.checkParameter({ normal: 2 });
	
	objectPreview = new __3dPlane();
	objectPreview.checkParameter({ normal: 2 });
	materialPreview = new __d3dMaterial();
	objectPreview.materials[0] = materialPreview;
	
	camera  = camera_create();
	
	newInput(in_mesh + 0, nodeValue_Surface("Surface", self))
		.setVisible(true, true);
	
	newInput(in_mesh + 1, nodeValue_Enum_Button("Projection", self, 0, [ "Orthographic", "Perspective" ]));
	
	newInput(in_mesh + 2, nodeValue_Float("FOV", self, 45));
	
	newInput(in_mesh + 3, nodeValue_Vec2("Texture Tiling", self, [ 1, 1 ]));
	
	input_display_list = [
		["Material", false], in_mesh + 0, in_mesh + 3, 
		__d3d_input_list_transform,
		["Camera",	 false], in_mesh + 1, in_mesh + 2, 
	]
	
	outputs[0].setVisible(false);
	outputs[1] = nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone);
	
	output_display_list = [ 1 ]
	
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
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _surf = _data[in_mesh + 0];
		var _proj = _data[in_mesh + 1];
		var _fov  = _data[in_mesh + 2];
		var _tile = _data[in_mesh + 3];
		if(!is_surface(_surf)) return 0;
		
		if(_output_index == 0) {
			object.materials = [ new __d3dMaterial(_surf) ];
			setTransform(object, _data);
			
			if(_array_index == preview_index) {
				materialPreview.surface = _surf;
				setTransform(objectPreview, _data);
			}
			return object;
		}
		
		if(_output_index == 1) {
			var _dim    = surface_get_dimension(_surf);
			var projMat = _proj? matrix_build_projection_perspective_fov(_fov, _dim[0] / _dim[1], 0.001, 10) : matrix_build_projection_ortho(1, 1, 0.001, 10);
			var viewMat = matrix_build_lookat(0, 0, 1, 
	                            		      0, 0, 0,
										      1, 0, 0);
			
			_output = surface_verify(_output, _dim[0], _dim[1]);
			surface_set_shader(_output, sh_d3d_3d_transform);
				shader_set_2("tiling", _tile);
				
				camera_set_view_mat(camera, viewMat);
				camera_set_proj_mat(camera, projMat);
				camera_apply(camera);
				gpu_set_texfilter(attributes.interpolate);
				
				object.transform.submitMatrix();
				matrix_set(matrix_world, matrix_stack_top());
				
				vertex_submit(object.VB[0], pr_trianglelist, surface_get_texture(_surf));
				
				object.transform.clearMatrix();
				matrix_set(matrix_world, matrix_build_identity());
				
				camera_apply(0);
				gpu_set_texfilter(false);
			surface_reset_shader();
		
			return _output;
		}
		
		return 0;
	}
	
	static getPreviewObject = function() { return objectPreview; }
	
	static getPreviewValues = function() { return outputs[1].getValue(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {
		if(!previewable) return;
		
		var _surf = outputs[1].getValue();
		if(is_array(_surf)) _surf = array_safe_get_fast(_surf, preview_index);
		if(!is_surface(_surf)) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		var aa   = 0.5 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		
		draw_surface_bbox(_surf, bbox,, aa);
	}
}