function Panel_Custom_Data() constructor {
	name = "New Panel"
	
	minw = ui(100);
	minh = ui(100);
	
	prew = ui(600);
	preh = ui(400);
	
	w = ui(600);
	h = ui(400);
	
	auto_pin   = true;
	open_start = false;
	
	#region root
		rootData = undefined;
		
		root = new Panel_Custom_Frame();
		root.name      = "root";
		root.style     = 1;
		root.draggable = false;
		
		root.anchor_x_type = PB_AXIS_ANCHOR.bounded;
		root.anchor_y_type = PB_AXIS_ANCHOR.bounded;
		root.pbBox.anchor_w = 1; root.pbBox.anchor_w_fract = true;
		root.pbBox.anchor_h = 1; root.pbBox.anchor_h_fract = true;
	#endregion
	
	focus = false;
	hover = false;
	
	pbBox = new __pbBox();
	
	////- Draw
	
	static setSize = function(_w, _h) {
		w = _w;
		h = _h;
		return self;
	}
	
	static setFocusHover = function(_focus, _hover) {
		focus = _focus;
		hover = _hover;
		return self;
	}
	
	static draw = function(panel, _m) {
		pbBox.base_bbox = [0,0,w,h];
		root.setSize(pbBox, panel.x, panel.y);
		
		root.setFocusHover(focus, hover);
		root.draw(panel, _m);
	}
	
	////- Serialize
	
	static initRoot = function() {
		if(rootData == undefined) return;
		
		root = new Panel_Custom_Element().deserialize(rootData);
		root.draggable = false;
		root.anchor_x_type = PB_AXIS_ANCHOR.bounded;
		root.anchor_y_type = PB_AXIS_ANCHOR.bounded;
		root.pbBox.anchor_w = 1; root.pbBox.anchor_w_fract = true;
		root.pbBox.anchor_h = 1; root.pbBox.anchor_h_fract = true;
	}
	
	static serialize = function() {
		var _m = {
			name, 
			minw: minw / UI_SCALE, 
			minh: minh / UI_SCALE, 
			prew: prew / UI_SCALE, 
			preh: preh / UI_SCALE, 
			auto_pin, 
			open_start, 
		}
		
		_m.root = root.serialize();
		
		return _m;
	}
	
	static deserialize = function(_m) {
		name = _m[$ "name"] ?? name;
		minw = (_m[$ "minw"] ?? minw) * UI_SCALE;
		minh = (_m[$ "minh"] ?? minh) * UI_SCALE;
		prew = (_m[$ "prew"] ?? prew) * UI_SCALE;
		preh = (_m[$ "preh"] ?? preh) * UI_SCALE;
		auto_pin   = _m[$ "auto_pin"] ?? auto_pin;
		open_start = _m[$ "open_start"] ?? open_start;
		
		rootData = _m.root;
		initRoot();
		return self;
	}
}