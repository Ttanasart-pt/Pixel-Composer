function NodeObject(_name, _spr, _node, _create, tags = []) constructor {
	name = _name;
	spr  = _spr;
	node = _node;
	createNode = _create;
	
	self.tags = tags;
	
	function build(_x, _y, _group = PANEL_GRAPH.getCurrentContext(), _param = "") {
		var _node = createNode[0]? new createNode[1](_x, _y, _group, _param) : createNode[1](_x, _y, _group, _param);
		return _node;
	}
}

#region nodes
	globalvar ALL_NODES, NODE_CATEGORY, NODE_PAGE_DEFAULT;
	ALL_NODES		= ds_map_create();
	NODE_CATEGORY	= ds_list_create();
	
	function nodeBuild(_name, _x, _y, _group = PANEL_GRAPH.getCurrentContext()) {
		if(!ds_map_exists(ALL_NODES, _name)) {
			log_warning("LOAD", "Node type " + _name + " not found");
			return noone;
		}
			
		var _node = ALL_NODES[? _name];
		return _node.build(_x, _y, _group);
	}
	
	function addNodeObject(_list, _name, _spr, _node, _fun, _tag = []) {
		var _n = new NodeObject(_name, _spr, _node, _fun, _tag);
		
		ALL_NODES[? _node] = _n;
		ds_list_add(_list, _n);
	}
	
	function addNodeCatagory(name, list, filter = "") {
		ds_list_add(NODE_CATEGORY, { name: name, list: list, filter: filter });
	}
	
	var group = ds_list_create();
	addNodeCatagory("Group", group, "Node_Group");
	addNodeObject(group, "Input",	s_node_group_input,	"Node_Group_Input",		[1, Node_Group_Input]);
	addNodeObject(group, "Output",	s_node_group_output,"Node_Group_Output",	[1, Node_Group_Output]);
	
	var iter = ds_list_create();
	addNodeCatagory("Loop", iter, "Node_Iterate");
	addNodeObject(iter, "Index",	s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]);
	addNodeObject(iter, "Input",	s_node_loop_input,		"Node_Iterator_Input",	[1, Node_Iterator_Input]);
	addNodeObject(iter, "Output",	s_node_loop_output,		"Node_Iterator_Output",	[1, Node_Iterator_Output]);
	
	var feed = ds_list_create();
	addNodeCatagory("Feedback", feed, "Node_Feedback");
	addNodeObject(feed, "Input",	s_node_feedback_input,	"Node_Feedback_Input",	[1, Node_Feedback_Input]);
	addNodeObject(feed, "Output",	s_node_feedback_output,	"Node_Feedback_Output",	[1, Node_Feedback_Output]);
	
	var vfx = ds_list_create();
	addNodeCatagory("VFX", vfx, "Node_VFX_Group");
	addNodeObject(vfx, "Input",			s_node_vfx_input,	"Node_Group_Input",		[1, Node_Group_Input]);
	addNodeObject(vfx, "Output",		s_node_vfx_output,	"Node_Group_Output",	[1, Node_Group_Output]);
	addNodeObject(vfx, "Spawner",		s_node_vfx_spawn,	"Node_VFX_Spawner",		[1, Node_VFX_Spawner]);
	addNodeObject(vfx, "Renderer",		s_node_vfx_render,	"Node_VFX_Renderer",	[1, Node_VFX_Renderer]);
	addNodeObject(vfx, "Accelerate",	s_node_vfx_accel,	"Node_VFX_Accelerate",	[1, Node_VFX_Accelerate]);
	addNodeObject(vfx, "Destroy",		s_node_vfx_destroy,	"Node_VFX_Destroy",		[1, Node_VFX_Destroy]);
	addNodeObject(vfx, "Attract",		s_node_vfx_attract,	"Node_VFX_Attract",		[1, Node_VFX_Attract]);
	addNodeObject(vfx, "Wind",			s_node_vfx_wind,	"Node_VFX_Wind",		[1, Node_VFX_Wind]);
	addNodeObject(vfx, "Vortex",		s_node_vfx_vortex,	"Node_VFX_Vortex",		[1, Node_VFX_Vortex]);
	addNodeObject(vfx, "Turbulence",	s_node_vfx_turb,	"Node_VFX_Turbulence",	[1, Node_VFX_Turbulence]);
	addNodeObject(vfx, "Repel",			s_node_vfx_repel,	"Node_VFX_Repel",		[1, Node_VFX_Repel]);
	
	var image = ds_list_create();
	NODE_PAGE_DEFAULT = ds_list_size(NODE_CATEGORY);
	ADD_NODE_PAGE = NODE_PAGE_DEFAULT;
	addNodeCatagory("Image", image);
	addNodeObject(image, "Canvas",				s_node_canvas,			"Node_Canvas",					[1, Node_Canvas], ["draw"]);
	addNodeObject(image, "Image",				s_node_image,			"Node_Image",					[0, Node_create_Image]);
	addNodeObject(image, "Image gif",			s_node_image_gif,		"Node_Image_gif",				[0, Node_create_Image_gif]);
	addNodeObject(image, "Splice spritesheet",	s_node_image_sheet,		"Node_Image_Sheet",				[1, Node_Image_Sheet]);
	addNodeObject(image, "Image array",			s_node_image_sequence,	"Node_Image_Sequence",			[0, Node_create_Image_Sequence]);
	addNodeObject(image, "Animation",			s_node_image_animation, "Node_Image_Animated",			[0, Node_create_Image_Animated]);
	addNodeObject(image, "Array to anim",		s_node_image_sequence_to_anim, "Node_Sequence_Anim",	[1, Node_Sequence_Anim]);
	
	var transform = ds_list_create();
	addNodeCatagory("Transform", transform);
	addNodeObject(transform, "Transform",		s_node_transform,		"Node_Transform",		[1, Node_Transform]);
	addNodeObject(transform, "Scale",			s_node_scale,			"Node_Scale",			[1, Node_Scale], ["resize"]);
	addNodeObject(transform, "Crop",			s_node_crop,			"Node_Crop",			[1, Node_Crop]);
	addNodeObject(transform, "Mirror",			s_node_mirror,			"Node_Mirror",			[1, Node_Mirror]);
	addNodeObject(transform, "Warp",			s_node_warp,			"Node_Warp",			[1, Node_Warp], ["wrap"]);
	addNodeObject(transform, "Skew",			s_node_skew,			"Node_Skew",			[1, Node_Skew]);
	addNodeObject(transform, "Mesh warp",		s_node_warp_mesh,		"Node_Mesh_Warp",		[1, Node_Mesh_Warp], ["mesh wrap"]);
	addNodeObject(transform, "Compose",			s_node_compose,			"Node_Composite",		[1, Node_Composite], ["merge"]);
	addNodeObject(transform, "Polar",			s_node_polar,			"Node_Polar",			[1, Node_Polar]);
	addNodeObject(transform, "Nine slice",		s_node_9patch,			"Node_9Slice",			[1, Node_9Slice], ["9", "splice"]);
	addNodeObject(transform, "Padding",			s_node_padding,			"Node_Padding",			[1, Node_Padding]);
	addNodeObject(transform, "Area wrap",		s_node_padding,			"Node_Wrap_Area",		[1, Node_Wrap_Area]);
	
	var filter = ds_list_create();
	addNodeCatagory("Filter", filter);
	addNodeObject(filter, "Blend",				s_node_blend,			"Node_Blend",			[0, Node_create_Blend], ["normal", "add", "subtract", "multiply", "screen", "maxx", "minn"]);
	addNodeObject(filter, "Outline",			s_node_border,			"Node_Outline",			[1, Node_Outline], ["border"]);
	addNodeObject(filter, "Erode",				s_node_erode,			"Node_Erode",			[1, Node_Erode]);
	addNodeObject(filter, "Trail",				s_node_trail,			"Node_Trail",			[1, Node_Trail]);
	addNodeObject(filter, "Blur",				s_node_blur,			"Node_Blur",			[1, Node_Blur], ["gaussian"]);
	addNodeObject(filter, "Directional Blur",	s_node_blur_directional,"Node_Blur_Directional",[1, Node_Blur_Directional]);
	addNodeObject(filter, "Radial Blur",		s_node_blur,			"Node_Blur_Radial",		[1, Node_Blur_Radial]);
	addNodeObject(filter, "Contrast Blur",		s_node_blur_contrast,	"Node_Blur_Contrast",	[1, Node_Blur_Contrast]);
	addNodeObject(filter, "Twirl",				s_node_twirl,			"Node_Twirl",			[1, Node_Twirl], ["twist"]);
	addNodeObject(filter, "Dilate",				s_node_dilate,			"Node_Dilate",			[1, Node_Dilate], ["inflate"]);
	addNodeObject(filter, "Glow",				s_node_glow,			"Node_Glow",			[1, Node_Glow]);
	addNodeObject(filter, "Shadow",				s_node_shadow,			"Node_Shadow",			[1, Node_Shadow]);
	addNodeObject(filter, "Bloom",				s_node_bloom,			"Node_Bloom",			[1, Node_Bloom]);
	addNodeObject(filter, "Replace color",		s_node_color_replace,	"Node_Color_replace",	[1, Node_Color_replace], ["isolate color", "select color"]);
	addNodeObject(filter, "Remove color",		s_node_color_remove,	"Node_Color_Remove",	[1, Node_Color_Remove], ["delete color"]);
	addNodeObject(filter, "Colorize",			s_node_colorize,		"Node_Colorize",		[1, Node_Colorize], ["recolor"]);
	addNodeObject(filter, "Posterize",			s_node_posterize,		"Node_Posterize",		[1, Node_Posterize]);
	addNodeObject(filter, "Dither",				s_node_dithering,		"Node_Dither",			[1, Node_Dither]);
	addNodeObject(filter, "Adjust color",		s_node_color_adjust,	"Node_Color_adjust",	[1, Node_Color_adjust], ["brightness", "contrast", "hue", "saturation", "value", "color blend", "alpha"]);
	addNodeObject(filter, "BW",					s_node_BW,				"Node_BW",				[1, Node_BW], ["black and white"]);
	addNodeObject(filter, "Greyscale",			s_node_greyscale,		"Node_Greyscale",		[1, Node_Greyscale]);
	addNodeObject(filter, "Invert",				s_node_invert,			"Node_Invert",			[1, Node_Invert], ["negate"]);
	addNodeObject(filter, "RGB Channels",		s_node_RGB,				"Node_RGB_Channel",		[1, Node_RGB_Channel], ["channel extract"]);
	addNodeObject(filter, "Level",				s_node_level,			"Node_Level",			[1, Node_Level]);
	addNodeObject(filter, "Level selector",		s_node_level_selector,	"Node_Level_Selector",	[1, Node_Level_Selector]);
	addNodeObject(filter, "Displace",			s_node_displace,		"Node_Displace",		[1, Node_Displace]);
	addNodeObject(filter, "Alpha to grey",		s_node_alpha_grey,		"Node_Alpha_Grey",		[1, Node_Alpha_Grey]);
	addNodeObject(filter, "Alpha cutoff",		s_node_alpha_cut,		"Node_Alpha_Cutoff",	[1, Node_Alpha_Cutoff], ["remove alpha"]);
	addNodeObject(filter, "Grey to alpha",		s_node_grey_alpha,		"Node_Grey_Alpha",		[1, Node_Grey_Alpha]);
	addNodeObject(filter, "De-corner",			s_node_decorner,		"Node_De_Corner",		[1, Node_De_Corner], ["decorner"]);
	addNodeObject(filter, "De-stray",			s_node_destray,			"Node_De_Stray",		[1, Node_De_Stray], ["destray"]);
	addNodeObject(filter, "Texture remap",		s_node_texture_map,		"Node_Texture_Remap",	[1, Node_Texture_Remap]);
	addNodeObject(filter, "Time remap",			s_node_time_map,		"Node_Time_Remap",		[1, Node_Time_Remap]);
	addNodeObject(filter, "2D light",			s_node_2d_light,		"Node_2D_light",		[1, Node_2D_light]);
	addNodeObject(filter, "Atlas",				s_node_atlas,			"Node_Atlas",			[1, Node_Atlas]);
	addNodeObject(filter, "Scale algorithm",	s_node_scale_algo,		"Node_Scale_Algo",		[0, Node_create_Scale_Algo], ["scale2x", "scale3x"]);
	addNodeObject(filter, "Pixel cloud",		s_node_pixel_cloud,		"Node_Pixel_Cloud",		[1, Node_Pixel_Cloud]);
	addNodeObject(filter, "Pixel sort",			s_node_pixel_sort,		"Node_Pixel_Sort",		[1, Node_Pixel_Sort]);
	addNodeObject(filter, "Edge detect",		s_node_edge_detect,		"Node_Edge_Detect",		[1, Node_Edge_Detect]);
	addNodeObject(filter, "Chromatic aberration",	s_node_chromatic_abarration,	"Node_Chromatic_Aberration",	[1, Node_Chromatic_Aberration]);
	//addNodeObject(filter, "Corner",			s_node_corner,			"Node_Corner",			[1, Node_create_Corner]);
	
	var threeD = ds_list_create();
	addNodeCatagory("3D", threeD);
	addNodeObject(threeD, "3D Transform",		s_node_3d_transform,	"Node_3D_Transform",	[1, Node_3D_Transform]);
	addNodeObject(threeD, "Normal",				s_node_normal,			"Node_Normal",			[1, Node_Normal]);
	addNodeObject(threeD, "Normal light",		s_node_normal_light,	"Node_Normal_Light",	[1, Node_Normal_Light]);
	addNodeObject(threeD, "Bevel",				s_node_bevel,			"Node_Bevel",			[1, Node_Bevel]);
	addNodeObject(threeD, "Sprite stack",		s_node_stack,			"Node_Sprite_Stack",	[1, Node_Sprite_Stack]);
	addNodeObject(threeD, "3D Obj",				s_node_3d_obj,			"Node_3D_Obj",			[1, Node_3D_Obj]);
	addNodeObject(threeD, "3D Cube",			s_node_3d_cube,			"Node_3D_Cube",			[1, Node_3D_Cube]);
	addNodeObject(threeD, "3D Cylinder",		s_node_3d_cylinder,		"Node_3D_Cylinder",		[1, Node_3D_Cylinder]);
	addNodeObject(threeD, "3D Extrude",			s_node_3d_extrude,		"Node_3D_Extrude",		[1, Node_3D_Extrude]);
	
	var generator = ds_list_create();
	addNodeCatagory("Generate", generator);
	addNodeObject(generator, "Solid",				s_node_solid,				"Node_Solid",				[1, Node_Solid]);
	addNodeObject(generator, "Gradient",			s_node_gradient,			"Node_Gradient",			[1, Node_Gradient]);
	addNodeObject(generator, "4 Points Gradient",	s_node_gradient_4points,	"Node_Gradient_Points",		[1, Node_Gradient_Points]);
	addNodeObject(generator, "Line",				s_node_line,				"Node_Line",				[1, Node_Line]);
	addNodeObject(generator, "Stripe",				s_node_stripe,				"Node_Stripe",				[1, Node_Stripe]);
	addNodeObject(generator, "Zigzag",				s_node_zigzag,				"Node_Zigzag",				[1, Node_Zigzag]);
	addNodeObject(generator, "Checker",				s_node_checker,				"Node_Checker",				[1, Node_Checker]);
	addNodeObject(generator, "Shape",				s_node_shape,				"Node_Shape",				[1, Node_Shape]);
	addNodeObject(generator, "Particle",			s_node_particle,			"Node_Particle",			[1, Node_Particle]);
	addNodeObject(generator, "VFX",					s_node_vfx,					"Node_VFX_Group",			[1, Node_VFX_Group]);
	//addNodeObject(generator, "Particle Effector",	s_node_particle_effector,	"Node_Particle_Effector",	[1, Node_Particle_Effector], ["affector"]);
	addNodeObject(generator, "Scatter",				s_node_scatter,				"Node_Scatter",				[1, Node_Scatter]);
	addNodeObject(generator, "Noise",				s_node_noise,				"Node_Noise",				[1, Node_Noise]);
	addNodeObject(generator, "Perlin noise",		s_node_noise_perlin,		"Node_Perlin",				[1, Node_Perlin]);
	addNodeObject(generator, "Cellular noise",		s_node_noise_cell,			"Node_Cellular",			[1, Node_Cellular], ["Voronoi", "Worley"]);
	addNodeObject(generator, "Grid noise",			s_node_grid_noise,			"Node_Grid_Noise",			[1, Node_Grid_Noise]);
	addNodeObject(generator, "Grid",				s_node_grid,				"Node_Grid",				[1, Node_Grid], ["tile"]);
	addNodeObject(generator, "Grid triangle",		s_node_grid_tri,			"Node_Grid_Tri",			[1, Node_Grid_Tri]);
	addNodeObject(generator, "Grid hexagonal",		s_node_grid_hex,			"Node_Grid_Hex",			[1, Node_Grid_Hex]);
	addNodeObject(generator, "Anisotropic noise",	s_node_noise_aniso,			"Node_Noise_Aniso",			[1, Node_Noise_Aniso]);
	addNodeObject(generator, "Seperate shape",	    s_node_sepearte_shape,		"Node_Seperate_Shape",		[1, Node_Seperate_Shape]);
	addNodeObject(generator, "Draw text",			s_node_text_render,			"Node_Text",				[1, Node_Text]);
	
	var renderNode = ds_list_create();
	addNodeCatagory("Render", renderNode);
	addNodeObject(renderNode, "Render sprite sheet",	s_node_sprite_sheet,	"Node_Render_Sprite_Sheet",	[1, Node_Render_Sprite_Sheet]);
	addNodeObject(renderNode, "Export",					s_node_export,			"Node_Export",				[0, Node_create_Export]);
	addNodeObject(renderNode, "Camera",					s_node_camera,			"Node_Camera",				[1, Node_Camera]);
	//addNodeObject(renderNode, "Preview timeline",		s_node_timeline_preview,"Node_Timeline_Preview",	[1, Node_create_Timeline_Preview]);
	
	var values = ds_list_create();
	addNodeCatagory("Values", values);
	addNodeObject(values, "Math",			s_node_math,			"Node_Math",			[0, Node_create_Math], ["add", "subtract", "multiply", "divide", "power", "modulo", "round", "ceiling", "floor", "sin", "cos", "tan"]);
	addNodeObject(values, "Statistic",		s_node_statistic,		"Node_Statistic",		[0, Node_create_Statistic], ["sum", "average", "mean", "median", "min", "max"]);
	addNodeObject(values, "Number",			s_node_number,			"Node_Number",			[1, Node_Number]);
	addNodeObject(values, "Vector2",		s_node_vec2,			"Node_Vector2",			[1, Node_Vector2]);
	addNodeObject(values, "Vector3",		s_node_vec3,			"Node_Vector3",			[1, Node_Vector3]);
	addNodeObject(values, "Vector4",		s_node_vec4,			"Node_Vector4",			[1, Node_Vector4]);
	addNodeObject(values, "Vector split",	s_node_vec_split,		"Node_Vector_Split",	[1, Node_Vector_Split]);
	addNodeObject(values, "Unicode",		s_node_unicode,			"Node_Unicode",			[1, Node_Unicode]);
	addNodeObject(values, "Text",			s_node_text,			"Node_String",			[1, Node_String]);
	addNodeObject(values, "Split text",		s_node_text_splice,		"Node_String_Split",	[1, Node_String_Split]);
	addNodeObject(values, "Path",			s_node_path,			"Node_Path",			[1, Node_Path]);
	addNodeObject(values, "Area",			s_node_area,			"Node_Area",			[1, Node_Area]);
	addNodeObject(values, "Array",			s_node_array,			"Node_Array",			[1, Node_Array]);
	addNodeObject(values, "Array range",	s_node_array_range,		"Node_Array_Range",		[1, Node_Array_Range]);
	addNodeObject(values, "Array add",		s_node_array_add,		"Node_Array_Add",		[1, Node_Array_Add]);
	addNodeObject(values, "Array length",	s_node_array_length,	"Node_Array_Length",	[1, Node_Array_Length]);
	addNodeObject(values, "Array get",		s_node_array_get,		"Node_Array_Get",		[1, Node_Array_Get]);
	//addNodeObject(number, "Surface data",	s_node_surface_data,	"Node_Surface_data",	[1, Node_Surface_data]);
	
	var color = ds_list_create();
	addNodeCatagory("Color", color);
	addNodeObject(color, "Color",		s_node_color_out,		"Node_Color",			[1, Node_Color]);
	addNodeObject(color, "RGB Color",	s_node_color_from_rgb,	"Node_Color_RGB",		[1, Node_Color_RGB]);
	addNodeObject(color, "HSV Color",	s_node_color_from_hsv,	"Node_Color_HSV",		[1, Node_Color_HSV]);
	addNodeObject(color, "Palette",		s_node_palette,			"Node_Palette",			[1, Node_Palette]);
	addNodeObject(color, "Gradient",	s_node_gradient_out,	"Node_Gradient_Out",	[1, Node_Gradient_Out]);
	addNodeObject(color, "Sampler",		s_node_sampler,			"Node_Sampler",			[1, Node_Sampler]);
	addNodeObject(color, "Color data",	s_node_color_data,		"Node_Color_Data",		[1, Node_Color_Data]);
	
	var animation = ds_list_create();
	addNodeCatagory("Animation", animation);
	addNodeObject(animation, "Counter",	s_node_counter,	"Node_Counter",		[1, Node_Counter]);
	addNodeObject(animation, "Wiggler", s_node_wiggler,	"Node_Wiggler",		[1, Node_Wiggler]);
	addNodeObject(animation, "Curve",	s_node_curve,	"Node_Anim_Curve",	[1, Node_Anim_Curve]);
	
	var node = ds_list_create();
	addNodeCatagory("Node", node);
	addNodeObject(node, "Group",			s_node_group,		"Node_Group",			[1, Node_Group]);
	addNodeObject(node, "Feedback",			s_node_feedback,	"Node_Feedback",		[1, Node_Feedback]);
	addNodeObject(node, "Loop",				s_node_loop,		"Node_Iterate",			[1, Node_Iterate]);
	addNodeObject(node, "Pin",				s_node_pin,			"Node_Pin",				[1, Node_Pin]);
	addNodeObject(node, "Frame",			s_node_frame,		"Node_Frame",			[1, Node_Frame]);
	addNodeObject(node, "Display text",		s_node_text,		"Node_Display_Text",	[1, Node_Display_Text]);
	addNodeObject(node, "Display image",	s_node_image,		"Node_Display_Image",	[0, Node_create_Display_Image]);
	addNodeObject(node, "Condition",		s_node_condition,	"Node_Condition",		[1, Node_Condition]);
#endregion

#region node function
	function nodeLoad(_data, scale = false) {
		if(!ds_exists(_data, ds_type_map)) return noone;
		
		var _x    = ds_map_try_get(_data, "x", 0);
		var _y    = ds_map_try_get(_data, "y", 0);
		var _type = ds_map_try_get(_data, "type", 0);
		var _node = nodeBuild(_type, _x, _y);
		
		if(_node) {
			var map = ds_map_clone(_data);
			_node.deserialize(map, scale);
		}
			
		return _node;
	}
	
	function nodeDelete(node, _merge = false) {
		var list = node.group == -1? NODES : node.group.nodes;
		ds_list_delete(list, ds_list_find_index(list, node));
		node.destroy(_merge);
		
		recordAction(ACTION_TYPE.node_delete, node);
	}
	
	function nodeCleanUp() {
		var key = ds_map_find_first(NODE_MAP);
		repeat(ds_map_size(NODE_MAP)) {
			if(NODE_MAP[? key]) {
				NODE_MAP[? key].cleanUp();
				delete NODE_MAP[? key];
			}
			key = ds_map_find_next(NODE_MAP, key);
		}
		ds_map_clear(NODE_MAP);
		ds_list_clear(NODES);	
	}
#endregion