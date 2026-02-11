globalvar THEME_DEF; THEME_DEF        = true;
globalvar USE_TEXTUREGROUP; USE_TEXTUREGROUP = false; 
globalvar SPRITES; 
globalvar THEME; 

function sprite_drawer(_spr) constructor {
	spr = _spr;
	w = sprite_get_width(spr);
	h = sprite_get_height(spr);
	
	static draw      = function(_x, _y, scale, color, alpha) {}
	static drawScale = function(_x, _y, scale, color, alpha) {}
}

function sprite_drawer_white(_spr, _col = c_white) : sprite_drawer(_spr) constructor {
	col = _col;
	
	static draw = function(_x, _y, scale, color, alpha) {
		draw_sprite_ui_uniform(spr, 0, _x, _y, scale, color, alpha);
		draw_sprite_ui_uniform(spr, 1, _x, _y, scale, col,   alpha);
	}
	
	static drawScale = function(_x, _y, scale, color, alpha) {
		__draw_sprite_ext(spr, 0, _x, _y, scale, scale, 0, color, alpha);
		__draw_sprite_ext(spr, 1, _x, _y, scale, scale, 0, col,   alpha);
	}
}

function __initTheme() {
	var root = DIRECTORY + "Themes";
	var t    = get_timer();
	
	directory_verify(root);
	if(check_version($"{root}/version")) {
		zip_unzip($"{working_directory}packs/theme.zip", root);	
		printDebug($"  - Unzip theme  | complete in {(get_timer()-t)/1000}ms");    t = get_timer();
	}
	
	loadColor(PREFERENCES.theme);			printDebug($"  - Load color   | complete in {(get_timer()-t)/1000}ms");    t = get_timer();
	loadGraphic(PREFERENCES.theme);			printDebug($"  - Load graphic | complete in {(get_timer()-t)/1000}ms");    t = get_timer();
}

function _sprite_path(rel, theme) { INLINE return $"{DIRECTORY}Themes/{theme}/graphics/{string_replace_all(rel, "./", "")}"; }

function _sprite_load_from_struct(str, theme, key) {
	var path = _sprite_path(str.path, theme);
	var numb = struct_try_get(str, "s", 1);
	var sx   = struct_try_get(str, "x", 0) * THEME_SCALE;
	var sy   = struct_try_get(str, "y", 0) * THEME_SCALE;
	
	var _path = filename_os(path);
	
	if(!file_exists_empty(_path)) { log_message("THEME", $"Load sprite {_path} failed: Path not exists."); return 0; }
	
	var s = sprite_add(_path, numb, false, true, sx, sy);
	if( s < 0) { log_message("THEME", $"Load sprite {_path} failed: Cannot read file."); return 0; }
	
	if(!struct_has(str, "slice")) return s;
	
	var slice = sprite_nineslice_create();	
	slice.enabled = true;
	
	var _sw = sprite_get_width(s);
	var _sh = sprite_get_height(s);
	
	if(is_array(str.slice)) {
		slice.left    = str.slice[0] > 0? str.slice[0] : _sw / 2 + str.slice[0];
		slice.right   = str.slice[1] > 0? str.slice[1] : _sw / 2 + str.slice[1];
		slice.top     = str.slice[2] > 0? str.slice[2] : _sh / 2 + str.slice[2];
		slice.bottom  = str.slice[3] > 0? str.slice[3] : _sh / 2 + str.slice[3];
		
	} else if(is_real(str.slice)) {
		var _sl = str.slice > 0? str.slice : _sw / 2 + str.slice;
		slice.left    = _sl;
		slice.right   = _sl;
		slice.top     = _sl;
		slice.bottom  = _sl;
		
	}
	
	if(struct_has(str, "slicemode"))
		slice.tilemode = array_create(5, str.slicemode);
	
	sprite_set_nineslice(s, slice);
	
	return s; 
}

