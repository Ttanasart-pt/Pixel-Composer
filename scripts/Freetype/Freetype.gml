globalvar FREETYPE_FONT_PATH; FREETYPE_FONT_PATH  = "";
globalvar FREETYPE_FONT_SIZE; FREETYPE_FONT_SIZE  = 16;
globalvar FREETYPE_FONT_AA; FREETYPE_FONT_AA    = false;
globalvar FREETYPE_FONT_SPACE; FREETYPE_FONT_SPACE = 0;

globalvar __FREETYPE_SURFACE; __FREETYPE_SURFACE = undefined;
globalvar __FREETYPE_OUTPUT; __FREETYPE_OUTPUT  = buffer_create(1, buffer_grow, 1);
globalvar __FREETYPE_BBOX; __FREETYPE_BBOX    = buffer_create(1, buffer_grow, 4);
	
	
function freetype_set_font(_path, _size, _aa = false, _spac = 0) {
	FREETYPE_FONT_PATH  = _path;
	FREETYPE_FONT_SIZE  = _size;
	FREETYPE_FONT_AA    = _aa;
	FREETYPE_FONT_SPACE = _spac;
}

function freetype_draw(_x, _y, _text) {
	freeType_setFont(FREETYPE_FONT_PATH, FREETYPE_FONT_SIZE);
	freeType_setFontAA(FREETYPE_FONT_AA);
	freeType_setFontSpacing(FREETYPE_FONT_SPACE);
	freeType_fontStart();
	freeType_setText(_text);
	
	freeType_GetTextBBox(buffer_get_address(__FREETYPE_BBOX));
	var tw = buffer_peek(__FREETYPE_BBOX, 0, buffer_u16);
	var th = buffer_peek(__FREETYPE_BBOX, 2, buffer_u16);
	
	__FREETYPE_OUTPUT = buffer_verify(__FREETYPE_OUTPUT, tw * th * 4, buffer_grow, 1);
	buffer_clear(__FREETYPE_OUTPUT);
	freeType_setCanvas(buffer_get_address(__FREETYPE_OUTPUT), tw, th);
	freeType_Render(0, th);
	
	freeType_fontEnd();
	
	__FREETYPE_SURFACE = surface_verify(__FREETYPE_SURFACE, tw, th);
	buffer_set_surface(__FREETYPE_OUTPUT, __FREETYPE_SURFACE, 0);
	
	draw_surface(__FREETYPE_SURFACE, _x, _y);
}

function freetype_draw_start() {
	freeType_setFont(FREETYPE_FONT_PATH, FREETYPE_FONT_SIZE);
	freeType_setFontAA(FREETYPE_FONT_AA);
	freeType_setFontSpacing(FREETYPE_FONT_SPACE);
	freeType_fontStart();
}

function freetype_draw_char(_x, _y, _text) {
	freeType_setText(_text);
	
	freeType_GetTextBBox(buffer_get_address(__FREETYPE_BBOX));
	var tw = buffer_peek(__FREETYPE_BBOX, 0, buffer_u16);
	var th = buffer_peek(__FREETYPE_BBOX, 2, buffer_u16);
	
	__FREETYPE_OUTPUT = buffer_verify(__FREETYPE_OUTPUT, tw * th * 4, buffer_grow, 1);
	buffer_clear(__FREETYPE_OUTPUT);
	freeType_setCanvas(buffer_get_address(__FREETYPE_OUTPUT), tw, th);
	var _width = freeType_Render(0, th);
	
	__FREETYPE_SURFACE = surface_verify(__FREETYPE_SURFACE, tw, th);
	buffer_set_surface(__FREETYPE_OUTPUT, __FREETYPE_SURFACE, 0);
	
	draw_surface(__FREETYPE_SURFACE, _x, _y - th);
	
	return _width;
}

function freetype_draw_end() {
	freeType_fontEnd();
}