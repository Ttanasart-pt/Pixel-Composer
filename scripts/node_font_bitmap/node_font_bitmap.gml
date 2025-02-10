function Node_Font_Bitmap(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Bitmap Font";
	
	newInput(0, nodeValue_Surface("Font Surfaces", self, []))
	    .setArrayDepth(1);
	
	newInput(1, nodeValue_Text("String Map", self, "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"));
	
	newInput(2, nodeValue_Bool("Proportional", self, true));
	
	newInput(3, nodeValue_Float("Separation", self, 2));
	
	newOutput(0, nodeValue_Output("Font", self, VALUE_TYPE.font, noone));
	
	input_display_list = [ 0, 
	    ["Settings", false], 1, 2, 3 
    ];
    spr  = noone;
	font = noone;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static update = function() {
	    var _surf = getInputData(0);
	    var _str  = getInputData(1);
	    var _prop = getInputData(2);
	    var _sep  = getInputData(3);
	    
	    if(!is_array(_surf)) _surf = [ _surf ];
	    if(font_exists(font))  font_delete(font);
	    if(sprite_exists(spr)) sprite_delete(spr)
	    
	    for( var i = 0, n = array_length(_surf); i < n; i++ ) {
	        var _s = _surf[i];
	        if(!surface_exists(_s)) continue;
	        
	        var _sw  = surface_get_width(_s);
    	    var _sh  = surface_get_height(_s);
    	    
    	    if(!sprite_exists(spr))
    	        spr = sprite_create_from_surface(_s, 0, 0, _sw, _sh, false, false, 0, 0);
    	    else 
    	        sprite_add_from_surface(spr, _s, 0, 0, _sw, _sh, false, false);
	    }
	    
	    if(!sprite_exists(spr)) return;
	    font = font_add_sprite_ext(spr, _str, _prop, _sep);
	    
	    outputs[0].setValue(font);
	}
	
	static getGraphPreviewSurface = function() { return getInputData(0); }
	
}