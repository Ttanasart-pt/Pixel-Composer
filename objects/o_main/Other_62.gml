/// @description network
var _id  = async_load[? "id"];

if(ds_map_exists(global.FILE_LOAD_ASYNC, async_load[? "id"])) {
	var cb = global.FILE_LOAD_ASYNC[? async_load[? "id"]];
	var callback = cb[0];
	var arguments = cb[1];
	
	callback(arguments);
}

if(PALETTE_LOSPEC && _id == PALETTE_LOSPEC) {
	PALETTE_LOSPEC = 0;
    if (async_load[? "status"] != 0) exit;
    
    var res = ds_map_find_value(async_load, "result");
    var resJson = json_try_parse(res, -1);
    
    if(resJson == -1) exit;
    if(!is_struct(resJson)) exit;
    if(!struct_has(resJson, "colors")) exit;
    
    var _name = resJson.name;
    var _auth = resJson.author;
    var _colr = resJson.colors;
    
    if(!is_array(_colr)) exit;
    
    _name = string_replace_all(_name, "-", " ");
    
    var _path = $"{DIRECTORY}Palettes/{_name}.hex"
    var _f = file_text_open_write(_path);
    	for (var i = 0, n = array_length(_colr); i < n; i++)
    		file_text_write_string(_f, $"{_colr[i]}\n");
    file_text_close(_f);
    __initPalette();
    
    noti_status($"Loaded palette: {_name} by {_auth} completed.", noone, true);
    
    with(o_dialog_palette)  { initPalette(); }
    with(o_dialog_gradient) { initPalette(); }
}

asyncLoad(async_load);