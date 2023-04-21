#region tags
	globalvar META_TAGS;
	META_TAGS = [ "3D", "Disappear", "Effect", "Filter", "Generator", "Transform", "Transition", "Utility" ];
	
	enum FILE_TYPE {
		project,
		collection,
		assets
	}
#endregion

function MetaDataManager() constructor {
	name		= "";
	description = "";
	author		= "";
	contact		= "";
	alias		= "";
	type		= FILE_TYPE.collection;
	author_steam_id = 0;
	file_id		= 0;
	tags		= [];
	version		= 0;
	steam		= false;
	
	static displays = [
		[ get_text("description", "Description"),	 function(meta) { return meta.description; }	, line_height() * 5],
		[ get_text("author", "Author"),				 function(meta) { return meta.author; }			, line_height() ],
		[ get_text("contact_info", "Contact info"),	 function(meta) { return meta.contact; }		, line_height() ],
		[ get_text("alias", "Alias"),				 function(meta) { return meta.alias; }			, line_height() ],
		[ get_text("tags", "Tags"),					 function(meta) { return meta.tags; }			, line_height() ],
	];
	
	static serialize = function() {
		var m = ds_map_create();
		m[? "description"]  = description;
		m[? "author"]		= author;
		m[? "contact"]		= contact;
		m[? "alias"]		= alias;
		m[? "aut_id"]		= author_steam_id;
		m[? "file_id"]		= file_id;
		
		ds_map_add_list(m, "tags", ds_list_create_from_array(tags));
		
		return m;
	}
	
	static deserialize = function(m, readonly = false) {
		description		= ds_map_try_get(m, "description", "");
		author			= ds_map_try_get(m, "author", "");
		contact			= ds_map_try_get(m, "contact", "");
		alias			= ds_map_try_get(m, "alias", "");
		author_steam_id = ds_map_try_get(m, "aut_id");
		file_id			= ds_map_try_get(m, "file_id");
		
		if(ds_map_exists(m, "tags"))
			tags = array_create_from_list(m[? "tags"]);
		
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
		var ww = ui(320), _w = 0;
		var _h = 0;
		
		if(type == FILE_TYPE.assets) {
			draw_set_font(f_p0);
			_h = string_height(name);
			_w = string_width(name);
			
			var mx = min(mouse_mx + ui(16), WIN_W - (_w + ui(16)));
			var my = min(mouse_my + ui(16), WIN_H - (_h + ui(16)));
			
			draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + ui(16), _h + ui(16));
			draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + ui(16), _h + ui(16));
			
			draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
			draw_text(mx + ui(8), my + ui(8), name);
			return;
		}
		
		var _aut = "By " + author;
		var _ver = version < SAVEFILE_VERSION? get_text("meta_old_version", "Created on an older version") : get_text("meta_new_version", "Created on a newer version");
		
		draw_set_font(f_h5);
		_h += string_height_ext(name, -1, ww) - ui(4);
		_w = max(_w, string_width_ext(name, -1, ww));
		
		draw_set_font(f_p0b);
		_h += string_height_ext(_aut, -1, ww);
		_w = max(_w, string_width_ext(_aut, -1, ww));
		
		if(contact != "") { 
			draw_set_font(f_p2);
			_h += ui(-4);
			_h += string_height_ext(contact, -1, ww);
			_w = max(_w, string_width_ext(contact, -1, ww));
		}
		
		draw_set_font(f_p0);
		_h += ui(8);
		_h += string_height_ext(description, -1, ww);
		_w = max(_w, string_width_ext(description, -1, ww));
		
		if(alias != "") { 
			_h += ui(16);
			draw_set_font(f_p2);
			_h += string_height_ext(alias, -1, ww);
			_w = max(_w, string_width_ext(alias, -1, ww));
		}
		
		if(version != SAVEFILE_VERSION) {
			draw_set_font(f_p2);
			_h += ui(8);
			_h += string_height_ext(_ver, -1, ww);
			_w = max(_w, string_width_ext(_ver, -1, ww));
		}
		
		if(array_length(tags)) {
			draw_set_font(f_p0);
			_h += ui(8);
			var tx = 0;
			var hh = line_height(f_p0, ui(4));
			var th = hh;
			for( var i = 0; i < array_length(tags); i++ ) {
				var ww = string_width(tags[i]) + ui(16);
				if(tx + ww + ui(2) > _w - ui(16)) {
					tx = 0;
					th += hh + ui(2);
				}
				tx += ww + ui(2);
			}
			_h += th;
		}
		
		var mx = min(mouse_mx + ui(16), WIN_W - (_w + ui(16)));
		var my = min(mouse_my + ui(16), WIN_H - (_h + ui(16)));
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + ui(16), _h + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + ui(16), _h + ui(16));
		
		var ty = my + ui(8);
		
		draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
		draw_text_ext(mx + ui(8), ty, name, -1, _w);
		ty += string_height_ext(name, -1, _w) - ui(4);
		
		draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_ext(mx + ui(8), ty, _aut, -1, _w);
		ty += string_height_ext(_aut, -1, _w);
		
		if(contact != "") {
			ty += ui(-4);
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_ext(mx + ui(8), ty, contact, -1, _w);
			ty += string_height_ext(contact, -1, _w);
		}
		
		ty += ui(8);
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_text_ext(mx + ui(8), ty, description, -1, _w);
		ty += string_height_ext(description, -1, _w);
		
		if(alias != "") { 
			ty += ui(16);
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_ext(mx + ui(8), ty, alias, -1, _w);
			ty += string_height_ext(alias, -1, _w);
		}
		
		if(version != SAVEFILE_VERSION) {
			ty += ui(8);
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_accent);
			draw_text_ext(mx + ui(8), ty, _ver, -1, _w);
			ty += string_height_ext(_ver, -1, _w);
		}
		
		if(array_length(tags)) {
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			ty += ui(8);
			var tx = 0;
			var hh = line_height(f_p0, ui(4));
			
			for( var i = 0; i < array_length(tags); i++ ) {
				var ww = string_width(tags[i]) + ui(16);
				if(tx + ww + ui(2) > _w - ui(16)) {
					tx = 0;
					ty += hh + ui(2);
				}
				
				draw_sprite_stretched_ext(THEME.group_label, 0, mx + ui(8) + tx, ty, ww, hh, COLORS._main_icon, 1);
				draw_text(mx + ui(8) + tx + ui(8), ty + hh / 2, tags[i]);
			
				tx += ww + ui(2);
			}
		}
		
	}
}

#region 
	globalvar METADATA;
	METADATA = noone;
	
	function __getdefaultMetaData() {
		var meta = new MetaDataManager();
		var path = DIRECTORY + "meta.json";
		
		if(!file_exists(path)) return meta;
		var over = json_load(path);
		return meta.deserialize(over);
	}
#endregion

