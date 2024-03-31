/*
* ASE file reader
* Author: MakhamDev
* File spec from: https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md
*/

enum _BIN_TYPE {
	byte,
	word,
	short,
	dword,
	long,
	fixed,
	float,
	double,
	qword,
	long64,
	
	string,
	point,
	size,
	rect,
	color,
	pixel,
}

//ASE blend mode
//Normal         = 0
//Multiply       = 1
//Screen         = 2
//Overlay        = 3
//Darken         = 4
//Lighten        = 5
//Color Dodge    = 6
//Color Burn     = 7
//Hard Light     = 8
//Soft Light     = 9
//Difference     = 10
//Exclusion      = 11
//Hue            = 12
//Saturation     = 13
//Color          = 14
//Luminosity     = 15
//Addition       = 16
//Subtract       = 17
//Divide         = 18

globalvar __ase_format_header;
__ase_format_header = [
	[_BIN_TYPE.dword,	"File size"],
	[_BIN_TYPE.word,	"Magic number"],
	[_BIN_TYPE.word,	"Frame amount"],
	[_BIN_TYPE.word,	"Width"],
	[_BIN_TYPE.word,	"Height"],
	[_BIN_TYPE.word,	"Color depth"], //32: RGBA, 16: Grey, 8: Index
	[_BIN_TYPE.dword,	"Flags"], 
	[_BIN_TYPE.word,	"Speed"], //DEPRECATED
	[_BIN_TYPE.dword,	"0"], 
	[_BIN_TYPE.dword,	"0"], 
	[_BIN_TYPE.byte,	"Palette entry"], //For indexed sprite, index in palette that consider a transparent color.
	[_BIN_TYPE.byte,	"Ignore", 3],
	[_BIN_TYPE.word,	"Number of colors"],
	[_BIN_TYPE.byte,	"Pixel width"],  //If zero, then pixel ratio is 1:1
	[_BIN_TYPE.byte,	"Pixel height"], //If zero, then pixel ratio is 1:1
	[_BIN_TYPE.short,	"Grid X"],
	[_BIN_TYPE.short,	"Grid Y"],
	[_BIN_TYPE.word,	"Grid width"], //If zero, no grid
	[_BIN_TYPE.word,	"Grid height"], //If zero, no grid
	[_BIN_TYPE.byte,	"Unused", 84],
];

globalvar __ase_format_frame;
__ase_format_frame = [
	[_BIN_TYPE.dword,	"Length"],
	[_BIN_TYPE.word,	"Magic number"],
	[_BIN_TYPE.word,	"Chunk amount"], //If 0xFFFF, use "Chunk amount new"
	[_BIN_TYPE.word,	"Duration"], //In millisec
	[_BIN_TYPE.byte,	"Unused", 2],
	[_BIN_TYPE.dword,	"Chunk amount new"],
];

globalvar __ase_format_chunk;
__ase_format_chunk = [
	[_BIN_TYPE.dword,	"Length"],
	[_BIN_TYPE.word,	"Type"],
];

globalvar __ase_format_chunk_old_palette;
__ase_format_chunk_old_palette = [
	[_BIN_TYPE.word,	"Packet amount"],
];

globalvar __ase_format_chunk_old_palette_packet;
__ase_format_chunk_old_palette_packet = [
	[_BIN_TYPE.byte,	"Entries skip index"],
	[_BIN_TYPE.byte,	"Color amount"],
	[_BIN_TYPE.color,	"Colors", "Color amount"],
];

globalvar __ase_format_chunk_layer;
__ase_format_chunk_layer = [
	[_BIN_TYPE.word,	"Flag"], //1: Visible, 2: Editable, 4:Lock, 8:BG
	[_BIN_TYPE.word,	"Layer type"], //0: Normal, 1: Group, 2: Tilemap
	[_BIN_TYPE.word,	"Child level"],
	[_BIN_TYPE.word,	"Ignore"],
	[_BIN_TYPE.word,	"Ignore"],
	[_BIN_TYPE.word,	"Blend mode"],
	[_BIN_TYPE.byte,	"Opacity"],
	[_BIN_TYPE.byte,	"Unused", 3],
	[_BIN_TYPE.string,	"Name"],
	[_BIN_TYPE.dword,	"Tileset index", 1, function(chunk) { return chunk[? "Layer type"] == 2; }],
];

