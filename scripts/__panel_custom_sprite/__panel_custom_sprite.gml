function Panel_Custom_Sprite(_name = "") constructor {
	name = _name;
	
	path  = "";
	data  = "";
	spr   = undefined;
	
	visible = true;
	
	slice = sprite_nineslice_create();
	slice.enabled  = false;
	slice.left     = 0;
	slice.right    = 0;
	slice.top      = 0;
	slice.bottom   = 0;
	slice.tilemode = array_create(5, nineslice_stretch);
	
	rx = 0;
	ry = 0;
	
	////- Draw
	
	spriteTB = textBox_Text( function(t) /*=>*/ {return setPath(t)})
		.setSideButton(button(function() /*=>*/ { 
				var _path = get_open_filename_compat("Image (.png)|.png", ""); key_release();
				if(_path == "") return noone;
				setPath(_path);
			}).setIcon(THEME.button_path_icon, 0, COLORS._main_icon).setTooltip(__txt("Open Explorer") + "...")
		)
		
		.setFrontButton(button(function() /*=>*/ {
				dialogPanelCall(new Panel_Asset_Selector(function(v) /*=>*/ { if(is_string(v)) setPath(v); }), rx, ry);
			}).setIcon(THEME.panel_icon_element_image, 0, c_white).iconPad().setTooltip(__txt("Assetbox"))
		)
		
	spriteEdit     = Simple_Editor("Sprite", spriteTB, function() /*=>*/ {return path}, function(t) /*=>*/ {return setPath(t)});
	sliceEnableBox = new checkBox(function() /*=>*/ { slice.enabled = !slice.enabled; updateSpr(); });
	sliceSize      = new vectorBox(4, function(v,i) /*=>*/ { 
		switch(i) {
			case 0 : slice.left   = v; break;
			case 1 : slice.right  = v; break;
			case 2 : slice.top    = v; break;
			case 3 : slice.bottom = v; break;
		}
		updateSpr();
	});
	
	sliceMode      = new scrollBox([ "Stretch", "Repeat", "Mirror", "Blank", "Hide" ], function(i) /*=>*/ {
		slice.tilemode = array_create(5, i);	
		updateSpr();
	});
	
	static draw = function(wdx, wdy, wdw, wdh, _m, foc, hov, _rx, _ry) {
		rx = _rx + wdx;
		ry = _ry + wdy;
		
		var hh = 0;
		
		var _param = new widgetParam(wdx, wdy, wdw, wdh, path, undefined, _m, _rx, _ry).setFont(f_p3);
		spriteEdit.editWidget.setFocusHover(foc, hov);
		spriteEdit.editWidget.drawParam(_param);
		wdy += wdh + ui(2);
		hh  += wdh + ui(2);
		
		draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text_sub);
		draw_text_add(wdx - ui(8), wdy + wdh / 2, "Slice");
		
		var _param = new widgetParam(wdx, wdy, wdw, wdh, slice.enabled, undefined, _m, _rx, _ry).setFont(f_p3);
		sliceEnableBox.setFocusHover(foc, hov);
		sliceEnableBox.drawParam(_param);
		wdy += wdh + ui(2);
		hh  += wdh + ui(2);
		
		if(slice.enabled) {
			var _param = new widgetParam(wdx, wdy, wdw, wdh, [slice.left, slice.right, slice.top, slice.bottom], undefined, _m, _rx, _ry).setFont(f_p3);
			sliceSize.setFocusHover(foc, hov);
			sliceSize.drawParam(_param);
			wdy += wdh + ui(2);
			hh  += wdh + ui(2);
				
			var _param = new widgetParam(wdx, wdy, wdw, wdh, slice.tilemode[0], undefined, _m, _rx, _ry).setFont(f_p3);
			sliceMode.setFocusHover(foc, hov);
			sliceMode.drawParam(_param);
			wdy += wdh + ui(2);
			hh  += wdh + ui(2);
		}
		
		return hh - ui(2);
	}
	
	////- Get Set
	
	static setPath = function(p) /*=>*/ { 
		if(path == p) return self;
		
		if(spr != undefined && sprite_exists(spr)) 
			sprite_delete(spr);
			
		path = p; 
		data = "";
		spr  = undefined;
		return self; 
	}
	
	static getSpr = function() /*=>*/ {
		if(spr != undefined) return spr;
		
		if(data != "") {
			spr = sprite_add(data);
			updateSpr();
			return spr;
		}
		
		if(!file_exists_empty(path)) {
			path = "";
			data = "";
			return undefined;
		}
		
		var _buff = buffer_load(path);
		var _base64_data = buffer_base64_encode(_buff, 0, buffer_get_size(_buff));
		buffer_delete(_buff);
		
		data = $"data:image/png;base64,{_base64_data}";
		spr  = sprite_add(data);
		updateSpr();
		
		return spr;
	}
	
	static updateSpr = function() /*=>*/ {
		if(!sprite_exists(spr)) return;
		sprite_set_nineslice(spr, slice);
	}
	
	////- Serialize
	
	static serialize = function() {
		return { path, data, slice };
	}
	
	static deserialize = function(_m) { 
		if(!is_struct(_m)) return self;
		path  = _m.path;
		data  = _m.data;
		
		if(has(_m, "slice")) {
			var sli = _m.slice;
			slice.enabled  = sli.enabled;
			slice.left     = sli.left;
			slice.right    = sli.right;
			slice.top      = sli.top;
			slice.bottom   = sli.bottom;
			slice.tilemode = sli.tilemode;
		}
		
		
		return self;
	}
}