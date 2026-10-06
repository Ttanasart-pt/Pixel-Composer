/*[cpp] freeTypeRenderer
//lib brotlicommon.dll
//lib brotlidec.dll
//lib brotlienc.dll
//lib bz2.dll
//lib freetype.dll
//lib libpng16.dll
//lib z.dll
    
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_MULTIPLE_MASTERS_H
 
#include <stdlib.h>
#include <string.h>
#include <cstdint>
#include <algorithm>
#include <limits>

FT_Library ft;
FT_Face    face;
FT_MM_Var* mm_var;

char*    font; 
uint16_t font_size;
bool     font_aa;
double   letter_spacing;

char* text;

uint32_t* canvas;
uint16_t canvas_w;
uint16_t canvas_h;

// Render a single character bitmap to buffer
static void blit_glyph(uint32_t* buffer, int buf_w, int buf_h, FT_Bitmap* bitmap, int dest_x, int dest_y) {
    for (unsigned int row = 0; row < bitmap->rows; ++row) {
        int target_y = dest_y + row;
        if (target_y < 0 || target_y >= buf_h) continue;

        for (unsigned int col = 0; col < bitmap->width; ++col) {
            int target_x = dest_x + col;
            if (target_x < 0 || target_x >= buf_w) continue;

            // FreeType FT_RENDER_MODE_NORMAL produces 8-bit grayscale alpha values (0..255)
            uint32_t*     dst_pixel = &buffer[target_y * buf_w + target_x];

            unsigned char src_pixel = bitmap->buffer[row * bitmap->pitch + col];
            if(!font_aa) src_pixel = (src_pixel > 127) ? 255 : 0;

            // Additive blending
            uint32_t blended = *dst_pixel + (uint32_t)src_pixel;
            *dst_pixel = (blended > 0xFF) ? 0xFF : blended;
        }
    }
}

cfunction double freeType_setCanvas(void* _canvas, double w, double h) {
    canvas   = (uint32_t*)_canvas;
    canvas_w = (uint16_t)w;
    canvas_h = (uint16_t)h;
    return 0.;
}

    ////- Font

cfunction double freeType_setFont(void* _font, double size) { 
    font      = (char*)_font; 
    font_size = (uint16_t)size;
    return 0.;
}

cfunction double freeType_setText(void* _text)      { text = (char*)_text;  return 0.; }
cfunction double freeType_setFontAA(double aa)      { font_aa = (aa != 0.); return 0.; }
cfunction double freeType_setFontSpacing(double sp) { letter_spacing = sp;  return 0.; }

    ////- Variables
const int MAX_AXIS = 16;
FT_Fixed* var_mm     = nullptr;   // current values, 16.16
FT_Fixed* var_coords = nullptr;   // default values, 16.16

static void freeVar() {
    if (mm_var) FT_Done_MM_Var(ft, mm_var);
    mm_var = nullptr;
    free(var_coords); 
    var_coords = nullptr;
}

cfunction double freeType_Font_getVariableData() {
    freeVar();
    if(!face) return 0.;

    var_mm     = nullptr;
    var_coords = (FT_Fixed*)malloc(sizeof(FT_Fixed) * MAX_AXIS);

    if (FT_Get_MM_Var(face, &mm_var)) 
        mm_var = nullptr; 

    if (FT_Get_Var_Design_Coordinates(face, mm_var->num_axis, var_coords)) {
        free(var_coords);
        var_coords = nullptr;
    }

    return mm_var->num_axis;
}

cfunction double freeType_Font_getVariableCount() { 
    return mm_var ? (double)mm_var->num_axis : 0.; 
}

cfunction char* freeType_Font_getVariableName(double index) {
    int i = (int)index;
    if (!mm_var || i < 0 || i >= (int)mm_var->num_axis) return (char*)"";
    return mm_var->axis[i].name;
}

cfunction double freeType_Font_getVariableMin(double index) {
    int i = (int)index;
    if (!mm_var || i < 0 || i >= (int)mm_var->num_axis) return 0.;
    return mm_var->axis[i].minimum / 65536.0;
}
cfunction double freeType_Font_getVariableMax(double index) {
    int i = (int)index;
    if (!mm_var || i < 0 || i >= (int)mm_var->num_axis) return 0.;
    return mm_var->axis[i].maximum / 65536.0;
}
cfunction double freeType_Font_getVariableDef(double index) {
    int i = (int)index;
    if (!mm_var || i < 0 || i >= (int)mm_var->num_axis) return 0.;
    return mm_var->axis[i].def / 65536.0;
}

cfunction double freeType_Font_setVariable(double index, double value) {
    int i = (int)index;
    if (!mm_var || !var_coords || i < 0 || i >= (int)mm_var->num_axis) return 0.;
    var_coords[i] = (FT_Fixed)(value * 65536.0);
    return FT_Set_Var_Design_Coordinates(face, mm_var->num_axis, var_coords) ? 0. : 1.;
}

    ////- Draw util

cfunction double freeType_fontStart() {
    if (FT_Init_FreeType(&ft)) return -1.;
    if (FT_New_Face(ft, font, 0, &face)) { 
        FT_Done_FreeType(ft); 
        face = nullptr; 
        return -2.; 
    }
    
    FT_Set_Pixel_Sizes(face, 0, font_size);
    return 0.;
}

cfunction double freeType_fontEnd() {
    freeVar();                       // must happen before FT_Done_FreeType
    if (face) FT_Done_Face(face);
    face = nullptr;
    FT_Done_FreeType(ft);
    return 0.;
}

    ////- Render

cfunction double freeType_Render(double x, double y) {
    uint16_t start_x   = (uint16_t)x;
    uint16_t start_y   = (uint16_t)y;

    double pen_x = start_x;
    double pen_y = start_y;
    size_t len = strlen(text);

    for (size_t i = 0; i < len; ++i) {
        if (FT_Load_Char(face, text[i], FT_LOAD_RENDER)) continue;

        FT_GlyphSlot slot = face->glyph;

        int draw_x = pen_x + slot->bitmap_left;
        int draw_y = pen_y - slot->bitmap_top;

        blit_glyph(canvas, canvas_w, canvas_h, &slot->bitmap, draw_x, draw_y);

        pen_x += slot->advance.x >> 6;
        pen_x += letter_spacing;
        
        pen_y += slot->advance.y >> 6;
    }

    return pen_x - start_x;
}

struct bbox {
    uint16_t w;
    uint16_t h;
};

cfunction double freeType_GetTextBBox(void* _bbox) {
    bbox* b = (bbox*)_bbox;

    double pen_x = 0;
    double pen_y = 0;
    size_t len = strlen(text);

    uint16_t w = 0;
    uint16_t h = 0;

    for (size_t i = 0; i < len; ++i) {
        if (FT_Load_Char(face, text[i], FT_LOAD_RENDER)) continue;

        FT_GlyphSlot slot = face->glyph;

        int draw_x = pen_x + slot->bitmap_left;
        int draw_y = pen_y - slot->bitmap_top;

        uint16_t _w = draw_x + slot->bitmap.width;
        uint16_t _h = pen_y  + slot->bitmap.rows;

        w = std::max(w, _w);
        h = std::max(h, _h);
		
        pen_x += slot->advance.x >> 6;
        pen_x += letter_spacing;
        
        pen_y += slot->advance.y >> 6;
    }

    b->w = w;
    b->h = h;
    
    return 1.0;
}

*/