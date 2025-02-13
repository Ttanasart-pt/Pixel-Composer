globalvar DYNADRAW_SHAPE_MAP, DYNADRAW_SHAPES, DYNADRAW_FOLDER;

function __init_dynaDraw() {
    DYNADRAW_SHAPE_MAP = {};
    DYNADRAW_SHAPES    = [
        new dynaDraw_circle_fill(), 
        new dynaDraw_circle_outline(), 
        new dynaDraw_square_fill(), 
        new dynaDraw_square_outline(), 
    ];
    
    DYNADRAW_FOLDER = new DirectoryObject("DynaDraw");
    
    for( var i = 0, n = array_length(DYNADRAW_SHAPES); i < n; i++ ) {
        var _sh = DYNADRAW_SHAPES[i];
        
        ds_list_add(DYNADRAW_FOLDER.content, _sh);
        DYNADRAW_SHAPE_MAP[$ _sh.path] = _sh;
    }
}