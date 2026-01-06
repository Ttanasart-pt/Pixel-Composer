function Node_create_Export(_x, _y, _group = noone) {
	var node = new Node_Export(_x, _y, _group);
	    node.skipDefault();
	
	var path = "";
	if(NODE_NEW_MANUAL) {
		var _ext = @"Portable Network Graphics (.png)|*.png|
Joint Photographic Experts Group (.jpg)|*.jpg|
Graphics Interchange Format (.gif)|*.gif|
Animated WebP (.webp)|*.webp|
MPEG-4 (.mp4)|*.mp4";
		
		var _dir = PROJECT.attributes.export_dir;
		if(_dir == "") _dir = PREFERENCES.dialog_path;
		
		path = get_save_filename_compat(_ext, "export", "Export to", _dir);
		key_release();
		
		var _dirr = filename_dir(path) + "/";
		var _namm = filename_name_only(path);
		var _extt = filename_ext(path);
		
		node.inputs[ 1].setValue(_dirr);
		node.inputs[20].setValue(_namm);
		node.extensionCheck(_extt);
	}
	
	return node;
}
	
function exportAll() {
	if(IS_RENDERING) return;
	
	for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
		var node = PROJECT.allNodes[i];
		if(!is(node, Node_Export) || !node.active) continue;
		
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
	
	format_single    = [ "Single image",    "Image sequence",  "Animation"  ];
	format_array     = [ "Multiple images", "Image sequences", "Animations" ];
	
	format_image     = [ ".png", ".jpg",  ".webp", ".exr", ".bmp", ".ico", ".txt" ];
	format_animation = [ ".gif", ".apng", ".webp", ".mp4" ];
	
	png_format       = [ "INDEX4", "INDEX8", "Default (PNG32)" ];
	
	////- =Export
	newInput( 0, nodeValue_Surface( "Surface"   ));
	newInput( 1, nodeValue_Path(    "Directory" )).setDisplay(VALUE_DISPLAY.path_save, { 
		type        : "area", 
		filter      : "dir", 
		default_dir : function() /*=>*/ {return PROJECT.attributes.export_dir} 
	}).setVisible(true).widgetBreakLine();
	
	newInput(20, nodeValue_Text(    "File name" ));
	newInput( 4, nodeValue_Int(     "Template guides", 0      ));
	newInput( 2, nodeValue_Text(    "Template",        "%d%n" )).rejectArray();
	inputs[2].getEditWidget().format		 = TEXT_AREA_FORMAT.path_template;
	inputs[2].getEditWidget().auto_update = true;
	
	newInput(16, nodeValue_Bool(    "Export on Save",   false)).setTooltip("Automatically export when saving project.");
	newInput(22, nodeValue_Bool(    "Export on Update", false));
	
	////- =Format
	newInput( 3, nodeValue_Enum_Scroll( "Type",   0, { data: format_single, update_hover: false } )).rejectArray();
	newInput( 9, nodeValue_Enum_Scroll( "Format", 0, { data: format_image,  update_hover: false } )).rejectArray();
	newInput(17, nodeValue_Bool(        "Use Built-in gif encoder", false      ))
	newInput(18, nodeValue_Int(         "Quality",                  2, [0,3,1] )).rejectArray();
	newInput( 6, nodeValue_Bool(        "Frame optimization",       false      )).setVisible(false).rejectArray();
	newInput( 7, nodeValue_Slider(      "Color merge",             .02         )).setVisible(false).rejectArray();
	newInput(10, nodeValue_Slider(      "Quality",                  23, [ 0, 100, 0.1 ] )).rejectArray();
	newInput(13, nodeValue_Enum_Scroll( "Subformat",                 2, { data: png_format, update_hover: false }));
	
	////- =Post-Process
	newInput(19, nodeValue_Float( "Scale", 1 ));
	
	////- =Custom Range
	newInput(15, nodeValue_Bool(         "Custom Range", false )).rejectArray();
	newInput(12, nodeValue_Slider_Range( "Frame range", [0,-1], { range: [0, TOTAL_FRAMES, 0.1] }));
	
	////- =Animation
	newInput( 8, nodeValue_Int(  "Framerate",        30 )).rejectArray();
	newInput( 5, nodeValue_Bool( "Loop",           true )).setVisible(false).rejectArray();
	newInput(11, nodeValue_Int(  "Sequence begin",    0 ));
	newInput(14, nodeValue_Int(  "Frame step",        1 ));
	newInput(21, nodeValue_Int(  "Batch gif",         0 )).setTooltip("Batch animations to reduce memory footprint. Set to zero to export all at once.");
	
	// inputs 23
	
	newOutput(0, nodeValue_Output("Preview", VALUE_TYPE.surface, noone));
	
	template_guide = [
		["%d",     "Directory"],
		["%1d",    "Goes up 1 level"],
		["%n",     "File name"],
		["%f",     "Frame"],
		["%i",     "Array index"],
		["%{i+1}", "Array index + 1"],
		["%s",     "Scale Factor"],
	];
	
	export_template = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		
		var _tx = _x + ui(10);
		var _ty = _y;
		var _tw = _w - ui(8);
		
		var rawpath = getInputData( 1);
		var rawname = getInputData(20);
		var _ext    = getInputData( 9);
		
		var _pathDir = array_safe_get_fast(rawpath, 0, rawpath);
		var _pathNam = array_safe_get_fast(rawname, 0, rawname);
				
		var path    = pathString(_pathDir, _pathNam, 0, false);
		var pathA   = pathString(_pathDir, _pathNam, 0,  true);
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
					case "s" :   draw_set_color(COLORS.widget_text_dec_i); break;
					case "ext" : draw_set_color(COLORS._main_text_sub);    break;
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
			
				draw_text_add(lx, ly, ch);
			
				lw += ww;
				lx += ww;
			}
		}
		draw_set_alpha(1);
		
		var hh  = _th + ui(16 + 20 * array_length(template_guide));
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
		["Export",		 false    ],  0,  1, 20,  2, export_template, 16, 22, 
		["Format",		 false    ],  3,  9, 17, 18,  6,  7, 10, 13, 
		["Post-Process", false    ], 19,
		["Custom Range",  true, 15], 12, 
		["Animation",	 false    ],  8,  5, 11, 14, 21, 
	];
	
	attributes.clear_directory = true;
	array_push(attributeEditors, Node_Attribute("Delete temp Folder", function() /*=>*/ {return attributes.clear_directory}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("clear_directory")})}));
	
	////- Paths
	
	render_process_id    = 0;
	render_process_batch = [];
	render_process_batch_merge = "";
	
	current_format    = "";
	render_type       = "";
	render_target     = "";
	exportLog         = true;
	
	use_gif_encoder   = false;
	gif_encoder       = [];
	gif_frames        = 0;
	
	directory = "";
	converter = filepath_resolve(PREFERENCES.ImageMagick_path) + "convert.exe";
	magick    = filepath_resolve(PREFERENCES.ImageMagick_path) + "magick.exe";
	webp      = filepath_resolve(PREFERENCES.webp_path)		   + "webpmux.exe";
	gifski    = filepath_resolve(PREFERENCES.gifski_path) 	   + "win/gifski.exe";
	ffmpeg    = filepath_resolve(PREFERENCES.ffmpeg_path) 	   + "bin/ffmpeg.exe";
	
	temp_surface = [ noone ]; 
	
	if(OS == os_windows) {
		var _w = function(s,p) /*=>*/ {return $"No {s} detected at {p}, please make sure the installation is complete and {s} path is set correctly in the preference."};
		
		if(!file_exists_empty(converter)) noti_warning(_w("ImageMagick", magick), noone, self);
		if(!file_exists_empty(magick))    noti_warning(_w("ImageMagick", magick), noone, self);
		if(!file_exists_empty(webp))      noti_warning(_w("webp",        webp),   noone, self);
		if(!file_exists_empty(gifski))    noti_warning(_w("gifski",      gifski), noone, self);
		if(!file_exists_empty(ffmpeg))    noti_warning(_w("FFmpeg",      ffmpeg), noone, self);
		
	} else if(OS == os_macosx) {
		var _w = function(str) /*=>*/ {return $"No {str} installed, please install {str} with homebrew or use the provided 'mac-libraries-installer.command'."};
		
		if(string_pos(shell_execute_output("convert", ""), "not found")) noti_warning(_w("ImageMagick"), noone, self);
		if(string_pos(shell_execute_output("webp", ""),    "not found")) noti_warning(_w("webp"),        noone, self);
		if(string_pos(shell_execute_output("ffmpeg", ""),  "not found")) noti_warning(_w("FFmpeg"),      noone, self);
		
		converter = "/opt/homebrew/bin/convert";
		magick    = "/opt/homebrew/bin/magick";
		webp      = "/opt/homebrew/bin/webp";
		ffmpeg    = "/opt/homebrew/bin/ffmpeg";
	}
	
	static onValueUpdate = function(_index) {
		if(!(NOT_LOAD)) return;
		
		var form = getInputData(3);
		
		if(_index == 3)
			inputs[9].setValue(0);
		
		if(_index == 3 && form == 1)
			inputs[2].setValue("%d%n%3f%i");
		
		if(_index == 1) {
			var _path = getInputData(1);
			extensionCheck(filename_ext(_path));
		}
	}
	
	static extensionCheck = function(_extt) {
		var _ext  = string_lower(_extt);
		
		var indexImg = array_get_index(format_image,     _ext);
		if(indexImg > -1) {
			inputs[3].setValue(0);
			inputs[9].setValue(indexImg);
			return;
		}
		
		var indexAni = array_get_index(format_animation, _ext);
		if(indexAni > -1) {
			inputs[3].setValue(0);
			inputs[9].setValue(indexAni);
			return;
		}
		
	}
	
	static pathString = function(dirr, fnam = "", index = 0, _array = false) {
		var suff = getInputData( 2);
		var form = getInputData( 3);
		var strt = getInputData(11);
		
		dirr = string_replace_all(dirr, "\\", "/");
		if(dirr != "" && !string_ends_with(dirr, "/")) dirr += "/";
		
		if(fnam != "") fnam = filename_name_only(fnam);
		
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
					case "s" :
						
						switch(cmd) {
							case "f": val = CURRENT_FRAME + 1 + strt; break;
							case "i": val = index;                    break;
							case "s": val = getInputData(19);         break;
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
						var dir  = filename_dir(dirr) + "/";
						
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
						_txt = fnam;
						
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
	
	////- Renderers
	
	static getSurface = function() { return inputs[0].value_from == noone? PROJECT.getOutputSurface() : getInputData(0); }
	
	static renderWebp = function(temp_path, target_path) {
		var _path  = file_find_first(temp_path + "*.png", 0);
		var frames = [];
		
		while(_path != "") {
			var _frame    = string_quote(temp_path + string_replace_all(_path, ".png", "") + ".webp");
			var _pathTemp = string_quote(temp_path + _path);
			var shell_cmd = $"{_pathTemp} -define webp:lossless=true {_frame}";
			
			array_push(frames, _frame);
			shell_execute(magick, shell_cmd, self, false);
			
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
		var bsiz = getInputData(21);
		
		temp_path   = string_replace_all(temp_path, "/", "\\");
		target_path = string_replace_all(target_path, "/", "\\");
		
		var framerate  = 100 / rate;
		var loop_str   = loop? 0 : 1;
		var use_gifski = false;
		
		if(bsiz) {
			for(var i = 0; i < gif_frames; i += bsiz) {
				var temp_batch_path = string_replace(temp_path, "*.png", $"{i/bsiz}-*.png");
				var targ_batch_path = string_replace(temp_path, "*.png", $"{i/bsiz}.gif");
				
				var		 shell_cmd  = $"-delay {framerate} -alpha set -dispose 2 -loop {loop_str}";
				if(opti) shell_cmd += $" -fuzz {fuzz * 100}% -layers OptimizeFrame -layers OptimizeTransparency";
						 shell_cmd += $" {string_quote(temp_batch_path)} {string_quote(targ_batch_path)}";
				var _id = shell_execute_async(converter, shell_cmd, self);
				array_push(render_process_batch, _id);
			}
			
			var batch_gif_path = string_replace(temp_path, "*.png", $"*.gif");
			render_process_batch_merge = $"{string_quote(batch_gif_path)} {string_quote(target_path)}";
			
		} else {
			var		 shell_cmd  = $"-delay {framerate} -alpha set -dispose 2 -loop {loop_str}";
			if(opti) shell_cmd += $" -fuzz {fuzz * 100}% -layers OptimizeFrame -layers OptimizeTransparency";
					 shell_cmd += $" {string_quote(temp_path)} {string_quote(target_path)}";
			
			render_process_id = shell_execute_async(converter, shell_cmd, self);
		}
		
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
	
	static save_surface = function(_surf, _path) {
		var form = getInputData( 3);
		var scal = getInputData(19);
		
		if(scal != 1) {
			temp_surface[0] = surface_verify(temp_surface[0], surface_get_width_safe(_surf) * scal, surface_get_height_safe(_surf) * scal, surface_get_format_safe(_surf));
			surface_set_shader(temp_surface[0], noone);
				draw_surface_ext(_surf, 0, 0, scal, scal, 0, c_white, 1);
			surface_reset_shader();
			
			_surf = temp_surface[0];
		}
		
		if(form == NODE_EXPORT_FORMAT.animation) { surface_save_safe(_surf, _path); return _path; }
		
		var extd = getInputData( 9);
		var qual = getInputData(10);
		var indx = getInputData(13);
		var ext  = array_safe_get_fast(format_image, extd, ".png");
		
		var _pathOut  = filename_change_ext(_path, ext);
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
						
					case 2 : surface_save_safe(_surf, _pathOut); break;
				}
				break;
				
			case ".webp":
				surface_save_safe(_surf, _pathTemp);
				var shell_cmd = $"{string_quote(_pathTemp)} -quality {qual} -define webp:lossless=true {string_quote(_pathOut)}";
				shell_execute_async(magick, shell_cmd, self);
				break;
				
			case ".exr": surface_exr_encode(_surf, _pathOut); break;
			case ".bmp": surface_bmp_encode(_surf, _pathOut); break;
			
			default: 
				surface_save_safe(_surf, _pathTemp);
				var shell_cmd = $"{string_quote(_pathTemp)} -quality {qual} {string_quote(_pathOut)}";
				shell_execute_async(magick, shell_cmd, self);
				break;
		}
		
		return _pathOut;
	}
	
	static export = function(log = true) {
		// print($">>>>>>>>>>>>>>>>>>>> export {CURRENT_FRAME} <<<<<<<<<<<<<<<<<<<<");
		// printCallStack();
		
		randomize();
		exportLog = log;
		
		var surf = getSurface();
		var path = getInputData( 1);
		var fnam = getInputData(20);
		
		var form = getInputData( 3);
		var rang = getInputData(12);
		var stps = getInputData(14);
		var user = getInputData(15);
		var scal = getInputData(19);
		
		if(!user) rang = [ FIRST_FRAME + 1, LAST_FRAME + 1];
		
		if(form >= 1) {
			var rng_s  = rang[0] - 1;
			var rng_e  = rang[1] - 1;
			
			if(user && CURRENT_FRAME < rng_s) return;
			if(user && CURRENT_FRAME > rng_e) return;
			
			var rng_st = safe_mod(CURRENT_FRAME - rng_s, stps);
			if(rng_st != 0) return;
		}
		
		if(use_gif_encoder) {
			var rate = getInputData( 8);
			var quan = getInputData(18);
			
			if(!is_array(surf)) surf = [ surf ];
			for( var i = 0, n = array_length(surf); i < n; i++ ) {
				var _s = surf[i];
				
				if(scal != 1) {
					temp_surface[0] = surface_verify(temp_surface[0], surface_get_width_safe(_s) * scal, surface_get_height_safe(_s) * scal, surface_get_format_safe(_s));
					surface_set_shader(temp_surface[0], noone);
						draw_surface_ext(_s, 0, 0, scal, scal, 0, c_white, 1);
					surface_reset_shader();
					
					_s = temp_surface[0];
				}
				
				gif_add_surface(gif_encoder[i], _s, 100 / rate, 0, 0, quan);
			}
			
			return;
		}
		
		if(is_array(surf)) {
			var p = "";
			for(var i = 0; i < array_length(surf); i++) {
				var _surf = surf[i];
				if(!is_surface(_surf)) continue;
				
				if(form == NODE_EXPORT_FORMAT.animation) {
					p = $"{directory}/{i}/{string_lead_zero(CURRENT_FRAME, 5)}.png";
					
				} else {
					var _pathDir = array_safe_get_fast(path, i, path);
					var _pathNam = array_safe_get_fast(fnam, i, fnam);
					
					p = pathString(_pathDir, _pathNam, i);
					CLI_EXPORT_AMOUNT++;
				}
					
				p = save_surface(_surf, p);
			}
			
			if(exportLog && form != NODE_EXPORT_FORMAT.animation && !IS_CMD) {
				var _txt = $"Export {array_length(surf)} images complete.";
				logNode(_txt);
				
				var path = filename_dir(p);
				var noti = log_message("EXPORT", _txt, THEME.noti_icon_tick, COLORS._main_value_positive, false)
								.setOnClick(function(p) /*=>*/ {return shellOpenExplorer(p)}, "Open in explorer", THEME.explorer, path);
				
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
			
		} else if(is_surface(surf)) {
			var _pathDir = array_safe_get_fast(path, 0, path);
			var _pathNam = array_safe_get_fast(fnam, 0, fnam);
			var bsiz     = getInputData(21);
			var p;
				
			if(form == NODE_EXPORT_FORMAT.animation) {
				var _name = string_lead_zero(gif_frames, 5);
				if(bsiz) _name = $"{floor(gif_frames/bsiz)}-{string_lead_zero(gif_frames, 5)}";
				gif_frames++;
				
				p = $"{directory}/{_name}.png";
				
			} else {
				p = pathString(_pathDir, _pathNam);
				CLI_EXPORT_AMOUNT++;
			}
			
			p = save_surface(surf, p);
			
			if(exportLog && form != NODE_EXPORT_FORMAT.animation && !IS_CMD) {
				var _txt = $"Export image as {p}";
				logNode(_txt);
				
				var path = filename_dir(p);
				var noti = log_message("EXPORT", _txt, THEME.noti_icon_tick, COLORS._main_value_positive, false)
								.setOnClick(function(p) /*=>*/ {return shellOpenExplorer(p)}, "Open in explorer", THEME.explorer, path);
					
				PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
			}
		}
		
		// print($">>>>>>>>>>>>>>>>>>>> export {CURRENT_FRAME} complete <<<<<<<<<<<<<<<<<<<<");
	}
	
	static renderStarted = function() {
		var scal        = getInputData(19);
		gif_frames      = 0;
		use_gif_encoder = false;
		
		if(current_format == ".gif") {
			var _build_in_gif = getInputData(17);
			if(!_build_in_gif) return;
			
			use_gif_encoder = true;
			var surf = getSurface();
			if(!is_array(surf)) surf = [ surf ];
			
			for( var i = 0, n = array_length(surf); i < n; i++ ) {
				var _s = surf[i];
				var _d = surface_get_dimension(_s);
				
				gif_encoder[i] = gif_open(_d[0] * scal, _d[1] * scal, 0);
			}
		}
		
	}
	
	static renderCompleted = function() {
		var surf = getSurface();
		var path = getInputData( 1);
		var fnam = getInputData(20);
		var extd = getInputData( 9);
		var temp_path, target_path;
		
		update_on_frame = false;
		
		if(is_array(surf)) {
			for(var i = 0; i < array_length(surf); i++) {
				temp_path = $"{directory}/{i}/*.png";
				
				var _pathDir = array_safe_get_fast(path, i, path);
				var _pathNam = array_safe_get_fast(fnam, i, fnam);
				target_path  = pathString(_pathDir, _pathNam, i);
				
				target_path = string_replace(target_path, ".png", format_animation[extd]);
				
				switch(format_animation[extd]) {
					case ".gif" :
						if(use_gif_encoder) gif_save(gif_encoder[i], target_path);
						else                renderGif(temp_path, target_path);
						break;
						
					case ".webp" : renderWebp(temp_path, target_path); break;
					case ".mp4"  : renderMp4( temp_path, target_path); break;
					case ".apng" : renderApng(temp_path, target_path); break;
				}
			}
		} else {
			var _pathDir = array_safe_get_fast(path, 0, path);
			var _pathNam = array_safe_get_fast(fnam, 0, fnam);
				
			target_path = pathString(_pathDir, _pathNam);
			target_path = string_replace(target_path, ".png", format_animation[extd]);
			
			switch(format_animation[extd]) {
				case ".gif"  : 
					if(use_gif_encoder) gif_save(gif_encoder[0], target_path);
					else                renderGif(directory + "/*.png", target_path); 
				break;
				
				case ".webp" : renderWebp(directory + "/",      target_path); break;
				case ".mp4"  : renderMp4( directory + "/",      target_path); break;
				case ".apng" : renderApng(directory + "/",      target_path); break;
			}
		}
		
		updatedOutTrigger.setValue(true);
		CLI_EXPORT_AMOUNT++;
	}
	
	////- Nodes
	
	insp1button = button(function(fr) /*=>*/ {
		if(IS_RENDERING) return;
		if(fr) { export(); return; }
		doInspectorAction();
		
	}).setTooltip(__txt("Export"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	insp2button = button(function() /*=>*/ { if(IS_RENDERING) return; exportAll(); }).setTooltip(__txt("Export All"))
		.setIcon(THEME.play_all, 0, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static doInspectorAction = function() {
		if(!IS_CMD && (LOADING || APPENDING)) return;
		directory = $"{TEMPDIR}{irandom_range(100000, 999999)}";
		
		var path = getInputData(1);
		if(path == "") { noti_warning("Export: Path is empty"); return; }
		
		var form = getInputData(3);
		var extd = getInputData(9);
		
		switch(form) {
			case NODE_EXPORT_FORMAT.single    : current_format = format_image[extd];     break;
			case NODE_EXPORT_FORMAT.sequence  : current_format = format_image[extd];     break;
			case NODE_EXPORT_FORMAT.animation : current_format = format_animation[extd]; break;
		}
		
		if(form == NODE_EXPORT_FORMAT.single) {
			RenderSync(project);
			export();
			updatedOutTrigger.setValue(true);
			return;
		}
		
		update_on_frame = true;
		playing			= true;
		played			= 0;
		
		directory_clear(directory);
		renderStarted();
		PROJECT.animator.render();
		
		if(IS_CMD) array_push(PROGRAM_ARGUMENTS._exporting, node_id);
	}
	
	static step = function() {
		insp1button.visible = !IS_RENDERING;
		insp2button.visible = !IS_RENDERING;
		
		var expo = getInputData(16);
		var anim = getInputData( 3); // single, sequence, animation
		
		if(expo && anim == NODE_EXPORT_FORMAT.single && IS_SAVING)
			doInspectorAction();
		
		if(render_process_id != 0) {
			var res = ProcIdExists(render_process_id);
			PANEL_GRAPH.refreshDraw();
			
			if(res == 0 || OS == os_macosx) {
				var msg = ExecutedProcessReadFromStandardOutput(render_process_id);
				
				if(!IS_CMD) {
					if(msg == "") {
						var noti = log_message("EXPORT", $"Export {render_type} as {render_target}", THEME.noti_icon_tick, COLORS._main_value_positive, false);
						var path = filename_dir(render_target);
						noti.setOnClick(function(p) /*=>*/ { shellOpenExplorer(p); }, "Open in explorer", THEME.explorer, path);
						PANEL_MENU.setNotiIcon(THEME.noti_icon_tick);
						
					} else {
						var noti  = log_message("EXPORT", $"Export error: {msg}", THEME.cross_16, COLORS._main_value_negative, false);
						PANEL_MENU.setNotiIcon(THEME.cross_16);
					}
				}
				
				render_process_id = 0;
				if(attributes.clear_directory) directory_destroy(directory);
				if(IS_CMD) array_remove(PROGRAM_ARGUMENTS._exporting, node_id);
			}
		}
		
		if(!array_empty(render_process_batch)) {
			var _completed = true;
			for( var i = 0, n = array_length(render_process_batch); i < n; i++ ) {
				var res = ProcIdExists(render_process_batch[i]);
				if(res) _completed = false;
			}
			
			if(_completed) {
				render_process_id    = shell_execute_async(converter, render_process_batch_merge, self);
				render_process_batch = [];
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		
		var surf = getSurface();
		var anim = getInputData( 3);
		var extn = getInputData( 9);
		var expt = getInputData(22);
		
		#region visiblity
			outputs[0].setValue(surf);
			
			if(is_array(surf)) {
				inputs[3].display_data.data	   = format_array;
				inputs[3].getEditWidget().data_list = format_array;
			} else {
				inputs[3].display_data.data    = format_single;
				inputs[3].getEditWidget().data_list = format_single;
			}
			
			inputs[11].setVisible(anim == 1);
			inputs[16].setVisible(anim == 0);
			
			inputs[12].getEditWidget().minn = FIRST_FRAME + 1;
			inputs[12].getEditWidget().maxx = LAST_FRAME + 1;
			
			inputs[14].setVisible(anim >  0);
			
			if(anim == NODE_EXPORT_FORMAT.animation) {
				var _enc = getInputData(17);
				var _fmt = array_safe_get_fast(format_animation, extn);
				
				inputs[ 5].setVisible(_fmt == ".gif");
				
				inputs[17].setVisible(_fmt == ".gif");
				inputs[ 6].setVisible(_fmt == ".gif" && !_enc);
				inputs[ 7].setVisible(_fmt == ".gif" && !_enc);
				inputs[18].setVisible(_fmt == ".gif" &&  _enc);
				inputs[ 8].setVisible(true);
				inputs[21].setVisible(true);
				
				inputs[ 9].display_data.data	= format_animation;
				inputs[ 9].getEditWidget().data_list = format_animation;
				
				inputs[13].setVisible(false);
				
				if(_fmt == ".mp4") {
					inputs[10].setName("CRF value");
					inputs[10].tooltip = "Quality of the output, with 0 being the highest (and largest file size), and 51 being the lowest.";
					
					inputs[10].setVisible(true);
					inputs[10].getEditWidget().minn =  0;
					inputs[10].getEditWidget().maxx = 51;
				} else 
					inputs[10].setVisible(false);
					
			} else {
				var _fmt = array_safe_get_fast(format_image, extn);
				
				inputs[ 5].setVisible(false);
				inputs[ 6].setVisible(false);
				inputs[ 7].setVisible(false);
				inputs[17].setVisible(false);
				inputs[18].setVisible(false);
				inputs[ 8].setVisible(false);
				inputs[21].setVisible(false);
			
				inputs[ 9].display_data.data	= format_image;
				inputs[ 9].getEditWidget().data_list = format_image;
				
				inputs[13].setVisible(_fmt == ".png");
				
				if(_fmt == ".jpg" || _fmt == ".webp") {
					inputs[10].setName("Quality");
					inputs[10].tooltip = "Quality of the output.";
					
					inputs[10].setVisible(true);
					inputs[10].getEditWidget().minn =   0;
					inputs[10].getEditWidget().maxx = 100;
					
				} else 
					inputs[10].setVisible(false);
			}
		#endregion
		
		if(anim == NODE_EXPORT_FORMAT.single) {
			if(expt && !IS_RENDERING) export(false);
			return;
		}
		
		if(!PROJECT.animator.is_playing) { 
			playing = false; 
			return; 
		}
		
		if(!playing) return;
		
		export();
		
		if(IS_LAST_FRAME && anim == NODE_EXPORT_FORMAT.animation) {
			renderCompleted();
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		graph_preview_alpha = 1;
		
		if(render_process_id != 0 || !array_empty(render_process_batch)) {
			graph_preview_alpha = 0.5;
			var cx = xx + w * _s / 2;
			var cy = yy + h * _s / 2;
			draw_sprite_ui(THEME.loading, 0, cx, cy, _s, _s, current_time / 2, COLORS._main_icon, 1);
		}
	}
	
	////- Serialize
	
	static postApplyDeserialize = function() /*=>*/ {return onValueUpdate(3)};
}