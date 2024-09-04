function Node_create_Export(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_save_filename_pxc(@"Portable Network Graphics (.png)|*.png|
Joint Photographic Experts Group (.jpg)|*.jpg|
Graphics Interchange Format (.gif)|*.gif|
Animated WebP (.webp)|*.webp|
MPEG-4 (.mp4)|*.mp4", 
			"export");
			
		key_release();
	}
	
	var node = new Node_Export(_x, _y, _group).skipDefault();
	node.inputs[1].setValue(path);
	if(NODE_NEW_MANUAL) node.extensionCheck();
	
	return node;
}

function exportAll() {
	if(IS_RENDERING) return;
	
	for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
		var node = PROJECT.allNodes[i];
		if(!node.active) continue;
		if(!is_instanceof(node, Node_Export)) continue;
		
		node.doInspectorAction();
	}
}

enum NODE_EXPORT_FORMAT {
	single,
	sequence, 
	animation,
}

function Node_Export(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	name = "Export";
	preview_channel = 0;
	
	playing = false;
	played  = 0;
	
	_format_still = { filter: "Portable Network Graphics (.png)|*.png|Joint Photographic Experts Group (.jpg)|*.jpg" };
	_format_anim  = { filter: "Graphics Interchange Format (.gif)|*.gif|Animated WebP (.webp)|*.webp" };
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Path("Paths",   self, ""))
		.setDisplay(VALUE_DISPLAY.path_save, _format_still)
		.setVisible(true);
	
	newInput(2, nodeValue_Text("Template",  self, "%d%n"))
		.rejectArray();
	inputs[2].editWidget.format		 = TEXT_AREA_FORMAT.path_template;
	inputs[2].editWidget.auto_update = true;
	
	format_single = ["Single image", "Image sequence", "Animation"];
	format_array  = ["Multiple images", "Image sequences", "Animations"];
	
	newInput(3, nodeValue_Enum_Scroll("Type", self,  0, { data: format_single, update_hover: false }))
		.rejectArray();
	
	newInput(4, nodeValue_Int("Template guides", self, 0));

	newInput(5, nodeValue_Bool("Loop", self, true))
		.setVisible(false)
		.rejectArray();
	
	newInput(6, nodeValue_Bool("Frame optimization", self, false))
		.setVisible(false)
		.rejectArray();
	
	newInput(7, nodeValue_Float("Color merge", self, 0.02))
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(false)
		.rejectArray();
	
	newInput(8, nodeValue_Int("Framerate", self, 30))
		.rejectArray();
	
	format_image     = [ ".png", ".jpg", ".webp" ];
	format_animation = [ ".gif", ".apng", ".webp", ".mp4" ];
	
	newInput(9, nodeValue_Enum_Scroll("Format", self,  0, { data: format_image, update_hover: false }))
		.rejectArray();
	
	newInput(10, nodeValue_Float("Quality", self, 23))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 100, 0.1 ] })
		.rejectArray();
	
	newInput(11, nodeValue_Int("Sequence begin", self, 0));
	
	newInput(12, nodeValue_Slider_Range("Frame range", self, [0, -1], { range: [0, TOTAL_FRAMES, 0.1] }));
	
	png_format   = [ "INDEX4", "INDEX8", "Default (PNG32)" ];
	newInput(13, nodeValue_Enum_Scroll("Subformat", self,  2, { data: png_format, update_hover: false }));
	
	newInput(14, nodeValue_Int("Frame step", self, 1));
	
	newInput(15, nodeValue_Bool("Custom Range", self, false))
		.rejectArray();
	
	newInput(16, nodeValue_Bool("Export on Save", self, false))
	
	newOutput(0, nodeValue_Output("Preview", self, VALUE_TYPE.surface, noone));
	
	template_guide = [
		["%d",     "Directory"],
		["%1d",    "Goes up 1 level"],
		["%n",     "File name"],
		["%f",     "Frame"],
		["%i",     "Array index"],
		["%{i+1}", "Array index + 1"],
	];
	
	export_template = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _tx = _x + ui(10);
		var _ty = _y;
		var _tw = _w - ui(8);
		
		var rawpath = getInputData(1);
		if(is_array(rawpath)) rawpath = array_safe_get_fast(rawpath, 0, "");
		
		var _ext    = getInputData(9);
		var path    = pathString(rawpath);
		var pathA   = pathString(rawpath,, true);
		path = string_replace(path, ".png", array_safe_get_fast(inputs[ 9].display_data.data, _ext, ""));
		
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
		["Export",		false], 0, 1, 2, export_template, 16, 
		["Format",		false], 3, 9, 6, 7, 10, 13, 
		["Custom Range", true, 15], 12, 
		["Animation",	false], 8, 5, 11, 14, 
	];
	
	render_process_id = 0;
	render_type   = "";
	render_target = "";
	exportLog     = true;
	
	directory = TEMPDIR + string(irandom_range(100000, 999999));
	converter = filepath_resolve(PREFERENCES.ImageMagick_path) + "convert.exe";
	magick    = filepath_resolve(PREFERENCES.ImageMagick_path) + "magick.exe";
	webp      = filepath_resolve(PREFERENCES.webp_path)		   + "webpmux.exe";
	gifski    = filepath_resolve(PREFERENCES.gifski_path) 	   + "win/gifski.exe";
	ffmpeg    = filepath_resolve(PREFERENCES.ffmpeg_path) 	   + "bin/ffmpeg.exe";
	
	if(OS == os_windows) {
		if(!file_exists_empty(converter) || !file_exists_empty(magick)) noti_warning($"No ImageMagick detected at {magick}, please make sure the installation is complete and ImageMagick path is set properly in preference.");
		if(!file_exists_empty(webp))    noti_warning($"No webp detected at {webp}, please make sure the installation is complete and webp path is set properly in preference.");
		if(!file_exists_empty(gifski))  noti_warning($"No gifski detected at {gifski}, please make sure the installation is complete and gifski path is set properly in preference.");
		if(!file_exists_empty(ffmpeg))  noti_warning($"No FFmpeg detected at {ffmpeg}, please make sure the installation is complete and FFmpeg path is set properly in preference.");
		
	} else if(OS == os_macosx) {
		var check_convert = ExecutedProcessReadFromStandardOutput(shell_execute("convert", ""));
		if(string_pos(check_convert, "not found")) noti_warning($"No ImageMagick installed, please install imagemagick with homebrew or use the provided 'mac-libraries-installer.command'.");
		
		var check_webp = ExecutedProcessReadFromStandardOutput(shell_execute("webp", ""));
		if(string_pos(check_webp, "not found")) noti_warning($"No webp installed, please install webp with homwbrew or use the provided 'mac-libraries-installer.command'.");
		
		var check_ffmpeg = ExecutedProcessReadFromStandardOutput(shell_execute("ffmpeg", ""));
		if(string_pos(check_ffmpeg, "not found")) noti_warning($"No FFmpeg installed, please install FFmpeg with homebrew or use the provided 'mac-libraries-installer.command'.");
		
		var _opt = "/opt/homebrew/bin/";
		converter = _opt + "convert";
		magick    = _opt + "magick";
		webp      = _opt + "webp";
		ffmpeg    = _opt + "ffmpeg";
	}
	
	static onValueUpdate = function(_index) {
		var form = getInputData(3);
		
		if(_index == 3) {
			if(NOT_LOAD) inputs[9].setValue(0);
			
			switch(form) {
				case 0 : 
				case 1 : 
					inputs[1].display_data = _format_still;
					break;
				case 2 : 
					inputs[1].display_data = _format_anim;
					break;
			}
		}
		
		if(NOT_LOAD && _index == 3 && form == 1)
			inputs[2].setValue("%d%n%3f%i");
		
		if(NOT_LOAD && _index == 1) {
			var _path = getInputData(1);
			var _ext  = filename_ext(_path);
			
			switch(_ext) {
				case ".png" :  inputs[9].setValue(0); break;
				case ".jpg" :  inputs[9].setValue(1); break;
			
				case ".gif" :  inputs[9].setValue(0); break;
				case ".webp" : inputs[9].setValue(1); break;
			}
		}
	}
	
	static extensionCheck = function() {
		var _path = getInputData(1);
		var _ext  = filename_ext(_path);
			
		switch(_ext) {
			case ".png" : 
				inputs[3].setValue(0);
				inputs[9].setValue(0);
				break;
			case ".jpg" : 
				inputs[3].setValue(0);
				inputs[9].setValue(1);
				break;
			
			case ".gif" : 
				inputs[3].setValue(2);
				inputs[9].setValue(0);
				break;
			case ".webp" : 
				inputs[3].setValue(2);
				inputs[9].setValue(1);
				break;
		}
	}
	
	static renderWebp = function(temp_path, target_path) {
		var _path  = file_find_first(temp_path + "*.png", 0);
		var frames = [];
		
		while(_path != "") {
		    var _frame    = string_quote(temp_path + string_replace_all(_path, ".png", "") + ".webp");
			var _pathTemp = string_quote(temp_path + _path);
			var shell_cmd = _pathTemp + " -define webp:lossless=true " + _frame;
			
			array_push(frames, _frame);
			shell_execute_async(magick, shell_cmd, self, false);
			
		    _path = file_find_next();
		}
		
		var rate = getInputData(8);
		if(rate == 0) rate = 1;
		
		var framerate = round(1 / rate * 1000);
		var cmd = "";
		
		for( var i = 0, n = array_length(frames); i < n; i++ )
			cmd += $"-frame {frames[i]} +{framerate}+0+0+1 ";
		
		cmd += "-bgcolor 0,0,0,0 ";
		cmd += "-o " + string_quote(target_path);
		
		render_process_id = shell_execute_async(webp, cmd, self); 
		render_type       = "webp";
		render_target     = target_path;
	}
	
	static renderGif = function(temp_path, target_path) {
		var loop = getInputData( 5);
		var opti = getInputData( 6);
		var fuzz = getInputData( 7);
		var rate = max(1, getInputData( 8));
		var qual = getInputData(10);
		
		temp_path   = string_replace_all(temp_path, "/", "\\");
		target_path = string_replace_all(target_path, "/", "\\");
		
		var framerate  = 100 / rate;
		var loop_str   = loop? 0 : 1;
		var use_gifski = false;
		
		var		 shell_cmd  = $"-delay {framerate} -alpha set -dispose 2 -loop {loop_str}";
		if(opti) shell_cmd += $" -fuzz {fuzz * 100}% -layers OptimizeFrame -layers OptimizeTransparency";
				 shell_cmd += $" {string_quote(temp_path)} {string_quote(target_path)}";
			
		render_process_id = shell_execute_async(converter, shell_cmd, self);
		render_type       = "gif";
		render_target     = target_path;
	}
	 
	static renderMp4 = function(temp_path, target_path) {
		var rate = getInputData( 8);
		var qual = getInputData(10); qual = clamp(qual, 0, 51);
		if(rate == 0) rate = 1;
		
		if(file_exists_empty(target_path)) file_delete(target_path);
		
		temp_path   = string_replace_all(temp_path, "/", "\\");
		temp_path   = string_trim(temp_path, ["*.png"]) + "%05d.png";
		target_path = string_replace_all(target_path, "/", "\\");
		
		var	shell_cmd  = $"-hide_banner -loglevel quiet -framerate {rate} -i \"{temp_path}\" -c:v libx264 -r {rate} -pix_fmt yuv420p -crf {qual} {string_quote(target_path)}";
		
		render_process_id = shell_execute_async(ffmpeg, shell_cmd, self);
		render_type       = "mp4";
		render_target     = target_path;
	}
	 
	static renderApng = function(temp_path, target_path) {
		var rate = getInputData( 8);
		if(rate == 0) rate = 1;
		
		if(file_exists_empty(target_path)) file_delete(target_path);
		
		temp_path   = string_replace_all(temp_path, "/", "\\");
		temp_path   = string_trim(temp_path, ["*.png"]) + "%05d.png";
		target_path = string_replace_all(target_path, "/", "\\");
		
		var	shell_cmd  = $"-hide_banner -loglevel quiet -framerate {rate} -i \"{temp_path}\" -plays 0 {string_quote(target_path)}";
		
		render_process_id = shell_execute_async(ffmpeg, shell_cmd, self);
		render_type       = "apng";
		render_target     = target_path;
	}
	
	static pathString = function(path, index = 0, _array = false) {
		var suff = getInputData( 2);
		var form = getInputData( 3);
		var strt = getInputData(11);
		
		path = string_replace_all(path, "\\", "/");
		
		var s = _array? [] : "";
		var i = 1;
		var len = string_length(suff);
		var ch, cmd, cmx, par, eli, val, _txt;
		
		while(i <= len) {
			ch = string_char_at(suff, i);
				
			if(ch == "%") {
				i++;
				
				par  = "";
				cmd  = "";
				cmx  = "";
				_txt = "";
				
				eli = 0;
				val = 0;
				
				do {
					var _rawc = string_char_at(suff, i++);
					
						 if(_rawc == "{") eli++;
					else if(_rawc == "}") {
						eli--;
						
						if(eli == 0) {
							cmx = string_trim(cmx, ["{", "}"]);
							cmd = string_letters(cmx);
							break;
						}
					}
					
					if(eli) {
						cmx += _rawc;
					} else {
						if(string_letters(_rawc) == "")
							par += _rawc;
						else {
							cmd = _rawc;
							break;
						}
					}
				} until(i > len);
				
				par = toNumber(par);
				
				switch(cmd) {
					case "f" :
					case "i" :
						
						switch(cmd) {
							case "f": val = CURRENT_FRAME + 1 + strt; break;
							case "i": val = index; break;
						}
						
						if(cmx != "") {
							cmx = string_replace_all(cmx, "f", string(CURRENT_FRAME + 1 + strt));
							cmx = string_replace_all(cmx, "i", string(index));
							
							val = evaluateFunction(cmx);
						}
						
						val = string(val);
						
						if(par) {
							var str_val = max(par - string_length(val), 0);
							repeat(str_val) _txt += "0";
						}
						
						_txt += val;
						if(_array)	array_push(s, [ cmd, _txt ]);
						else		s += _txt;
						break;
						
					case "d" : 
						var dir  = filename_dir(path) + "/";
						
						if(par) {
							var dir_s = "";
							var sep   = string_splice(dir, "/");
							
							for(var j = 0; j < array_length(sep) - par; j++)
								dir_s += sep[j] + "/";
							_txt += dir_s;
						} else 
							_txt += dir;
						
						if(_array)	array_push(s, [ "d", _txt ]);
						else		s += _txt;
						break;
						
					case "n" : 
						_txt = filename_name_only(path);
						
						if(_array)	array_push(s, [ "n", _txt ]);
						else		s += _txt;
						break;
				}
			} else {
				if(_array)	array_push(s, ch);
				else		s += ch;
				i++;
			}
		}
		
		var _e   = getInputData(9);
		var _ext = array_safe_get_fast(inputs[9].display_data.data, _e, ".png");
		
		if(_array)	array_push(s, ["ext", _ext]);
		else		s += _ext;
		
		return s;
	}
	
	static save_surface = function(_surf, _path) {
		var form = getInputData(3);
		// print($">>>>>>>>>>>>>>>>>>>> save surface {_surf} - {_path} <<<<<<<<<<<<<<<<<<<<");
		
		if(form == NODE_EXPORT_FORMAT.animation) {
			surface_save_safe(_surf, _path);
			return _path;
		}
		
		var extd = getInputData( 9);
		var qual = getInputData(10);
		var indx = getInputData(13);
		var ext  = array_safe_get_fast(format_image, extd, ".png");
		
		var _pathOut  = _path;
		var _pathTemp = $"{directory}/{irandom_range(10000, 99999)}.png";
		
		switch(ext) {
			case ".png": 
				switch(indx) {
					case 0 : 	
						surface_save_safe(_surf, _pathTemp);
					
						var shell_cmd = $"convert {string_quote(_pathTemp)} {string_quote(_pathOut)}";
						shell_execute_async(magick, shell_cmd, self);
						break;
					case 1 : 
						surface_save_safe(_surf, _pathTemp);
					
						var shell_cmd = $"convert {string_quote(_pathTemp)} PNG8:{string_quote(_pathOut)}";
						shell_execute_async(magick, shell_cmd, self);
						break;
					case 2 : 
						surface_save_safe(_surf, _pathOut);
						break;
				}
				break;
				
			case ".jpg": 
				surface_save_safe(_surf, _pathTemp);
					
				_pathOut = $"\"{string_replace_all(_path, ".png", "")}.jpg\"";
				var shell_cmd = $"{string_quote(_pathTemp)} -quality {qual} {string_quote(_pathOut)}";
				
				shell_execute_async(magick, shell_cmd, self);
				break;
				
			case ".webp":
				surface_save_safe(_surf, _pathTemp);
				
				_pathOut = $"\"{string_replace_all(_path, ".png", "")}.webp\"";
				var shell_cmd = $"{string_quote(_pathTemp)} -quality {qual} -define webp:lossless=true {string_quote(_pathOut)}";
				
				shell_execute_async(magick, shell_cmd, self);
				break;
		}
		
		return _pathOut;
	}
	
	static export = function(log = true) {
		// print($">>>>>>>>>>>>>>>>>>>> export {CURRENT_FRAME} <<<<<<<<<<<<<<<<<<<<");
		
		exportLog = log;
		
		var surf = getInputData( 0);
		var path = getInputData( 1);
		var suff = getInputData( 2);
		var form = getInputData( 3);
		var rang = getInputData(12);
		var stps = getInputData(14);
		var user = getInputData(15);
		
		if(form >= 1 && user) {
			var rng_s  = rang[0];
			var rng_e  = rang[1];
			var rng_st = stps >= 1? (CURRENT_FRAME - rng_s) % stps : 0;
			
			if(CURRENT_FRAME < rng_s - 1) return;
			if(CURRENT_FRAME > rng_e - 1) return;
			if(rng_st != 0) return;
		}
		
		if(is_array(surf)) {
			var p = "";
			for(var i = 0; i < array_length(surf); i++) {
				var _surf = surf[i];
				if(!is_surface(_surf)) continue;
				
				if(form == NODE_EXPORT_FORMAT.animation) {
					p = $"{directory}/{i}/{string_lead_zero(CURRENT_FRAME, 5)}.png";
				} else {
					if(is_array(path) && array_length(path) == array_length(surf))
						p = pathString(array_safe_get_fast(path, i), i);
					else
						p = pathString(path, i);
					CLI_EXPORT_AMOUNT++;
				}
					
				p = save_surface(_surf, p);
			}
			
			if(exportLog && form != NODE_EXPORT_FORMAT.animation && !IS_CMD) {
				var _txt = $"Export {array_length(surf)} images complete.";
				logNode(_txt);
				
				var noti  = log_message("EXPORT", _txt, THEME.noti_icon_tick, COLORS._main_value_positive, false);
				noti.path = filename_dir(p);
				noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
				
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
			
		} else if(is_surface(surf)) {
			var p = path;
			if(is_array(path)) p = path[0];
				
			if(form == NODE_EXPORT_FORMAT.animation) {
				p = $"{directory}/{string_lead_zero(CURRENT_FRAME, 5)}.png";
			} else {
				p = pathString(p);
				CLI_EXPORT_AMOUNT++;
			}
			
			p = save_surface(surf, p);
			
			if(exportLog && form != NODE_EXPORT_FORMAT.animation && !IS_CMD) {
				var _txt = $"Export image as {p}";
				logNode(_txt);
				
				var noti  = log_message("EXPORT", _txt, THEME.noti_icon_tick, COLORS._main_value_positive, false);
				noti.path = filename_dir(p);
				noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
					
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
		}
		
		// print($">>>>>>>>>>>>>>>>>>>> export {CURRENT_FRAME} complete <<<<<<<<<<<<<<<<<<<<");
	}
	
	static renderCompleted = function() {
		var surf = getInputData( 0);
		var path = getInputData( 1);
		var suff = getInputData( 2);
		var extd = getInputData( 9);
		var temp_path, target_path;
		
		update_on_frame = false;
		
		if(is_array(surf)) {
			for(var i = 0; i < array_length(surf); i++) {
				temp_path = $"{directory}/{i}/*.png";
				if(is_array(path)) target_path = pathString(array_safe_get_fast(path, i), i);
				else               target_path = pathString(path, i);
				
				switch(format_animation[extd]) {
					case ".gif" :
						target_path = string_replace(target_path, ".png", ".gif");
						renderGif(temp_path, target_path);
						break;
					case ".webp" :
						target_path = string_replace(target_path, ".png", ".webp");
						renderWebp(temp_path, target_path);
						break;
					case ".mp4" :
						target_path = string_replace(target_path, ".png", ".mp4");
						renderMp4(temp_path, target_path);
						break;
					case ".apng" :
						target_path = string_replace(target_path, ".png", ".apng");
						renderApng(temp_path, target_path);
						break;
				}
			}
		} else {
			target_path = pathString(path);
			
			switch(format_animation[extd]) {
				case ".gif" :	
					target_path = string_replace(target_path, ".png", ".gif");
					renderGif(directory + "/*.png", target_path);
					break;
				case ".webp" : 
					target_path = string_replace(target_path, ".png", ".webp");
					renderWebp(directory + "/", target_path);
					break;
				case ".mp4" : 
					target_path = string_replace(target_path, ".png", ".mp4");
					renderMp4(directory + "/", target_path);
					break;
				case ".apng" : 
					target_path = string_replace(target_path, ".png", ".apng");
					renderApng(directory + "/", target_path);
					break;
			}
		}
		
		updatedOutTrigger.setValue(true);
		CLI_EXPORT_AMOUNT++;
	}
	
	insp1UpdateTooltip   = "Export";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	insp2UpdateTooltip = "Export All";
	insp2UpdateIcon    = [ THEME.play_all, 0, COLORS._main_value_positive ];
	
	static onInspector1Update = function(_fromValue = false) {
		if(IS_RENDERING) return;
		
		if(_fromValue) {
			export();
			return;
		}
		
		if(isInLoop())	RENDER_ALL
		else			doInspectorAction();
	}
	
	static onInspector2Update = function(_fromValue = false) {
		if(IS_RENDERING) return;
		exportAll(); 
	}
	
	static doInspectorAction = function() {
		if(!IS_CMD && (LOADING || APPENDING)) return;
		
		var path = getInputData(1);
		if(path == "") return;
		var form = getInputData(3);
		
		if(form == NODE_EXPORT_FORMAT.single) {
			Render();
			export();
			updatedOutTrigger.setValue(true);
			return;
		}
		
		update_on_frame = true;
		playing			= true;
		played			= 0;
		
		PROJECT.animator.render();
		
		if(IS_CMD) array_push(PROGRAM_ARGUMENTS._exporting, node_id);
		
		if(directory_exists(directory))
			directory_destroy(directory);
		directory_create(directory);
	}
	
	static step = function() {
		insp1UpdateActive  = !IS_RENDERING;
		insp2UpdateActive  = !IS_RENDERING;
		
		var surf = getInputData( 0);
		var pngf = getInputData(13);
		var expo = getInputData(16);
		
		if(is_array(surf)) {
			inputs[3].display_data.data	 = format_array;
			inputs[3].editWidget.data_list = format_array;
		} else {
			inputs[3].display_data.data    = format_single;
			inputs[3].editWidget.data_list = format_single;
		}
		
		outputs[0].setValue(surf);
		
		var anim = getInputData(3); // single, sequence, animation
		var extn = getInputData(9);
		var user = getInputData(15);
		
		if(expo && anim == NODE_EXPORT_FORMAT.single && IS_SAVING)
			doInspectorAction();
		
		inputs[11].setVisible(anim == 1);
		inputs[16].setVisible(anim == 0);
		
		inputs[12].editWidget.minn = FIRST_FRAME + 1;
		inputs[12].editWidget.maxx = LAST_FRAME + 1;
		if(!user) inputs[12].setValueDirect([ FIRST_FRAME + 1, LAST_FRAME + 1], noone, false, 0, false);
		
		inputs[14].setVisible(anim >  0);
		
		if(anim == NODE_EXPORT_FORMAT.animation) {
			var _fmt = array_safe_get_fast(format_animation, extn);
			
			inputs[ 5].setVisible(_fmt == ".gif");
			inputs[ 6].setVisible(_fmt == ".gif");
			inputs[ 7].setVisible(_fmt == ".gif");
			inputs[ 8].setVisible(true);
		
			inputs[ 9].display_data.data	  = format_animation;
			inputs[ 9].editWidget.data_list = format_animation;
			
			inputs[13].setVisible(false);
			
			if(_fmt == ".mp4") {
				inputs[10].setName("CRF value");
				inputs[10].tooltip = "Quality of the output, with 0 being the highest (and largest file size), and 51 being the lowest.";
				
				inputs[10].setVisible(true);
				inputs[10].editWidget.minn =  0;
				inputs[10].editWidget.maxx = 51;
			} else 
				inputs[10].setVisible(false);
		} else {
			var _fmt = array_safe_get_fast(format_image, extn);
			
			inputs[ 5].setVisible(false);
			inputs[ 6].setVisible(false);
			inputs[ 7].setVisible(false);
			inputs[ 8].setVisible(false);
		
			inputs[ 9].display_data.data	  = format_image;
			inputs[ 9].editWidget.data_list = format_image;
			
			inputs[13].setVisible(_fmt == ".png");
			
			if(_fmt == ".jpg" || _fmt == ".webp") {
				inputs[10].setName("Quality");
				inputs[10].tooltip = "Quality of the output.";
				
				inputs[10].setVisible(true);
				inputs[10].editWidget.minn =   0;
				inputs[10].editWidget.maxx = 100;
			} else 
				inputs[10].setVisible(false);
		}
		
		if(render_process_id != 0) {
			var res = ProcIdExists(render_process_id);
			
			if(res == 0 || OS == os_macosx) {
				if(!IS_CMD) {
					var noti  = log_message("EXPORT", $"Export {render_type} as {render_target}", THEME.noti_icon_tick, COLORS._main_value_positive, false);
					noti.path = filename_dir(render_target);
					noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
					PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
				}
				
				render_process_id = 0;
				
				if(IS_CMD) array_remove(PROGRAM_ARGUMENTS._exporting, node_id);
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var anim = getInputData(3);
		
		if(anim == NODE_EXPORT_FORMAT.single) {
			if(isInLoop()) export(false);
			return;
		}
		
		if(!PROJECT.animator.is_playing) {
			playing = false;
			return;
		}
		
		if(!playing) return;
		
		export();
		
		if(IS_LAST_FRAME && anim == NODE_EXPORT_FORMAT.animation)
			renderCompleted();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		graph_preview_alpha = 1;
		if(render_process_id != 0) {
			graph_preview_alpha = 0.5;
			draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
		}
	}
	
	static doApplyDeserialize = function() { onValueUpdate(3); }
}