globalvar __ase_format_chunk_cel;
__ase_format_chunk_cel = [
	[_BIN_TYPE.word,	"Layer index"],
	[_BIN_TYPE.short,	"X"],
	[_BIN_TYPE.short,	"Y"],
	[_BIN_TYPE.byte,	"Opacity"],
	[_BIN_TYPE.word,	"Cel type"], //0: Raw image, 1: Linked, 2: Compressed image, 3: Compressed tilemap
	[_BIN_TYPE.byte,	"Unused", 7],
];

globalvar __ase_format_chunk_cel_raw_image;
__ase_format_chunk_cel_raw_image = [
	[_BIN_TYPE.word,	"Width"],
	[_BIN_TYPE.word,	"Height"],
	[_BIN_TYPE.pixel,	"Pixels", function(chunk) { return chunk[? "Width"] * chunk[? "Width"]; }],
];

globalvar __ase_format_chunk_cel_linked;
__ase_format_chunk_cel_linked = [
	[_BIN_TYPE.word,	"Frame position"],
];

globalvar __ase_format_chunk_cel_compress_image;
__ase_format_chunk_cel_compress_image = [
	[_BIN_TYPE.word,	"Width"],
	[_BIN_TYPE.word,	"Height"],
	//[_BIN_TYPE.long,	"Raw cel", function(chunk) { return chunk[? "Width"] * chunk[? "Width"]; }],
];

globalvar __ase_format_chunk_cel_compress_tilemap;
__ase_format_chunk_cel_compress_tilemap = [
	[_BIN_TYPE.word,	"Width"],
	[_BIN_TYPE.word,	"Height"],
	[_BIN_TYPE.word,	"Bits per tile"],
	[_BIN_TYPE.dword,	"Bitmask for tile ID"],
	[_BIN_TYPE.dword,	"X flip"],
	[_BIN_TYPE.dword,	"Y flip"],
	[_BIN_TYPE.dword,	"90CW rotation"],
	[_BIN_TYPE.byte,	"Unused", 10],
	//[_BIN_TYPE.tile,	"Tiles", function(chunk) { return chunk[? "Width"] * chunk[? "Width"]; }],
];

globalvar __ase_format_chunk_cel_extra;
__ase_format_chunk_cel_extra = [
	[_BIN_TYPE.dword,	"Flag"],
	[_BIN_TYPE.fixed,	"X"],
	[_BIN_TYPE.fixed,	"Y"],
	[_BIN_TYPE.fixed,	"Width"],
	[_BIN_TYPE.fixed,	"Height"],
	[_BIN_TYPE.byte,	"Unused", 16],
];

globalvar __ase_format_chunk_color_profile;
__ase_format_chunk_color_profile = [
	[_BIN_TYPE.word,	"Type"], //0: no profile, 1: sRGB, 2: ICC
	[_BIN_TYPE.word,	"Flag"], //1: Fix gamma
	[_BIN_TYPE.fixed,	"Fixed gamma"],
	[_BIN_TYPE.byte,	"Unused", 8],
	[_BIN_TYPE.dword,	"ICC Data length", 1, function(chunk) { return chunk[? "Type"] == 2; }],
	[_BIN_TYPE.byte,	"ICC Data", "ICC Data length", function(chunk) { return chunk[? "Type"] == 2; }],
];

globalvar __ase_format_chunk_file;
__ase_format_chunk_file = [
	[_BIN_TYPE.dword,	"Entries"],
	[_BIN_TYPE.byte,	"Unused", 8],
];

globalvar __ase_format_chunk_file_entry;
__ase_format_chunk_file_entry = [
	[_BIN_TYPE.dword,	"ID"],
	[_BIN_TYPE.byte,	"File type"], //0: External palette, 1: External tileset, 2: Extension anme
	[_BIN_TYPE.byte,	"Unused", 7],
	[_BIN_TYPE.string,	"File name"],
];

globalvar __ase_format_chunk_tag;
__ase_format_chunk_tag = [
	[_BIN_TYPE.word,	"Tag amount"],
	[_BIN_TYPE.byte,	"Unused", 8],
];

globalvar __ase_format_chunk_tag_entry;
__ase_format_chunk_tag_entry = [
	[_BIN_TYPE.word,	"Frame start"],
	[_BIN_TYPE.word,	"Frame end"],
	[_BIN_TYPE.byte,	"Loop"], //0: Forward, 1: Backward, 2: Ping pong, 3: Ping pong reverse
	[_BIN_TYPE.word,	"Repeat amount"], //0: Infinite, N: N-times
	[_BIN_TYPE.byte,	"Unused", 6],
	[_BIN_TYPE.color,	"Color"],
	[_BIN_TYPE.byte,	"Extra"],
	[_BIN_TYPE.string,	"Name"],
]

