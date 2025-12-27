globalvar DYNADRAW_FOLDER, DYNADRAW_DEFAULT;

function __init_dynaDraw() {
    DYNADRAW_DEFAULT = new dynaDraw_circle_fill();
    DYNADRAW_FOLDER  = new DirectoryObject("DynaDraw");
    DYNADRAW_FOLDER.icon       = THEME.dynadraw;
    DYNADRAW_FOLDER.icon_blend = c_white;
    
    var _d = function(a) /*=>*/ {return array_push(DYNADRAW_FOLDER.content, a)};
    _d(new dynaDraw_canvas());
    _d(new dynaDraw_line());
    
    _d(new dynaDraw_circle_fill());
    _d(new dynaDraw_circle_fill_gradient());
    _d(new dynaDraw_circle_outline());
    _d(new dynaDraw_pie_fill());
    _d(new dynaDraw_pie_outline());
    
    _d(new dynaDraw_square_fill());
    _d(new dynaDraw_square_fill_gradient());
    _d(new dynaDraw_square_outline());
    
    _d(new dynaDraw_polygon_fill());
    _d(new dynaDraw_polygon_fill_gradient());
    _d(new dynaDraw_polygon_outline());
    _d(new dynaDraw_star_fill());
    _d(new dynaDraw_star_fill_gradient());
    _d(new dynaDraw_star_outline());
    _d(new dynaDraw_cube_fill());
    _d(new dynaDraw_cube_outline());
    
    _d(new dynaDraw_leaf_fill());
    _d(new dynaDraw_cross());
    _d(new dynaDraw_spiral());
    
}

function dynaDraw() : dynaSurf() constructor {
	node    = noone;
	editors = [];
	
	static getWidth  = function() /*=>*/ {return 0};
	static getHeight = function() /*=>*/ {return 0};
	static getFormat = function() /*=>*/ {return surface_rgba8unorm};

	static updateNode = function() {
	    if(node == noone) return;
	    node.clearCache();
	    node.triggerRender();
	}
	
	static doSerialize = function(m) {}
	static serialize   = function()  { 
	    var _m  = {};
	    _m.type = instanceof(self);
	    doSerialize(_m);
	    
	    return _m;
	}
	
	static deserialize = function(m) { 
	    var _c = asset_get_index(m.type);
	    return _c == -1? noone : new _c().deserialize(m);
	}
	
	static clone = function() /*=>*/ {return variable_clone(self)};
}