function loadGraphic(theme = "default") {
	SPRITES = {};
	THEME   = {};
	
	var path   = _sprite_path("./graphics.json", theme);
	var sprDef = json_load_struct(_sprite_path("./graphics.json", "default"));
	var _metaP = $"{DIRECTORY}Themes/{theme}/meta.json";
	
	if(!file_exists_empty(_metaP))
		noti_warning("Init Theme: meta.json not found");
	else {
		var _meta = json_load_struct(_metaP);
		if(_meta[$ "version"] < VERSION)
			noti_warning($"Init Theme: Loading theme made for older version [{_meta[$ "version"]} < {VERSION}].");
	}
	
	printDebug($"  - Loading theme {theme}");
	if(!file_exists_empty(path)) { print($"  > Theme not defined at {path}, rollback to default theme."); return; }
	
	var packPath = $"{DIRECTORY}Themes/{theme}/packed";
	var packed   = !PREFERENCES.theme_load_unpack && file_exists($"{packPath}/struct.json");
	
	if(TESTING) packed = false;
	USE_TEXTUREGROUP = packed;
	
	if(packed) {
		var  pTex = $"{packPath}/texture.png";
		var  pStr = $"{packPath}/struct.json";
		var _data = json_load_struct(pStr);
		
		texturegroup_add("UI", pTex, _data);
		texturegroup_load("UI");
		
		var graphics = variable_struct_get_names(_data.sprites);
		for( var i = 0, n = array_length(graphics); i < n; i++ ) {
			key = graphics[i];
			
			THEME[$ key]   = asset_get_index(key);
			SPRITES[$ key] = THEME[$ key];
		}
		
	} else {
		var sprStr   = json_load_struct(path);
		var graphics = variable_struct_get_names(sprStr);
		var str, key;
		
		for( var i = 0, n = array_length(graphics); i < n; i++ ) {
			key = graphics[i];
			str = sprStr[$ key];
			
			THEME[$ key]   = _sprite_load_from_struct(str, theme, key);
			SPRITES[$ key] = THEME[$ key];
		}
	}
	
	THEME.dPath_open                = new sprite_drawer_white(THEME.path_open,    CDEF.blue);
	THEME.dPath_open_20             = new sprite_drawer_white(THEME.path_open_20, CDEF.blue);
	
	THEME.dFile_save                = new sprite_drawer_white(THEME.file_save);
	THEME.dFile_load                = new sprite_drawer_white(THEME.file_load);
	
	THEME.dGradient_keys_blend      = new sprite_drawer_white(THEME.gradient_keys_blend);
	THEME.dGradient_keys_distribute = new sprite_drawer_white(THEME.gradient_keys_distribute);
	THEME.dGradient_keys_reverse    = new sprite_drawer_white(THEME.gradient_keys_reverse);
	
	THEME.dFolder_add               = new sprite_drawer_white(THEME.folder_add, COLORS._main_value_positive);
	THEME.dCache_clear              = new sprite_drawer_white(THEME.cache_remove, COLORS._main_value_negative);
	
}

function __test_generate_theme() {
	var _txt = "function Theme() constructor {\n";
	var _spr = struct_get_names(THEME);
	
	for( var i = 0, n = array_length(_spr); i < n; i++ )
		_txt += $"\t{_spr[i]} = noone;\n";
	_txt += "}";
	
	clipboard_set_text(_txt);
}

function __test_update_theme() {
	var _p = "D:/Project/MakhamDev/LTS-PixelComposer/RESOURCE/data/default/meta.json"
	var _d = json_load_struct(_p);
	_d.version = BUILD_NUMBER;
	json_save_struct(_p, _d, true);
	
	var _p = "D:/Project/MakhamDev/LTS-PixelComposer/RESOURCE/data/default HQ/meta.json"
	var _d = json_load_struct(_p);
	_d.version = BUILD_NUMBER;
	json_save_struct(_p, _d, true);
	
	noti_status($"Update theme to version {VERSION_STRING}.", noone, COLORS._main_value_positive);
	return 0;
}

function __generate_texturegroup_dir(_f) {
	var _packedDir = $"{_f}/packed";
	directory_clear(_packedDir);
	
	var _ss = 1024 * THEME_SCALE;
	
	var _sprites = {};
	var _surface = surface_create(_ss, _ss);
	
	var _xx = 0;
	var _yy = 0;
	var _lh = 0;
	
	var _keys = struct_get_names(SPRITES);
	array_sort(_keys, function(a,b) /*=>*/ {return sprite_get_height(SPRITES[$ b]) - sprite_get_height(SPRITES[$ a])});
	
	surface_set_shader(_surface);
	
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var _key = _keys[i];
			var _spr = SPRITES[$ _key];
			
			var _sn = sprite_get_number(_spr);
			var _sw = sprite_get_width(_spr);
			var _sh = sprite_get_height(_spr);
			
			var _ox = sprite_get_xoffset(_spr);
			var _oy = sprite_get_yoffset(_spr);
			
			var _ni = sprite_get_nineslice(_spr);
			
			var _fram = [];
			var _data = {
				width  : _sw,
				height : _sh, 
				
				xoffset: _ox,
				yoffset: _oy,
			};
			
			if(_ni.enabled) {
				_data.nineslice = {
					left   : _ni.left,
					right  : _ni.right,
					top    : _ni.top,
					bottom : _ni.bottom,
					
					tilemode_left   : _ni.tilemode[0], 
					tilemode_right  : _ni.tilemode[1], 
					tilemode_top    : _ni.tilemode[2], 
					tilemode_bottom : _ni.tilemode[3], 
					tilemode_centre : _ni.tilemode[4]
				};
			}
			
			var _ind = 0;
			repeat(_sn) {
				if(_xx + _sw > _ss) {
					_xx  = 0;
					_yy += _lh;
					
					_lh = 0;
				}
				
				draw_sprite(_spr, _ind, _xx + _ox, _yy + _oy);
				_fram[_ind] = { x: _xx, y: _yy };
				
				_ind++;
				_xx += _sw;
				_lh = max(_lh, _sh);
			}
			
			_data.frames = _fram;
			_sprites[$ _key] = _data;
		}
		
	surface_reset_shader();
	
	var _struct = { sprites: _sprites };
	
	json_save_struct($"{_packedDir}/struct.json", _struct);
	surface_save(_surface, $"{_packedDir}/texture.png");
	surface_free(_surface);
}

function __generate_texturegroup() {
	__generate_texturegroup_dir($"D:/Project/MakhamDev/LTS-PixelComposer/RESOURCE/data/{PREFERENCES.theme}");
	__test_update_theme();
	
	file_delete_safe("D:/Project/MakhamDev/LTS-PixelComposer/RESOURCE/data/latest_zip_time.txt");
}