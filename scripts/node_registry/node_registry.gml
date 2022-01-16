function NodeObject(_name, _spr, _create, tags = []) constructor {
	name = _name;
	spr  = _spr;
	createNode = _create;
	
	self.tags = tags;
	
	function build(_x, _y) {
		var _node = createNode(_x, _y);
		return _node;
	}
}

#region nodes
	globalvar ALL_NODES, NODE_CATAGORY, NODE_CREATE_FUCTION;
	ALL_NODES			= ds_map_create();
	NODE_CATAGORY		= ds_list_create();
	NODE_CREATE_FUCTION = ds_map_create();
	
	function addNodeObject(_list, _name, _spr, _node, _fun, _tag = []) {
		NODE_CREATE_FUCTION[? _node] = _fun;
		ds_list_add(_list, new NodeObject(_name, _spr, _fun, _tag));
	}
	
	function addNodeCatagory(name, list) {
		ALL_NODES[? name] = list;
		ds_list_add(NODE_CATAGORY, name);
	}
	
	function nodeFind(_name) {
		for(var i = 0; i < ds_list_size(NODE_CATAGORY); i++) {
			var _page = ALL_NODES[? NODE_CATAGORY[| i]];
			
			for(var j = 0; j < ds_list_size(_page); j++) {
				var _node = _page[| j];
				if(_node.name == _name) 
					return _node;
			}
		}
		return noone;
	}
	
	function nodeBuild(_name, _x, _y) {
		var _node = nodeFind(_name).build(_x, _y);
		if(!_node) return noone;
		PANEL_GRAPH.node_focus = _node;
		PANEL_GRAPH.previewing = _node;
		
		return _node;
	}
	
	var input = ds_list_create();
	addNodeCatagory("Input", input);
	addNodeObject(input, "Canvas",				s_node_canvas,			"Node_Canvas",			Node_create_Canvas, ["draw"]);
	addNodeObject(input, "Image",				s_node_image,			"Node_Image",			Node_create_Image);
	addNodeObject(input, "Image gif",			s_node_image_gif,		"Node_Image_gif",		Node_create_Image_gif);
	addNodeObject(input, "Splice spritesheet",	s_node_image_sheet,		"Node_Image_Sheet",		Node_create_Image_Sheet);
	addNodeObject(input, "Image array",			s_node_image_sequence,	"Node_Image_Sequence",	Node_create_Image_Sequence);
	addNodeObject(input, "Animation",			s_node_image_animation, "Node_Image_Animated",	Node_create_Image_Animated);
	addNodeObject(input, "Array to anim",		s_node_image_sequence_to_anim, "Node_Sequence_Anim",	Node_create_Sequence_Anim);
	
	var transform = ds_list_create();
	addNodeCatagory("Transform", transform);
	addNodeObject(transform, "Transform",		s_node_transform,		"Node_Transform",		Node_create_Transform);
	addNodeObject(transform, "Scale",			s_node_scale,			"Node_Scale",			Node_create_Scale, ["resize"]);
	addNodeObject(transform, "Crop",			s_node_crop,			"Node_Crop",			Node_create_Crop);
	addNodeObject(transform, "Mirror",			s_node_mirror,			"Node_Mirror",			Node_create_Mirror);
	addNodeObject(transform, "Warp",			s_node_warp,			"Node_Warp",			Node_create_Warp, ["wrap"]);
	addNodeObject(transform, "Mesh warp",		s_node_warp_mesh,		"Node_Mesh_Warp",		Node_create_Mesh_Warp, ["mesh wrap"]);
	addNodeObject(transform, "Compose",			s_node_compose,			"Node_Composite",		Node_create_Composite, ["merge"]);
	addNodeObject(transform, "Polar",			s_node_polar,			"Node_Polar",			Node_create_Polar);
	addNodeObject(transform, "Nine slice",		s_node_9patch,			"Node_9Slice",			Node_create_9Slice, ["9", "splice"]);
	addNodeObject(transform, "Padding",			s_node_padding,			"Node_Padding",			Node_create_Padding);
	
	var filter = ds_list_create();
	addNodeCatagory("Filter", filter);
	addNodeObject(filter, "Blend",				s_node_color_adjust,	"Node_Blend",			Node_create_Blend, ["merge"]);
	addNodeObject(filter, "Outline",			s_node_border,			"Node_Outline",			Node_create_Outline, ["border"]);
	addNodeObject(filter, "Erode",				s_node_erode,			"Node_Erode",			Node_create_Erode);
	addNodeObject(filter, "Trail",				s_node_trail,			"Node_Trail",			Node_create_Trail);
	addNodeObject(filter, "Blur",				s_node_blur,			"Node_Blur",			Node_create_Blur, ["gaussian"]);
	addNodeObject(filter, "Directioanl Blur",	s_node_blur_directional,"Node_Blur_Directional",Node_create_Blur_Directional);
	addNodeObject(filter, "Radial Blur",		s_node_blur,			"Node_Blur_Radial",		Node_create_Blur_Radial);
	addNodeObject(filter, "Contrast Blur",		s_node_blur_contrast,	"Node_Blur_Contrast",	Node_create_Blur_Contrast);
	addNodeObject(filter, "Twirl",				s_node_twirl,			"Node_Twirl",			Node_create_Twirl, ["twist"]);
	addNodeObject(filter, "Dilate",				s_node_dilate,			"Node_Dilate",			Node_create_Dilate, ["inflate"]);
	addNodeObject(filter, "Glow",				s_node_glow,			"Node_Glow",			Node_create_Glow);
	addNodeObject(filter, "Shadow",				s_node_shadow,			"Node_Shadow",			Node_create_Shadow);
	addNodeObject(filter, "Bloom",				s_node_bloom,			"Node_Bloom",			Node_create_Bloom);
	addNodeObject(filter, "Replace color",		s_node_color_replace,	"Node_Color_replace",	Node_create_Color_replace, ["isolate color", "select color"]);
	addNodeObject(filter, "Remove color",		s_node_color_remove,	"Node_Color_Remove",	Node_create_Color_Remove, ["delete color"]);
	addNodeObject(filter, "Colorize",			s_node_colorize,		"Node_Colorize",		Node_create_Colorize, ["recolor"]);
	addNodeObject(filter, "Posterize",			s_node_posterize,		"Node_Posterize",		Node_create_Posterize);
	addNodeObject(filter, "Dither",				s_node_dithering,		"Node_Dither",			Node_create_Dither);
	addNodeObject(filter, "Adjust color",		s_node_color_adjust,	"Node_Color_adjust",	Node_create_Color_adjust, ["brightness", "contrast", "hue", "saturation", "value", "color blend", "alpha"]);
	addNodeObject(filter, "BW",					s_node_BW,				"Node_BW",				Node_create_BW, ["black and white"]);
	addNodeObject(filter, "Greyscale",			s_node_greyscale,		"Node_Greyscale",		Node_create_Greyscale);
	addNodeObject(filter, "Invert",				s_node_invert,			"Node_Invert",			Node_create_Invert, ["negate"]);
	addNodeObject(filter, "RGB Channels",		s_node_RGB,				"Node_RGB_Channel",		Node_create_RGB_Channel, ["channel extract"]);
	addNodeObject(filter, "Level",				s_node_level,			"Node_Level",			Node_create_Level);
	addNodeObject(filter, "Level selector",		s_node_level_selector,	"Node_Level_Selector",	Node_create_Level_Selector);
	addNodeObject(filter, "Displace",			s_node_displace,		"Node_Displace",		Node_create_Displace);
	addNodeObject(filter, "Alpha to grey",		s_node_alpha_grey,		"Node_Alpha_Grey",		Node_create_Alpha_Grey);
	addNodeObject(filter, "Alpha cutoff",		s_node_alpha_cut,		"Node_Alpha_Cutoff",	Node_create_Alpha_Cutoff, ["remove alpha"]);
	addNodeObject(filter, "Grey to alpha",		s_node_grey_alpha,		"Node_Grey_Alpha",		Node_create_Grey_Alpha);
	addNodeObject(filter, "De-corner",			s_node_decorner,		"Node_De_Corner",		Node_create_De_Corner, ["decorner"]);
	addNodeObject(filter, "De-stray",			s_node_destray,			"Node_De_Stray",		Node_create_De_Stray, ["destray"]);
	addNodeObject(filter, "Texture remap",		s_node_texture_map,		"Node_Texture_Remap",	Node_create_Texture_Remap);
	addNodeObject(filter, "Time remap",			s_node_time_map,		"Node_Time_Remap",		Node_create_Time_Remap);
	addNodeObject(filter, "2D light",			s_node_2d_light,		"Node_2D_light",		Node_create_2D_light);
	addNodeObject(filter, "Atlas",				s_node_atlas,			"Node_Atlas",			Node_create_Atlas);
	addNodeObject(filter, "Scale algorithm",	s_node_scale_algo,		"Node_Scale_Algo",		Node_create_Scale_Algo, ["Scale2x", "Scale3x"]);
	//addNodeObject(filter, "Corner",			s_node_corner,			"Node_Corner",			Node_create_Corner);
	
	var threeD = ds_list_create();
	addNodeCatagory("3D", threeD);
	addNodeObject(threeD, "3D Transform",		s_node_3d_transform,	"Node_3D_Transform",	Node_create_3D_Transform);
	addNodeObject(threeD, "Normal",				s_node_normal,			"Node_Normal",			Node_create_Normal);
	addNodeObject(threeD, "Normal light",		s_node_normal_light,	"Node_Normal_Light",	Node_create_Normal_Light);
	addNodeObject(threeD, "Bevel",				s_node_bevel,			"Node_Bevel",			Node_create_Bevel);
	addNodeObject(threeD, "Sprite stack",		s_node_stack,			"Node_Sprite_Stack",	Node_create_Sprite_Stack);
	addNodeObject(threeD, "3D Cube",			s_node_3d_cube,			"Node_3D_Cube",			Node_create_3D_Cube);
	addNodeObject(threeD, "3D Cylinder",		s_node_3d_cylinder,		"Node_3D_Cylinder",		Node_create_3D_Cylinder);
	addNodeObject(threeD, "3D Obj",				s_node_3d_obj,			"Node_3D_Obj",			Node_create_3D_Obj);
	
	var number = ds_list_create();
	addNodeCatagory("Number", number);
	addNodeObject(number, "Math",			s_node_math,		"Node_Math",		Node_create_Math);
	//addNodeObject(number, "Array",		s_node_array,		"Node_Array",		Node_create_Array);
	addNodeObject(number, "Number",			s_node_number,		"Node_Number",		Node_create_Number);
	addNodeObject(number, "Vector2",		s_node_vec2,		"Node_Vector2",		Node_create_Vector2);
	addNodeObject(number, "Vector3",		s_node_vec3,		"Node_Vector3",		Node_create_Vector3);
	addNodeObject(number, "Vector4",		s_node_vec4,		"Node_Vector4",		Node_create_Vector4);
	addNodeObject(number, "Vector split",	s_node_vec_split,	"Node_Vector_Split",Node_create_Vector_Split);
	addNodeObject(number, "Unicode",		s_node_unicode,		"Node_Unicode",		Node_create_Unicode);
	addNodeObject(number, "Path",			s_node_path,		"Node_Path",		Node_create_Path);
	addNodeObject(number, "Area",			s_node_area,		"Node_Area",		Node_create_Area);
	addNodeObject(number, "Surface data",	s_node_surface_data,"Node_Surface_data",Node_create_Surface_data);
	
	var color = ds_list_create();
	addNodeCatagory("Color", color);
	addNodeObject(color, "Color",		s_node_color_out,		"Node_Color",			Node_create_Color);
	addNodeObject(color, "RGB Color",	s_node_color_from_rgb,	"Node_Color_RGB",		Node_create_Color_RGB);
	addNodeObject(color, "HSV Color",	s_node_color_from_hsv,	"Node_Color_HSV",		Node_create_Color_HSV);
	addNodeObject(color, "Palette",		s_node_palette,			"Node_Palette",			Node_create_Palette);
	addNodeObject(color, "Gradient",	s_node_gradient_out,	"Node_Gradient_Out",	Node_create_Gradient_Out);
	addNodeObject(color, "Sampler",		s_node_sampler,			"Node_Sampler",			Node_create_Sampler);
	addNodeObject(color, "Color data",	s_node_color_data,		"Node_Color_Data",		Node_create_Color_Data);
	
	var animation = ds_list_create();
	addNodeCatagory("Animation", animation);
	addNodeObject(animation, "Counter",	s_node_counter,	"Node_Counter",		Node_create_Counter);
	addNodeObject(animation, "Wiggler", s_node_wiggler,	"Node_Wiggler",		Node_create_Wiggler);
	addNodeObject(animation, "Curve",	s_node_curve,	"Node_Anim_Curve",	Node_create_Anim_Curve);
	
	var generator = ds_list_create();
	addNodeCatagory("Generate", generator);
	addNodeObject(generator, "Solid",				s_node_solid,				"Node_Solid",				Node_create_Solid);
	addNodeObject(generator, "Gradient",			s_node_gradient,			"Node_Gradient",			Node_create_Gradient);
	addNodeObject(generator, "Line",				s_node_line,				"Node_Line",				Node_create_Line);
	addNodeObject(generator, "Stripe",				s_node_stripe,				"Node_Stripe",				Node_create_Stripe);
	addNodeObject(generator, "Zigzag",				s_node_zigzag,				"Node_Zigzag",				Node_create_Zigzag);
	addNodeObject(generator, "Checker",				s_node_checker,				"Node_Checker",				Node_create_Checker);
	addNodeObject(generator, "Shape",				s_node_shape,				"Node_Shape",				Node_create_Shape);
	addNodeObject(generator, "Particle",			s_node_particle,			"Node_Particle",			Node_create_Particle);
	addNodeObject(generator, "Particle Effector",	s_node_particle_effector,	"Node_Particle_Effector",	Node_create_Particle_Effector, ["affector"]);
	addNodeObject(generator, "Scatter",				s_node_scatter,				"Node_Scatter",				Node_create_Scatter);
	addNodeObject(generator, "Perlin noise",		s_node_noise_perlin,		"Node_Perlin",				Node_create_Perlin);
	addNodeObject(generator, "Cellular noise",		s_node_noise_cell,			"Node_Cellular",			Node_create_Cellular);
	addNodeObject(generator, "Grid noise",			s_node_grid_noise,			"Node_Grid_Noise",			Node_create_Grid_Noise);
	addNodeObject(generator, "Grid",				s_node_grid_noise,			"Node_Grid",				Node_create_Grid);
	addNodeObject(generator, "Anisotropic noise",	s_node_noise_aniso,			"Node_Noise_Aniso",			Node_create_Noise_Aniso);
	addNodeObject(generator, "Seperate shape",	    s_node_sepearte_shape,		"Node_Seperate_Shape",		Node_create_Seperate_Shape);
	addNodeObject(generator, "Text",				s_node_text,				"Node_Text",				Node_create_Text);
	addNodeObject(generator, "Pixel cloud",			s_node_pixel_cloud,			"Node_Pixel_Cloud",			Node_create_Pixel_Cloud);
	
	var render = ds_list_create();
	addNodeCatagory("Render", render);
	addNodeObject(render, "Render sprite sheet",	s_node_sprite_sheet,	"Node_Render_Sprite_Sheet",	Node_create_Render_Sprite_Sheet);
	addNodeObject(render, "Export",					s_node_export,			"Node_Export",				Node_create_Export);
	addNodeObject(render, "Preview timeline",		s_node_timeline_preview,"Node_Timeline_Preview",	Node_create_Timeline_Preview);
	
	var group = ds_list_create();
	addNodeCatagory("Group", group);
	addNodeObject(group, "Input",	s_node_input,	"Node_Group_Input",		Node_create_Group_Input);
	addNodeObject(group, "Output",	s_node_output,	"Node_Group_Output",	Node_create_Group_Output);
	
	var node = ds_list_create();
	addNodeCatagory("Node", node);
	addNodeObject(node, "Pin",		s_node_pin,		"Node_Pin",		Node_create_Pin);
	addNodeObject(node, "Frame",	s_node_frame,	"Node_Frame",	Node_create_Frame);
	
	NODE_CREATE_FUCTION[? "Node_Group"] = Node_create_Group;
#endregion

#region node load
	function nodeLoad(_data, scale = false) {
		if(!ds_exists(_data, ds_type_map)) return noone;
		
		var _x    = ds_map_try_get(_data, "x", 0);
		var _y    = ds_map_try_get(_data, "y", 0);
		var _type = ds_map_try_get(_data, "type", 0);
		
		if(!ds_map_exists(NODE_CREATE_FUCTION, _type)) {
			show_debug_message("Append ERROR : no type " + _type)
			return noone;
		}
		
		var _node = NODE_CREATE_FUCTION[? _type](_x, _y);
		
		if(_node) 
			_node.deserialize(_data, scale);
			
		return _node;
	}
	
	function node_delete(node) {
		var list = node.group == -1? NODES : node.group.nodes;
		ds_list_delete(list, ds_list_find_index(list, node));
		node.destroy();
		
		recordAction(ACTION_TYPE.node_deleted, node);
	}
#endregion