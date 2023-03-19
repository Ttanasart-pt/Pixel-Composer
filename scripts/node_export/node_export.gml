function Node_create_Export(_x, _y, _group = noone) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_save_filename(".png", "export"); 
		key_release();
	}
	
	var node = new Node_Export(_x, _y, _group);
	node.inputs[| 1].setValue(path);
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum NODE_EXPORT_FORMAT {
	single,
	sequence, 
	gif,
}

function Node_Export(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Export";
	preview_channel = 1;
	
	playing = false;
	played  = 0;
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Paths",   self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_save, ["*.png", ""])
		.setVisible(true);
	
	inputs[| 2] = nodeValue("Template",  self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "%d%n")
		.rejectArray();
	
	format_single = ["Single image", "Image sequence", "Animation"];
	format_array  = ["Multiple images", "Image sequences", "Animation"];
	
	inputs[| 3] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, format_single, { update_hover: false })
		.rejectArray();
	
	inputs[| 4] = nodeValue("Template guides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.label, 
@"%d          Directory
%1d        Goes up 1 level
%n          File name
%f           Frame
%i           Array index" );

	inputs[| 5] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.setVisible(false)
		.rejectArray();
	
	inputs[| 6] = nodeValue("Frame optimization", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(false)
		.rejectArray();
	
	inputs[| 7] = nodeValue("Color merge", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.02)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(false)
		.rejectArray();
	
	inputs[| 8] = nodeValue("Framerate", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 30)
		.rejectArray();
	
	format_image     = [ ".png", ".jpg", ".webp" ];
	format_animation = [ ".gif", ".webp" ];
	
	inputs[| 9] = nodeValue("Format", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, format_image, { update_hover: false })
		.rejectArray();
	
	inputs[| 10] = nodeValue("Quality", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 80)
		.setDisplay(VALUE_DISPLAY.slider, [0, 100, 1])
		.rejectArray();
	
	inputs[| 11] = nodeValue("Sequence begin", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
	
	outputs[| 0] = nodeValue("Loop exit", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	outputs[| 1] = nodeValue("Preview", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone)
		.setVisible(false);
	
	input_display_list = [
		["Export",		false], 0, 1, 2, 4, 
		["Format ",		false], 3, 9, 
		["Settings",	false], 8, 5, 6, 7, 10, 11, 
	];
	
	directory = DIRECTORY + "temp/" + string(irandom_range(100000, 999999));
	converter = working_directory + "ImageMagick/convert.exe";
	magick    = working_directory + "ImageMagick/magick.exe";
	webp      = working_directory + "webp/webpmux.exe";
	
	static onValueUpdate = function(_index) {
		var form = inputs[| 3].getValue();
		
		if(_index == 3)
			inputs[| 9].setValue(0);
		
		if(_index == 3 && form == 1)
			inputs[| 2].setValue("%d%n%3f%i");
	}
	
	static renderWebp = function(temp_path, target_path) {
		var _path = file_find_first(temp_path + "*.png", 0);
		var frames = [];
		
		while(_path != "") {
		    var _frame    = "\"" + temp_path + string_replace_all(_path, ".png", "") + ".webp\"";
			var _pathTemp = "\"" + temp_path + _path + "\"";
			var shell_cmd = _pathTemp + " -define webp:lossless=true " + _frame;
			
			array_push(frames, _frame);
			execute_shell(magick, shell_cmd);
		
		    _path = file_find_next();
		}
		
		var rate = inputs[| 8].getValue();
		var framerate = round(1 / rate * 1000);
		
		var cmd = "";
		
		for( var i = 0; i < array_length(frames); i++ )
			cmd += "-frame " + frames[i] + " +" + string(framerate) + "+0+0+1 ";
		
		cmd += "-bgcolor 0,0,0,0 ";
		cmd += "-o \"" + target_path + "\"";
		
		execute_shell(webp, cmd); 
		
		var noti = log_message("EXPORT", "Export webp as " + target_path, THEME.noti_icon_tick, COLORS._main_value_positive);
		noti.path = filename_dir(target_path);
		noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
		
		PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
	}
	
	static renderGif = function(temp_path, target_path) {
		var loop = inputs[| 5].getValue();
		var opti = inputs[| 6].getValue();
		var fuzz = inputs[| 7].getValue();
		var rate = inputs[| 8].getValue();
		
		var framerate = 100 / rate;
		var loop_str = loop? 0 : 1;
		
		var shell_cmd = "-delay " + string(framerate) +
			" -alpha set" + 
			" -dispose previous" + 
			" -loop " + string(loop_str);
		
		if(opti) {
			shell_cmd += " -fuzz " + string(fuzz * 100) + "%" +
				" -layers OptimizeFrame" +
				" -layers OptimizeTransparency";
		}
		
		shell_cmd += " " + temp_path + 
					 " " + target_path;
		
		execute_shell(converter, shell_cmd);
		
		var noti = log_message("EXPORT", "Export gif as " + target_path, THEME.noti_icon_tick, COLORS._main_value_positive);
		noti.path = filename_dir(target_path);
		noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
		
		PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
	}
	
	static pathString = function(path, suff, index = 0) {
		var form = inputs[|  3].getValue();
		var strt = inputs[| 11].getValue();
		
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
								var str_val = max(float_val - string_length(string(ANIMATOR.current_frame + strt)), 0);
								repeat(str_val)
									s += "0";
							}
								
							s += string(ANIMATOR.current_frame + strt);
							res = true;
							break;
						case "i" :
							s += string(index);
							res = true;
							break;
						case "d" : 
							var dir = filename_dir(path) + "/";
							
							var float_str = string_digits(str);
							if(float_str != "") {
								var float_val = string_digits(float_str);
								var dir_s = "";
								var sep = string_splice(dir, "/");
								for(var j = 0; j < array_length(sep) - float_val; j++) {
									dir_s += sep[j] + "/";
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
		
		s += ".png";
		
		return s;
	}
	
	static save_surface = function(_surf, _path) {
		var form = inputs[| 3].getValue();
		
		if(form == NODE_EXPORT_FORMAT.gif) {
			surface_save_safe(_surf, _path);
			return _path;
		}
		
		var extd = inputs[|  9].getValue();
		var qual = inputs[| 10].getValue();
		var ext  = array_safe_get(format_image, extd, ".png");
		
		var _pathOut = _path;
		var _pathTemp = directory + "/" + string(irandom_range(10000, 99999)) + ".png";
		
		switch(ext) {
			case ".png": 
				surface_save_safe(_surf, _path);
				break;
			case ".jpg": 
				surface_save_safe(_surf, _pathTemp);
				
				_pathOut = "\"" + string_replace_all(_path, ".png", "") + ".jpg\"";
				_pathTemp = "\"" + _pathTemp + "\"";
				var shell_cmd = _pathTemp + " -quality " + string(qual) + " " + _pathOut;
				
				print(shell_cmd)
				execute_shell(magick, shell_cmd);
				break;
			case ".webp": 
				surface_save_safe(_surf, _pathTemp);
				
				_pathOut = "\"" + string_replace_all(_path, ".png", "") + ".webp\"";
				_pathTemp = "\"" + _pathTemp + "\"";
				var shell_cmd = _pathTemp + " -quality " + string(qual) + " -define webp:lossless=true " + _pathOut;
				
				execute_shell(magick, shell_cmd);
				break;
		}
		
		return _pathOut;
	}
	
	static export = function() { 
		var surf = inputs[| 0].getValue();
		var path = inputs[| 1].getValue();
		var suff = inputs[| 2].getValue();
		var form = inputs[| 3].getValue();
		
		var _ts = current_time;
		
		if(is_array(surf)) {
			var p = "";
			for(var i = 0; i < array_length(surf); i++) {
				var _surf = surf[i];
				if(!is_surface(_surf)) continue;
				
				if(form == NODE_EXPORT_FORMAT.gif) {
					p = directory + "/" + string(i) + "/" + string_lead_zero(ANIMATOR.current_frame, 5) + ".png";
				} else {
					if(is_array(path) && array_length(path) == array_length(surf))
						p = pathString(path[ safe_mod(i, array_length(path)) ], suff, i);
					else
						p = pathString(path, suff, i);
				}
					
				p = save_surface(_surf, p);
			}
			
			if(form != NODE_EXPORT_FORMAT.gif) {
				var noti = log_message("EXPORT", "Export " + string(array_length(surf)) + " images complete.", THEME.noti_icon_tick, COLORS._main_value_positive);
				noti.path = filename_dir(p);
				noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
				
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
		} else if(is_surface(surf)) {
			var p = path;
			if(is_array(path)) p = path[0];
				
			if(form == NODE_EXPORT_FORMAT.gif)
				p = directory + "/" + string_lead_zero(ANIMATOR.current_frame, 5) + ".png";
			else
				p = pathString(p, suff);
			
			//print("Exporting " + p);
			p = save_surface(surf, p);
				
			if(form != NODE_EXPORT_FORMAT.gif) {
				var noti = log_message("EXPORT", "Export image as " + p, THEME.noti_icon_tick, COLORS._main_value_positive);
				noti.path = filename_dir(p);
				noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
					
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
		}
	}
	
	inspUpdateTooltip   = "Export";
	inspUpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	insp2UpdateTooltip = "Export All";
	insp2UpdateIcon    = [ THEME.play_all, 0, COLORS._main_value_positive ];
	
	static onInspectorUpdate = function() {		
		if(isInLoop())	UPDATE |= RENDER_TYPE.full;
		else			doInspectorAction();
	}
	
	static onInspector2Update = function() {
		var key = ds_map_find_first(NODE_MAP);
		repeat(ds_map_size(NODE_MAP)) {
			var node = NODE_MAP[? key];
			key = ds_map_find_next(NODE_MAP, key);
			
			if(!node.active) continue;
			if(instanceof(node) != "Node_Export") continue;
					
			node.doInspectorAction();
		}
		
		if(isInLoop()) UPDATE |= RENDER_TYPE.full;
	}
	
	static doInspectorAction = function() {
		if(LOADING || APPENDING) return;
		
		var path = inputs[| 1].getValue();
		if(path == "") return;
		var form = inputs[| 3].getValue();
		
		if(form == NODE_EXPORT_FORMAT.single) {
			export();
			return;
		}
		
		playing					= true;
		played					= 0;
		ANIMATOR.real_frame		= -1;
		ANIMATOR.current_frame	= -1;
		ANIMATOR.is_playing		= true;
		ANIMATOR.rendering		= true;
		
		if(directory_exists(directory))
			directory_destroy(directory);
		directory_create(directory);
	}
	
	static step = function() {
		var surf = inputs[| 0].getValue();
		if(is_array(surf)) {
			inputs[| 3].display_data		 = format_array;
			inputs[| 3].editWidget.data_list = format_array;
		} else {
			inputs[| 3].display_data	     = format_single;
			inputs[| 3].editWidget.data_list = format_single;
		}
		
		outputs[| 1].setValue(surf);
		
		var anim = inputs[| 3].getValue();
		var extn = inputs[| 9].getValue();
		
		inputs[|  5].setVisible(anim == 2);
		inputs[|  6].setVisible(anim == 2);
		inputs[|  7].setVisible(anim == 2);
		inputs[|  8].setVisible(anim == 2);
		inputs[| 11].setVisible(anim == 1);
		
		if(anim == NODE_EXPORT_FORMAT.gif) {
			inputs[|  9].display_data		  = format_animation;
			inputs[|  9].editWidget.data_list = format_animation;
			inputs[| 10].setVisible(extn == 1);
		} else {
			inputs[|  9].display_data		  = format_image;
			inputs[|  9].editWidget.data_list = format_image;
			inputs[| 10].setVisible(extn != 0);
		}
		
		outputs[| 0].visible = isInLoop();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var anim = inputs[| 3].getValue();
		if(anim == NODE_EXPORT_FORMAT.single) {
			if(isInLoop()) export();
			return;
		}
		
		if(!ANIMATOR.is_playing) {
			playing = false;
			return;
		}
		
		if(!ANIMATOR.frame_progress || !playing || ANIMATOR.current_frame <= -1)
			return;
		
		export();
		
		if(ANIMATOR.current_frame < ANIMATOR.frames_total - 1) 
			return;
		
		if(anim != NODE_EXPORT_FORMAT.gif)
			return;
				
		var surf = inputs[| 0].getValue();
		var path = inputs[| 1].getValue();
		var suff = inputs[| 2].getValue();
		var extd = inputs[| 9].getValue();
		var temp_path, target_path;
						
		if(is_array(surf)) {
			for(var i = 0; i < array_length(surf); i++) {
				temp_path = directory + "/" + string(i) + "/" + "*.png";
				if(is_array(path))
					target_path = pathString(path[ safe_mod(i, array_length(path)) ], suff, i);
				else
					target_path = pathString(path, suff, i);
				
				if(extd == 0) {
					target_path = string_replace(target_path, ".png", ".gif");
					renderGif("\"" + temp_path + "\"", "\"" + target_path + "\"");
				} else if(extd == 1) {
					target_path = string_replace(target_path, ".png", ".webp");
					renderWebp(temp_path, target_path);
				}
			}
		} else {
			target_path = pathString(path, suff);
			
			if(extd == 0) {
				target_path = string_replace(target_path, ".png", ".gif");
				renderGif("\"" + directory + "/*.png\"", "\"" + target_path + "\"");
			} else if(extd == 1) {
				target_path = string_replace(target_path, ".png", ".webp");
				renderWebp(directory + "/", target_path);
			}
		}
		
		//directory_destroy(directory);
	}
}