globalvar __ase_format_chunk_palette;
__ase_format_chunk_palette = [
	[_BIN_TYPE.dword,	"Color amount"],
	[_BIN_TYPE.dword,	"First index"],
	[_BIN_TYPE.dword,	"Last index"],
	[_BIN_TYPE.byte,	"Unused", 8],
];

globalvar __ase_format_chunk_palette_entry;
__ase_format_chunk_palette_entry = [
	[_BIN_TYPE.word,	"Flag"], //1: Has name
	[_BIN_TYPE.byte,	"Red"],
	[_BIN_TYPE.byte,	"Green"],
	[_BIN_TYPE.byte,	"Blue"],
	[_BIN_TYPE.byte,	"Alpha"],
	[_BIN_TYPE.string,	"Name", 1, function(chunk) { return chunk[? "Flag"] & (1 << 0); }],
];

globalvar __ase_format_chunk_user_data;
__ase_format_chunk_user_data = [
	[_BIN_TYPE.dword,	"Flag"], //1: Text, 2: Color, 4: Properties
	[_BIN_TYPE.string,	"Name", 1,  function(chunk) { return chunk[? "Flag"] & (1 << 0); }],
	[_BIN_TYPE.byte,	"Red", 1,   function(chunk) { return chunk[? "Flag"] & (1 << 1); }],
	[_BIN_TYPE.byte,	"Green", 1, function(chunk) { return chunk[? "Flag"] & (1 << 1); }],
	[_BIN_TYPE.byte,	"Blue", 1,  function(chunk) { return chunk[? "Flag"] & (1 << 1); }],
	[_BIN_TYPE.byte,	"Alpha", 1, function(chunk) { return chunk[? "Flag"] & (1 << 1); }],
];

globalvar __ase_format_chunk_user_data_prop;
__ase_format_chunk_user_data_prop = [
	[_BIN_TYPE.dword,	"Length"],
	[_BIN_TYPE.dword,	"Prop amount"],
]

/* TODO: Use data read */

globalvar __ase_format_chunk_slice;
__ase_format_chunk_slice = [
	[_BIN_TYPE.dword,	"Slice key amount"],
	[_BIN_TYPE.dword,	"Flag"], //1: 9 slice, 2: pivot
	[_BIN_TYPE.dword,	"Reserved"], 
	[_BIN_TYPE.string,	"Name"], 
];

globalvar __ase_format_chunk_slice_key;
__ase_format_chunk_slice_key = [
	[_BIN_TYPE.dword,	"Frame number"],
	[_BIN_TYPE.long,	"X"],
	[_BIN_TYPE.long,	"Y"],
	[_BIN_TYPE.dword,	"Width"],
	[_BIN_TYPE.dword,	"Height"],
];

globalvar __ase_format_chunk_slice_nine;
__ase_format_chunk_slice_nine = [
	[_BIN_TYPE.long,	"Center X"],
	[_BIN_TYPE.long,	"Center Y"],
	[_BIN_TYPE.dword,	"Center width"],
	[_BIN_TYPE.dword,	"Center height"],
];

globalvar __ase_format_chunk_slice_pivot;
__ase_format_chunk_slice_pivot = [
	[_BIN_TYPE.long,	"Pivot X"],
	[_BIN_TYPE.long,	"Pivot Y"],
];

globalvar __ase_format_chunk_tileset;
__ase_format_chunk_tileset = [
	[_BIN_TYPE.dword,	"ID"],
	[_BIN_TYPE.dword,	"Flag"], //1: Link to external file, 2: Include tile in this file, 4: Use ID 0 as empty tiles.
	[_BIN_TYPE.dword,	"Tile amount"],
	[_BIN_TYPE.word,	"Tile width"],
	[_BIN_TYPE.word,	"Tile height"],
	[_BIN_TYPE.short,	"Base index"],
	[_BIN_TYPE.byte,	"Reserved", 14],
	[_BIN_TYPE.string,	"Name"],
	[_BIN_TYPE.dword,	"ID of external file", 1, function(chunk) { return chunk[? "Flag"] & (1 << 1); }],
	[_BIN_TYPE.dword,	"Tileset ID",		   1, function(chunk) { return chunk[? "Flag"] & (1 << 1); }],
	[_BIN_TYPE.dword,	"Data length",		   1, function(chunk) { return chunk[? "Flag"] & (1 << 2); }],
	[_BIN_TYPE.pixel,	"Compressed image", "Data length", function(chunk) { return chunk[? "Flag"] & (1 << 2); }],
];

