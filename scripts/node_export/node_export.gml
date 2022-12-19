function Node_create_Export(_x, _y, _group = -1) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_save_filename(".png", "export");
	}
	
	var node = new Node_Export(_x, _y, _group);
	node.inputs[| 1].setValue(path);
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Export(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Export";
	auto_update = false;
	previewable = false;
	
	w = 96;
	min_h = 0;
	playing = false;
	played  = 0;
	
	inputs[| 0] = nodeValue(0, "Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Paths",   self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_save, ["*.png", ""])
		.setVisible(true);
	
	inputs[| 2] = nodeValue(2, "Template",  self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "%d%n")
		.setDisplay(VALUE_DISPLAY.export_format);
	
	format_single = ["Single image (.png)", "Image sequence (.png)", "Animated gif (.gif)"];
	format_array  = ["Multiple image (.png)", "Image sequence (.png)", "Animated gif (.gif)"];
	inputs[| 3] = nodeValue(3, "Format", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Single image (.png)", "Image sequence (.png)", "Animated gif (.gif)"]);
	
	inputs[| 4] = nodeValue(4, "Template guides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.label, 
@"%d          Directory
%1d        Goes up 1 level
%n          File name
%f           Frame
%i           Array index" );

	inputs[| 5] = nodeValue(5, "Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.setVisible(false);
	inputs[| 6] = nodeValue(6, "Frame optimization", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(false);
	inputs[| 7] = nodeValue(7, "Color merge", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.02)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(false);
	inputs[| 8] = nodeValue(8, "Dithering", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(false);
	inputs[| 9] = nodeValue(9, "Auto execute", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [
		9, 
		["Path",			false], 0, 1, 2, 4, 
		["Format settings", false], 3, 
		["Gif settings",	false], 5, 6, 7, 8,
	];
	
	static onValueUpdate = function(_index) {
		var form = inputs[| 3].getValue();
		
		if(_index == 3 && form == 1)
			inputs[| 2].setValue("%d%n%3f%i");
		
		inputs[| 5].setVisible(form == 2);
		inputs[| 6].setVisible(form == 2);
		inputs[| 7].setVisible(form == 2);
		inputs[| 8].setVisible(form == 2);
	}
	
	static renderGif = function(temp_path, target_path) {
		show_debug_message("render from " + temp_path + " to " + target_path);
		var loop = inputs[| 5].getValue();
		var opti = inputs[| 6].getValue();
		var fuzz = inputs[| 7].getValue();
		var dith = inputs[| 8].getValue();
		
		var converter = working_directory + "ImageMagick\\convert.exe";
		var framerate = ANIMATOR.framerate / 10;
		var loop_str = loop? 0 : 1;
		
		var shell_cmd = "-delay " + string(framerate) +
			" -alpha set" + 
			" -dispose previous" + 
			" -loop " + string(loop_str);
		
		if(opti) {
			var first_image = string_replace(temp_path, "*", "100000");
			
			shell_cmd += " -fuzz " + string(fuzz * 100) + "%" +
				" -layers OptimizeFrame" +
				" -layers OptimizeTransparency";
		}
		
		if(dith) {
			shell_cmd += " +dither";	
		}
		
		shell_cmd += " " + temp_path + 
					 " " + target_path;
		//show_debug_message(converter);
		//show_debug_message(shell_cmd);
		execute_shell_simple(converter, shell_cmd);
	}
	
	static step = function() {
		auto_update = inputs[| 9].getValue();
		var surf = inputs[| 0].getValue();
		if(is_array(surf))	inputs[| 3].display_data = format_array;
		else				inputs[| 3].display_data = format_single;
		
		var anim = inputs[| 3].getValue();
		if(!anim) return;
		
		if(!ANIMATOR.is_playing) {
			playing = false;
			return;
		}
		
		if(!ANIMATOR.frame_progress || !playing || ANIMATOR.current_frame <= -1)
			return;
			
		export();
				
		if(ANIMATOR.current_frame < ANIMATOR.frames_total - 1) 
			return;
				
		ANIMATOR.is_playing = false;
		playing = false;
					
		if(anim != 2)
			return;
				
		var path = inputs[| 1].getValue();
		var suff = inputs[| 2].getValue();
		var temp_path, target_path;
						
		if(is_array(surf)) {
			for(var i = 0; i < array_length(surf); i++) {
				temp_path = "\"" + DIRECTORY + "temp\\" + string(i) + "\\" + "*.png\"";
				if(is_array(path))
					target_path = pathString(path[ safe_mod(i, array_length(path)) ], suff, i);
				else
					target_path = pathString(path, suff, i);
				renderGif(temp_path, "\"" + target_path + "\"");
			}
		} else {
			target_path = "\"" + pathString(path, suff) + "\"";
			renderGif("\"" + DIRECTORY + "temp\\*.png\"", target_path);
		}
	}
	
	static pathString = function(path, suff, index = 0) {
		var form = inputs[| 3].getValue();
		
		var s = "", i = 1, ch, ch_s;
		var len = string_length(suff);
		while(i <= len) {
			ch = string_char_at(suff, i);
				
			if(ch == "%") {
				i++;
				var res = false, str = "";
					
				do {
					ch_s = string_char_at(suff, i);
					switch(ch_s) {
						case "f" :
							var float_str = string_digits(str);
							if(float_str != "") {
								var float_val = string_digits(float_str);
								var str_val = max(float_val - string_length(string(ANIMATOR.current_frame)), 0);
								repeat(str_val)
									s += "0";
							}
								
							s += string(ANIMATOR.current_frame);
							res = true;
							break;
						case "i" :
							s += string(index);
							res = true;
							break;
						case "d" : 
							var dir = filename_dir(path) + "\\";
							
							var float_str = string_digits(str);
							if(float_str != "") {
								var float_val = string_digits(float_str);
								var dir_s = "";
								var sep = string_splice(dir, "\\");
								for(var j = 0; j < array_length(sep) - float_val; j++) {
									dir_s += sep[j] + "\\";
								}
								s += dir_s;
							} else 
								s += dir;
							res = true;
							break;
						case "n" : 
							var ext = filename_ext(path);
							s += string_replace(filename_name(path), ext, "");
							res = true;
							break;
						default :
							str += ch_s;
					}
						
					i++;
				} until(i > string_length(suff) || res);
			} else {
				s += ch;
				i++;
			}
		}
		
		if(form == 0 || form == 1)
			s += ".png";
		else
			s += ".gif";
		
		return s;
	}
	
	static export = function() {
		var surf = inputs[| 0].getValue();
		var path = inputs[| 1].getValue();
		var suff = inputs[| 2].getValue();
		var form = inputs[| 3].getValue();
		
		var _ts = current_time;
		
		if(is_array(surf)) {
			for(var i = 0; i < array_length(surf); i++) {
				var _surf = surf[i];
				if(!is_surface(_surf)) continue;
				
				var p = "";
				if(form == 2) {
					p = DIRECTORY + "temp\\" + string(i) + "\\" + string(100000 + ANIMATOR.current_frame) + ".png";
				} else {
					if(is_array(path) && array_length(path) == array_length(surf))
						p = pathString(path[ safe_mod(i, array_length(path)) ], suff, i);
					else
						p = pathString(path, suff, i);
				}
					
				surface_save(_surf, p);
			}
		} else {
			if(is_surface(surf)) {
				var p = path;
				if(is_array(path)) p = path[0];
				
				if(form == 2) {
					p = DIRECTORY + "temp\\" + string(100000 + ANIMATOR.current_frame) + ".png";
				} else {
					p = pathString(p, suff);
				}
				
				surface_save(surf, p);
			}	
		}
	}
	
	static update = function() {
		if(LOADING || APPENDING) return;
		
		var path = inputs[| 1].getValue();
		if(path == "") return;
		var anim = inputs[| 3].getValue();
		
		if(anim) {
			playing					= true;
			played					= 0;
			ANIMATOR.real_frame		= -1;
			ANIMATOR.current_frame	= -1;
			ANIMATOR.is_playing		= true;
			
			if(directory_exists(DIRECTORY + "temp"))
				directory_destroy(DIRECTORY + "temp");
		} else
			export();
	}
}