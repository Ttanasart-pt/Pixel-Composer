#region tags
	globalvar META_TAGS;
	META_TAGS = [ "3D", "Disappear", "Effect", "Filter", "Generator", "Transform", "Transition", "Utility" ];
	
	enum FILE_TYPE {
		project,
		collection,
		assets
	}
	
	enum FILE_STEAM_TYPE {
		local,
		steamUpload,
		steamOpen
	}
#endregion

function MetaDataManager() constructor {
	name		= "";
	description = "";
	author		= "";
	contact		= "";
	alias		= "";
	type		= FILE_TYPE.collection;
	isDefault   = false;
	
	author_steam_id = 0;
	file_id		= 0;
	tags		= [];
	version		= SAVE_VERSION;
	steam		= FILE_STEAM_TYPE.local;
	
	static displays = [
		[ "Description",  function(m) /*=>*/ {return m.description}, 5],
		[ "Author",       function(m) /*=>*/ {return m.author},      1],
		[ "Contact info", function(m) /*=>*/ {return m.contact},     1],
		[ "Alias",        function(m) /*=>*/ {return m.alias},       1],
		[ "Tags",         function(m) /*=>*/ {return m.tags},        1],
	];
	
	static serialize = function() {
		var m = {
			description, 
			author, 
			contact, 
			alias, 
			file_id, 
			tags, 
			version, 
			isDefault, 
		};
		
		m.aut_id = author_steam_id;
		
		return m;
	}
	
	static deserialize = function(m, readonly = false) {
		description     = m[$ "description"] ?? description;
		author          = m[$ "author"]      ?? author;
		contact         = m[$ "contact"]     ?? contact;
		alias           = m[$ "alias"]       ?? alias;
		author_steam_id = m[$ "aut_id"]      ?? author_steam_id;
		file_id         = m[$ "file_id"]     ?? file_id;
		tags            = m[$ "tags"]        ?? tags;
		version         = m[$ "version"]     ?? version;
		isDefault       = m[$ "isDefault"]   ?? isDefault;
		
		return self;
	}
	
	static clone = function() {
		var m = new MetaDataManager();
		
		m.description	= description;
		m.author		= author;		
		m.contact		= contact;			
		m.alias			= alias;
		
		return m;
	}
	
	static drawTooltip = function() {
		var _pd = ui(10);
		
		var ww = ui(320), _w = 0;
		var _h = 0;
		
		if(type == FILE_TYPE.assets) {
			draw_set_font(f_p1);
			_h = string_height(name);
			_w = string_width(name);
			
			var mx = min(mouse_mxs + _pd * 2, WIN_W - (_w + _pd * 2));
			var my = min(mouse_mys + _pd * 2, WIN_H - (_h + _pd * 2));
			
			draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + _pd * 2, _h + _pd * 2);
			draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + _pd * 2, _h + _pd * 2);
			
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
			draw_text(mx + _pd, my + _pd, name);
			return;
		}
		
		var _own = author_steam_id == STEAM_USER_ID;
		var _ont = "Your creation";
		var _aut = $"{__txt("By")} {author}";
		var _ver = floor(version) < floor(SAVE_VERSION)? __txtx("meta_old_version", "Created on an older version") : __txtx("meta_new_version", "Created on a newer version");
		
		draw_set_font(f_h5);
		_h += string_height_ext(name, -1, ww) - ui(4);
		_w = max(_w, string_width_ext(name, -1, ww) + isDefault * ui(6 + 56));
		
		draw_set_font(f_p1);
		_h += string_height_ext(_aut, -1, ww);
		_w = max(_w, string_width_ext(_aut, -1, ww) + _own * (ui(24) + string_width(_ont)));
		
		if(contact != "") { 
			draw_set_font(f_p2);
			_h += string_height_ext(contact, -1, ww);
			_w = max(_w, string_width_ext(contact, -1, ww));
		}
		
		if(description != "") {
			draw_set_font(f_p1);
			_h += ui(8);
			_h += string_height_ext(description, -1, ww);
			_w = max(_w, string_width_ext(description, -1, ww));
		}
		
		if(alias != "") { 
			_h += ui(16);
			draw_set_font(f_p2);
			_h += string_height_ext(alias, -1, ww);
			_w = max(_w, string_width_ext(alias, -1, ww));
		}
		
		if(floor(version) != floor(SAVE_VERSION)) {
			draw_set_font(f_p2);
			_h += ui(8);
			_h += string_height_ext(_ver, -1, ww);
			_w = max(_w, string_width_ext(_ver, -1, ww));
		}
		
		if(array_length(tags)) {
			draw_set_font(f_p1);
			_h += ui(8);
			var tx = 0;
			var hh = line_get_height(f_p1, ui(4));
			var th = hh;
			for( var i = 0, n = array_length(tags); i < n; i++ ) {
				var ww = string_width(tags[i]) + ui(16);
				if(tx + ww + ui(2) > _w - ui(16)) {
					tx = 0;
					th += hh + ui(2);
				}
				tx += ww + ui(2);
			}
			_h += th;
		}
		
		var mx = min(mouse_mxs + _pd * 2, WIN_W - (_w + _pd * 2));
		var my = min(mouse_mys + _pd * 2, WIN_H - (_h + _pd * 2));
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + _pd * 2, _h + _pd * 2);
		draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + _pd * 2, _h + _pd * 2);
		
		var tx = mx + _pd;
		var ty = my + ui(8);
		
		draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
		draw_text_line(tx, ty, name, -1, _w);
		
		if(isDefault) {
			var _dx = tx + string_width(name) + ui(6);
			var _dy = ty + ui(6);
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, _dx, _dy, ui(56), ui(20), COLORS._main_icon_dark, 1);
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_accent);
			draw_text(_dx + ui(4), _dy + ui(2), "Default");
			
			draw_set_font(f_h5);
		}
		
		ty += string_height_ext(name, -1, _w) - ui(4);
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_line(tx, ty, _aut, -1, _w);
		if(_own) {
			var _owX = tx + string_width_ext(_aut, -1, _w) + ui(12);
			
			draw_set_font(f_p2);
			var _owW = string_width( _ont);
			var _owH = string_height(_ont);
			draw_sprite_stretched_ext(THEME.box_r2, 0, _owX - ui(4), ty + ui(1) - ui(2), _owW + ui(8), _owH + ui(4), COLORS._main_icon_dark, 1);
			
			draw_set_color(COLORS._main_text_accent);
			draw_text_line(_owX, ty + ui(1), _ont, -1, _w);
		}
		ty += string_height_ext(_aut, -1, _w);
		
		if(contact != "") {
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_line(tx, ty, contact, -1, _w);
			ty += string_height_ext(contact, -1, _w);
		}
		
		if(description != "") {
			ty += ui(8);
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
			draw_text_line(tx, ty, description, -1, _w);
			ty += string_height_ext(description, -1, _w);
		}
		
		if(alias != "") { 
			ty += ui(16);
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_line(tx, ty, alias, -1, _w);
			ty += string_height_ext(alias, -1, _w);
		}
		
		if(floor(version) != floor(SAVE_VERSION)) {
			ty += ui(8);
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_accent);
			draw_text_line(tx, ty, _ver, -1, _w);
			ty += string_height_ext(_ver, -1, _w);
		}
		
		if(array_length(tags)) {
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			ty += ui(8);
			var tx = 0;
			var hh = line_get_height(f_p1, ui(4));
			
			for( var i = 0, n = array_length(tags); i < n; i++ ) {
				var ww = string_width(tags[i]) + ui(16);
				if(tx + ww + ui(2) > _w - ui(16)) {
					tx = 0;
					ty += hh + ui(2);
				}
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, mx + ui(8) + tx, ty, ww, hh, COLORS._main_icon, 1);
				draw_text(mx + ui(8) + tx + ui(8), ty + hh / 2, tags[i]);
			
				tx += ww + ui(2);
			}
		}
		
	}
}

#region 
	function __getdefaultMetaData() {
		var meta = new MetaDataManager();
		var path = DIRECTORY + "meta.json";
		
		if(!file_exists_empty(path)) return meta;
		var over = json_load_struct(path);
		return meta.deserialize(over);
	}
#endregion