function read_format_type(bin, datType, outMap) {
	switch(datType) {
		case _BIN_TYPE.byte:	return bin_read_byte(bin);
		case _BIN_TYPE.word:	return bin_read_word(bin);
		case _BIN_TYPE.short:	return bin_read_short(bin);
		case _BIN_TYPE.dword:	return bin_read_dword(bin);
		case _BIN_TYPE.long:	return bin_read_long(bin);
		case _BIN_TYPE.fixed:	return bin_read_fixed(bin);
		case _BIN_TYPE.float:	return bin_read_float(bin);
		case _BIN_TYPE.double:	return bin_read_double(bin);
		case _BIN_TYPE.qword:	return bin_read_qword(bin);
		case _BIN_TYPE.long64:	return bin_read_long64(bin);
		
		case _BIN_TYPE.string:	return bin_read_string(bin);
		case _BIN_TYPE.point:	return bin_read_point(bin);
		case _BIN_TYPE.size:	return bin_read_size(bin);
		case _BIN_TYPE.rect:	return bin_read_rect(bin);
		case _BIN_TYPE.color:	return bin_read_color(bin);
		case _BIN_TYPE.pixel:	return bin_read_pixel(bin, outMap[? "Color depth"]);
	}
	
	
	return 0;
}

function read_format(bin, format, outMap) {
	var datType = array_safe_get_fast(format, 0, 0);
	var key     = array_safe_get_fast(format, 1, "");
	var amount  = array_safe_get_fast(format, 2, 1);
	if(is_string(amount))
		amount = ds_map_exists(outMap, amount)? outMap[? amount] : 1;
	else if(is_method(amount))
		amount = amount(outMap);
		
	if(amount == 1) {
		var val = read_format_type(bin, datType, outMap);
		outMap[? key] = val;
		return val;
	} else {
		var a = array_create(amount);
		for( var i = 0; i < amount; i++ )
			a[i] = read_format_type(bin, datType, outMap);
		outMap[? key] = a;
		return a;
	}
}

function read_format_array(bin, formatArr, outMap) {
	for( var i = 0, n = array_length(formatArr); i < n; i++ ) {
		if(array_length(formatArr[i]) >= 4 && !formatArr[i][3](outMap)) 
			continue;
		var pos = file_bin_position(bin);
		var val = read_format(bin, formatArr[i], outMap);
		//printIf(global.FLAG.ase_import, "Pos " + dec_to_hex(pos) + " - " + dec_to_hex(file_bin_position(bin)));
		
		if(formatArr[i][1] == "Type")
			printIf(global.FLAG.ase_import, "\t" + formatArr[i][1] + ":\t 0x" + dec_to_hex(val, 4));
		else
			printIf(global.FLAG.ase_import, "\t" + formatArr[i][1] + ":\t " + string(val));
	}
}

function read_ase(path, fileMap) {
	printIf(global.FLAG.ase_import, "===== Reading: " + path + " =====");
	var file = file_bin_open(path, 0);
	file_bin_seek(file, 0);
	
	ds_map_clear(fileMap);
	read_format_array(file, __ase_format_header, fileMap);
	
	var frames = [];
	var frameAmo = ds_map_exists(fileMap, "Frame amount")? fileMap[? "Frame amount"] : 0;
	for( var i = 0; i < frameAmo; i++ ) {
		printIf(global.FLAG.ase_import, "\n=== Reading frame " + string(i) + " ===");
		array_push(frames, read_ase_frame(file));
	}
	fileMap[? "Frames"] = frames; 
	
	file_bin_close(file);
	
	return fileMap;
}

function read_ase_frame(file) {
	var frame = ds_map_create();
	
	read_format_array(file, __ase_format_frame, frame);
	
	var chunks = [];
	var chunkAmo = ds_map_exists(frame, "Chunk amount")? frame[? "Chunk amount"] : 0;
	if(chunkAmo == 65535)
		chunkAmo = ds_map_exists(frame, "Chunk amount new")? frame[? "Chunk amount new"] : chunkAmo;
	
	for( var i = 0; i < chunkAmo; i++ ) {
		printIf(global.FLAG.ase_import, "\n=== Reading chunk " + string(i) + " ===");
		array_push(chunks, read_ase_chunk(file));
	}
	frame[? "Chunks"] = chunks; 
	
	return frame;
}

