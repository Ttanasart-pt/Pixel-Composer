#region data
	global.GLOBALVAR_TYPES      = [ 
		VALUE_TYPE.integer, 
		VALUE_TYPE.float, 
		VALUE_TYPE.boolean, 
		VALUE_TYPE.color, 
		VALUE_TYPE.gradient, 
		VALUE_TYPE.path, 
		VALUE_TYPE.curve, 
		VALUE_TYPE.text 
	];
	
	global.GLOBALVAR_TYPES_NAME = [ 
		"Integer", 
		"Float", 
		"Boolean", 
		"Color", 
		"Gradient", 
		"Path", 
		"Curve", 
		"Text" 
	];
	
	global.GLOBALVAR_TYPES_ENUM = undefined;
	function initGlobalvarType() {
		for( var i = 0, n = array_length(global.GLOBALVAR_TYPES_NAME); i < n; i++ ) {
			var name = global.GLOBALVAR_TYPES_NAME[i];
			var type = global.GLOBALVAR_TYPES[i];
			global.GLOBALVAR_TYPES_ENUM[i] = new scrollItem(name, THEME.node_junctions_single, type, c_white);
		}
	}
	
	global.GLOBALVAR_DISPLAY    = [
		/*Integer*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector2", "Vector3", "Vector4", "Vector range", "Vector2 range", "Area" ],
		/*Float*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector2", "Vector3", "Vector4", "Vector range", "Vector2 range", "Area" ],
		/*Boolean*/	[ "Default" ],
		/*Color*/	[ "Default", "Palette" ],
		/*Gradient*/[ "Default" ],
		/*Path*/	[ "Read", "Write" ],
		/*Curve*/	[ "Default", ],
		/*Text*/	[ "Default", ],
	];
	
	global.GLOBALVAR_DISPLAY_MAP = {}
	global.GLOBALVAR_DISPLAY_MAP[$ "Default"]        = VALUE_DISPLAY._default;
	global.GLOBALVAR_DISPLAY_MAP[$ "Range"]          = VALUE_DISPLAY.range;
	global.GLOBALVAR_DISPLAY_MAP[$ "Rotation"]       = VALUE_DISPLAY.rotation;
	global.GLOBALVAR_DISPLAY_MAP[$ "Rotation range"] = VALUE_DISPLAY.rotation_range;
	global.GLOBALVAR_DISPLAY_MAP[$ "Slider"]         = VALUE_DISPLAY.slider;
	global.GLOBALVAR_DISPLAY_MAP[$ "Slider range"]   = VALUE_DISPLAY.slider_range;
	global.GLOBALVAR_DISPLAY_MAP[$ "Padding"]        = VALUE_DISPLAY.padding;
	global.GLOBALVAR_DISPLAY_MAP[$ "Vector2"]        = VALUE_DISPLAY.vector;
	global.GLOBALVAR_DISPLAY_MAP[$ "Vector3"]        = VALUE_DISPLAY.vector;
	global.GLOBALVAR_DISPLAY_MAP[$ "Vector4"]        = VALUE_DISPLAY.vector;
	global.GLOBALVAR_DISPLAY_MAP[$ "Vector range"]   = VALUE_DISPLAY.vector_range;
	global.GLOBALVAR_DISPLAY_MAP[$ "Vector2 range"]  = VALUE_DISPLAY.vector_range;
	global.GLOBALVAR_DISPLAY_MAP[$ "Area"]           = VALUE_DISPLAY.area;
	global.GLOBALVAR_DISPLAY_MAP[$ "Palette"]        = VALUE_DISPLAY.palette;
	global.GLOBALVAR_DISPLAY_MAP[$ "Read"]           = VALUE_DISPLAY.path_load;
	global.GLOBALVAR_DISPLAY_MAP[$ "Write"]          = VALUE_DISPLAY.path_save;
	
#endregion

function nodeValue_Global(_name) { return new NodeValue_Global(_name, self ); }
function NodeValue_Global(_name, _node) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, 0) constructor {
	editor        = new variable_editor(self);
	def_serial    = true;
	defEditWidget = undefined;
	
	static getDefEditWidget = function() {
		if(defEditWidget != undefined) return defEditWidget;
		defEditWidget = getEditWidget().clone();
		defEditWidget.onModify  = function(v,i=noone) /*=>*/ {return setDefaultValue(v,i)};
		return defEditWidget;
	}
	
	static dragValue = function() /*=>*/ { DRAGGING = { type: "Globalvar", data: name }; }
}

