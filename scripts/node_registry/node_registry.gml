function NodeObject(_name, _spr, _node, _create, tags = []) constructor {
	name = _name;
	spr  = _spr;
	node = _node;
	createNode = _create;
	
	new_node = false;
	
	self.tags = tags;
	
	static set_version = function(version) {
		new_node = version == VERSION;
		return self;
	}
	
	function build(_x, _y, _group = PANEL_GRAPH.getCurrentContext(), _param = "") {
		var _node = createNode[0]? new createNode[1](_x, _y, _group, _param) : createNode[1](_x, _y, _group, _param);
		_node.doUpdate();
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
		
		return _n;
	}
	
	function addNodeCatagory(name, list, filter = "") {
		ds_list_add(NODE_CATEGORY, { name: name, list: list, filter: filter });
	}
	
	var group = ds_list_create();
	addNodeCatagory("Group", group, "Node_Group");
		ds_list_add(group, "Groups");
		addNodeObject(group, "Input",	s_node_group_input,	"Node_Group_Input",		[1, Node_Group_Input]);
		addNodeObject(group, "Output",	s_node_group_output,"Node_Group_Output",	[1, Node_Group_Output]);
	
	var iter = ds_list_create();
	addNodeCatagory("Loop", iter, "Node_Iterate");
		ds_list_add(iter, "Groups");
		addNodeObject(iter, "Input",	s_node_loop_input,		"Node_Iterator_Input",	[1, Node_Iterator_Input]);
		addNodeObject(iter, "Output",	s_node_loop_output,		"Node_Iterator_Output",	[1, Node_Iterator_Output]);
		
		ds_list_add(iter, "Loops");
		addNodeObject(iter, "Index",	s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]);
	
	var feed = ds_list_create();
	addNodeCatagory("Feedback", feed, "Node_Feedback");
		ds_list_add(feed, "Groups");
		addNodeObject(feed, "Input",	s_node_feedback_input,	"Node_Feedback_Input",	[1, Node_Feedback_Input]);
		addNodeObject(feed, "Output",	s_node_feedback_output,	"Node_Feedback_Output",	[1, Node_Feedback_Output]);
	
	var vfx = ds_list_create();
	addNodeCatagory("VFX", vfx, "Node_VFX_Group");
		ds_list_add(vfx, "Groups");
		addNodeObject(vfx, "Input",			s_node_vfx_input,	"Node_Group_Input",		[1, Node_Group_Input]);
		addNodeObject(vfx, "Output",		s_node_vfx_output,	"Node_Group_Output",	[1, Node_Group_Output]);
		
		ds_list_add(vfx, "VFXs");
		addNodeObject(vfx, "Spawner",		s_node_vfx_spawn,	"Node_VFX_Spawner",		[1, Node_VFX_Spawner]);
		addNodeObject(vfx, "Renderer",		s_node_vfx_render,	"Node_VFX_Renderer",	[1, Node_VFX_Renderer]);
		
		ds_list_add(vfx, "Affectors");
		addNodeObject(vfx, "Accelerate",	s_node_vfx_accel,	"Node_VFX_Accelerate",	[1, Node_VFX_Accelerate]);
		addNodeObject(vfx, "Destroy",		s_node_vfx_destroy,	"Node_VFX_Destroy",		[1, Node_VFX_Destroy]);
		addNodeObject(vfx, "Attract",		s_node_vfx_attract,	"Node_VFX_Attract",		[1, Node_VFX_Attract]);
		addNodeObject(vfx, "Wind",			s_node_vfx_wind,	"Node_VFX_Wind",		[1, Node_VFX_Wind]);
		addNodeObject(vfx, "Vortex",		s_node_vfx_vortex,	"Node_VFX_Vortex",		[1, Node_VFX_Vortex]);
		addNodeObject(vfx, "Turbulence",	s_node_vfx_turb,	"Node_VFX_Turbulence",	[1, Node_VFX_Turbulence]);
		addNodeObject(vfx, "Repel",			s_node_vfx_repel,	"Node_VFX_Repel",		[1, Node_VFX_Repel]);
	
	var input = ds_list_create();
	NODE_PAGE_DEFAULT = ds_list_size(NODE_CATEGORY);
	ADD_NODE_PAGE = NODE_PAGE_DEFAULT;
	addNodeCatagory("IO", input);
		ds_list_add(input, "Images");
		addNodeObject(input, "Canvas",				s_node_canvas,			"Node_Canvas",					[1, Node_Canvas], ["draw"]);
		addNodeObject(input, "Image",				s_node_image,			"Node_Image",					[0, Node_create_Image]);
		addNodeObject(input, "Image gif",			s_node_image_gif,		"Node_Image_gif",				[0, Node_create_Image_gif]);
		addNodeObject(input, "Splice spritesheet",	s_node_image_sheet,		"Node_Image_Sheet",				[1, Node_Image_Sheet]);
		addNodeObject(input, "Image array",			s_node_image_sequence,	"Node_Image_Sequence",			[0, Node_create_Image_Sequence]);
		addNodeObject(input, "Animation",			s_node_image_animation, "Node_Image_Animated",			[0, Node_create_Image_Animated]);
		addNodeObject(input, "Array to anim",		s_node_image_sequence_to_anim, "Node_Sequence_Anim",	[1, Node_Sequence_Anim]);
		addNodeObject(input, "Export",				s_node_export,			"Node_Export",					[0, Node_create_Export]);
		
		ds_list_add(input, "Files");
		addNodeObject(input, "Text file in",		s_node_text_file_read,	"Node_Text_File_Read",			[1, Node_Text_File_Read], ["txt"]).set_version(1080);
		addNodeObject(input, "Text file out",		s_node_text_file_write,	"Node_Text_File_Write",			[1, Node_Text_File_Write], ["txt"]).set_version(1090);
		addNodeObject(input, "CSV file in",			s_node_csv_file_read,	"Node_CSV_File_Read",			[1, Node_CSV_File_Read], ["comma"]).set_version(1090);
		addNodeObject(input, "JSON file in",		s_node_json_file_read,	"Node_Json_File_Read",			[1, Node_Json_File_Read]).set_version(1090);
		addNodeObject(input, "JSON file out",		s_node_json_file_write,	"Node_Json_File_Write",			[1, Node_Json_File_Write]).set_version(1090);
	
	var transform = ds_list_create();
	addNodeCatagory("Transform", transform);
		ds_list_add(transform, "Transformations");
		addNodeObject(transform, "Transform",		s_node_transform,		"Node_Transform",		[1, Node_Transform]);
		addNodeObject(transform, "Scale",			s_node_scale,			"Node_Scale",			[1, Node_Scale], ["resize"]);
		addNodeObject(transform, "Scale algorithm",	s_node_scale_algo,		"Node_Scale_Algo",		[0, Node_create_Scale_Algo], ["scale2x", "scale3x"]);
		addNodeObject(transform, "Flip",			s_node_flip,			"Node_Flip",			[1, Node_Flip]);
		
		ds_list_add(transform, "Warps");
		addNodeObject(transform, "Crop",			s_node_crop,			"Node_Crop",			[1, Node_Crop]);
		addNodeObject(transform, "Warp",			s_node_warp,			"Node_Warp",			[1, Node_Warp], ["wrap"]);
		addNodeObject(transform, "Skew",			s_node_skew,			"Node_Skew",			[1, Node_Skew]);
		addNodeObject(transform, "Mesh warp",		s_node_warp_mesh,		"Node_Mesh_Warp",		[1, Node_Mesh_Warp], ["mesh wrap"]);
		addNodeObject(transform, "Polar",			s_node_polar,			"Node_Polar",			[1, Node_Polar]);
		addNodeObject(transform, "Area warp",		s_node_padding,			"Node_Wrap_Area",		[1, Node_Wrap_Area]);
		
		ds_list_add(transform, "Others");
		addNodeObject(transform, "Compose",			s_node_compose,			"Node_Composite",		[1, Node_Composite], ["merge"]);
		addNodeObject(transform, "Nine slice",		s_node_9patch,			"Node_9Slice",			[1, Node_9Slice], ["9", "splice"]);
		addNodeObject(transform, "Padding",			s_node_padding,			"Node_Padding",			[1, Node_Padding]);
		
	var filter = ds_list_create();
	addNodeCatagory("Filter", filter);
		ds_list_add(filter, "Combines");
		addNodeObject(filter, "Blend",				s_node_blend,			"Node_Blend",			[0, Node_create_Blend], ["normal", "add", "subtract", "multiply", "screen", "maxx", "minn"]);
		addNodeObject(filter, "RGB combine",		s_node_RGB_combine,		"Node_Combine_RGB",		[1, Node_Combine_RGB]).set_version(1070);
		addNodeObject(filter, "HSV combine",		s_node_HSV_combine,		"Node_Combine_HSV",		[1, Node_Combine_HSV]).set_version(1070);
		
		ds_list_add(filter, "Blurs");
		addNodeObject(filter, "Blur",				s_node_blur,			"Node_Blur",			[1, Node_Blur], ["gaussian"]);
		addNodeObject(filter, "Blur simple",		s_node_blur_simple,		"Node_Blur_Simple",		[1, Node_Blur_Simple]).set_version(1070);
		addNodeObject(filter, "Directional Blur",	s_node_blur_directional,"Node_Blur_Directional",[1, Node_Blur_Directional]);
		addNodeObject(filter, "Radial Blur",		s_node_blur,			"Node_Blur_Radial",		[1, Node_Blur_Radial]);
		addNodeObject(filter, "Contrast Blur",		s_node_blur_contrast,	"Node_Blur_Contrast",	[1, Node_Blur_Contrast]);
		
		ds_list_add(filter, "Warps");
		addNodeObject(filter, "Mirror",				s_node_mirror,			"Node_Mirror",			[1, Node_Mirror]).set_version(1070);
		addNodeObject(filter, "Twirl",				s_node_twirl,			"Node_Twirl",			[1, Node_Twirl], ["twist"]);
		addNodeObject(filter, "Dilate",				s_node_dilate,			"Node_Dilate",			[1, Node_Dilate], ["inflate"]);
		addNodeObject(filter, "Displace",			s_node_displace,		"Node_Displace",		[1, Node_Displace]);
		addNodeObject(filter, "Texture remap",		s_node_texture_map,		"Node_Texture_Remap",	[1, Node_Texture_Remap]);
		addNodeObject(filter, "Time remap",			s_node_time_map,		"Node_Time_Remap",		[1, Node_Time_Remap]);
		
		ds_list_add(filter, "Effects");
		addNodeObject(filter, "Outline",			s_node_border,			"Node_Outline",			[1, Node_Outline], ["border"]);
		addNodeObject(filter, "Glow",				s_node_glow,			"Node_Glow",			[1, Node_Glow]);
		addNodeObject(filter, "Shadow",				s_node_shadow,			"Node_Shadow",			[1, Node_Shadow]);
		addNodeObject(filter, "Bloom",				s_node_bloom,			"Node_Bloom",			[1, Node_Bloom]);
		addNodeObject(filter, "Trail",				s_node_trail,			"Node_Trail",			[1, Node_Trail]);
		addNodeObject(filter, "Erode",				s_node_erode,			"Node_Erode",			[1, Node_Erode]);
		addNodeObject(filter, "2D light",			s_node_2d_light,		"Node_2D_light",		[1, Node_2D_light]);
		addNodeObject(filter, "Atlas",				s_node_atlas,			"Node_Atlas",			[1, Node_Atlas]);
		addNodeObject(filter, "Pixel cloud",		s_node_pixel_cloud,		"Node_Pixel_Cloud",		[1, Node_Pixel_Cloud]);
		addNodeObject(filter, "Pixel sort",			s_node_pixel_sort,		"Node_Pixel_Sort",		[1, Node_Pixel_Sort]);
		addNodeObject(filter, "Edge detect",		s_node_edge_detect,		"Node_Edge_Detect",		[1, Node_Edge_Detect]);
		addNodeObject(filter, "Convolution",		s_node_convolution,		"Node_Convolution",		[1, Node_Convolution]).set_version(1090);
		addNodeObject(filter, "Chromatic aberration",	s_node_chromatic_abarration,	"Node_Chromatic_Aberration",	[1, Node_Chromatic_Aberration]);
		
		ds_list_add(filter, "Colors");
		addNodeObject(filter, "Replace color",		s_node_color_replace,	"Node_Color_replace",	[1, Node_Color_replace], ["isolate color", "select color"]);
		addNodeObject(filter, "Remove color",		s_node_color_remove,	"Node_Color_Remove",	[1, Node_Color_Remove], ["delete color"]);
		addNodeObject(filter, "Colorize",			s_node_colorize,		"Node_Colorize",		[1, Node_Colorize], ["recolor"]);
		addNodeObject(filter, "Posterize",			s_node_posterize,		"Node_Posterize",		[1, Node_Posterize]);
		addNodeObject(filter, "Dither",				s_node_dithering,		"Node_Dither",			[1, Node_Dither]);
		addNodeObject(filter, "Adjust color",		s_node_color_adjust,	"Node_Color_adjust",	[1, Node_Color_adjust], ["brightness", "contrast", "hue", "saturation", "value", "color blend", "alpha"]);
		addNodeObject(filter, "BW",					s_node_BW,				"Node_BW",				[1, Node_BW], ["black and white"]);
		addNodeObject(filter, "Greyscale",			s_node_greyscale,		"Node_Greyscale",		[1, Node_Greyscale]);
		addNodeObject(filter, "Invert",				s_node_invert,			"Node_Invert",			[1, Node_Invert], ["negate"]);
		addNodeObject(filter, "Level",				s_node_level,			"Node_Level",			[1, Node_Level]);
		addNodeObject(filter, "Level selector",		s_node_level_selector,	"Node_Level_Selector",	[1, Node_Level_Selector]);
		addNodeObject(filter, "Threshold",			s_node_threshold,		"Node_Threshold",		[1, Node_Threshold]).set_version(1080);
		
		ds_list_add(filter, "Conversions");
		addNodeObject(filter, "RGB extract",		s_node_RGB,				"Node_RGB_Channel",		[1, Node_RGB_Channel], ["channel extract"]);
		addNodeObject(filter, "HSV extract",		s_node_HSV,				"Node_HSV_Channel",		[1, Node_HSV_Channel]).set_version(1070);
		addNodeObject(filter, "Alpha to grey",		s_node_alpha_grey,		"Node_Alpha_Grey",		[1, Node_Alpha_Grey]);
		addNodeObject(filter, "Alpha cutoff",		s_node_alpha_cut,		"Node_Alpha_Cutoff",	[1, Node_Alpha_Cutoff], ["remove alpha"]);
		addNodeObject(filter, "Grey to alpha",		s_node_grey_alpha,		"Node_Grey_Alpha",		[1, Node_Grey_Alpha]);
		
		ds_list_add(filter, "Fixes");
		addNodeObject(filter, "De-corner",			s_node_decorner,		"Node_De_Corner",		[1, Node_De_Corner], ["decorner"]);
		addNodeObject(filter, "De-stray",			s_node_destray,			"Node_De_Stray",		[1, Node_De_Stray], ["destray"]);
	
	var threeD = ds_list_create();
	addNodeCatagory("3D", threeD);
		ds_list_add(threeD, "2D operations");
		addNodeObject(threeD, "Normal",				s_node_normal,			"Node_Normal",			[1, Node_Normal]);
		addNodeObject(threeD, "Normal light",		s_node_normal_light,	"Node_Normal_Light",	[1, Node_Normal_Light]);
		addNodeObject(threeD, "Bevel",				s_node_bevel,			"Node_Bevel",			[1, Node_Bevel]);
		addNodeObject(threeD, "Sprite stack",		s_node_stack,			"Node_Sprite_Stack",	[1, Node_Sprite_Stack]);
	
		ds_list_add(threeD, "3D generates");
		addNodeObject(threeD, "3D Object",			s_node_3d_obj,			"Node_3D_Obj",			[1, Node_3D_Obj]);
		addNodeObject(threeD, "3D Plane",			s_node_3d_plane,		"Node_3D_Plane",		[1, Node_3D_Plane]);
		addNodeObject(threeD, "3D Cube",			s_node_3d_cube,			"Node_3D_Cube",			[1, Node_3D_Cube]);
		addNodeObject(threeD, "3D Cylinder",		s_node_3d_cylinder,		"Node_3D_Cylinder",		[1, Node_3D_Cylinder]);
		addNodeObject(threeD, "3D Extrude",			s_node_3d_extrude,		"Node_3D_Extrude",		[1, Node_3D_Extrude]);
	
		ds_list_add(threeD, "3D operations");
		addNodeObject(threeD, "3D Transform",		s_node_3d_transform,	"Node_3D_Transform",	[1, Node_3D_Transform]).set_version(1080);
		addNodeObject(threeD, "3D Combine",			s_node_3d_obj_combine,	"Node_3D_Combine",		[1, Node_3D_Combine]).set_version(1080);
		addNodeObject(threeD, "3D Repeat",			s_node_3d_array,		"Node_3D_Repeat",		[1, Node_3D_Repeat], ["array", "3d array"]).set_version(1080);
	
	var generator = ds_list_create();
	addNodeCatagory("Generate", generator);
		ds_list_add(generator, "Colors");
		addNodeObject(generator, "Solid",				s_node_solid,				"Node_Solid",				[1, Node_Solid]);
		addNodeObject(generator, "Gradient",			s_node_gradient,			"Node_Gradient",			[1, Node_Gradient]);
		addNodeObject(generator, "4 Points Gradient",	s_node_gradient_4points,	"Node_Gradient_Points",		[1, Node_Gradient_Points]);
		
		ds_list_add(generator, "Drawer");
		addNodeObject(generator, "Line",				s_node_line,				"Node_Line",				[1, Node_Line]);
		addNodeObject(generator, "Draw text",			s_node_text_render,			"Node_Text",				[1, Node_Text]);
		addNodeObject(generator, "Shape",				s_node_shape,				"Node_Shape",				[1, Node_Shape]);
		
		ds_list_add(generator, "Noises");
		addNodeObject(generator, "Noise",				s_node_noise,				"Node_Noise",				[1, Node_Noise]);
		addNodeObject(generator, "Perlin noise",		s_node_noise_perlin,		"Node_Perlin",				[1, Node_Perlin]);
		addNodeObject(generator, "Simplex noise",		s_node_noise_simplex,		"Node_Noise_Simplex",		[1, Node_Noise_Simplex], ["perlin"]).set_version(1080);
		addNodeObject(generator, "Cellular noise",		s_node_noise_cell,			"Node_Cellular",			[1, Node_Cellular], ["voronoi", "worley"]);
		addNodeObject(generator, "Grid noise",			s_node_grid_noise,			"Node_Grid_Noise",			[1, Node_Grid_Noise]);
		addNodeObject(generator, "Anisotropic noise",	s_node_noise_aniso,			"Node_Noise_Aniso",			[1, Node_Noise_Aniso]);
		
		ds_list_add(generator, "Patterns");
		addNodeObject(generator, "Stripe",				s_node_stripe,				"Node_Stripe",				[1, Node_Stripe]);
		addNodeObject(generator, "Zigzag",				s_node_zigzag,				"Node_Zigzag",				[1, Node_Zigzag]);
		addNodeObject(generator, "Checker",				s_node_checker,				"Node_Checker",				[1, Node_Checker]);
		addNodeObject(generator, "Grid",				s_node_grid,				"Node_Grid",				[1, Node_Grid], ["tile"]);
		addNodeObject(generator, "Grid triangle",		s_node_grid_tri,			"Node_Grid_Tri",			[1, Node_Grid_Tri]);
		addNodeObject(generator, "Grid hexagonal",		s_node_grid_hex,			"Node_Grid_Hex",			[1, Node_Grid_Hex]);
		
		ds_list_add(generator, "Particles");
		addNodeObject(generator, "Particle",			s_node_particle,			"Node_Particle",			[1, Node_Particle]);
		addNodeObject(generator, "VFX",					s_node_vfx,					"Node_VFX_Group",			[1, Node_VFX_Group]);
		addNodeObject(generator, "Scatter",				s_node_scatter,				"Node_Scatter",				[1, Node_Scatter]);
		
		ds_list_add(generator, "Others");
		addNodeObject(generator, "Seperate shape",	    s_node_sepearte_shape,		"Node_Seperate_Shape",		[1, Node_Seperate_Shape]);
	
	var compose = ds_list_create();
	addNodeCatagory("Compose", compose);
		ds_list_add(compose, "Composes");
		addNodeObject(compose, "Blend",		s_node_blend,		"Node_Blend",		[1, Node_Blend]);
		addNodeObject(compose, "Compose",	s_node_compose,		"Node_Composite",	[1, Node_Composite]);
		addNodeObject(compose, "Stack",		s_node_draw_stack,	"Node_Stack",		[1, Node_Stack]).set_version(1070);
	
	var renderNode = ds_list_create();
	addNodeCatagory("Render", renderNode);
		ds_list_add(renderNode, "Renders");
		addNodeObject(renderNode, "Render sprite sheet",	s_node_sprite_sheet,	"Node_Render_Sprite_Sheet",	[1, Node_Render_Sprite_Sheet]);
		addNodeObject(renderNode, "Export",					s_node_export,			"Node_Export",				[0, Node_create_Export]);
		addNodeObject(renderNode, "Camera",					s_node_camera,			"Node_Camera",				[1, Node_Camera]);
		//addNodeObject(renderNode, "Preview timeline",		s_node_timeline_preview,"Node_Timeline_Preview",	[1, Node_create_Timeline_Preview]);
	
	var values = ds_list_create();
	addNodeCatagory("Values", values);
		ds_list_add(values, "Data types");
		addNodeObject(values, "Path",			s_node_path,			"Node_Path",			[1, Node_Path]);
		addNodeObject(values, "Area",			s_node_area,			"Node_Area",			[1, Node_Area]);
	
		ds_list_add(values, "Numbers");
		addNodeObject(values, "Number",			s_node_number,			"Node_Number",			[1, Node_Number]);
		addNodeObject(values, "Math",			s_node_math,			"Node_Math",			[0, Node_create_Math], ["add", "subtract", "multiply", "divide", "power", "modulo", "round", "ceiling", "floor", "sin", "cos", "tan"]);
		addNodeObject(values, "Compare",		s_node_compare,			"Node_Compare",			[0, Node_create_Compare], ["equal", "greater", "lesser"]);
		addNodeObject(values, "Statistic",		s_node_statistic,		"Node_Statistic",		[0, Node_create_Statistic], ["sum", "average", "mean", "median", "min", "max"]);
		addNodeObject(values, "Vector2",		s_node_vec2,			"Node_Vector2",			[1, Node_Vector2]);
		addNodeObject(values, "Vector3",		s_node_vec3,			"Node_Vector3",			[1, Node_Vector3]);
		addNodeObject(values, "Vector4",		s_node_vec4,			"Node_Vector4",			[1, Node_Vector4]);
		addNodeObject(values, "Vector split",	s_node_vec_split,		"Node_Vector_Split",	[1, Node_Vector_Split]);
	
		ds_list_add(values, "Texts");
		addNodeObject(values, "Text",			s_node_text,			"Node_String",			[1, Node_String]);
		addNodeObject(values, "Unicode",		s_node_unicode,			"Node_Unicode",			[1, Node_Unicode]);
		addNodeObject(values, "Split text",		s_node_text_splice,		"Node_String_Split",	[1, Node_String_Split]);
		addNodeObject(values, "Trim text",		s_node_text_trim,		"Node_String_Trim",		[1, Node_String_Trim]).set_version(1080);
	
		ds_list_add(values, "Arrays");
		addNodeObject(values, "Array create",		s_node_array,			"Node_Array",			[1, Node_Array]);
		addNodeObject(values, "Array create range",	s_node_array_range,		"Node_Array_Range",		[1, Node_Array_Range]);
		addNodeObject(values, "Array add",			s_node_array_add,		"Node_Array_Add",		[1, Node_Array_Add]);
		addNodeObject(values, "Array length",		s_node_array_length,	"Node_Array_Length",	[1, Node_Array_Length]);
		addNodeObject(values, "Array get",			s_node_array_get,		"Node_Array_Get",		[1, Node_Array_Get]);
	
	var color = ds_list_create();
	addNodeCatagory("Color", color);
		ds_list_add(color, "Colors");
		addNodeObject(color, "Color",			s_node_color_out,		"Node_Color",			[1, Node_Color]);
		addNodeObject(color, "RGB Color",		s_node_color_from_rgb,	"Node_Color_RGB",		[1, Node_Color_RGB]);
		addNodeObject(color, "HSV Color",		s_node_color_from_hsv,	"Node_Color_HSV",		[1, Node_Color_HSV]);
		addNodeObject(color, "Palette",			s_node_palette,			"Node_Palette",			[1, Node_Palette]);
		addNodeObject(color, "Gradient data",	s_node_gradient_out,	"Node_Gradient_Out",	[1, Node_Gradient_Out]);
		addNodeObject(color, "Sampler",			s_node_sampler,			"Node_Sampler",			[1, Node_Sampler]);
		addNodeObject(color, "Color data",		s_node_color_data,		"Node_Color_Data",		[1, Node_Color_Data]);
	
	var animation = ds_list_create();
	addNodeCatagory("Animation", animation);
		ds_list_add(animation, "Animations");
		addNodeObject(animation, "Counter",	s_node_counter,	"Node_Counter",		[1, Node_Counter]);
		addNodeObject(animation, "Wiggler", s_node_wiggler,	"Node_Wiggler",		[1, Node_Wiggler]);
		addNodeObject(animation, "Curve",	s_node_curve,	"Node_Anim_Curve",	[1, Node_Anim_Curve]);
	
	var node = ds_list_create();
	addNodeCatagory("Node", node);
		ds_list_add(node, "Logic");
		addNodeObject(node, "Condition",		s_node_condition,	"Node_Condition",	[1, Node_Condition]);
		addNodeObject(node, "Switch",			s_node_switch,		"Node_Switch",		[1, Node_Switch]).set_version(1090);
		
		ds_list_add(node, "Groups");
		addNodeObject(node, "Group",			s_node_group,		"Node_Group",			[1, Node_Group]);
		addNodeObject(node, "Feedback",			s_node_feedback,	"Node_Feedback",		[1, Node_Feedback]);
		addNodeObject(node, "Loop",				s_node_loop,		"Node_Iterate",			[1, Node_Iterate]);
		
		ds_list_add(node, "Lua");
		addNodeObject(node, "Lua global",		s_node_lua_global,	"Node_Lua_Global",		[1, Node_Lua_Global]).set_version(1090);
		addNodeObject(node, "Lua surface",		s_node_lua_surface,	"Node_Lua_Surface",		[1, Node_Lua_Surface]).set_version(1090);
		addNodeObject(node, "Lua compute",		s_node_lua_compute,	"Node_Lua_Compute",		[1, Node_Lua_Compute]).set_version(1090);
		
		ds_list_add(node, "Organize");
		addNodeObject(node, "Pin",				s_node_pin,			"Node_Pin",				[1, Node_Pin]);
		addNodeObject(node, "Frame",			s_node_frame,		"Node_Frame",			[1, Node_Frame]);
		addNodeObject(node, "Display text",		s_node_text_display,"Node_Display_Text",	[1, Node_Display_Text]);
		addNodeObject(node, "Display image",	s_node_image,		"Node_Display_Image",	[0, Node_create_Display_Image]);
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