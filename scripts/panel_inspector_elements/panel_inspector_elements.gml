function Inspector_Custom_Renderer(drawFn, registerFn = noone) : widget() constructor {
	visible = true;
    node    = noone;
    panel   = noone;
    name    = "";
	padName = false;
    
    popupPanel  = noone;
    popupDialog = noone;
    
    h = 64;
    fixHeight = -1;
    
    if(registerFn != noone) register = registerFn;
    else {
        register = function(parent = noone) { 
            if(!interactable) return;
            self.parent = parent;
        }
    }
    
    b_toggle = button(function() /*=>*/ { togglePopup(name); }).setIcon(THEME.node_goto, 0, COLORS._main_icon, .75);
    
    ////- =Setters
    
    static setName    = function(n) /*=>*/ { name = n;       return self; }
    static setPadName = function( ) /*=>*/ { padName = true; return self; }
    static setNode    = function(n) /*=>*/ { node = n;       return self; }
    static toString   = function( ) /*=>*/ { return $"Custon renderer: {name}"; }
    
    static togglePopup = function(_title) { 
        if(popupPanel == noone) {
            popupPanel  = new Panel_Custom_Inspector(_title, self);
            popupDialog = dialogPanelCall(popupPanel);
            return;
        }
        
        if(instance_exists(popupDialog))
            instance_destroy(popupDialog);
            
        if(is(popupPanel, PanelContent))
            popupPanel.close();
        
        popupPanel = noone;
    }
    
    ////- =Step
    
    static step = function() {
        b_toggle.icon_blend = popupPanel == noone? COLORS._main_icon : COLORS._main_accent;
    }
    
    ////- =Draw
    
    draw = drawFn;
    
    static fetchHeight = function(params) { return drawParam(params); }
	static drawParam   = function(params) { 
		return draw(params.x, params.y, params.w, params.m, params.hover ?? hover, params.focus ?? active);
	}
    
    ////- =Actions
    
    static clone    = function() { 
        var _n = new Inspector_Custom_Renderer(draw, register);
        var _key = variable_instance_get_names(self);
        
        for( var i = 0, n = array_length(_key); i < n; i++ ) 
            _n[$ _key[i]] = self[$ _key[i]];
        
        return _n;
    }
}

function Inspector_Label(_text = "", _font = f_p3, _color = COLORS._main_text_sub, _boxColor = COLORS._main_icon_light) constructor { 
	visible  = true;
    text     = _text; 
    font     = _font; 
    color    = _color;
    boxColor = _boxColor;
    
    open = true;
}

function __inspc(_h = ui(6),  _line =  true, _coll = true, _shf = ui(2)) { return new Inspector_Spacer(_h, _line, _coll, _shf); }
function Inspector_Spacer(_h, _line = false, _coll = true, _shf = ui(2)) constructor { 
	active = true;
    h      = _h;  
    line   = _line;
    coll   = _coll;
    lshf   = _shf;
}

function Inspector_Sprite() constructor {
	type  = "Inspector_Sprite";
	data  = "";
	spr   = undefined;
	subimages = 1;
	
	static setPath = function(p) /*=>*/ { 
		if(spr != undefined && sprite_exists(spr)) 
			sprite_delete(spr);
		
		var _buff = buffer_load(p);
		var _base64_data = buffer_base64_encode(_buff, 0, buffer_get_size(_buff));
		buffer_delete(_buff);
		
		subimages = 1;
		if(string_pos("strip", p)) {
			var _spl = string_split(p, "strip");
			var _num = toNumber(array_safe_get(_spl, 1, ""));
			if(_num) subimages = _num;
		}
		
		data = $"data:image/png;base64,{_base64_data}";
		spr  = sprite_add(data, subimages);
		return self; 
	}
	
	static getSpr = function() /*=>*/ {
		if(spr != undefined) return spr;
		if(data != "") spr = sprite_add(data, subimages);
		return spr;
	}
	
	////- =Serialize

	static serialize = function() {
		return { data, subimages };
	}
	
	static deserialize = function(_m) { 
		if(!is_struct(_m)) return self;
		data      = _m[$ "data"]      ?? data;
		subimages = _m[$ "subimages"] ?? subimages;
		return self;
	}

}