function read_ase_chunk(file) {
	var chunk = ds_map_create();
	var startPos = file_bin_position(file);
	
	read_format_array(file, __ase_format_chunk, chunk);
	
	var skipPos = startPos + chunk[? "Length"];
	
	switch(chunk[? "Type"]) {
		case 0x0004: //old palette
		case 0x0011: //old palette
			printIf(global.FLAG.ase_import, "\n -- Reading chunk [Old palette] -- "); 
			read_format_array(file, __ase_format_chunk_old_palette, chunk);
			var cc = [];
			for( var i = 0; i < chunk[? "Packet amount"]; i++ ) {
				cc[i] = ds_map_create();
				read_format_array(file, __ase_format_chunk_old_palette_packet, cc[i]);
			}
			chunk[? "Packets"] = cc;
			break;
		case 0x2004: //layer
			printIf(global.FLAG.ase_import, "\n -- Reading chunk [Layer] -- "); 
			read_format_array(file, __ase_format_chunk_layer, chunk);
			break;
		case 0x2005: //cel
			printIf(global.FLAG.ase_import, "\n -- Reading chunk [Cel] -- "); 
			read_format_array(file, __ase_format_chunk_cel, chunk);
			
			var type = chunk[? "Cel type"];
			switch(type) {
				case 0 : 
					read_format_array(file, __ase_format_chunk_cel_raw_image, chunk);
					break;
				case 1 : 
					read_format_array(file, __ase_format_chunk_cel_linked, chunk);
					break;
				case 2 : 
					read_format_array(file, __ase_format_chunk_cel_compress_image, chunk);
					chunk[? "Surface"] = noone;
					
					var compressLength = (skipPos - file_bin_position(file));
					var _compBuff = buffer_create(compressLength * buffer_sizeof(buffer_u8), buffer_grow, 1);
					buffer_seek(_compBuff, buffer_seek_start, 0);
					
					repeat(compressLength) {
						var byte = file_bin_read_byte(file);
						buffer_write(_compBuff, buffer_u8, byte);
					}
					
					var _rawBuff = buffer_decompress(_compBuff);
					if(_rawBuff != -1) chunk[? "Buffer"] = _rawBuff;
					printIf(global.FLAG.ase_import, "    Buffer size: " + string(compressLength));
					
					buffer_delete(_compBuff);
					break;
				case 3 : 
					read_format_array(file, __ase_format_chunk_cel_compress_tilemap, chunk);
					//TILE READ
					break;
			}
			break;
		case 0x2006: //cel extra
			break;
		case 0x2007: //color profile
			printIf(global.FLAG.ase_import, "\n -- Reading chunk [Color profile] -- "); 
			read_format_array(file, __ase_format_chunk_color_profile, chunk);
			break;
		case 0x2008: //external file
			break;
		case 0x2009: //mask DEPRECATED
			break;
		case 0x2017: //path
			break;
		case 0x2018: //tag
			printIf(global.FLAG.ase_import, "\n -- Reading chunk [Tag] -- "); 
			read_format_array(file, __ase_format_chunk_tag, chunk);
			var amo = chunk[? "Tag amount"]
			var tags = [];
			repeat(amo) {
				var m = ds_map_create();	
				read_format_array(file, __ase_format_chunk_tag_entry, m);
				array_push(tags, m);
			}
			chunk[? "Tags"] = tags;
			break;
		case 0x2019: //palette
			printIf(global.FLAG.ase_import, "\n -- Reading chunk [Palette] -- "); 
			read_format_array(file, __ase_format_chunk_palette, chunk);
			var cc = [];
			for( var i = 0; i < chunk[? "Color amount"]; i++ ) {
				cc[i] = ds_map_create();
				read_format_array(file, __ase_format_chunk_palette_entry, cc[i]);
			}
			chunk[? "Palette"] = cc;
			break;
		case 0x2020: //user data
			break;
		case 0x2022: //slice
			break;
		case 0x2023: //tileset
			break;
	}
	file_bin_seek(file, skipPos - file_bin_position(file));
	
	return chunk;
}