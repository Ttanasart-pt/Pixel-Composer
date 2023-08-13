function Node_create_Export(_x, _y, _group = noone) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_save_filename(@"Portable Network Graphics (.png)|*.png|
Joint Photographic Experts Group (.jpg)|*.jpg|
Graphics Interchange Format (.gif)|*.gif|
Animated WebP (.webp)|*.webp", 
			"export");
			
		key_release();
	}
	
	var node = new Node_Export(_x, _y, _group);
	node.inputs[| 1].setValue(path);
	node.extensionCheck();
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function exportAll() {
	PROJECT.animator.rendering = true;
	Render();
	PROJECT.animator.rendering = false;
	
	var key = ds_map_find_first(PROJECT.nodeMap);
	repeat(ds_map_size(PROJECT.nodeMap)) {
		var node = PROJECT.nodeMap[? key];
		key = ds_map_find_next(PROJECT.nodeMap, key);
			
		if(!node.active) continue;
		if(instanceof(node) != "Node_Export") continue;
					
		node.doInspectorAction();
	}
}

enum NODE_EXPORT_FORMAT {
	single,
	sequence, 
	gif,
}

function Node_Export(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Export";
	preview_channel = 1;
	
	playing = false;
	played  = 0;
	
	_format_still = ["Portable Network Graphics (.png)|*.png|Joint Photographic Experts Group (.jpg)|*.jpg", ""];
	_format_anim  = ["Graphics Interchange Format (.gif)|*.gif|Animated WebP (.webp)|*.webp", ""];
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Paths",   self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_save, _format_still)
		.setVisible(true);
	
	inputs[| 2] = nodeValue("Template",  self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "%d%n")
		.rejectArray();
	inputs[| 2].editWidget.format		= TEXT_AREA_FORMAT.path_template;
	inputs[| 2].editWidget.auto_update	= true;
	
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
	
	inputs[| 12] = nodeValue("Frame range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, -1])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, PROJECT.animator.frames_total, 1])
	
	outputs[| 0] = nodeValue("Loop exit", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	outputs[| 1] = nodeValue("Preview", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone)
		.setVisible(false);
	
	template_guide = [
		["%d",  "Directory"],
		["%1d", "Goes up 1 level"],
		["%n",  "File name"],
		["%f",  "Frame"],
		["%i",  "Array index"],
	];
	export_template = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _tx = _x + ui(10);
		var _ty = _y;
		var _tw = _w - ui(8);
		
		var rawpath = inputs[| 1].getValue(,,, true);
		if(is_array(rawpath)) rawpath = array_safe_get(rawpath, 0, "");
		
		var _ext    = inputs[| 9].getValue(,,, true);
		var path    = pathString(rawpath);
		var pathA   = pathString(rawpath,, true);
		path = string_replace(path, ".png", array_safe_get(inputs[|  9].display_data, _ext, ""));
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
		var _th = ui(12) + string_height_ext(path, -1, _tw - ui(16), true);
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _tx, _ty, _tw, _th, COLORS.node_composite_bg_blend, 1);
		
		var lw  = 0;
		var lx  = _tx + ui(8);
		var ly  = _ty + ui(6);
		
		draw_set_alpha(0.9);
		for( var i = 0, n = array_length(pathA); i < n; i++ ) {
			var _txt = pathA[i];
			
			if(is_array(_txt)) {
				switch(_txt[0]) {
					case "d" :   draw_set_color(COLORS.widget_text_dec_d); break;	
					case "n" :   draw_set_color(COLORS.widget_text_dec_n); break;	
					case "f" :   draw_set_color(COLORS.widget_text_dec_f); break;	
					case "i" :   draw_set_color(COLORS.widget_text_dec_i); break;
					case "ext" : draw_set_color(COLORS._main_text_sub); break;
				}
				
				_txt = _txt[1];
			} else 
				draw_set_color(COLORS._main_text);
			
			for( var j = 1; j <= string_length(_txt); j++ ) {
				var ch = string_char_at(_txt, j);
				var ww = string_width(ch);
			
				if(lw + ww > _tw - ui(16)) {
					lw = 0;
					lx = _tx + ui(8);
					ly += string_height("M");
				}
			
				draw_text(lx, ly, ch);
			
				lw += ww;
				lx += ww;
			}
		}
		draw_set_alpha(1);
		
		var hh  = _th + ui(116);
		var _cy = _y + _th + ui(8);
		for( var i = 0, n = array_length(template_guide); i < n; i++ ) {
			var _yy = _cy + ui(20) * i;
			
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x + ui(16 + 16), _yy, template_guide[i][0]);
			
			draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text_sub);
			draw_text_add(_x + _w - ui(4 + 16), _yy, template_guide[i][1]);
		}
		
		return hh;
	});
	
	input_display_list = [
		["Export",		false], 0, 1, 2, export_template, 
		["Format ",		false], 3, 9, 
		["Settings",	false], 12, 8, 5, 6, 7, 10, 11, 
	];
	
	directory = DIRECTORY + "temp/" + string(irandom_range(100000, 999999));
	converter = working_directory + "ImageMagick/convert.exe";
	magick    = working_directory + "ImageMagick/magick.exe";
	webp      = working_directory + "webp/webpmux.exe";
	
	gifski = working_directory + "gifski\\win\\gifski.exe";
	
	static onValueUpdate = function(_index) {
		var form = inputs[| 3].getValue();
		
		if(_index == 3) {
			inputs[| 9].setValue(0);
			
			switch(form) {
				case 0 : 
				case 1 : 
					inputs[| 1].display_data = _format_still;
					break;
				case 2 : 
					inputs[| 1].display_data = _format_anim;
					break;
			}
		}
		
		if(_index == 3 && form == 1)
			inputs[| 2].setValue("%d%n%3f%i");
		
		if(_index == 1) {
			var _path = inputs[| 1].getValue();
			var _ext  = filename_ext(_path);
			
			switch(_ext) {
				case ".png" :  inputs[| 9].setValue(0); break;
				case ".jpg" :  inputs[| 9].setValue(1); break;
			
				case ".gif" :  inputs[| 9].setValue(0); break;
				case ".webp" : inputs[| 9].setValue(1); break;
			}
		}
	}
	
	static extensionCheck = function() {
		var _path = inputs[| 1].getValue();
		var _ext  = filename_ext(_path);
			
		switch(_ext) {
			case ".png" : 
				inputs[| 3].setValue(0);
				inputs[| 9].setValue(0);
				break;
			case ".jpg" : 
				inputs[| 3].setValue(0);
				inputs[| 9].setValue(1);
				break;
			
			case ".gif" : 
				inputs[| 3].setValue(2);
				inputs[| 9].setValue(0);
				break;
			case ".webp" : 
				inputs[| 3].setValue(2);
				inputs[| 9].setValue(1);
				break;
		}
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
		if(rate == 0) rate = 1;
		
		var framerate = round(1 / rate * 1000);
		
		var cmd = "";
		
		for( var i = 0, n = array_length(frames); i < n; i++ )
			cmd += "-frame " + frames[i] + " +" + string(framerate) + "+0+0+1 ";
		
		cmd += "-bgcolor 0,0,0,0 ";
		cmd += "-o \"" + target_path + "\"";
		
		execute_shell(webp, cmd); 
		
		var noti = log_message("EXPORT", "Export webp as " + target_path, THEME.noti_icon_tick, COLORS._main_value_positive, false);
		noti.path = filename_dir(target_path);
		noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
		
		PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
	}
	
	static renderGif = function(temp_path, target_path) {
		var loop = inputs[|  5].getValue();
		var opti = inputs[|  6].getValue();
		var fuzz = inputs[|  7].getValue();
		var rate = inputs[|  8].getValue();
		var qual = inputs[| 10].getValue();
		if(rate == 0) rate = 1;
		
		target_path = string_replace_all(target_path, "/", "\\");
		var framerate  = 100 / rate;
		var loop_str   = loop? 0 : 1;
		var use_gifski = false;
		
		if(use_gifski) {
			var	shell_cmd  = $"-o {target_path} -r {rate} --repeat {loop_str} -Q {qual} ";
				shell_cmd += temp_path;
			
			//print($"{gifski} {shell_cmd}");
			execute_shell(gifski, shell_cmd);
		} else {
			var		 shell_cmd  = $"-delay {framerate} -alpha set -dispose previous -loop {loop_str}";
			if(opti) shell_cmd += $" -fuzz {fuzz * 100}% -layers OptimizeFrame -layers OptimizeTransparency";
					 shell_cmd += " " + temp_path + " " + target_path;
			
			//print($"{converter} {shell_cmd}");
			execute_shell(converter, shell_cmd);
		}
		
		var noti = log_message("EXPORT", "Export gif as " + target_path, THEME.noti_icon_tick, COLORS._main_value_positive, false);
		noti.path = filename_dir(target_path);
		noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
		
		PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
	}
	
	static pathString = function(path, index = 0, _array = false) {
		var suff = inputs[|  2].getValue();
		var form = inputs[|  3].getValue();
		var strt = inputs[| 11].getValue();
		
		path = string_replace_all(path, "\\", "/");
		
		var s = _array? [] : "";
		var i = 1;
		var ch, ch_s;
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
							var _txt = "";
							var float_str = string_digits(str);
							if(float_str != "") {
								var float_val = string_digits(float_str);
								var str_val = max(float_val - string_length(string(PROJECT.animator.current_frame + strt)), 0);
								repeat(str_val)
									_txt += "0";
							}
							
							_txt += string(PROJECT.animator.current_frame + strt);
							if(_array)	array_push(s, [ "f", _txt ]);
							else		s += _txt;
							res = true;
							break;
						case "i" :
							if(_array)	array_push(s, [ "i", string(index) ]);
							else		s += string(index);
							res = true;
							break;
						case "d" : 
							var dir  = filename_dir(path) + "/";
							var _txt = "";
							
							var float_str = string_digits(str);
							if(float_str != "") {
								var float_val = toNumber(string_digits(float_str)) + 1;
								var dir_s = "";
								var sep   = string_splice(dir, "/");
								
								for(var j = 0; j < array_length(sep) - float_val; j++)
									dir_s += sep[j] + "/";
								_txt += dir_s;
							} else 
								_txt += dir;
							
							if(_array)	array_push(s, [ "d", _txt ]);
							else		s += _txt;
							res = true;
							break;
						case "n" : 
							var ext  = filename_ext(path);
							var _txt = string_replace(filename_name(path), ext, "");
							
							if(_array)	array_push(s, [ "n", _txt ]);
							else		s += _txt;
							res = true;
							break;
						default :
							str += ch_s;
					}
						
					i++;
				} until(i > string_length(suff) || res);
			} else {
				if(_array)	array_push(s, ch);
				else		s += ch;
				i++;
			}
		}
		
		if(_array)	array_push(s, ["ext", ".png"]);
		else		s += ".png";
		
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
		
		var _pathOut  = _path;
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
		var surf = inputs[|  0].getValue();
		var path = inputs[|  1].getValue();
		var suff = inputs[|  2].getValue();
		var form = inputs[|  3].getValue();
		var rang = inputs[| 12].getValue();
		
		var _ts = current_time;
		
		if(form >= 1) {
			var rng_s = rang[0];
			var rng_e = rang[1] == -1? PROJECT.animator.frames_total : rang[1];
			
			if(PROJECT.animator.current_frame < rng_s) return;
			if(PROJECT.animator.current_frame > rng_e) return;
		}
		
		if(is_array(surf)) {
			var p = "";
			for(var i = 0; i < array_length(surf); i++) {
				var _surf = surf[i];
				if(!is_surface(_surf)) continue;
				
				if(form == NODE_EXPORT_FORMAT.gif) {
					p = directory + "/" + string(i) + "/" + string_lead_zero(PROJECT.animator.current_frame, 5) + ".png";
				} else {
					if(is_array(path) && array_length(path) == array_length(surf))
						p = pathString(path[ safe_mod(i, array_length(path)) ], i);
					else
						p = pathString(path, i);
				}
					
				p = save_surface(_surf, p);
			}
			
			if(form != NODE_EXPORT_FORMAT.gif) {
				var noti = log_message("EXPORT", "Export " + string(array_length(surf)) + " images complete.", THEME.noti_icon_tick, COLORS._main_value_positive, false);
				noti.path = filename_dir(p);
				noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
				
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
		} else if(is_surface(surf)) {
			var p = path;
			if(is_array(path)) p = path[0];
				
			if(form == NODE_EXPORT_FORMAT.gif)
				p = directory + "/" + string_lead_zero(PROJECT.animator.current_frame, 5) + ".png";
			else
				p = pathString(p);
			
			//print("Exporting " + p);
			p = save_surface(surf, p);
				
			if(form != NODE_EXPORT_FORMAT.gif) {
				var noti = log_message("EXPORT", "Export image as " + p, THEME.noti_icon_tick, COLORS._main_value_positive, false);
				noti.path = filename_dir(p);
				noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
					
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
		}
	}
	
	insp1UpdateTooltip   = "Export";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	insp2UpdateTooltip = "Export All";
	insp2UpdateIcon    = [ THEME.play_all, 0, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		if(isInLoop())	UPDATE |= RENDER_TYPE.full;
		else			doInspectorAction();
	}
	
	static onInspector2Update = function() { exportAll(); }
	
	static doInspectorAction = function() {
		if(LOADING || APPENDING) return;
		
		var path = inputs[| 1].getValue();
		if(path == "") return;
		var form = inputs[| 3].getValue();
		
		if(form == NODE_EXPORT_FORMAT.single) {
			PROJECT.animator.rendering = true;
			Render();
			PROJECT.animator.rendering = false;
			
			export();
			return;
		}
		
		playing					= true;
		played					= 0;
		PROJECT.animator.real_frame		= -1;
		PROJECT.animator.current_frame	= -1;
		PROJECT.animator.is_playing		= true;
		PROJECT.animator.rendering		= true;
		
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
		inputs[| 12].setVisible(anim >= 1);
		inputs[| 12].editWidget.maxx = PROJECT.animator.frames_total;
		
		if(anim == NODE_EXPORT_FORMAT.gif) {
			inputs[|  9].display_data		  = format_animation;
			inputs[|  9].editWidget.data_list = format_animation;
			inputs[| 10].setVisible(true);
		} else {
			inputs[|  9].display_data		  = format_image;
			inputs[|  9].editWidget.data_list = format_image;
			inputs[| 10].setVisible(extn != 0);
		}
		
		outputs[| 0].visible = isInLoop();
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var anim = inputs[| 3].getValue();
		if(anim == NODE_EXPORT_FORMAT.single) {
			if(isInLoop()) export();
			return;
		}
		
		if(!PROJECT.animator.is_playing) {
			playing = false;
			return;
		}
		
		if(!PROJECT.animator.frame_progress || !playing || PROJECT.animator.current_frame <= -1)
			return;
		
		export();
		
		if(PROJECT.animator.current_frame < PROJECT.animator.frames_total - 1) 
			return;
		
		if(anim != NODE_EXPORT_FORMAT.gif)
			return;
				
		var surf = inputs[|  0].getValue();
		var path = inputs[|  1].getValue();
		var suff = inputs[|  2].getValue();
		var extd = inputs[|  9].getValue();
		var rang = inputs[| 12].getValue();
		var temp_path, target_path;
		
		if(is_array(surf)) {
			for(var i = 0; i < array_length(surf); i++) {
				temp_path = directory + "/" + string(i) + "/" + "*.png";
				if(is_array(path))
					target_path = pathString(path[ safe_mod(i, array_length(path)) ], i);
				else
					target_path = pathString(path, i);
				
				if(extd == 0) {
					target_path = string_replace(target_path, ".png", ".gif");
					renderGif("\"" + temp_path + "\"", "\"" + target_path + "\"");
				} else if(extd == 1) {
					target_path = string_replace(target_path, ".png", ".webp");
					renderWebp(temp_path, target_path);
				}
			}
		} else {
			target_path = pathString(path);
			
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
	
	static doApplyDeserialize = function() {
		onValueUpdate(3);
	}
}