function variable_editor(nodeVal) constructor {
	if(global.GLOBALVAR_TYPES_ENUM == undefined) initGlobalvarType();
	
	value    = nodeVal;
	tb_name  = textBox_Text(function(s) /*=>*/ {return value.node.valueRename(value, s)}).setHide(1).setSlide(false).setLabelIcon(THEME.rename);
	
	vb_range = new vectorBox(2, function(v, i) /*=>*/ { slider_range[i] = v; refreshInput(); }).setLinkable(false);
	tb_step  = textBox_Number(function(v) /*=>*/ { slider_step = v; refreshInput(); });
	sc_type  = new scrollBox(global.GLOBALVAR_TYPES_ENUM, function(v) /*=>*/ {
		sc_disp.data_list = global.GLOBALVAR_DISPLAY[v];
		type_index = v;
		disp_index = 0;
		refreshInput();
		RENDER_ALL
	}).setTextColor(CDEF.main_mdwhite).setUpdateHover(false).setIconPadding(ui(8));
	
	sc_disp  = new scrollBox(global.GLOBALVAR_DISPLAY[0], function(v) /*=>*/ {
		disp_index = v;
		refreshInput();
		RENDER_ALL
	}).setTextColor(CDEF.main_mdwhite).setUpdateHover(false).setIconPadding(ui(8));
	
	type_index = 0; _type_index = 0;
	disp_index = 0; _disp_index = 0;
	
	slider_range = [ 0, 1 ];
	slider_step  = 0.01;
	
	static setFont = function(_f) { 
		tb_name.setFont(_f);
		sc_type.setFont(_f);
		sc_disp.setFont(_f);
		vb_range.setFont(_f);
		tb_step.setFont(_f);
		return self;
	}
	
	static refreshInput = function() {
		value.setType(global.GLOBALVAR_TYPES[type_index]);
		sc_disp.data_list = global.GLOBALVAR_DISPLAY[type_index];
		
		if(_type_index != type_index || _disp_index != disp_index) {
			switch(value.type) {
				case VALUE_TYPE.integer :
				case VALUE_TYPE.float :
					switch(sc_disp.data_list[disp_index]) {
						case "Vector2" :	
						case "Range" :
						case "Vector range" :	
						case "Slider range" :	
						case "Rotation range" :	
							value.setValue( [0, 0] );
							value.def_val = [0, 0];
							break;
						
						case "Vector3" :
							value.setValue( [0, 0, 0]);
							value.def_val = [0, 0, 0];
							break;
						
						case "Vector4" :	
						case "Vector2 range" :	
						case "Padding" :
							value.setValue( [0, 0, 0, 0]);
							value.def_val = [0, 0, 0, 0];
							break;
							
						case "Area" : 
							value.setValue( [0, 0, 0, 0, 0]); 
							value.def_val = [0, 0, 0, 0, 0]; 
							break;
							
						default : 
							value.setValue( 0);
							value.def_val = 0;
					}
					break;
					
				case VALUE_TYPE.color : 
					switch(sc_disp.data_list[disp_index]) {
						case "Palette" : value.setValue([ca_black]); value.def_val = [ca_black]; break;
						default :        value.setValue( ca_black);  value.def_val =  ca_black;  break;
					}
					break;
					
				case VALUE_TYPE.gradient : 
					value.setValue( new gradientObject(ca_black));
					value.def_val = new gradientObject(ca_black);
					break;
					
				case VALUE_TYPE.boolean :  
					value.setValue( false);
					value.def_val = false;
					break;
					
				case VALUE_TYPE.text :
				case VALUE_TYPE.path :
					value.setValue( "");
					value.def_val = "";
					break;
				
				case VALUE_TYPE.curve : 
					value.setValue( CURVE_DEF_01);
					value.def_val = CURVE_DEF_01;
					break;
			}
		}
		
		_type_index = type_index;
		_disp_index = disp_index;
		var _dtype  = global.GLOBALVAR_DISPLAY_MAP[$ sc_disp.data_list[disp_index]];
		
		switch(sc_disp.data_list[disp_index]) {
			case "Slider" : 
			case "Slider range" :
				value.setDisplay(_dtype, { range: [slider_range[0], slider_range[1], slider_step] }); break;
			
			case "Read" : 
			case "Write" : 
				value.setDisplay(_dtype, { filter: "" }); break;
			
			default : value.setDisplay(_dtype); break;
		}
		
		value.resetDisplay();
		value.defEditWidget    = undefined;
		value.editWidgetSetted = true;
	}
	
	static updateType = function() {
		type_index = array_find(global.GLOBALVAR_TYPES, value.type);
		disp_index = 0;
		sc_disp.data_list = global.GLOBALVAR_DISPLAY[type_index];
		
		var _disp = value.display_type;
		var _disK = struct_find_key(global.GLOBALVAR_DISPLAY_MAP, _disp);
		if(_disK == undefined) return self;
		
		disp_index = array_find(sc_disp.data_list, _disK);
		return self;
	}
	
	static draw = function(_x, _y, _w, _m, _focus, _hover, viewMode) {
		var _h = 0;
		var _font = viewMode == INSP_VIEW_MODE.spacious? f_p0 : f_p2;
		
		var _wd_h = viewMode == INSP_VIEW_MODE.spacious? ui(32) : ui(24);
		var _pd_h = viewMode == INSP_VIEW_MODE.spacious? ui(4)  : ui(2)

		switch(sc_disp.data_list[disp_index]) {
			case "Slider" :			
			case "Slider range" :	
				if(viewMode == INSP_VIEW_MODE.compact) { _h += ui(2); _y += ui(2); }
				
				vb_range.setFocusHover(_focus, _hover);
				 tb_step.setFocusHover(_focus, _hover);
				
				vb_range.axis = [ __txt("min"), __txt("max") ];
				tb_step.label = __txt("step");
				
				var stw = _w / 3;
				var _wx = _x;
				var _ww = _w - (stw + ui(4));
				vb_range.draw(_wx, _y, _ww, _wd_h, slider_range, noone, _m);
				tb_step.draw(_x + _w - stw, _y, stw, _wd_h, slider_step , _m);
				
				_h += _wd_h + ui(2);
				_y += _wd_h + ui(2);
				break;
		}
		
		return _h;
	}
}
