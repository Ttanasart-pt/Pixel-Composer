function NodeObject(_name, _spr, _node, _create, tags = []) constructor {
	name = _name;
	spr  = _spr;
	node = _node;
	createNode = _create;
	self.tags  = tags;
	
	tooltip	     = "";
	
	var pth = DIRECTORY + "Nodes\\tooltip\\" + node + ".png";
	if(file_exists(pth))
		tooltip_spr = sprite_add(pth, 0, false, false, 0, 0);
	else
		tooltip_spr  = noone;
	new_node     = false;
	
	if(struct_has(global.NODE_GUIDE, node)) {
		var _n = global.NODE_GUIDE[$ node];
		name    = _n.name;
		if(_n.tooltip != "")
			tooltip = _n.tooltip;
	}
	
	static setVersion = function(version) {
		new_node = version == VERSION;
		return self;
	}
	
	function build(_x, _y, _group = PANEL_GRAPH.getCurrentContext(), _param = "") {
		var _node = createNode[0]? new createNode[1](_x, _y, _group, _param) : createNode[1](_x, _y, _group, _param);
		if(!_node) return noone;
		
		_node.clearInputCache();
		_node.doUpdate();
		return _node;
	}
}

#region nodes
	globalvar ALL_NODES, ALL_NODE_LIST, NODE_CATEGORY, NODE_PAGE_DEFAULT;
	ALL_NODES		= ds_map_create();
	ALL_NODE_LIST	= ds_list_create();
	NODE_CATEGORY	= ds_list_create();
	
	function nodeBuild(_name, _x, _y, _group = PANEL_GRAPH.getCurrentContext()) {
		if(!ds_map_exists(ALL_NODES, _name)) {
			log_warning("LOAD", "Node type " + _name + " not found");
			return noone;
		}
		
		var _node = ALL_NODES[? _name];
		return _node.build(_x, _y, _group);
	}
	
	function addNodeObject(_list, _name, _spr, _node, _fun, _tag = [], tooltip = "") {
		var _n;
		
		if(ds_map_exists(ALL_NODES, _node))
			_n = ALL_NODES[? _node];
		else { 
			_n = new NodeObject(_name, _spr, _node, _fun, _tag);
			if(!ds_map_exists(ALL_NODES, _node))
				ds_list_add(ALL_NODE_LIST, _n);
			ALL_NODES[? _node] = _n;
		}
		
		if(tooltip != "")
			_n.tooltip = tooltip;
		ds_list_add(_list, _n);
		return _n;
	}
	
	function addNodeCatagory(name, list, filter = []) {
		ds_list_add(NODE_CATEGORY, { name: name, list: list, filter: filter });
	}
	
	function __init_nodes() {
		var group = ds_list_create();
		addNodeCatagory("Group", group, ["Node_Group"]);
			ds_list_add(group, "Groups");
			addNodeObject(group, "Input",	s_node_group_input,	"Node_Group_Input",		[1, Node_Group_Input]);
			addNodeObject(group, "Output",	s_node_group_output,"Node_Group_Output",	[1, Node_Group_Output]);
	
		var iter = ds_list_create();
		addNodeCatagory("Loop", iter, ["Node_Iterate"]);
			ds_list_add(iter, "Groups");
			addNodeObject(iter, "Input",	s_node_loop_input,		"Node_Iterator_Input",	[1, Node_Iterator_Input]);
			addNodeObject(iter, "Output",	s_node_loop_output,		"Node_Iterator_Output",	[1, Node_Iterator_Output]);
		
			ds_list_add(iter, "Loops");
			addNodeObject(iter, "Index",		s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]);
			addNodeObject(iter, "Loop amount",	s_node_iterator_amount,	"Node_Iterator_Length",	[1, Node_Iterator_Length]);
	
		var itere = ds_list_create();
		addNodeCatagory("Loop", itere, ["Node_Iterate_Each"]);
			ds_list_add(itere, "Groups");
			addNodeObject(itere, "Input",	s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]);
			addNodeObject(itere, "Output",	s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]);
		
			ds_list_add(itere, "Loops");
			addNodeObject(itere, "Index",			s_node_iterator_index,	"Node_Iterator_Index",	[1, Node_Iterator_Index]);
			addNodeObject(itere, "Array Length",	s_node_iterator_length,	"Node_Iterator_Each_Length",	[1, Node_Iterator_Each_Length]);
	
		var feed = ds_list_create();
		addNodeCatagory("Feedback", feed, ["Node_Feedback"]);
			ds_list_add(feed, "Groups");
			addNodeObject(feed, "Input",	s_node_feedback_input,	"Node_Feedback_Input",	[1, Node_Feedback_Input]);
			addNodeObject(feed, "Output",	s_node_feedback_output,	"Node_Feedback_Output",	[1, Node_Feedback_Output]);
	
		var vfx = ds_list_create();
		addNodeCatagory("VFX", vfx, ["Node_VFX_Group"]);
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
		
			ds_list_add(vfx, "Instance control");
			addNodeObject(vfx, "VFX Variable",	s_node_vfx_variable,	"Node_VFX_Variable",	[1, Node_VFX_Variable]).setVersion(1120);
			addNodeObject(vfx, "VFX Override",	s_node_vfx_override,	"Node_VFX_Override",	[1, Node_VFX_Override]).setVersion(1120);
	
		var rigidSim = ds_list_create();
		addNodeCatagory("RigidSim", rigidSim, ["Node_Rigid_Group"]);
			ds_list_add(rigidSim, "Group");
			addNodeObject(rigidSim, "Input",	s_node_group_input,	"Node_Group_Input",		[1, Node_Group_Input]);
			addNodeObject(rigidSim, "Output",	s_node_group_output,"Node_Group_Output",	[1, Node_Group_Output]);
		
			ds_list_add(rigidSim, "RigidSim");
			addNodeObject(rigidSim, "Object",			s_node_rigidSim_object,		"Node_Rigid_Object",		[1, Node_Rigid_Object]).setVersion(1110);
			addNodeObject(rigidSim, "Object Spawner",	s_node_rigidSim_object_spawner,		"Node_Rigid_Object_Spawner",		[1, Node_Rigid_Object_Spawner]).setVersion(1110);
			addNodeObject(rigidSim, "Render",			s_node_rigidSim_renderer,	"Node_Rigid_Render",		[1, Node_Rigid_Render]).setVersion(1110);
			addNodeObject(rigidSim, "Apply Force",		s_node_rigidSim_force,		"Node_Rigid_Force_Apply",	[1, Node_Rigid_Force_Apply]).setVersion(1110);
		
			ds_list_add(rigidSim, "Instance control");
			addNodeObject(rigidSim, "Activate Physics",	s_node_rigidSim_activate,	"Node_Rigid_Activate",		[1, Node_Rigid_Activate]).setVersion(1110);
			addNodeObject(rigidSim, "Rigidbody Variable",	s_node_rigid_variable,	"Node_Rigid_Variable",		[1, Node_Rigid_Variable]).setVersion(1120);
			addNodeObject(rigidSim, "Rigidbody Override",	s_node_rigid_override,	"Node_Rigid_Override",		[1, Node_Rigid_Override]).setVersion(1120);
		
		var fluidSim = ds_list_create();
		addNodeCatagory("FluidSim", fluidSim, ["Node_Fluid_Group"]);
			ds_list_add(fluidSim, "Group");
			addNodeObject(fluidSim, "Input",	s_node_group_input,		"Node_Group_Input",		[1, Node_Group_Input]);
			addNodeObject(fluidSim, "Output",	s_node_group_output,	"Node_Group_Output",	[1, Node_Group_Output]);
		
			ds_list_add(fluidSim, "System");
			addNodeObject(fluidSim, "Fluid Domain",		s_node_fluidSim_domain,			"Node_Fluid_Domain",		[1, Node_Fluid_Domain]).setVersion(1120);
			addNodeObject(fluidSim, "Update Domain",	s_node_fluidSim_update,			"Node_Fluid_Update",		[1, Node_Fluid_Update]).setVersion(1120);
			addNodeObject(fluidSim, "Render Domain",	s_node_fluidSim_render,			"Node_Fluid_Render",		[1, Node_Fluid_Render]).setVersion(1120);
			addNodeObject(fluidSim, "Queue Domain",		s_node_fluidSim_domain_queue,	"Node_Fluid_Domain_Queue",	[1, Node_Fluid_Domain_Queue]).setVersion(1120);
		
			ds_list_add(fluidSim, "Fluid");
			addNodeObject(fluidSim, "Add Fluid",		s_node_fluidSim_add_fluid,		"Node_Fluid_Add",				[1, Node_Fluid_Add]).setVersion(1120);
			addNodeObject(fluidSim, "Apply Velocity",	s_node_fluidSim_apply_velocity,	"Node_Fluid_Apply_Velocity",	[1, Node_Fluid_Apply_Velocity]).setVersion(1120);
			addNodeObject(fluidSim, "Add Collider",		s_node_fluidSim_add_collider,	"Node_Fluid_Add_Collider",		[1, Node_Fluid_Add_Collider]).setVersion(1120);
			addNodeObject(fluidSim, "Vortex",			s_node_fluidSim_vortex,			"Node_Fluid_Vortex",			[1, Node_Fluid_Vortex]).setVersion(1120);
			addNodeObject(fluidSim, "Repulse",			s_node_fluidSim_repulse,		"Node_Fluid_Repulse",			[1, Node_Fluid_Repulse]).setVersion(1120);
			addNodeObject(fluidSim, "Turbulence",		s_node_fluidSim_turbulence,		"Node_Fluid_Turbulence",		[1, Node_Fluid_Turbulence]).setVersion(1120);
	
		var input = ds_list_create();
		NODE_PAGE_DEFAULT = ds_list_size(NODE_CATEGORY);
		ADD_NODE_PAGE = NODE_PAGE_DEFAULT;
		addNodeCatagory("IO", input);
			ds_list_add(input, "Images");
			addNodeObject(input, "Canvas",				s_node_canvas,			"Node_Canvas",					[1, Node_Canvas], ["draw"], "Draw on surface using brush, eraser, etc.")
			addNodeObject(input, "Image",				s_node_image,			"Node_Image",					[0, Node_create_Image],, "Load a single image from your computer.");
			addNodeObject(input, "Image GIF",			s_node_image_gif,		"Node_Image_gif",				[0, Node_create_Image_gif],, "Load animated .gif from your computer.");
			addNodeObject(input, "Splice Spritesheet",	s_node_image_sheet,		"Node_Image_Sheet",				[1, Node_Image_Sheet],, "Cut up spritesheet into animation or image array.");
			addNodeObject(input, "Image Array",			s_node_image_sequence,	"Node_Image_Sequence",			[0, Node_create_Image_Sequence],, "Load multiple images from your computer as array.");
			addNodeObject(input, "Animation",			s_node_image_animation, "Node_Image_Animated",			[0, Node_create_Image_Animated],, "Load multiple images from your computer as animation.");
			addNodeObject(input, "Array to Anim",		s_node_image_sequence_to_anim, "Node_Sequence_Anim",	[1, Node_Sequence_Anim],, "Convert array of images into animation.");
			if(!DEMO) addNodeObject(input, "Export",	s_node_export,			"Node_Export",					[0, Node_create_Export],, "Export image, image array to file, image sequence, animation.");
		
			ds_list_add(input, "Files");
			addNodeObject(input, "Text File In",		s_node_text_file_read,	"Node_Text_File_Read",		[1, Node_Text_File_Read],  ["txt"], "Load .txt in as text.").setVersion(1080);
			addNodeObject(input, "Text File Out",		s_node_text_file_write,	"Node_Text_File_Write",		[1, Node_Text_File_Write], ["txt"], "Save text as a .txt file.").setVersion(1090);
			addNodeObject(input, "CSV File In",			s_node_csv_file_read,	"Node_CSV_File_Read",		[1, Node_CSV_File_Read],  ["comma separated value"], "Load .csv as text, number array.").setVersion(1090);
			addNodeObject(input, "CSV File Out",		s_node_csv_file_write,	"Node_CSV_File_Write",		[1, Node_CSV_File_Write], ["comma separated value"], "Save array as .csv file.").setVersion(1090);
			addNodeObject(input, "JSON File In",		s_node_json_file_read,	"Node_Json_File_Read",		[1, Node_Json_File_Read],,  "Load .json file using keys.").setVersion(1090);
			addNodeObject(input, "JSON File Out",		s_node_json_file_write,	"Node_Json_File_Write",		[1, Node_Json_File_Write],, "Save data to .json file.").setVersion(1090);
			addNodeObject(input, "ASE File In",			s_node_ase_file,		"Node_ASE_File_Read",		[0, Node_create_ASE_File_Read],, "Load Aseprite file with support for layers, tags.").setVersion(1100);
			addNodeObject(input, "ASE Layer",			s_node_ase_layer,		"Node_ASE_layer",			[1, Node_ASE_layer]).setVersion(1100);
	
		var transform = ds_list_create();
		addNodeCatagory("Transform", transform);
			ds_list_add(transform, "Transformations");
			addNodeObject(transform, "Transform",		s_node_transform,		"Node_Transform",		[1, Node_Transform], ["move", "rotate", "scale"], "Move, rotate, and scale image.");
			addNodeObject(transform, "Scale",			s_node_scale,			"Node_Scale",			[1, Node_Scale], ["resize"], "Simple node for scaling image.");
			addNodeObject(transform, "Scale Algorithm",	s_node_scale_algo,		"Node_Scale_Algo",		[0, Node_create_Scale_Algo], ["scale2x", "scale3x"], "Scale image using scale2x, scale3x algorithm.");
			addNodeObject(transform, "Flip",			s_node_flip,			"Node_Flip",			[1, Node_Flip], ["mirror"], "Flip image horizontally or vertically.");
		
			ds_list_add(transform, "Warps");
			addNodeObject(transform, "Crop",			s_node_crop,			"Node_Crop",			[1, Node_Crop],, "Crop out image to create smaller ones.");
			addNodeObject(transform, "Crop Content",	s_node_crop_content,	"Node_Crop_Content",	[1, Node_Crop_Content],, "Crop out empty pixel pixel from the image.");
			addNodeObject(transform, "Warp",			s_node_warp,			"Node_Warp",			[1, Node_Warp], ["wrap"], "Warp image by freely moving the corners.");
			addNodeObject(transform, "Skew",			s_node_skew,			"Node_Skew",			[1, Node_Skew],, "Skew image horizontally, or vertically.");
			addNodeObject(transform, "Mesh Warp",		s_node_warp_mesh,		"Node_Mesh_Warp",		[1, Node_Mesh_Warp], ["mesh wrap"], "Wrap image by converting it to mesh, and using control points.");
			addNodeObject(transform, "Polar",			s_node_polar,			"Node_Polar",			[1, Node_Polar],, "Convert image to polar coordinate.");
			addNodeObject(transform, "Area Warp",		s_node_padding,			"Node_Wrap_Area",		[1, Node_Wrap_Area],, "Wrap image to fit area value (x, y, w, h).");
		
			ds_list_add(transform, "Others");
			addNodeObject(transform, "Composite",		s_node_compose,			"Node_Composite",		[1, Node_Composite], ["merge"], "Combine multiple images with controllable position, rotation, scale.");
			addNodeObject(transform, "Nine Slice",		s_node_9patch,			"Node_9Slice",			[1, Node_9Slice], ["9", "splice"], "Cut image into 3x3 parts, and scale/repeat only the middle part.");
			addNodeObject(transform, "Padding",			s_node_padding,			"Node_Padding",			[1, Node_Padding],, "Make image bigger by adding space in 4 directions.");
		
		var filter = ds_list_create();
		addNodeCatagory("Filter", filter);
			ds_list_add(filter, "Combines");
			addNodeObject(filter, "Blend",				s_node_blend,			"Node_Blend",			[0, Node_create_Blend], ["normal", "add", "subtract", "multiply", "screen", "maxx", "minn"], "Blend 2 images using different blendmodes.");
			addNodeObject(filter, "RGBA Combine",		s_node_RGB_combine,		"Node_Combine_RGB",		[1, Node_Combine_RGB],, "Combine 4 image in to one. Each image use to control RGBA channel.").setVersion(1070);
			addNodeObject(filter, "HSV Combine",		s_node_HSV_combine,		"Node_Combine_HSV",		[1, Node_Combine_HSV],, "Combine 4 image in to one. Each image use to control HSVA channel.").setVersion(1070);
		
			ds_list_add(filter, "Blurs");
			addNodeObject(filter, "Blur",				s_node_blur,			"Node_Blur",			[1, Node_Blur], ["gaussian blur"], "Blur image smoothly.");
			addNodeObject(filter, "Simple Blur",		s_node_blur_simple,		"Node_Blur_Simple",		[1, Node_Blur_Simple],, "Blur image using simpler algorithm. Allowing for variable blur strength.").setVersion(1070);
			addNodeObject(filter, "Directional Blur",	s_node_blur_directional,"Node_Blur_Directional",[1, Node_Blur_Directional], ["motion blur"], "Blur image given a direction.");
			addNodeObject(filter, "Zoom Blur",			s_node_zoom,			"Node_Blur_Zoom",		[1, Node_Blur_Zoom],, "Blur image by zooming in/out from a mid point.");
			addNodeObject(filter, "Radial Blur",		s_node_radial,			"Node_Blur_Radial",		[1, Node_Blur_Radial],, "Blur image by rotating aroung a mid point.").setVersion(1110);
			addNodeObject(filter, "Lens Blur",			s_node_bokeh,			"Node_Blur_Bokeh",		[1, Node_Blur_Bokeh], ["bokeh"], "Create bokeh effect. Blur lighter color in a lens-like manner.").setVersion(1110);
			addNodeObject(filter, "Contrast Blur",		s_node_blur_contrast,	"Node_Blur_Contrast",	[1, Node_Blur_Contrast],, "Blur only pixel of a similiar color.");
			addNodeObject(filter, "Average",			s_node_average,			"Node_Average",			[1, Node_Average],, "Average color of every pixels in the image.").setVersion(1110);
		
			ds_list_add(filter, "Warps");
			addNodeObject(filter, "Mirror",				s_node_mirror,			"Node_Mirror",			[1, Node_Mirror],, "Reflect the image along a reflection line.").setVersion(1070);
			addNodeObject(filter, "Twirl",				s_node_twirl,			"Node_Twirl",			[1, Node_Twirl], ["twist"], "Twist the image around a mid point.");
			addNodeObject(filter, "Dilate",				s_node_dilate,			"Node_Dilate",			[1, Node_Dilate], ["inflate"], "Expand the image around a mid point.");
			addNodeObject(filter, "Displace",			s_node_displace,		"Node_Displace",		[1, Node_Displace], ["distort"], "Distort image using another image as a map.");
			addNodeObject(filter, "Texture Remap",		s_node_texture_map,		"Node_Texture_Remap",	[1, Node_Texture_Remap],, "Remap image using texture map. Where red channel control x position and green channel control y position.");
			addNodeObject(filter, "Time Remap",			s_node_time_map,		"Node_Time_Remap",		[1, Node_Time_Remap],, "Remap image using texture as time map. Where brighter pixel means using pixel from an older frame.");
		
			ds_list_add(filter, "Effects");
			addNodeObject(filter, "Outline",			s_node_border,			"Node_Outline",			[1, Node_Outline], ["border"], "Add border to the image.");
			addNodeObject(filter, "Glow",				s_node_glow,			"Node_Glow",			[1, Node_Glow],, "Apply glow to the border of the image.");
			addNodeObject(filter, "Shadow",				s_node_shadow,			"Node_Shadow",			[1, Node_Shadow],, "Apply shadow behind the image.");
			addNodeObject(filter, "Bloom",				s_node_bloom,			"Node_Bloom",			[1, Node_Bloom],, "Apply bloom effect, bluring and brighten the bright part of the image.");
			addNodeObject(filter, "Trail",				s_node_trail,			"Node_Trail",			[1, Node_Trail],, "Blend animation by filling in the pixel 'in-between' two or more frames.").setVersion(1130);
			addNodeObject(filter, "Erode",				s_node_erode,			"Node_Erode",			[1, Node_Erode],, "Remove pixel that are close to the border of the image.");
			addNodeObject(filter, "Corner",				s_node_corner,			"Node_Corner",			[1, Node_Corner], ["round corner"], "Round out sharp corner of the image.").setVersion(1110);
			addNodeObject(filter, "2D Light",			s_node_2d_light,		"Node_2D_light",		[1, Node_2D_light],, "Apply different shaped light on the image.");
			addNodeObject(filter, "Cast Shadow",		s_node_shadow_cast,		"Node_Shadow_Cast",		[1, Node_Shadow_Cast],, "Apply light that create shadow using shadow mask.").setVersion(1100);
			addNodeObject(filter, "Pixel Expand",		s_node_atlas,			"Node_Atlas",			[1, Node_Atlas], ["atlas"], "Replace transparent pixel with the closet non-transparent pixel.");
			addNodeObject(filter, "Pixel Cloud",		s_node_pixel_cloud,		"Node_Pixel_Cloud",		[1, Node_Pixel_Cloud],, "Displace each pixel of the image randomly.");
			addNodeObject(filter, "Pixel Sort",			s_node_pixel_sort,		"Node_Pixel_Sort",		[1, Node_Pixel_Sort],, "Sort pixel by brightness in horizontal, or vertial axis.");
			addNodeObject(filter, "Edge Detect",		s_node_edge_detect,		"Node_Edge_Detect",		[1, Node_Edge_Detect],, "Edge detect by applying Sobel, Prewitt, or Laplacian kernel.");
			addNodeObject(filter, "Convolution",		s_node_convolution,		"Node_Convolution",		[1, Node_Convolution], ["kernel"], "Apply convolution operation on each pixel using a custom 3x3 kernel.").setVersion(1090);
			addNodeObject(filter, "Local Analyze",		s_node_local_analyze,	"Node_Local_Analyze",	[1, Node_Local_Analyze],, "Apply non-linear operation (minimum, maximum) on each pixel locally.").setVersion(1110);
			addNodeObject(filter, "SDF",				s_node_sdf,				"Node_SDF",				[1, Node_SDF],, "Create signed distance field using jump flooding algorithm.").setVersion(1130);
			addNodeObject(filter, "Chromatic Aberration",	s_node_chromatic_abarration,	"Node_Chromatic_Aberration",	[1, Node_Chromatic_Aberration],, "Apply chromatic aberration effect to the image.");
		
			ds_list_add(filter, "Colors");
			addNodeObject(filter, "Replace Color",		s_node_color_replace,	"Node_Color_replace",	[1, Node_Color_replace], ["isolate color", "select color", "palette swap"], "Replace color that match one palette with another palette.");
			addNodeObject(filter, "Remove Color",		s_node_color_remove,	"Node_Color_Remove",	[1, Node_Color_Remove], ["delete color"], "Remove color that match a palette.");
			addNodeObject(filter, "Colorize",			s_node_colorize,		"Node_Colorize",		[1, Node_Colorize], ["recolor"], "Map brightness of a pixel to a color from a gradient.");
			addNodeObject(filter, "Posterize",			s_node_posterize,		"Node_Posterize",		[1, Node_Posterize],, "Reduce and remap color to match a palette.");
			addNodeObject(filter, "Dither",				s_node_dithering,		"Node_Dither",			[1, Node_Dither],, "Reduce color and use dithering to preserve original color.");
			addNodeObject(filter, "Color Adjust",		s_node_color_adjust,	"Node_Color_adjust",	[1, Node_Color_adjust], ["brightness", "contrast", "hue", "saturation", "value", "color blend", "alpha"], "Adjust brightness, contrast, hue, saturation, value, alpha, and blend image with color.");
			addNodeObject(filter, "BW",					s_node_BW,				"Node_BW",				[1, Node_BW], ["black and white"], "Convert color image to black and white.");
			addNodeObject(filter, "Greyscale",			s_node_greyscale,		"Node_Greyscale",		[1, Node_Greyscale],, "Convert color image to greyscale.");
			addNodeObject(filter, "Invert",				s_node_invert,			"Node_Invert",			[1, Node_Invert], ["negate"], "Invert color.");
			addNodeObject(filter, "Level",				s_node_level,			"Node_Level",			[1, Node_Level],, "Adjust brightness of an image by changing its brightness range.");
			addNodeObject(filter, "Level Selector",		s_node_level_selector,	"Node_Level_Selector",	[1, Node_Level_Selector],, "Isolate part of the image that falls in the selected brightness range.");
			addNodeObject(filter, "Curve",				s_node_curve_edit,		"Node_Curve",			[1, Node_Curve],, "Adjust brightness of an image using curves.").setVersion(1120);
			addNodeObject(filter, "Threshold",			s_node_threshold,		"Node_Threshold",		[1, Node_Threshold],, "Set a threshold where pixel darker will becomes black, and brighter to white. Also works with alpha.").setVersion(1080);
			addNodeObject(filter, "Alpha Cutoff",		s_node_alpha_cut,		"Node_Alpha_Cutoff",	[1, Node_Alpha_Cutoff], ["remove alpha"], "Remove pixel with low alpha value.");
		
			ds_list_add(filter, "Conversions");
			addNodeObject(filter, "RGBA Extract",		s_node_RGB,				"Node_RGB_Channel",		[1, Node_RGB_Channel], ["channel extract"], "Extract RGBA channel on an image, each channel becomes its own image.");
			addNodeObject(filter, "HSV Extract",		s_node_HSV,				"Node_HSV_Channel",		[1, Node_HSV_Channel],, "Extract HSVA channel on an image, each channel becomes its own image.").setVersion(1070);
			addNodeObject(filter, "Alpha to Grey",		s_node_alpha_grey,		"Node_Alpha_Grey",		[1, Node_Alpha_Grey],, "Convert alpha value into solid greyscale.");
			addNodeObject(filter, "Grey to Alpha",		s_node_grey_alpha,		"Node_Grey_Alpha",		[1, Node_Grey_Alpha],, "Convert greyscale to alpha value.");
		
			ds_list_add(filter, "Fixes");
			addNodeObject(filter, "De-Corner",			s_node_decorner,		"Node_De_Corner",		[1, Node_De_Corner], ["decorner"], "Attempt to remove single pixel corner from the image.");
			addNodeObject(filter, "De-Stray",			s_node_destray,			"Node_De_Stray",		[1, Node_De_Stray], ["destray"], "Attempt to remove orphan pixel.");
	
		var threeD = ds_list_create();
		addNodeCatagory("3D", threeD);
			ds_list_add(threeD, "2D operations");
			addNodeObject(threeD, "Normal",				s_node_normal,			"Node_Normal",			[1, Node_Normal],, "Create normal map using greyscale value as height.");
			addNodeObject(threeD, "Normal Light",		s_node_normal_light,	"Node_Normal_Light",	[1, Node_Normal_Light],, "Light up the image using normal mapping.");
			addNodeObject(threeD, "Bevel",				s_node_bevel,			"Node_Bevel",			[1, Node_Bevel],, "Apply 2D bevel on the image.");
			addNodeObject(threeD, "Sprite Stack",		s_node_stack,			"Node_Sprite_Stack",	[1, Node_Sprite_Stack],, "Create sprite stack either from repeating a single image or stacking different images using array.");
		
			ds_list_add(threeD, "3D generates");
			addNodeObject(threeD, "3D Object",			s_node_3d_obj,			"Node_3D_Obj",			[1, Node_3D_Obj],, "Load .obj file from your computer as a 3D object.");
			addNodeObject(threeD, "3D Plane",			s_node_3d_plane,		"Node_3D_Plane",		[1, Node_3D_Plane],, "Put 2D image on a plane in 3D space.");
			addNodeObject(threeD, "3D Cube",			s_node_3d_cube,			"Node_3D_Cube",			[1, Node_3D_Cube]);
			addNodeObject(threeD, "3D Cylinder",		s_node_3d_cylinder,		"Node_3D_Cylinder",		[1, Node_3D_Cylinder]);
			addNodeObject(threeD, "3D Sphere",			s_node_3d_sphere,		"Node_3D_Sphere",		[1, Node_3D_Sphere]).setVersion(1090);
			addNodeObject(threeD, "3D Cone",			s_node_3d_cone,			"Node_3D_Cone",			[1, Node_3D_Cone]).setVersion(1090);
			addNodeObject(threeD, "3D Extrude",			s_node_3d_extrude,		"Node_3D_Extrude",		[1, Node_3D_Extrude],, "Extrude 2D image into 3D object.");
		
			ds_list_add(threeD, "3D operations");
			addNodeObject(threeD, "3D Transform",		s_node_3d_transform,	"Node_3D_Transform",	[1, Node_3D_Transform]).setVersion(1080);
			addNodeObject(threeD, "3D Combine",			s_node_3d_obj_combine,	"Node_3D_Combine",		[1, Node_3D_Combine],, "Combine multiple 3D object to a single scene,").setVersion(1080);
			addNodeObject(threeD, "3D Repeat",			s_node_3d_array,		"Node_3D_Repeat",		[1, Node_3D_Repeat], ["3d array"], "Repeat 3D object multiple times.").setVersion(1080);
		
		var generator = ds_list_create();
		addNodeCatagory("Generate", generator);
			ds_list_add(generator, "Colors");
			addNodeObject(generator, "Solid",				s_node_solid,				"Node_Solid",				[1, Node_Solid],, "Create image of a single color.");
			addNodeObject(generator, "Draw Gradient",		s_node_gradient,			"Node_Gradient",			[1, Node_Gradient],, "Create image from gradient.");
			addNodeObject(generator, "4 Points Gradient",	s_node_gradient_4points,	"Node_Gradient_Points",		[1, Node_Gradient_Points],, "Create image from 4 color points.");
		
			ds_list_add(generator, "Drawer");
			addNodeObject(generator, "Line",			s_node_line,			"Node_Line",			[1, Node_Line],, "Draw line on an image. Connect path data to it to draw line from path.");
			addNodeObject(generator, "Draw Text",		s_node_text_render,		"Node_Text",			[1, Node_Text],, "Draw text on an image.");
			addNodeObject(generator, "Shape",			s_node_shape,			"Node_Shape",			[1, Node_Shape],, "Draw simple shapes using signed distance field.");
			addNodeObject(generator, "Polygon Shape",	s_node_shape_polygon,	"Node_Shape_Polygon",	[1, Node_Shape_Polygon],, "Draw simple shapes using triangles.").setVersion(1130);
		
			ds_list_add(generator, "Noises");
			addNodeObject(generator, "Noise",				s_node_noise,				"Node_Noise",				[1, Node_Noise],, "Generate white noise.");
			addNodeObject(generator, "Perlin Noise",		s_node_noise_perlin,		"Node_Perlin",				[1, Node_Perlin],, "Generate perlin noise.");
			addNodeObject(generator, "Simplex Noise",		s_node_noise_simplex,		"Node_Noise_Simplex",		[1, Node_Noise_Simplex], ["perlin"], "Generate simplex noise, similiar to perlin noise with better fidelity but non-tilable.").setVersion(1080);
			addNodeObject(generator, "Cellular Noise",		s_node_noise_cell,			"Node_Cellular",			[1, Node_Cellular], ["voronoi", "worley"], "Generate voronoi pattern.");
			addNodeObject(generator, "Anisotropic Noise",	s_node_noise_aniso,			"Node_Noise_Aniso",			[1, Node_Noise_Aniso],, "Generate anisotropic noise.");
		
			ds_list_add(generator, "Patterns");
			addNodeObject(generator, "Stripe",				s_node_stripe,				"Node_Stripe",				[1, Node_Stripe],, "Generate stripe pattern.");
			addNodeObject(generator, "Zigzag",				s_node_zigzag,				"Node_Zigzag",				[1, Node_Zigzag],, "Generate zigzag pattern.");
			addNodeObject(generator, "Checker",				s_node_checker,				"Node_Checker",				[1, Node_Checker],, "Genearte checkerboard pattern.");
			addNodeObject(generator, "Grid",				s_node_grid,				"Node_Grid",				[1, Node_Grid], ["tile"], "Generate grid pattern.");
			addNodeObject(generator, "Triangular Grid",		s_node_grid_tri,			"Node_Grid_Tri",			[1, Node_Grid_Tri],, "Generate triangular grid pattern.");
			addNodeObject(generator, "Hexagonal Grid",		s_node_grid_hex,			"Node_Grid_Hex",			[1, Node_Grid_Hex],, "Generate hexagonal grid pattern.");
		
			ds_list_add(generator, "Populate");
			addNodeObject(generator, "Repeat",				s_node_repeat,				"Node_Repeat",				[1, Node_Repeat],, "Repeat image multiple times linearly, or in grid pattern.").setVersion(1100);
			addNodeObject(generator, "Scatter",				s_node_scatter,				"Node_Scatter",				[1, Node_Scatter],, "Scatter image randomly multiple times.");
		
			ds_list_add(generator, "Simulation");
			addNodeObject(generator, "Particle",			s_node_particle,			"Node_Particle",			[1, Node_Particle],, "Generate particle effect.");
			addNodeObject(generator, "VFX",					s_node_vfx,					"Node_VFX_Group",			[1, Node_VFX_Group],, "Create VFX group, which generate particles that can be manipulated using different force nodes.");
			addNodeObject(generator, "RigidSim",			s_node_rigidSim,			"Node_Rigid_Group",			[1, Node_Rigid_Group],, "Create group for rigidbody simulation.").setVersion(1110);
			addNodeObject(generator, "RigidSim Global",		s_node_rigidSim_global,		"Node_Rigid_Global",		[1, Node_Rigid_Global]).setVersion(1110);
			addNodeObject(generator, "FluidSim",			s_node_fluidSim_group,		"Node_Fluid_Group",			[1, Node_Fluid_Group],, "Create group for fluid simulation.").setVersion(1120);
		
			ds_list_add(generator, "Others");
			addNodeObject(generator, "Separate Shape",	s_node_sepearte_shape,	"Node_Seperate_Shape",	[1, Node_Seperate_Shape],, "Separate disconnected pixel each into an image in an image array.");
			addNodeObject(generator, "Flood Fill",		s_node_flood_fill,		"Node_Flood_Fill",		[1, Node_Flood_Fill],, "Filled connected pixel given position and color.").setVersion(1133);
	
		var compose = ds_list_create();
		addNodeCatagory("Compose", compose);
			ds_list_add(compose, "Composes");
			addNodeObject(compose, "Blend",					s_node_blend,			"Node_Blend",				[1, Node_Blend]);
			addNodeObject(compose, "Composite",				s_node_compose,			"Node_Composite",			[1, Node_Composite]);
			addNodeObject(compose, "Stack",					s_node_draw_stack,		"Node_Stack",				[1, Node_Stack],, "Place image next to each other linearly, or on top of each other.").setVersion(1070);
			addNodeObject(compose, "Camera",				s_node_camera,			"Node_Camera",				[1, Node_Camera],, "Create camera that crop image to fix dimension with control of position, zoom. Also can be use to create parallax effect.");
			addNodeObject(compose, "Render Spritesheet",	s_node_sprite_sheet,	"Node_Render_Sprite_Sheet",	[1, Node_Render_Sprite_Sheet],, "Create spritesheet from image array or animation.");
	
		var renderNode = ds_list_create();
		addNodeCatagory("Render", renderNode);
			ds_list_add(renderNode, "Renders");
			addNodeObject(renderNode, "Render Spritesheet",	s_node_sprite_sheet,	"Node_Render_Sprite_Sheet",	[1, Node_Render_Sprite_Sheet]);
			if(!DEMO) addNodeObject(renderNode, "Export",	s_node_export,			"Node_Export",				[0, Node_create_Export]);
			//addNodeObject(renderNode, "Preview timeline",		s_node_timeline_preview,"Node_Timeline_Preview",	[1, Node_create_Timeline_Preview]);
	
		var values = ds_list_create();
		addNodeCatagory("Values", values);
			ds_list_add(values, "Raw data");
			addNodeObject(values, "Number",			s_node_number,		"Node_Number",			[1, Node_Number]);
			addNodeObject(values, "Text",			s_node_text,		"Node_String",			[1, Node_String]);
			addNodeObject(values, "Path",			s_node_path,		"Node_Path",			[1, Node_Path]);
			addNodeObject(values, "Area",			s_node_area,		"Node_Area",			[1, Node_Area]);
			addNodeObject(values, "Boolean",		s_node_boolean,		"Node_Boolean",			[1, Node_Boolean]).setVersion(1090);
		
			ds_list_add(values, "Numbers");
			addNodeObject(values, "Number",			s_node_number,			"Node_Number",			[1, Node_Number]);
			addNodeObject(values, "Math",			s_node_math,			"Node_Math",			[0, Node_create_Math], [ "add", "subtract", "multiply", "divide", "power", "modulo", "round", "ceiling", "floor", "sin", "cos", "tan", "abs" ]);
			addNodeObject(values, "Equation",		s_node_equation,		"Node_Equation",		[1, Node_Equation],, "Evaluate string of equation. With an option for setting variables.");
			addNodeObject(values, "Random",			s_node_random,			"Node_Random",			[1, Node_Random]);
			addNodeObject(values, "Statistic",		s_node_statistic,		"Node_Statistic",		[0, Node_create_Statistic], ["sum", "average", "mean", "median", "min", "max"]);
			addNodeObject(values, "Vector2",		s_node_vec2,			"Node_Vector2",			[1, Node_Vector2]);
			addNodeObject(values, "Vector3",		s_node_vec3,			"Node_Vector3",			[1, Node_Vector3]);
			addNodeObject(values, "Vector4",		s_node_vec4,			"Node_Vector4",			[1, Node_Vector4]);
			addNodeObject(values, "Vector Split",	s_node_vec_split,		"Node_Vector_Split",	[1, Node_Vector_Split]);
			addNodeObject(values, "Scatter Points",	s_node_scatter_point,	"Node_Scatter_Points",	[1, Node_Scatter_Points],, "Generate array of vector 2 points for scattering.").setVersion(1120);
		
			ds_list_add(values, "Texts");
			addNodeObject(values, "Text",			s_node_text,			"Node_String",			[1, Node_String]);
			addNodeObject(values, "Unicode",		s_node_unicode,			"Node_Unicode",			[1, Node_Unicode]);
			addNodeObject(values, "Combine Text",	s_node_text_combine,	"Node_String_Merge",	[1, Node_String_Merge]);
			addNodeObject(values, "Join Text",		s_node_text_join,		"Node_String_Join",		[1, Node_String_Join]).setVersion(1120);
			addNodeObject(values, "Split Text",		s_node_text_splice,		"Node_String_Split",	[1, Node_String_Split]);
			addNodeObject(values, "Trim Text",		s_node_text_trim,		"Node_String_Trim",		[1, Node_String_Trim]).setVersion(1080);
			addNodeObject(values, "Get Character",	s_node_text_char_get,	"Node_String_Get_Char",	[1, Node_String_Get_Char]).setVersion(1100);
		
			ds_list_add(values, "Arrays");
			addNodeObject(values, "Array",			s_node_array,			"Node_Array",			[1, Node_Array]);
			addNodeObject(values, "Array Range",	s_node_array_range,		"Node_Array_Range",		[1, Node_Array_Range],, "Create array of number in range by setting start, end and step size.");
			addNodeObject(values, "Array Add",		s_node_array_add,		"Node_Array_Add",		[1, Node_Array_Add], ["add array"]);
			addNodeObject(values, "Array Length",	s_node_array_length,	"Node_Array_Length",	[1, Node_Array_Length]);
			addNodeObject(values, "Array Get",		s_node_array_get,		"Node_Array_Get",		[1, Node_Array_Get], ["get array"]);
			addNodeObject(values, "Array Set",		s_node_array_set,		"Node_Array_Set",		[1, Node_Array_Set], ["set array"]).setVersion(1120);
			addNodeObject(values, "Array Find",		s_node_array_find,		"Node_Array_Find",		[1, Node_Array_Find], ["find array"]).setVersion(1120);
			addNodeObject(values, "Array Insert",	s_node_array_insert,	"Node_Array_Insert",	[1, Node_Array_Insert], ["insert array"]).setVersion(1120);
			addNodeObject(values, "Array Remove",	s_node_array_remove,	"Node_Array_Remove",	[1, Node_Array_Remove], ["remove array", "delete array", "array delete"]).setVersion(1120);
			addNodeObject(values, "Array Reverse",	s_node_array_reverse,	"Node_Array_Reverse",	[1, Node_Array_Reverse], ["reverse array"]).setVersion(1120);
			addNodeObject(values, "Array Shift",	s_node_array_shift,		"Node_Array_Shift",		[1, Node_Array_Shift]).setVersion(1137);
			addNodeObject(values, "Sort Array",		s_node_array_sort,		"Node_Array_Sort",		[1, Node_Array_Sort], ["array sort"]).setVersion(1120);
			addNodeObject(values, "Shuffle Array",	s_node_array_shuffle,	"Node_Array_Shuffle",	[1, Node_Array_Shuffle], ["array shuffle"]).setVersion(1120);
		
			ds_list_add(values, "Paths");
			addNodeObject(values, "Path",			s_node_path,			"Node_Path",			[1, Node_Path]);
			addNodeObject(values, "Path Array",		s_node_path_array,		"Node_Path_Array",		[1, Node_Path_Array]).setVersion(1137);
			addNodeObject(values, "Sample Path",	s_node_path_sample,		"Node_Path_Sample",		[1, Node_Path_Sample],, "Sample a 2D position from a path");
			addNodeObject(values, "Blend Path",		s_node_path_blend,		"Node_Path_Blend",		[1, Node_Path_Blend],, "Blend between 2 paths.");
			addNodeObject(values, "Remap Path",		s_node_path_map,		"Node_Path_Map_Area",	[1, Node_Path_Map_Area],, "Scale path to fit a given area.").setVersion(1130);
			addNodeObject(values, "Transform Path",	s_node_path_transform,	"Node_Path_Transform",	[1, Node_Path_Transform]).setVersion(1130);
			addNodeObject(values, "Shift Path",		s_node_path_shift,		"Node_Path_Shift",		[1, Node_Path_Shift],, "Move path along its normal.").setVersion(1130);
			addNodeObject(values, "Trim Path",		s_node_path_trim,		"Node_Path_Trim",		[1, Node_Path_Trim]).setVersion(1130);
			addNodeObject(values, "Wave Path",		s_node_path_wave,		"Node_Path_Wave",		[1, Node_Path_Wave], ["zigzag path"]).setVersion(1130);
			addNodeObject(values, "Reverse Path",	s_node_path_reverse,	"Node_Path_Reverse",	[1, Node_Path_Reverse]).setVersion(1130);
			addNodeObject(values, "Path Builder",	s_node_path_builder,	"Node_Path_Builder",	[1, Node_Path_Builder]).setVersion(1137);
			addNodeObject(values, "L system",		s_node_path_l_system,	"Node_Path_L_System",	[1, Node_Path_L_System]).setVersion(1137);
			
			ds_list_add(values, "Boolean");
			addNodeObject(values, "Boolean",		s_node_boolean,		"Node_Boolean",		[1, Node_Boolean]);
			addNodeObject(values, "Compare",		s_node_compare,		"Node_Compare",		[0, Node_create_Compare], ["equal", "greater", "lesser"]);
			addNodeObject(values, "Logic Opr",		s_node_logic_opr,	"Node_Logic",		[0, Node_create_Logic], [ "and", "or", "not", "nand", "nor" , "xor" ]);
		
		var color = ds_list_create();
		addNodeCatagory("Color", color);
			ds_list_add(color, "Colors");
			addNodeObject(color, "Color",			s_node_color_out,		"Node_Color",			[1, Node_Color]);
			addNodeObject(color, "RGB Color",		s_node_color_from_rgb,	"Node_Color_RGB",		[1, Node_Color_RGB],, "Create color from RGB value.");
			addNodeObject(color, "HSV Color",		s_node_color_from_hsv,	"Node_Color_HSV",		[1, Node_Color_HSV],, "Create color from HSV value.");
			addNodeObject(color, "Sampler",			s_node_sampler,			"Node_Sampler",			[1, Node_Sampler],, "Sample color from an image.");
			addNodeObject(color, "Color Data",		s_node_color_data,		"Node_Color_Data",		[1, Node_Color_Data],, "Get data (rgb, hsv, brightness) from color.");
			addNodeObject(color, "Find pixel",		s_node_pixel_find,		"Node_Find_Pixel",		[1, Node_Find_Pixel],, "Get the position of the first pixel with a given color.").setVersion(1130);
		
			ds_list_add(color, "Palettes");
			addNodeObject(color, "Palette",			s_node_palette,			"Node_Palette",			[1, Node_Palette]);
			addNodeObject(color, "Sort Palette",	s_node_palette_sort,	"Node_Palette_Sort",	[1, Node_Palette_Sort]).setVersion(1130);
			addNodeObject(color, "Palette Extract",	s_node_palette_extract,	"Node_Palette_Extract",	[1, Node_Palette_Extract],, "Extract palette from an image.").setVersion(1100);
			addNodeObject(color, "Palette Replace",	s_node_palette_replace,	"Node_Palette_Replace",	[1, Node_Palette_Replace]).setVersion(1120);
		
			ds_list_add(color, "Gradient");
			addNodeObject(color, "Gradient",			s_node_gradient_out,		"Node_Gradient_Out",			[1, Node_Gradient_Out]);
			addNodeObject(color, "Gradient Palette",	s_node_gradient_palette,	"Node_Gradient_Palette",		[1, Node_Gradient_Palette],, "Create gradient from palette.").setVersion(1135);
			addNodeObject(color, "Gradient Shift",		s_node_gradient_shift,		"Node_Gradient_Shift",			[1, Node_Gradient_Shift],, "Move gradients keys.");
			addNodeObject(color, "Gradient Replace",	s_node_gradient_replace,	"Node_Gradient_Replace_Color",	[1, Node_Gradient_Replace_Color]).setVersion(1135);
			addNodeObject(color, "Gradient Data",		s_node_gradient_data,		"Node_Gradient_Extract",		[1, Node_Gradient_Extract],, "Get palatte and array of key positions from gradient.").setVersion(1135);
	
		var animation = ds_list_create();
		addNodeCatagory("Animation", animation);
			ds_list_add(animation, "Animations");
			addNodeObject(animation, "Frame Index",		s_node_counter,		"Node_Counter",		[1, Node_Counter], ["current frame", "counter"], "Output current frame as frame index, or animation progress (0 - 1).");
			addNodeObject(animation, "Wiggler",			s_node_wiggler,		"Node_Wiggler",		[1, Node_Wiggler],, "Create smooth random value.");
			addNodeObject(animation, "Evaluate Curve",	s_node_curve_eval,	"Node_Anim_Curve",	[1, Node_Anim_Curve],, "Evaluate value from an animation curve.");
	
		var node = ds_list_create();
		addNodeCatagory("Node", node);
			ds_list_add(node, "Logic");
			addNodeObject(node, "Condition",		s_node_condition,	"Node_Condition",	[1, Node_Condition],, "Given a condition, output one value if true, another value is false.");
			addNodeObject(node, "Switch",			s_node_switch,		"Node_Switch",		[1, Node_Switch],, "Given an index, output value base on index matching.").setVersion(1090);
		
			ds_list_add(node, "Groups");
			addNodeObject(node, "Group",			s_node_group,		"Node_Group",			[1, Node_Group]);
			addNodeObject(node, "Feedback",			s_node_feedback,	"Node_Feedback",		[1, Node_Feedback],, "Create group that reuse output from last frame to the current one.");
			addNodeObject(node, "Loop",				s_node_loop,		"Node_Iterate",			[1, Node_Iterate], ["iterate", "for"], "Create group that reuse output as input repeatedly in one frame.");
			addNodeObject(node, "Loop Array",		s_node_loop_array,	"Node_Iterate_Each",	[1, Node_Iterate_Each], ["iterate each", "for each", "array loop"], "Create group that iterate to each member in an array.");
		
			ds_list_add(node, "Lua");
			addNodeObject(node, "Lua Global",		s_node_lua_global,	"Node_Lua_Global",		[1, Node_Lua_Global]).setVersion(1090);
			addNodeObject(node, "Lua Surface",		s_node_lua_surface,	"Node_Lua_Surface",		[1, Node_Lua_Surface]).setVersion(1090);
			addNodeObject(node, "Lua Compute",		s_node_lua_compute,	"Node_Lua_Compute",		[1, Node_Lua_Compute]).setVersion(1090);
		
			ds_list_add(node, "Organize");
			addNodeObject(node, "Pin",				s_node_pin,			"Node_Pin",				[1, Node_Pin],, "Craete pin to organize your connection. Can be create by double clicking on a connection line.");
			addNodeObject(node, "Frame",			s_node_frame,		"Node_Frame",			[1, Node_Frame],, "Create frame surrounding nodes.");
			addNodeObject(node, "Tunnel In",		s_node_tunnel_in,	"Node_Tunnel_In",		[1, Node_Tunnel_In],, "Create tunnel for sending value based on key matching.");
			addNodeObject(node, "Tunnel Out",		s_node_tunnel_out,	"Node_Tunnel_Out",		[1, Node_Tunnel_Out],, "Receive value from tunnel in of the same key.");
			addNodeObject(node, "Display Text",		s_node_text_display,"Node_Display_Text",	[1, Node_Display_Text],, "Display text on the graph.");
			addNodeObject(node, "Display Image",	s_node_image,		"Node_Display_Image",	[0, Node_create_Display_Image],, "Display image on the graph.");
		
			ds_list_add(node, "Cache");
			addNodeObject(node, "Cache",		s_node_cache,		"Node_Cache",		[1, Node_Cache],, "Store current animation. Cache persisted between save.").setVersion(1134);
			addNodeObject(node, "Cache Array",	s_node_cache_array,	"Node_Cache_Array",	[1, Node_Cache_Array],, "Store current animation as array.  Cache persisted between save.").setVersion(1130);
		
		var hid = ds_list_create();
		addNodeCatagory("Hidden", hid, ["Hidden"]);
			addNodeObject(hid, "Input",				s_node_feedback_input,	"Node_Iterator_Each_Input",		[1, Node_Iterator_Each_Input]);
			addNodeObject(hid, "Output",			s_node_feedback_output,	"Node_Iterator_Each_Output",	[1, Node_Iterator_Each_Output]);
			addNodeObject(hid, "Grid Noise",		s_node_grid_noise,		"Node_Grid_Noise",				[1, Node_Grid_Noise]);
			addNodeObject(hid, "Triangular Noise",	s_node_grid_tri_noise,	"Node_Noise_Tri",				[1, Node_Noise_Tri]).setVersion(1090);
			addNodeObject(hid, "Hexagonal Noise",	s_node_grid_hex_noise,	"Node_Noise_Hex",				[1, Node_Noise_Hex]).setVersion(1090);
	}
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
		var list = node.group == noone? NODES : node.group.getNodeList();
		ds_list_remove(list, node);
		node.destroy(_merge);
		
		recordAction(ACTION_TYPE.node_delete, node);
		PANEL_ANIMATION.updatePropertyList();
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
		
		ds_map_clear(APPEND_MAP);
		ds_map_clear(NODE_MAP);
		ds_list_clear(NODES);	
	}
	
	function graphFocusNode(node) {
		PANEL_INSPECTOR.inspecting = node;
		ds_list_clear(PANEL_GRAPH.nodes_select_list);
		PANEL_GRAPH.node_focus = node;
		PANEL_GRAPH.fullView();
	}
#endregion