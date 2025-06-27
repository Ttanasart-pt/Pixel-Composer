function nodeValue(_name, _node, _connect, _type, _value, _tooltip = "") { return new NodeValue(_name, _node, _connect, _type, _value, _tooltip); }

function nodeValueSeed(_type = VALUE_TYPE.float, _name = "Seed") { 
	var _val  = new NodeValue(_name, self, CONNECT_TYPE.input, _type, seed_random(6), "");
	var _rFun = function() /*=>*/ { randomize(); setValue(seed_random(6)); };
	    _rFun = method(_val, _rFun);
	
	_val.setDisplay(VALUE_DISPLAY._default, { side_button : button(_rFun).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	return _val; 
}

function NodeValue(_name, _node, _connect, _type, _value, _tooltip = "") constructor {
	
	static DISPLAY_DATA_KEYS = [ "atlas_crop" ];
	
	#region ---- Main ----
		active = true;
		from   = noone;
		name   = _name;
		node   = _node;
		tags   = VALUE_TAG.none; static setTags = function(t) /*=>*/ { tags = t; return self; }
		
		x	= node.x; rx  = node.x; 
		y   = node.y; ry  = node.y;
		
		index       = array_length(_connect == CONNECT_TYPE.input? node.inputs : node.outputs);
		lIndex      = index;
		type        = _type;
		forward     = true;
		_initName   = _name;
		name_custom = false;
		
		editWidget     = noone;
		editWidgetRaw  = noone;
		editWidgetMap  = {};
		editable       = true;
		
		graphWidget    = noone;
		graphWidgetH   = 0;
		graphWidgetP   = new widgetParam(0, 0, 0, 0, 0);
		mapWidget      = noone;
		active_tooltip = "";
		
		is_dummy       = false;
		ghost_hover    = noone;
		dummy_get      = noone;
		dummy_undo     = -1;
		dummy_redo     = -1;
		
		instanceBase   = noone;
	#endregion
	
	#region ---- Tooltip ----
		tooltip     = _tooltip;
		tooltipData = {};
		
		var _inode = instanceof(node);
		if(struct_has_ext(LOCALE_NOTE_JUNC, _inode, _initName)) {
			var _dat = LOCALE_NOTE_JUNC[$ _inode][$ _initName];
			
			if(struct_has(LOCALE_NOTE_DATA, _dat.note)) {
				tooltipData.title   = filename_name_only(_dat.note);
				tooltipData.content = LOCALE_NOTE_DATA[$ _dat.note];
				tooltip = function() /*=>*/ {return dialogPanelCall(new Panel_Note_Md(tooltipData))};
			}
		}
	#endregion
	
	#region ---- Connection ----
		connect_type      = _connect;
		value_from        = noone;
		value_from_loop   = noone;
		
		value_to          = [];
		value_to_loop     = [];
		
		accept_array      = true;
		array_depth       = 0;
		auto_connect      = true;
		setFrom_condition = -1;
		
		onSetFrom = noone;
		onSetTo   = noone;
	#endregion
	
	#region ---- Value ----
		static setDefValue = function(_value) {
			def_val    = array_clone(_value);
			
			sepable    = is_array(_value) && array_length(_value) > 1;
			animVector = array_safe_length(_value, -1);
			animator   = new valueAnimator(_value, self, false);
			animators  = animVector? array_create_ext(animVector, function(i) /*=>*/ {return new valueAnimator(def_val[i], self, true).setIndex(i)}) : [];
		}
		
		is_anim		= false;
		sep_axis	= false;
		animable    = true;
		key_inter   = CURVE_TYPE.linear;
		on_end		= KEYFRAME_END.hold;
		loop_range  = -1;
		
		setDefValue(_value);
		def_length    = is_array(def_val)? array_length(def_val) : 0;
		def_depth     = array_get_depth(def_val);
		unit		  = new nodeValueUnit(self);
		def_unit      = VALUE_UNIT.constant;
		
		is_modified   = false;
		cache_value   = [ false, false, undefined, undefined ];
		cache_array   = [ false, false ];
		use_cache     = true;
		record_value  = true;
		
		process_array = true;
		dynamic_array = false;
		validateValue = true;
		runInUI       = false;
		
		fullUpdate    = false;
		attributes    = {};
		
		__curr_get_val = [ 0, 0 ];
		validator      = noone;
		
		bypass_junc    = connect_type == CONNECT_TYPE.input? new __NodeValue_Input_Bypass(self, name, node, type) : noone;
	#endregion
	
	#region ---- Draw ----
		draw_line_shift_x = 0;
		draw_line_shift_y = 0;
		draw_line_shift_e = -1;
		
		draw_line_thick		  = 1;
		draw_line_shift_hover = false;
		draw_line_blend       = 1;
		draw_line_feed		  = false;
		drawLineIndex		  = 1;
		drawLineIndexRaw	  = 1;
		draw_line_vb		  = noone;
		draw_junction_index   = type;
		
		junction_drawing = [ THEME.node_junctions_single, type ];
		hover_in_graph   = false;
		
		drag_type = 0;
		drag_mx   = 0;
		drag_my   = 0;
		drag_sx   = 0;
		drag_sy   = 0;
		drag_rx   = 0;
		drag_ry   = 0;
		
		color = -1;
		color_display = 0;
		
		draw_bg = c_black;
		draw_fg = c_black;
		
		draw_blend       = 1;
		draw_blend_color = 1;
		
		__overlay_hover     = [];
		overlay_draw_text   = true;
		overlay_text_valign = fa_top;
		
		graph_selecting   = false;
		
		custom_icon  = noone;
		custom_color = noone;
	#endregion
	
	#region ---- Inspector ----
		visible = _connect == CONNECT_TYPE.output || _type == VALUE_TYPE.surface || _type == VALUE_TYPE.path || _type == VALUE_TYPE.PCXnode;
		visible_manual    = 0;
		show_in_inspector = true;
		visible_in_list   = true;
		
		display_type = VALUE_DISPLAY._default;
		if(_type == VALUE_TYPE.curve)			display_type = VALUE_DISPLAY.curve;
		else if(_type == VALUE_TYPE.d3vertex)	display_type = VALUE_DISPLAY.d3vertex;
		
		display_data		= {};
		display_attribute	= noone;
		
		popup_dialog = noone;
		type_array   = typeArray(self);
	#endregion
	
	#region ---- Graph ----
		show_graph	= false;
		show_graphs = array_create(array_safe_length(_value));
		graph_h		= 96;
		graph_range = [ 0, 1 ];
		
		value_validation   = VALIDATION.pass;
		error_notification = noone;
		
		extract_node = "";
	#endregion
	
	#region ---- Expression ----
		expUse     = false;
		expression = "";
		expTree    = noone;
		expContext = { 
			name: name,
			node_name: node.display_name,
			value: 0,
			node_values: node.input_value_map,
		};
		
		express_edit = new textArea(TEXTBOX_INPUT.text, function(str) { 
			expression = str;
			expressionUpdate();
		});
		express_edit.autocomplete_server	= pxl_autocomplete_server;
		express_edit.autocomplete_context	= expContext;
		express_edit.function_guide_server	= pxl_function_guide_server;
		express_edit.parser_server			= pxl_document_parser;
		express_edit.format   = TEXT_AREA_FORMAT.codeLUA;
		express_edit.font     = f_code;
		express_edit.boxColor = COLORS._main_value_positive;
		express_edit.align    = fa_left;
	#endregion
	
	#region ---- Serialization ----
		con_node  = -1;
		con_index = -1;
		con_tag   =  0;
	#endregion
	
	#region ---- Init Fn ----
		static setIndex = function(_index) {
			index  = _index;
			lIndex = _index;
			
			if(_index < 0) {
				setVisible(true, true);
				return self;
			}
			
			if(connect_type == CONNECT_TYPE.input) {
				bypass_junc.setIndex(index);
				node.input_bypass[index] = bypass_junc;
				node.inputs_data[index]  = def_val;
				
				if(node.is_dynamic_input) lIndex = (lIndex - node.input_fix_len) % node.data_length;
			}
		}
		
		static setInternalName = function(_iname) {
			internalName = string_to_var(_iname);
			
			if(is(node, Node)) {
					 if(connect_type == CONNECT_TYPE.input)  node.inputMap[$ internalName]  = self;
				else if(connect_type == CONNECT_TYPE.output) node.outputMap[$ internalName] = self;
			}
			
			return self;
		}
		
		static updateName = function(_name, _custom = true) {
			name          = _name;
			name_custom  = name_custom || _custom;
			
			setInternalName(name);
			return self;
		} 
		
		updateName(_name, false);
		
		if(connect_type == CONNECT_TYPE.input)
			node.input_value_map[$ internalName] = _value;
	#endregion
	
	////- META
	
	static setDummy = function(get_node, _dummy_undo = -1, _dummy_redo = -1) {
		is_dummy  = true;
		dummy_get = get_node;
		
		dummy_undo = _dummy_undo;
		dummy_redo = _dummy_redo;
		
		return self;
	}
	
	static setActive = function(_active, _tooltip) {
		INLINE
		active = _active;
		active_tooltip = _tooltip;
		
		return self;
	}
	
	static setWindows = function() {
		INLINE
		setActive(OS == os_windows, "Not available on MacOS");
		
		return self;
	}
	
	static setTooltip = function(_tip) { tooltip = _tip; return self; }
	
	static setIcon = function(_ico, _colr) { custom_icon = _ico; custom_color = _colr; return self; }
	
	static nonValidate = function() {
		validateValue = false;
		return self;
	}
	
	static nonForward = function() {
		forward = false;
		return self;
	}
	
	////- NAME
	
	static getName = function() /*=>*/ {return name_custom? name : __txt_junction_name(instanceof(node), connect_type, lIndex, name)};
	
	static setName = function(_name) /*=>*/ { name = _name; return self; }
	
	////- VALUE
	
	static setType = function(_type) {
		if(type == _type) return false;
		
		type = _type;
		draw_junction_index = type;
		updateColor();
		
		if(bypass_junc) bypass_junc.setType(_type);
		
		return true;
	}
	
	static setDefault = function(vals) {
		if(LOADING || APPENDING) return self;
		
		animator.values = [];
		for( var i = 0, n = array_length(vals); i < n; i++ )
			array_push(animator.values, new valueKey(vals[i][0], vals[i][1], animator));
			
		return self;
	}
	
	static resetValue = function() {
		
		unit.mode = def_unit;
		setValue(unit.apply(variable_clone(def_val))); 
		attributes.mapped = false;
	}
	
	static setUnitRef = function(ref, mode = VALUE_UNIT.constant) {
		express_edit.side_button = unit.triggerButton;
		display_data.onSurfaceSize = ref;
		
		if(editWidget) {
			editWidget.unit = unit;
			editWidget.onSurfaceSize = ref;
		}
		
		unit.reference  = ref;
		unit.mode		= mode;
		def_unit        = mode;
		cache_value[0]  = false;
		
		return self;
	}
	
	static setValidator = function(val) {
		validator = val;
		
		return self;
	}
	
	static rejectArray     = function()       { accept_array = false; return self; } 
	static setArrayDepth   = function(aDepth) { array_depth = aDepth; return self; }
	static setArrayDynamic = function()       { dynamic_array = true; return self; }
	
	static rejectArrayProcess = function() {
		process_array = false;
		return self;
	}
	
	static setDropKey = function() {
		switch(type) {
			case VALUE_TYPE.integer		: drop_key = "Number"; break;
			case VALUE_TYPE.float		: drop_key = "Number"; break;
			case VALUE_TYPE.boolean		: drop_key = "Bool";   break;
			case VALUE_TYPE.color		: 
				switch(display_type) {
					case VALUE_DISPLAY.palette :  drop_key = "Palette";  break;
					default : drop_key = "Color";
				}
				break;
			case VALUE_TYPE.gradient    : drop_key = "Gradient"; break;
			case VALUE_TYPE.path		: drop_key = "Asset";  break;
			case VALUE_TYPE.text		: drop_key = "Text";   break;
			case VALUE_TYPE.pathnode	: drop_key = "Path";   break;
			case VALUE_TYPE.struct   	: drop_key = "Struct"; break;
			
			default: 
				drop_key = "None";
		}
	} setDropKey();
	
	mapWidget   = noone;
	mappedJunc  = noone;
	mapped_vec4 = false;
	
	static setMappable = function(_index, _vec4 = false) {
		with(node) {
			var vmap = new NodeValue($"{other.name} Map", self, CONNECT_TYPE.input, VALUE_TYPE.surface, noone)
				.setVisible(false, false)
				.setMapped(other);
			newInput(_index + 0, vmap);
			
			if(other.type != VALUE_TYPE.gradient) break;
			
			var vmap = new NodeValue($"{other.name} Map Range", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 1, 0 ])
				.setDisplay(VALUE_DISPLAY.gradient_range)
				.setVisible(false, false)
				.setMapped(other);
			newInput(_index + 1, vmap);
		}
		
		attributes.mapped     = false;
		attributes.map_index  = _index;
		mapped_vec4           = _vec4;
		
		array_push(node.inputMappable, self);
		
		if(arrayLength == arrayLengthSimple) arrayLength = __arrayLength;
		
		mapButton = button(function() { 
						attributes.mapped = !attributes.mapped;
						
						if(type == VALUE_TYPE.integer || type == VALUE_TYPE.float) {
							if(attributes.mapped) setValue(mapped_vec4? [ 0, 0, 0, 0 ] : [ 0, 0 ]);
							else                  setValue(def_val);
							setArrayDepth(attributes.mapped);
						}
						
						node.triggerRender(); 
					})
				.setIcon( THEME.mappable_parameter, [ function() /*=>*/ {return attributes.mapped} ], COLORS._main_icon )
				.setTooltip("Toggle map");
		
		if(type != VALUE_TYPE.gradient) {
			mapWidget = _vec4? new vectorRangeBox(4, TEXTBOX_INPUT.number, function(v,i) /*=>*/ {return setValueDirect(v,i)}).setSideButton(mapButton) : 
			                   new rangeBox(function(v,i) /*=>*/ {return setValueDirect(v,i)}).setSideButton(mapButton);
		}
		
		editWidget.setSideButton(mapButton);
		
		return self;
	}
	
	static setMapped = function(junc) {
		mappedJunc = junc;
		isTimelineVisible = function() { INLINE return is_anim && value_from == noone && mappedJunc.attributes.mapped; }
		return self;
	}
	
	static mappableStep = function() {
		editWidget = mapWidget && attributes.mapped? mapWidget : editWidgetRaw;
		setArrayDepth(attributes.mapped);
		
		var inp = node.inputs[attributes.map_index];
		var vis = attributes.mapped && show_in_inspector;
		
		if(inp.visible != vis) {
			inp.visible = vis;
			node.refreshNodeDisplay();
		}
	}
	
	static setShaderProp = function(key) { node.shaderProp[$ key] = self; return self; }
	
	////- ANIMATION
	
	static setAnimable = function(_anim) { animable = _anim; return self; }
	
	static isAnimable = function() {
		if(instanceBase != noone) return instanceBase.isAnimable();
		
		if(type == VALUE_TYPE.PCXnode)				 return false;
		if(display_type == VALUE_DISPLAY.text_array) return false;
		return animable;
	}
	
	static setAnim = function(anim, record = false) {
		if(is_anim == anim) return;
		is_modified = true;
		
		if(record) recordAction_variable_change(self, "is_anim", is_anim, $"{name} animation status").setRef(node);
		is_anim = anim;
		
		if(is_anim) {
			if(array_empty(animator.values))
				array_push(animator.values, new valueKey(CURRENT_FRAME, animator.getValue(), animator));
			animator.values[0].time = CURRENT_FRAME;
			animator.updateKeyMap();
			
			for( var i = 0, n = array_length(animators); i < n; i++ ) {
				if(array_length(animators[i].values))
					array_push(animators[i].values, new valueKey(CURRENT_FRAME, animators[i].getValue(), animators[i]));
				animators[i].values[0].time = CURRENT_FRAME;
				animators[i].updateKeyMap();
			}
		} else {
			var _val = animator.getValue();
			animator.values = [];
			animator.values[0] = new valueKey(0, _val, animator);
			animator.updateKeyMap();
			
			for( var i = 0, n = array_length(animators); i < n; i++ ) {
				var _val = animators[i].getValue();
				animators[i].values = [];
				animators[i].values[0] = new valueKey(0, _val, animators[i]);
				animators[i].updateKeyMap();
			}
		}
		
		if(type == VALUE_TYPE.gradient && struct_has(attributes, "map_index")) 
			node.inputs[attributes.map_index + 1].setAnim(anim);
		
		node.refreshTimeline();
		if(NOT_LOAD && node.group) node.group.checkPureFunction();
	}
	
	static getAnim = function() { return instanceBase != noone? instanceBase.is_anim : is_anim; }
		
	////- DISPLAY
	
	static setVisibleManual = function(v) {
		visible_manual = v;
		node.toRefreshNodeDisplay = true;
		return self;
	}
	
	static setVisible = function(inspector) {
		var v    = visible;
		var _ref = false;
		
		if(connect_type == CONNECT_TYPE.input) {
			show_in_inspector = inspector;
			visible = argument_count > 1? argument[1] : visible;
			
		} else {
			visible = inspector;
		}
		
		if(v != visible && NOT_LOAD)
			node.toRefreshNodeDisplay = true;
		
		return self;
	}
	
	static forceVisible = function(_vis) {
		visible           = _vis;
		show_in_inspector = _vis;
		visible_manual    = 0;
		return self;
	}
	
	static isVisible = function() { 
		if(!node.active) return false;
		
		if(connect_type == CONNECT_TYPE.output) {
			if(!array_empty(value_to)) return true;
			if(visible_manual != 0)    return visible_manual == 1;
			
			return visible;
		}
		
		if(value_from)           return true;
		if(visible_manual != 0)  return visible_manual == 1;
		if(!visible)        	 return false;
		if(index == -1)          return true;
		
		return visible_in_list;
	}
	
	static setDisplay = function(_type = VALUE_DISPLAY._default, _data = {}) {
		display_type = _type;
		display_data = _data;
		type_array   = typeArray(self);
		resetDisplay();
		
		return self;
	}
	
	static resetDisplay = function() {
		
		editWidget = noone;
		switch(display_type) {
			case VALUE_DISPLAY.button :
				var _onClick = struct_has(display_data, "onClick")? method(node, display_data.onClick) : function() /*=>*/ { setAnim(true, true); setValueDirect(true); };
				
				editWidget   = button(_onClick).setText(struct_try_get(display_data, "name", "Trigger"));
				runInUI      = struct_try_get(display_data, "UI", false);
				
				visible = false;
				rejectArray();
				
				return;
		}
		
		switch(type) {
			case VALUE_TYPE.float :
			case VALUE_TYPE.integer :
				var _txt = TEXTBOX_INPUT.number;
				
				switch(display_type) { 
					case VALUE_DISPLAY._default :	
						editWidget = new textBox(_txt, function(val) /*=>*/ {return setValueInspector(val)});
						
						if(struct_has(display_data, "unit"))		 editWidget.unit			= display_data.unit;
						if(struct_has(display_data, "front_button")) editWidget.front_button	= display_data.front_button;
						
						extract_node = "Node_Number";
						break;
						
					case VALUE_DISPLAY.range :		
						editWidget = new rangeBox(function(val, i) /*=>*/ {return setValueInspector(val, i)});
						
						if(!struct_has(display_data, "linked")) display_data.linked = false;
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get_fast(global.displaySuffix_Range, i);
						
						extract_node = "Node_Number";
						break;
						
					case VALUE_DISPLAY.vector :		
						var val = animator.getValue();
						var len = array_length(val);
						
						if(len <= 4) {
							editWidget = new vectorBox(len, function(val, i) /*=>*/ {return setValueInspector(val, i)}, unit );
							
							if(struct_has(display_data, "label"))		 editWidget.axis	    = display_data.label;
							if(struct_has(display_data, "linkable"))	 editWidget.linkable    = display_data.linkable;
							if(struct_has(display_data, "per_line"))	 editWidget.per_line    = display_data.per_line;
							if(struct_has(display_data, "linked"))		 editWidget.linked      = display_data.linked;
							
							switch(len) {
								case 2 : extract_node = [ "Node_Vector2", "Node_Path" ]; break;
								case 3 : extract_node = "Node_Vector3";                  break;
								case 4 : extract_node = "Node_Vector4";                  break;
							}
						}
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {array_safe_get_fast(global.displaySuffix_Axis, i)}";
						
						break;
						
					case VALUE_DISPLAY.vector_range :
						var val = animator.getValue();
						
						editWidget = new vectorRangeBox(array_length(val), _txt, function(val, i) /*=>*/ {return setValueInspector(val, i)}, unit );
						
						if(!struct_has(display_data, "linked")) display_data.linked = false;
						if(!struct_has(display_data, "ranged")) display_data.ranged = false;
						
							 if(array_length(val) == 2) extract_node = "Node_Vector2";
						else if(array_length(val) == 3) extract_node = "Node_Vector3";
						else if(array_length(val) == 4) extract_node = "Node_Vector4";
							
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {array_safe_get_fast(global.displaySuffix_VecRange, i)}";
						
						break;
						
					case VALUE_DISPLAY.rotation :	
						var _step = struct_try_get(display_data, "step", -1); 
						
						editWidget   = new rotator(function(val) /*=>*/ {return setValueInspector(val)}, _step);
						
						extract_node = "Node_Number";
						break;
						
					case VALUE_DISPLAY.rotation_range :
						editWidget = new rotatorRange(function(val, i) /*=>*/ {return setValueInspector(val, i)});
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {array_safe_get_fast(global.displaySuffix_Range, i)}";
						
						extract_node = "Node_Rotation_Range_Data";
						break;
						
					case VALUE_DISPLAY.rotation_random :
						editWidget = new rotatorRandom(function(val, i) /*=>*/ {return setValueInspector(val, i)});
						
						extract_node = "Node_Rotation_Random_Data";
						break;
						
					case VALUE_DISPLAY.slider :		
						var _range = struct_try_get(display_data, "range", [0,1,.01]);
						var _rstep = array_safe_get(_range, 2, .01);
						
						editWidget = new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ {return setValueInspector(toNumber(val))})
										.setSlideRange( _range[0], _range[1] )
										.setSlideStep(  _rstep );
						
						if(struct_has(display_data, "update_stat"))
							editWidget.update_stat = display_data.update_stat;
						
						extract_node = "Node_Number";
						break;
						
					case VALUE_DISPLAY.slider_range :
						var _range = struct_try_get(display_data, "range", [0,1,.01]);
						var _rstep = array_safe_get(_range, 2, .01);
						
						editWidget = new sliderRange(_rstep, type == VALUE_TYPE.integer, [ _range[0], _range[1] ], function(val, i) /*=>*/ {return setValueInspector(val, i)});
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {array_safe_get_fast(global.displaySuffix_Range, i)}";
						
						extract_node = "Node_Vector2";
						break;
						
					case VALUE_DISPLAY.area :		
						editWidget = new areaBox(function(val, i) /*=>*/ {return setValueInspector(val, i)}, unit);
						
						editWidget.onSurfaceSize = struct_try_get(display_data, "onSurfaceSize", noone);
						editWidget.showShape     = struct_try_get(display_data, "useShape", true);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {array_safe_get_fast(global.displaySuffix_Area, i, "")}";
						
						extract_node = "Node_Area";
						break;
						
					case VALUE_DISPLAY.padding :	
						editWidget = new paddingBox(function(val, i) /*=>*/ {return setValueInspector(val, i)}, unit);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {array_safe_get_fast(global.displaySuffix_Padding, i)}";
						
						extract_node = "Node_Padding";
						break;
						
					case VALUE_DISPLAY.corner :		
						editWidget = new cornerBox(function(val, i) /*=>*/ {return setValueInspector(val, i)}, unit);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {array_safe_get_fast(global.displaySuffix_Padding, i)}";
						
						extract_node = "Node_Corner";
						break;
						
					case VALUE_DISPLAY.puppet_control :
						editWidget = new controlPointBox(function(val, i) /*=>*/ {return setValueInspector(val, i)});
						
						extract_node = "";
						break;
						
					case VALUE_DISPLAY.enum_scroll :
						if(!is_struct(display_data)) display_data = { data: display_data };
						var choices = __txt_junction_data(instanceof(node), connect_type, index, display_data.data);
						
						editWidget = new scrollBox(choices, function(val) /*=>*/ { return val == -1? undefined : setValueInspector(toNumber(val)); } );
						
						if(struct_has(display_data, "update_hover")) editWidget.update_hover = display_data.update_hover;
						if(struct_has(display_data, "horizontal"))   editWidget.horizontal   = display_data.horizontal;
						if(struct_has(display_data, "item_pad"))     editWidget.item_pad     = display_data.item_pad;
						if(struct_has(display_data, "text_pad"))     editWidget.text_pad     = display_data.text_pad;
						if(struct_has(display_data, "show_icon"))    editWidget.show_icon    = display_data.show_icon;
						
						rejectConnect();
						key_inter    = CURVE_TYPE.cut;
						extract_node = "";
						break;
						
					case VALUE_DISPLAY.enum_button :
						if(!is_struct(display_data)) display_data = { data: display_data };
						var choices = __txt_junction_data(instanceof(node), connect_type, index, display_data.data);
						
						editWidget = new buttonGroup(choices, function(val) /*=>*/ {return setValueInspector(val)});
						
						rejectConnect();
						key_inter    = CURVE_TYPE.cut;
						extract_node = "";
						break;
						
					case VALUE_DISPLAY.matrix :		
						editWidget = new matrixGrid(_txt, function(val, i) /*=>*/ {return setValueInspector(val, i)}, unit );
						if(struct_has(display_data, "size")) editWidget.setSize(display_data.size);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {i}";
						
						extract_node = "";
						break;
						
					case VALUE_DISPLAY.boolean_grid :
						editWidget = new matrixGrid(_txt, function(val, i) /*=>*/ {return setValueInspector(val, i)}, unit );
						if(struct_has(display_data, "size")) editWidget.setSize(display_data.size);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {i}";
						
						extract_node = "";
						break;
						
					case VALUE_DISPLAY.transform :	
						editWidget = new transformBox(function(val, i) /*=>*/ {return setValueInspector(val, i)});
						
						extract_node = "Node_Transform_Array";
						break;
						
					case VALUE_DISPLAY.toggle :		
						editWidget = new toggleGroup(display_data.data, function(val) /*=>*/ {return setValueInspector(val)});
						
						rejectConnect();
						key_inter    = CURVE_TYPE.cut;
						extract_node = "";
						break;
						
					case VALUE_DISPLAY.d3quarternion :
						editWidget = new quarternionBox(function(val, i) /*=>*/ {return setValueInspector(val, i)});
						
						extract_node = "Node_Vector4";
						attributes.angle_display = QUARTERNION_DISPLAY.euler;
						break;
						
					case VALUE_DISPLAY.path_anchor :
						editWidget = new pathAnchorBox(function(val, i) /*=>*/ {return setValueInspector(val, i)});
						extract_node = "Node_Path_Anchor";
						break;
						
					case VALUE_DISPLAY.number_array :
						editWidget = new numberArrayBox(function(val) /*=>*/ {return setValueInspector(val)});
						extract_node = "Node_Number";
						break;
						
				}
				
				if(editWidget && struct_has(editWidget, "setSlideType")) editWidget.setSlideType(type == VALUE_TYPE.integer);
				break;
				
			case VALUE_TYPE.boolean :	
				if(name == "Active") editWidget = new checkBoxActive(function() /*=>*/ {return setValueInspector(!animator.getValue())} );
				else				 editWidget = new checkBox(      function() /*=>*/ {return setValueInspector(!animator.getValue())} );
				
				key_inter    = CURVE_TYPE.cut;
				extract_node = "Node_Boolean";
				break;
				
			case VALUE_TYPE.color :		
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget   = new buttonColor(function(_color) /*=>*/ {return setValueInspector(_color)});
						extract_node = "Node_Color";
						break;
						
					case VALUE_DISPLAY.palette :
						editWidget   = new buttonPalette(function(_color) /*=>*/ {return setValueInspector(_color)});
						extract_node = "Node_Palette";
						break;
				}
				break;
				
			case VALUE_TYPE.gradient :	
				editWidget   = new buttonGradient(function(gradient) /*=>*/ {return setValueInspector(gradient)});
				extract_node = "Node_Gradient_Out";
				break;
				
			case VALUE_TYPE.path :		
				switch(display_type) {
					case VALUE_DISPLAY.path_array :
						editWidget = new pathArrayBox(self, display_data.filter, function(path) /*=>*/ {return setValueInspector(path)});
						break;
						
					case VALUE_DISPLAY.path_load :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { if(NOT_LOAD) check_directory_redirector(str); setValueInspector(str); });
						editWidget.align = fa_left;
						if(!is(node, Node_Global)) array_append(node.project.pathInputs, self);
						
						editWidget.side_button = button(function() /*=>*/ { 
							var path = display_data.filter == "dir"? get_directory(PREFERENCES.dialog_path) : get_open_filename_compat(display_data.filter, "");
							key_release();
							if(path == "") return noone;
							
							if(NOT_LOAD) check_directory_redirector(path);
							return setValueInspector(path);
						}).setIcon(THEME.button_path_icon, 0, COLORS._main_icon).setTooltip(__txt("Open Explorer..."));
						
						editWidget.front_button = button(function() /*=>*/ { 
							if(node.project.path == "") { noti_warning("Save the current project first."); return; }
							
							var _pth = getValue();
							if(!file_exists(_pth)) return;
							
							var _nam = filename_name(_pth);
							var _dir = filename_dir(node.project.path);
							
							var _newpath = _dir + "/" + _nam;
							file_copy(_pth, _newpath);
							setValue("./" + _nam);
							
						}).setIcon(THEME.copy_20, 0, COLORS._main_icon).setTooltip(__txt("Copy to Project"));
						
						extract_node = "Node_String";
						break;
						
					case VALUE_DISPLAY.path_save :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ {return setValueInspector(str)});
						
						editWidget.align = fa_left;
						editWidget.side_button = button(function() { 
							var path = display_data.filter == "dir"? get_directory(PREFERENCES.dialog_path) : get_save_filename_compat(display_data.filter, "");
							key_release();
							
							if(path == "") return noone;
							return setValueInspector(path);
						}).setIcon(THEME.button_path_icon, 0, COLORS._main_icon).setTooltip(__txt("Open Explorer..."));
						
						editWidget.front_button = button(function() { 
							var project = PROJECT;
							if(project.path == "") {
								noti_warning("Save the current project first.")
								return;
							}
							
							var _pth = getValue();
							var _nam = filename_name(_pth);
							var _dir = filename_dir(project.path);
							setValue("./" + _nam);
							
						}).setIcon(THEME.copy_20, 0, COLORS._main_icon).setTooltip(__txt("Make Relative"));
						
						extract_node = "Node_String";
						break;
						
					default :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ {return setValueInspector(str)});
						break;
				}
				break;
				
			case VALUE_TYPE.curve :		
				display_type = VALUE_DISPLAY.curve;
				editWidget  = new curveBox(function(_modified) /*=>*/ {return setValueInspector(_modified)});
				break;
				
			case VALUE_TYPE.text :		
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget   = new textArea(TEXTBOX_INPUT.text, function(str) /*=>*/ {return setValueInspector(str)});
						break;
						
					case VALUE_DISPLAY.text_box :
						editWidget   = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ {return setValueInspector(str)});
						break;
					
					case VALUE_DISPLAY.codeLUA :
						editWidget   = new textArea(TEXTBOX_INPUT.text, function(str) /*=>*/ {return setValueInspector(str)});
						
						editWidget.font      = f_code;
						editWidget.format    = TEXT_AREA_FORMAT.codeLUA;
						editWidget.min_lines = 4;
						break;
						
					case VALUE_DISPLAY.codeHLSL:
						editWidget = new textArea(TEXTBOX_INPUT.text, function(str) /*=>*/ {return setValueInspector(str)});
						
						editWidget.autocomplete_server	 = hlsl_autocomplete_server;
						editWidget.function_guide_server = hlsl_function_guide_server;
						editWidget.parser_server		 = hlsl_document_parser;
						editWidget.autocomplete_object	 = node;
						
						editWidget.font      = f_code;
						editWidget.format    = TEXT_AREA_FORMAT.codeHLSL;
						editWidget.min_lines = 4;
						break;
						
					case VALUE_DISPLAY.text_array :
						editWidget = new textArrayBox(function() /*=>*/ {return animator.values[0].value}, display_data.data, function() /*=>*/ {return node.doUpdate()});
						break;
				}
				
				extract_node = "Node_String";
				break;
			
			case VALUE_TYPE.font :
				editWidget = new fontScrollBox(function(val) /*=>*/ {return setValueInspector(FONT_INTERNAL[val])});
				break;
				
			case VALUE_TYPE.d3Material :
				show_in_inspector = true;
				editWidget = new materialBox(function(ind) /*=>*/ { 
					var res = setValueInspector(ind); 
					node.triggerRender();
					return res;
				} );
				
				if(!struct_has(display_data, "atlas")) display_data.atlas = true;
				extract_node = "Node_Canvas";
				break;
				
			case VALUE_TYPE.surface :	
				show_in_inspector = true;
				editWidget = new surfaceBox(function(ind) /*=>*/ {return setValueInspector(ind)});
				
				if(!struct_has(display_data, "atlas")) display_data.atlas = true;
				extract_node = "Node_Canvas";
				break;
				
			case VALUE_TYPE.dynaSurface : editWidget = new surfaceDynaBox();										break;
			case VALUE_TYPE.pathnode :	  editWidget = new pathnodeBox(self); extract_node = "Node_Path"; 			break;
			case VALUE_TYPE.tileset :     editWidget = new tilesetBox(self);  extract_node = "Node_Tile_Tileset"; 	break;
			case VALUE_TYPE.armature :    editWidget = new armatureBox(self); 										break;
			case VALUE_TYPE.mesh :        editWidget = new meshBox(self); 											break;
			case VALUE_TYPE.pbBox :       editWidget = new pbBoxBox(self); 											break;
			case VALUE_TYPE.struct :      editWidget = new outputStructBox(); 										break;
			case VALUE_TYPE.particle :    editWidget = noone; 														break;
				
			default : editWidget = new outputBox(); break;
		}
		
		if(is_struct(display_data) && struct_has(display_data, "side_button") && editWidget.side_button == noone)
			editWidget.side_button = display_data.side_button;
		
		editWidgetRaw = editWidget;
		if(editWidget) {
			graphWidget = editWidget.clone();
			
			editWidget.attributes  = attributes;
			graphWidget.attributes = attributes;
		}
		
		for( var i = 0, n = array_length(animator.values); i < n; i++ ) {
			animator.values[i].ease_in_type   = key_inter;
			animator.values[i].ease_out_type  = key_inter;
		}
		
		setDropKey();
	} 
	
	resetDisplay();
	
	////- RENDER
	
	static isRendered = function() {
		if(type == VALUE_TYPE.node)	return true;
		if(value_from == noone)     return true;
		
		var controlNode = value_from.from? value_from.from : value_from.node;
		if(!controlNode.active)			  return true;
		if(!controlNode.isRenderActive()) return true;
		
		return controlNode.rendered;
	}
	
	static isActiveDynamic = function() {
		INLINE
		
		if(value_from_loop)       return true;
		if(value_from != noone)   return false;
		if(instanceBase != noone) return instanceBase.isActiveDynamic();
		
		if(expUse) {
			if(!is_struct(expTree)) return false;
			var res = expTree.isDynamic();
			
			switch(res) {
				case EXPRESS_TREE_ANIM.none :		return false;
				case EXPRESS_TREE_ANIM.base_value : force_requeue = true; return is_anim;
				case EXPRESS_TREE_ANIM.animated :	force_requeue = true; return true;
			}
		}
		
		return is_anim;
	}
	
	__init_dynamic = true;
	__value_from   = noone;
	
	static isDynamic = function() {
		if(__init_dynamic)             { __init_dynamic = false;      return true; }
		if(value_from != __value_from) { __value_from   = value_from; return true; }
		
		if(!IS_PLAYING)           return true;
		if(value_from_loop)       return true;
		if(value_from != noone)   return true;
		if(instanceBase != noone) return instanceBase.isDynamic();
		
		if(expUse) {
			if(!is_struct(expTree)) return false;
			var res = expTree.isDynamic();
			
			switch(res) {
				case EXPRESS_TREE_ANIM.none :		return false;
				case EXPRESS_TREE_ANIM.base_value : force_requeue = true; return is_anim;
				case EXPRESS_TREE_ANIM.animated :	force_requeue = true; return true;
			}
		}
		
		return is_anim;
	}
	
	////- CACHE
	
	static uncache = function() {
		use_cache = false;
		return self;
	}
	
	static resetCache = function() { cache_value[0] = false; }
	
	////- GET
	
	static getEditWidget = function() /*=>*/ {return editWidget};
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		
		if(applyUnit && display_type == VALUE_DISPLAY.d3quarternion && attributes.angle_display == QUARTERNION_DISPLAY.euler)
			return quarternionFromEuler(value[0], value[1], value[2]);
		
		if(type == VALUE_TYPE.gradient && typeFrom == VALUE_TYPE.color) { // color compatibility [ color, palette, gradient ]
			if(is_instanceof(value, gradientObject)) return value;
				
			if(is_array(value)) {
				var amo  = array_length(value);
				var grad = array_create(amo);
				
				for( var i = 0; i < amo; i++ )
					grad[i] = new gradientKey(i / amo, value[i]);
					
				var g = new gradientObject();
				g.keys = grad;
				return g;
			} 
			
			return is_real(value)? new gradientObject(value) : new gradientObject(ca_black);
		}
	
		if(display_type == VALUE_DISPLAY.palette && !is_array(value)) return [ value ];
		
		if(display_type == VALUE_DISPLAY.area) {
			
			if(!is_undefined(nodeFrom) && struct_has(nodeFrom.display_data, "onSurfaceSize")) {
				var surf     = nodeFrom.display_data.onSurfaceSize();
				var dispType = array_safe_get_fast(value, 5, AREA_MODE.area);
				
				switch(dispType) {
					case AREA_MODE.area : 
						break;
					
					case AREA_MODE.padding : 
						var ww = unit.mode == VALUE_UNIT.reference? 1 : surf[0];
						var hh = unit.mode == VALUE_UNIT.reference? 1 : surf[1];
						
						var cx = (ww - value[0] + value[2]) / 2
						var cy = (value[1] + hh - value[3]) / 2;
						var sw = abs((ww - value[0]) - value[2]) / 2;
						var sh = abs(value[1] - (hh - value[3])) / 2;
						
						value = [cx, cy, sw, sh, value[4], value[5]];
						break;
					
					case AREA_MODE.two_point : 
						var cx = (value[0] + value[2]) / 2
						var cy = (value[1] + value[3]) / 2;
						var sw = abs(value[0] - value[2]) / 2;
						var sh = abs(value[1] - value[3]) / 2;
					
						value = [cx, cy, sw, sh, value[4], value[5]];
						break;
				}
			}
			
			return applyUnit? unit.apply(value, arrIndex) : value;
		}
		
		if(type == VALUE_TYPE.text) return display_type == VALUE_DISPLAY.text_array? value : string_real(value);
		
		if(typeNumeric(typeFrom) && type == VALUE_TYPE.color) return value;
		
		if(typeFrom == VALUE_TYPE.boolean && type == VALUE_TYPE.text) return value? "true" : "false";
		
		if(type == VALUE_TYPE.integer || type == VALUE_TYPE.float) {
			if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
			
			value = applyUnit? unit.apply(value, arrIndex) : value;
			if(validator != noone) value = validator.validate(value);
			
			return value;
		}
		
		if(type == VALUE_TYPE.surface && connect_type == CONNECT_TYPE.input && !is_surface(value) && def_val == USE_DEF)
			return DEF_SURFACE;
		
		return value;
	}
	
	static getStaticValue = function() { INLINE return array_empty(animator.values)? 0 : animator.values[0].value; } 
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		draw_junction_index = type;
		if(type == VALUE_TYPE.trigger) return _getValue(_time, false, 0, false);
		
		if(useCache && use_cache) {
			var cache_hit = cache_value[0];
			cache_hit = cache_hit && !isActiveDynamic(_time) || cache_value[1] == _time;
			cache_hit = cache_hit && cache_value[2] != undefined;
			cache_hit = cache_hit && cache_value[3] == applyUnit;
			cache_hit = cache_hit && connect_type == CONNECT_TYPE.input;
			cache_hit = cache_hit && unit.reference == noone || unit.mode == VALUE_UNIT.constant;
			
			if(cache_hit) return cache_value[2];
		}
		
		var val = _getValue(_time, applyUnit, arrIndex, log);
		
		if(!accept_array && array_get_depth(val) > def_depth) { noti_warning($"{name} does not accept array data.", noone, node); return 0; }
		
		if(type == VALUE_TYPE.surface || type == VALUE_TYPE.any) {
			var _sval = array_valid(val)? val[0] : val;
				
			if(is_instanceof(_sval, SurfaceAtlas)) 
				draw_junction_index = VALUE_TYPE.atlas;
		}
		
		if(useCache) {
			cache_value[0] = true;
			cache_value[1] = _time;
		}
		
		cache_value[2] = val;
		cache_value[3] = applyUnit;
		
		return val;
	}
	
	static _getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, log = false) {
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(connect_type == CONNECT_TYPE.output) return val;
		
		if(typ == VALUE_TYPE.surface && (type == VALUE_TYPE.integer || type == VALUE_TYPE.float)) { // Dimension conversion
			if(is_array(val)) {
				var eqSize = true;
				var sArr = [];
				var _osZ = 0;
				
				for( var i = 0, n = array_length(val); i < n; i++ ) {
					if(!is_surface(val[i])) continue;
					
					var surfSz = surface_get_dimension(val[i]);
					array_push(sArr, surfSz);
					
					if(i && !array_equals(surfSz, _osZ))
						eqSize = false;
					
					_osZ = surfSz;
				}
				
				if(eqSize) return _osZ;
				return sArr;
			} else if (is_surface(val)) 
				return [ surface_get_width_safe(val), surface_get_height_safe(val) ];
			return [ 1, 1 ];
			
		}
		
		if(type == VALUE_TYPE.d3Material) {
			if(nod == self) {
				return def_val;
				
			} else if(typ == VALUE_TYPE.surface) {
				if(!is_array(val)) return def_val.clone(val);
				
				var _val = array_create(array_length(val));
				for( var i = 0, n = array_length(val); i < n; i++ ) 
					_val[i] = def_val.clone(val[i]);
				
				return _val;
			}
		}
		
		if(PROJECT.attributes.strict) return val;
		
		val = arrayBalance(val);
		
		if(isArray(val) && array_length(val) < 1024) { // Process data
			var _val = array_create(array_length(val));
			for( var i = 0, n = array_length(val); i < n; i++ )
				_val[i] = valueProcess(val[i], nod, applyUnit, arrIndex);
			
			return _val;
			
		}
		
		var _val = valueProcess(val, nod, applyUnit, arrIndex);
		return _val;
	}
	
	static getValueRecursive = function(arr = __curr_get_val, _time = CURRENT_FRAME) {
		
		if(value_from_loop && value_from_loop.bypassConnection() && value_from_loop.junc_out) {
			value_from_loop.getValue(arr);
			arr[@ 0] = arr[0];
		}
		
		else if(value_from && value_from != self)
			value_from.getValueRecursive(arr, _time);
		
		else {
			arr[@ 0] = __getAnimValue(_time);
			arr[@ 1] = self;
		}
		
		if(!expUse || expTree == noone || !expTree.validate()) return;
			
		if(global.EVALUATE_HEAD == self)  {
			noti_warning($"Expression evaluation error : recursive call detected.");
			return;
		} 
		
		if(global.EVALUATE_HEAD == noone) {
			
			global.EVALUATE_HEAD = self;
			expContext = { 
				name :        name,
				node_name :   node.display_name,
				value :       arr[0],
				node_values : node.input_value_map,
			};
			
			var _exp_res = expTree.eval(variable_clone(expContext));
			
			printIf(global.LOG_EXPRESSION, $">>>> Result = {_exp_res}");
			
			if(is_undefined(_exp_res)) {
				arr[@ 0] = 0;
				noti_warning("Expression returns undefine values.");
				
			} else 
				arr[@ 0] = _exp_res;
		}
		
		global.EVALUATE_HEAD = noone;
	}
	
	static arrayBalance = function(val) {
		if(!is_array(def_val)) return val;
		if(isDynamicArray())   return val;
		if(isArray(val))       return val;
		if(!is_array(val))     return array_create(def_length, val);
		
		if(array_length(val) < def_length) {
			val = array_clone(val, 1);
			array_resize(val, def_length);
		}
		
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(!is_anim) {
			if(sep_axis) {
				var val = array_create(array_length(_anims));
				for( var i = 0, n = array_length(_anims); i < n; i++ )
					val[i] = _anims[i].processType(_anims[i].values[0].value);
				return val;
			}
			
			if(array_empty(_anim.values)) return 0;
			
			return _anim.processType(_anim.values[0].value);
		}
		
		if(sep_axis) {
			var val = [];
			for( var i = 0, n = array_length(_anims); i < n; i++ )
				val[i] = _anims[i].getValue(_time);
			return val;
		} 
		
		return _anim.getValue(_time);
	}
	
	static isTimelineVisible = function() { INLINE return is_anim && value_from == noone; }
	
	show_val = [];
	static __showValue = function() {
		INLINE
		
		var val = 0;
		
		if(value_from != noone || is_anim || expUse) 
			val = getValue(CURRENT_FRAME, false);
			
		else if(sep_axis) {
			show_val = array_verify(show_val, array_length(animators));
			for( var i = 0, n = array_length(animators); i < n; i++ )
				show_val[i] = array_empty(animators[i].values)? 0 : animators[i].processType(animators[i].values[0].value);
			val = show_val;
		} else 
			val = array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		
		return val;
	}
	
	static showValue = function() { ////showValue
		return __showValue();
	}
	
	static unitConvert = function(mode) {
		var _v = animator.values;
		
		for( var i = 0; i < array_length(_v); i++ ) 
			_v[i].value = unit.convertUnit(_v[i].value, mode);
	}
	
	static isDynamicArray = function() {
		if(dynamic_array) return true;
		
		switch(display_type) {
			case VALUE_DISPLAY.curve :
			case VALUE_DISPLAY.palette :
				return true;
		}
		
		return false;
	}
	
	static isArray = function(val = undefined) {
		val ??= getValue();
		return __array_get_depth(val) > array_depth + type_array;
	}
	
	__is_array     = false;
	__array_length = -1;
	
	static __arrayLength = function(val = undefined) {
		val ??= getValue();
		
		var _vdp = array_depth + type_array;
		var _dep = array_get_depth(val);
		__is_array = _dep > 0;
		
		return _dep > _vdp? array_length(val) : -1;
	}
	
	static arrayLengthSimple = function(val = undefined) {
		val ??= getValue();
		
		__is_array = is_array(val);
		return __is_array? array_length(val) : -1;
	}
	
	arrayLength = __arrayLength;
	
	////- SET
	
	static onValidate = function() {
		if(!validateValue) return;
		var _val = value_validation, str = "";
		value_validation = VALIDATION.pass; 
		
		switch(type) {
			case VALUE_TYPE.path:
				switch(display_type) {
					case VALUE_DISPLAY.path_load: 
						var path = animator.getValue();
						if(is_array(path)) path = path[0];
						
						if(!is_string(path) || path == "") {
							str = $"Path invalid: {path}";
							break;
						}
						
						if(path_get(path) == -1) {
							value_validation = VALIDATION.error;	
							str = $"File not exist: {path}";
						}
						break;
						
					case VALUE_DISPLAY.path_array: 
						var paths = animator.getValue();
						if(is_array(paths)) {
							for( var i = 0, n = array_length(paths); i < n; i++ ) {
								if(path_get(paths[i]) != -1) continue;
								value_validation = VALIDATION.error;	
								str = $"File not exist: {paths[i]}";
							} 
						} else {
							value_validation = VALIDATION.error;	
							str = $"File not exist: {paths}";
						}
						break;
				}
				break;
		}
		
		if(NOT_LOAD) node.onValidate();
		
		if(_val == value_validation) return self;
		
		#region notification
			if(value_validation == VALIDATION.error && error_notification == noone) {
				error_notification = noti_error(str);
				error_notification.onClick = function() { PANEL_GRAPH.focusNode(node); };
			}
				
			if(value_validation == VALIDATION.pass && error_notification != noone) {
				noti_remove(error_notification);
				error_notification = noone;
			}
		#endregion
		
		return self;
	}
	
	static onSetValue = undefined;
	static setValue = function(val = 0, record = true, time = CURRENT_FRAME, _update = true) { ////Set value
		val = unit.invApply(val);
		var _set = setValueDirect(val, noone, record, time, _update);
		if(onSetValue != undefined) onSetValue(val);
		
		return _set;
	}
	
	static overrideValue = function(_val) {
		animator.values = [];
		array_push(animator.values, new valueKey(0, _val, animator));
		
		for( var i = 0, n = array_length(animators); i < n; i++ ) {
			animators[i].values = [];
			array_push(animators[i].values, new valueKey(0, array_safe_get_fast(_val, i), animators[i]));
		}
	}
	
	static setValueInspector = function(_val = 0, _index = noone, time = CURRENT_FRAME) { // This should be in panel_inspector not here. 
		INLINE
		
		var res = false;
		
		if(PANEL_INSPECTOR && PANEL_INSPECTOR.inspectGroup == 1) {
			var ind = index;
			
			for( var i = 0, n = array_length(PANEL_INSPECTOR.inspectings); i < n; i++ ) {
				var _node = PANEL_INSPECTOR.inspectings[i];
				if(ind >= array_length(_node.inputs)) continue;
				
				var r = _node.inputs[ind].setValueDirect(_val, _index, true, time);
				if(_node == node) res = r;
			}
		} else
			res = setValueDirect(_val, _index, true, time);
		if(onSetValue != undefined) onSetValue(_val);
		
		return res;
	}
	
	static onSetValueDirect = undefined;
	static setValueDirect = function(val = 0, _index = noone, record = true, time = CURRENT_FRAME, _update = true) {
		is_modified = true;
		var updated = false;
		var _val    = val;
		var _inp    = connect_type == CONNECT_TYPE.input;
		
		record = record && record_value & _inp;
		
		if(sep_axis) {
			if(_index == noone) {
				for( var i = 0, n = array_length(animators); i < n; i++ )
					updated = animators[i].setValue(val[i], record, time) || updated; 
			} else
				updated = animators[_index].setValue(val, record, time);
				
		} else {
			if(_index != noone) {
				_val = animator.getValue(time);
				if(_inp) _val = variable_clone(_val); 
				
				_val[_index] = val;
			}
			
			updated = animator.setValue(_val, record, time);
		}
		
		if(type == VALUE_TYPE.gradient)				updated = true;
		if(display_type == VALUE_DISPLAY.palette)   updated = true;
		
		if(!updated) return false; /////////////////////////////////////////////////////////////////////////////////
		
		if(is_instanceof(self, __NodeValue_Dimension))
			attributes.use_project_dimension = false;
		
		if(connect_type == CONNECT_TYPE.input && index >= 0) {
			var _val = getValue(time);
			
			node.inputs_data[index]         = _val; // setInputData(index, _val);
			node.input_value_map[$ internalName] = _val;
		}
		
		draw_junction_index = type;
		if(type == VALUE_TYPE.surface) {
			var _sval = val;
			if(is_array(_sval) && !array_empty(_sval))
				_sval = _sval[0];
				
			if(is_instanceof(_sval, SurfaceAtlas))
				draw_junction_index = VALUE_TYPE.atlas;
		}
		
		if(connect_type == CONNECT_TYPE.output) {
			if(index == 0) {
				node.preview_value = getValue();
				node.preview_array = $"[{array_shape(node.preview_value)}]";
			}
			return;
		}
		
		if(tags == VALUE_TAG.updateInTrigger || tags == VALUE_TAG.updateOutTrigger) return true;
		
		if(_update) { // This part used to have !IS_PLAYING
			node.triggerRender();
			node.valueUpdate(index);
			node.clearCacheForward();
		}
		
		if(fullUpdate) RENDER_ALL
		
		if(!LOADING) PROJECT.modified = true;
					
		cache_value[0] = false;
		onValidate();
		
		return true;
	}
	
	static getString = function() {
		var val = showValue();
		
		if(type == VALUE_TYPE.text) return val;
		return json_stringify(val);
	}
	
	static setString = function(str) {
		if(!editable || connect_type == CONNECT_TYPE.output) return;
		if(type == VALUE_TYPE.text) { setValue(str); return; }
		
		switch(type) {
			case VALUE_TYPE.gradient :
				var _grad = new gradientObject().deserialize(str);
				setValueRaw(_grad);
				break;
				
			default : 
				var _dat = json_try_parse(str, -1);
				if(_dat != -1) setValueRaw(_dat);
		}
		
	}
	
	static setValueRaw = function(_dat) { setValue(_dat); }
	
	////- CONNECT
	
	static rejectConnect = function() {
		auto_connect = false;
		return self;
	}
	
	static isConnectable = function(_valueFrom, checkRecur = true, _log = false) { 
		
		if(_valueFrom == -1 || _valueFrom == undefined || _valueFrom == noone) {
			if(_log) noti_warning($"LOAD: Cannot set node connection from {_valueFrom} to {name} of node {node.name}.",, node);
			return -1;
		}
		
		if(_valueFrom.type == VALUE_TYPE.pbBox && is(self, __NodeValue_Dimension)) 
			return 1;
		
		if(_valueFrom == value_from) {
			if(_log) noti_warning("setFrom: Can't connect to itself");
			return -2;
		}
		
		if(_valueFrom == self) {
			if(_log) noti_warning("setFrom: Self connection is not allowed.",, node);
			return -3;
		}
		
		if(!typeCompatible(_valueFrom.type, type)) { 
			if(_log) noti_warning($"Connection error: Incompatible type {_valueFrom.type} to {type}",, node);
			return -4;
		}
		
		if(typeIncompatible(_valueFrom, self)) {
			if(_log) noti_warning("Connection error: Incompatible type",, node);
			return -5;
		}
		
		if(connect_type == _valueFrom.connect_type) {
			if(_log) noti_warning("setFrom: Connect type mismatch",, node);
			return -6;
		}
		
		if(checkRecur && _valueFrom.searchNodeBackward(node)) {
			if(_log) noti_warning("setFrom: Cyclic connection not allowed.",, node);
			return -7;
		}
		
		if(LOADING || APPENDING) return 1;
		
		if(!accept_array && isArray(_valueFrom.getValue())) {
			noti_warning($"Connection error: {name} does not support array input.",, node);
			return -8;
		}
			
		if(!accept_array && _valueFrom.type == VALUE_TYPE.surface && (type == VALUE_TYPE.integer || type == VALUE_TYPE.float)) {
			if(_log) noti_warning("setFrom: Array mismatch",, node);
			return -9;
		}
			
		return 1;
	} 
	
	static isConnectableStrict = function(_valueFrom) { return bool(value_bit(type) & value_bit(_valueFrom.type)); } 
	
	static triggerSetFrom = function() { node.valueUpdate(index); }
	
	static setFrom = function(_valueFrom, _update = true, checkRecur = true, log = false) { //// Set from
		
		if(is_dummy && dummy_get != noone) {
			var conn = isConnectable(_valueFrom, checkRecur, log);
			if(conn < 0) return conn;
			
			var _targ    = dummy_get();
			dummy_target = _targ;
			UNDO_HOLDING = true;
			var _res     = _targ.setFrom(_valueFrom, _update, checkRecur, log);
			UNDO_HOLDING = false;
			
			recordAction(ACTION_TYPE.junction_connect, self, [ _targ, _valueFrom ]).setRef(node);
			return _res;
		}
		
		if(_valueFrom == noone) return removeFrom();
		var conn = isConnectable(_valueFrom, checkRecur, log);
		if(conn < 0) return conn;
		
		run_in(2, function() /*=>*/ { updateColor(getValue()); });
		
		if(setFrom_condition != -1 && !setFrom_condition(_valueFrom)) return -2;
		
		if(value_from != noone) array_remove(value_from.value_to, self);
		
		var _o = animator.getValue();
		recordAction(ACTION_TYPE.junction_connect, self, value_from).setRef(node);
		value_from = _valueFrom;
		
		array_push(_valueFrom.value_to, self);
		
		if(NOT_LOAD && node.inline_context == noone) {
			var _inCtx = _valueFrom.node.inline_context;
			if(_inCtx != noone && _inCtx.junctionIsInside(_valueFrom))
				_inCtx.addNode(node);
		}
		
		node.valueUpdate(index, _o);
		if(_update && connect_type == CONNECT_TYPE.input) {
			node.valueFromUpdate(index);
			node.refreshNodeDisplay();
			node.triggerRender();
			node.clearCacheForward();
			
			if(PANEL_GRAPH) PANEL_GRAPH.connection_draw_update = true;
			UPDATE |= RENDER_TYPE.partial;
		}
		
		cache_array[0] = false;
		cache_value[0] = false;
		
		if(NOT_LOAD && !CLONING) {
			draw_line_shift_x	= 0;
			draw_line_shift_y	= 0;
			PROJECT.modified	= true;
		}
		
		RENDER_PARTIAL_REORDER
		
		if(onSetFrom != noone)			onSetFrom(_valueFrom);
		if(_valueFrom.onSetTo != noone) _valueFrom.onSetTo(self);
		
		return true;
	}
	
	static getNodeFrom = function() { 
		if(value_from == noone)  return noone;
		
		var _node = value_from.node;
		if(!_node.active)        return noone;
		if(!is(_node, Node_Pin)) return _node;
		return _node.inputs[0].getNodeFrom(); 
	}
	
	static removeFrom = function(_remove_list = true) {
		run_in(2, function() /*=>*/ { updateColor(getValue()); });
		
		recordAction(ACTION_TYPE.junction_disconnect, self, value_from).setRef(node);
		if(_remove_list && value_from != noone)
			array_remove(value_from.value_to, self);
		value_from = noone;
		
		if(connect_type == CONNECT_TYPE.input)
			node.valueFromUpdate(index);
		node.clearCacheForward();
		node.refreshNodeDisplay();
		
		PROJECT.modified = true;
		if(PANEL_GRAPH) PANEL_GRAPH.connection_draw_update = true;
						
		RENDER_ALL_REORDER
		
		return false;
	}
	
	static removeFromLoop = function(_remove_list = true) {
		if(value_from_loop != noone)
			value_from_loop.destroy();
		
		PROJECT.modified = true;
	}
	
	static checkConnection = function(_remove_list = true) {
		if(value_from == noone) return;
		if(value_from.node.active) return;
		
		removeFrom(_remove_list);
	}
	
	static searchNodeBackward = function(_node) {
		if(node == _node) return true;
			
		if(NOT_LOAD && struct_has(node, "__key") && struct_has(_node, "__key") && node.__key == _node.__key)
			return true;
		
		for(var i = 0; i < array_length(node.inputs); i++) {
			var _in = node.inputs[i].value_from;
			if(_in && _in.searchNodeBackward(_node))
				return true;
		}
		return false;
	}
	
	static hasJunctionFrom = function() { INLINE return value_from != noone || value_from_loop != noone; }
	
	static getJunctionTo = function() { return array_filter(value_to, function(v) /*=>*/ {return v.value_from == self && v.node.active}); }
	
	////- DRAW
	
	static setColor = function(_color) {
		color = color_real(_color);
		updateColor();
		return self;
	}
	
	static updateColor = function(val = undefined) {
		INLINE
		
		if(color == -1) {
			draw_bg = is_array(val)? value_color_bg_array(draw_junction_index) : value_color_bg(draw_junction_index);
			draw_fg = value_color(draw_junction_index);
			
		} else {
			draw_bg = is_array(val)? merge_color(color, colorMultiply(color, CDEF.main_dkgrey), 0.5) : value_color_bg(draw_junction_index);
			draw_fg = color;
		}
		
		color_display = type == VALUE_TYPE.action? #8fde5d : draw_fg;
	} updateColor();
	
	__preview_bbox = noone;
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(expUse) return -1;
		
		var argc = 9;
		__preview_bbox = node.__preview_bbox;
		
		switch(type) {
			case VALUE_TYPE.integer :
			case VALUE_TYPE.float :
				if(value_from != noone) return -1;
				switch(display_type) {
					case VALUE_DISPLAY._default :
					case VALUE_DISPLAY.slider :
						var _angle = argument_count > argc + 0? argument[argc + 0] : 0;
						var _scale = argument_count > argc + 1? argument[argc + 1] : 1;
						var _spr   = argument_count > argc + 2? argument[argc + 2] : 0;
						return preview_overlay_scalar(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _angle, _scale, _spr);
								
					case VALUE_DISPLAY.rotation :
						var _rad = argument_count >  argc + 0? argument[ argc + 0] : 64;
						return preview_overlay_rotation(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad);
								
					case VALUE_DISPLAY.vector :
						var _typ = argument_count > argc + 0? argument[argc + 0] : 0;
						var _sca = argument_count > argc + 1? argument[argc + 1] : [ 1, 1 ];
						return preview_overlay_vector(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _typ, _sca);
						
					case VALUE_DISPLAY.gradient_range :
						var _dim = argument[argc];
						
						if(mappedJunc.attributes.mapped)
							return preview_overlay_gradient_range(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _dim);
						break;
								
					case VALUE_DISPLAY.area :
						var _flag = argument_count > argc + 0? argument[argc + 0] : 0b0011;
						return preview_overlay_area(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, struct_try_get(display_data, "onSurfaceSize"));
								
					case VALUE_DISPLAY.puppet_control :
						return preview_overlay_puppet(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				}
				break;
			
			case VALUE_TYPE.pathnode :
				var _path = getValue();
				if(is_struct(_path) && struct_has(_path, "drawOverlay")) return _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				break;
		}
		
		return -1;
	}
	
	static drawPreviewOverlay = function(_x, _y, _s, _panel) {
		var _raw = getValue();
		
		var _txt = _raw;
		var _x0 = _x;
		var _y0 = _y;
		var _x1 = _x + DEF_SURF_W * _s;
		var _y1 = _y + DEF_SURF_H * _s;
		
		var _bbox = BBOX().fromPoints(_x0 + ui(16), _y0 + ui(16), _x1 - ui(16), _y1 - ui(16));
		var _tc   = COLORS._main_text;
		
		switch(type) {
			case VALUE_TYPE.integer : 
			case VALUE_TYPE.float  : 
				if(display_type == VALUE_DISPLAY.vector) {
					var _d = array_get_depth(_raw);
					draw_set_color(COLORS._main_accent);
					draw_set_circle_precision(8);
					
					if(_d == 1) {
						var _px = _x + _raw[0] * _s;
						var _py = _y + _raw[1] * _s;
						draw_circle(_px, _py, ui(3), false);
						
					} else if(_d == 2) {
						for( var i = 0, n = array_length(_raw); i < n; i++ ) {
							var _p  = _raw[i];
							var _px = _x + _p[0] * _s;
							var _py = _y + _p[1] * _s;
							
							draw_circle(_px, _py, ui(3), false);
						}
					}
					return;
				}
				break;
			
			case VALUE_TYPE.boolean:
				if(is_array(_raw)) {
					_txt = [];
					for( var i = 0, n = array_length(_raw); i < n; i++ ) 
						_txt[i] = bool(_raw[i])? "True" : "False";
				} else 
					_txt = bool(_raw)? "True" : "False";
				break;
				
			case VALUE_TYPE.color:
				if(is_array(_raw)) {
					var _d = array_get_depth(_raw);
					if(_d == 1) {
						var _amo = array_length(_raw);
						var _w   = (_x1 - _x0) / _amo;
						
						for( var i = 0, n = array_length(_raw); i < n; i++ ) {
							draw_set_color(_raw[i]);
							draw_rectangle(_x0 + _w * i, _y0, _x0 + _w * (i + 1), _y1, false);
						}
					}
					return;
				} 
				
				draw_set_color(_raw);
				draw_rectangle(_x0, _y0, _x1, _y1, false);
				
				if(colorBrightness(_raw) > .8) _tc = c_black;
				_txt = $"#{color_get_hex(_raw)}";
				break;
			
			case VALUE_TYPE.gradient:	
				if(is_array(_raw))
					return;
				
				if(is(_raw, gradientObject))
					_raw.draw(_x0, _y0, _x1 - _x0, _y1 - _y0);
				return;
				
			case VALUE_TYPE.path: 
			case VALUE_TYPE.curve: 
			case VALUE_TYPE.struct:
				return;
				
			case VALUE_TYPE.atlas:
				return;
			
			case VALUE_TYPE.audioBit:
				return;
			
			case VALUE_TYPE.font:
				return;
			
			case VALUE_TYPE.text: 
				break;
				
			default: return;
		}
		
		if(string_length(_txt) > 64)
			_txt = string_copy(_txt, 1, 64) + "...";
			
		draw_set_text(f_sdf, fa_center, fa_center, _tc);
		draw_text_bbox(_bbox, _txt);
	}
	
	static drawJunction = function(_draw, _s, _mx, _my, _fast = false) {
		if(_fast) {
			var hov  = PANEL_GRAPH.pHOVER && (PANEL_GRAPH.node_hovering == noone || PANEL_GRAPH.node_hovering == node);
			var _d   = node.junction_draw_hei_y * _s;
			var _hov = hov && point_in_rectangle(_mx, _my, x - 6 * _s, y - _d / 2, x + 6 * _s, y + _d / 2 - 1);
			if(!_draw) return _hov;
			
			var _aa  = 0.75 + (!is_dummy * 0.25);
			hover_in_graph = _hov;
			
			draw_set_color(custom_color == noone? draw_fg : custom_color);
			draw_set_alpha(_aa);
			
			if(node.previewable)
				draw_circle(x, y, _s * 6, false);
				
			else if(index == -1)
				draw_rectangle(	x - _s * 4, y - _s * 1.5, 
								x + _s * 4, y + _s * 1.5, false);
			else
				draw_rectangle(	x - _s * 1.5, y - _s * 4, 
								x + _s * 1.5, y + _s * 4, false);
			
			draw_set_alpha(1);
			
			return _hov;
		}
		
		var hov  = PANEL_GRAPH.pHOVER && (PANEL_GRAPH.node_hovering == noone || PANEL_GRAPH.node_hovering == node);
		var _d   = node.junction_draw_hei_y * _s / 2;
		var _hov = hov && point_in_rectangle(_mx, _my, x - _d, y - _d, x + _d - 1, y + _d - 1);
		hover_in_graph = _hov;
		if(!_draw) return _hov;
		
		_s /= 2 * THEME_SCALE;
		
		if(custom_icon != noone) {
			__draw_sprite_ext(custom_icon, 0, x, y, _s, _s, 0, c_white, 1);
			
		} else if(is_dummy) {
			if(ghost_hover == noone) __draw_sprite_ext(THEME.node_junction_add, _hov, x, y, _s, _s, 0, c_white, 0.5 + 0.5 * _hov);
			else {
				__draw_sprite_ext(THEME.node_junctions_bg,      ghost_hover.draw_junction_index, x, y, _s, _s, 0, ghost_hover.draw_bg, 1);
				__draw_sprite_ext(THEME.node_junctions_outline, ghost_hover.draw_junction_index, x, y, _s, _s, 0, ghost_hover.draw_fg, 1);
			}
			
			ghost_hover = noone;
			
		} else if(type == VALUE_TYPE.action) {
			var _cbg = c_white;
			
			if(draw_blend != -1)
				_cbg = merge_color(draw_blend_color, _cbg, draw_blend);
		
			__draw_sprite_ext(THEME.node_junction_inspector, _hov, x, y, _s, _s, 0, _cbg, 1);
			
		} else {
			var _cbg = draw_bg;
			var _cfg = draw_fg;
			
			if(draw_blend != -1) {
				_cbg = merge_color(draw_blend_color, _cbg, draw_blend);
				_cfg = merge_color(draw_blend_color, _cfg, draw_blend);
			}
			
			var _bgS = THEME.node_junctions_bg;
			var _fgS = _hov? THEME.node_junctions_outline_hover : THEME.node_junctions_outline;
			
			if(graph_selecting) __draw_sprite_ext(THEME.node_junction_selecting, 0, x, y, _s * THEME_SCALE, _s * THEME_SCALE, 0, _cfg, .8);
			graph_selecting = false;
			
			__draw_sprite_ext(_bgS, draw_junction_index, x, y, _s, _s, 0, _cbg, 1);
			
			gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
			__draw_sprite_ext(_fgS, draw_junction_index, x, y, _s, _s, 0, _cfg, 1);
			gpu_set_blendmode(bm_normal);
		}
		
		return _hov;
	}
	
	static drawNameBG = function(_s) {
		var _f = node.previewable? f_p1 : f_p3;
		draw_set_text(_f, fa_left, fa_center);
		
		var tw = string_width(name) + 32;
		var th = string_height(name) + 16;
		
		if(type == VALUE_TYPE.action) {
			var tx = x;
			draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, tx - tw / 2, y - th, tw, th, c_white, 0.5);
			
		} else if(connect_type == CONNECT_TYPE.input) {
			var tx = x - 12 * _s;
			draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, tx - tw + 16, y - th / 2, tw, th, c_white, 0.5);
			
		} else {
			var tx = x + 12 * _s;
			draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, tx - 16, y - th / 2, tw, th, c_white, 0.5);
		}
	}
	
	static drawName = function(_s, _mx, _my) {
		
		var _draw_cc = COLORS._main_text;
		var _draw_aa = 0.6 + hover_in_graph * 0.4;
		
		var _f = node.previewable? f_p2 : f_p3;
		
		draw_set_text(_f, fa_left, fa_center, _draw_cc);
		draw_set_alpha(_draw_aa);
		
		if(type == VALUE_TYPE.action) {
			var tx = x;
			draw_set_text(_f, fa_center, fa_center, _draw_cc);
			draw_text_add(tx, y - (line_get_height() + 16) / 2, name);
			
		} else if(connect_type == CONNECT_TYPE.input) {
			var tx = x - 12 * _s;
			draw_set_halign(fa_right);
			draw_text_add(tx, y, name);
			
		} else {
			var tx = x + 12 * _s;
			draw_set_halign(fa_left);
			draw_text_add(tx, y, name);
			
		}
		
		draw_set_alpha(1);
	}
	
	static drawConnections = function(params = {}, _draw = true) {
		if(value_from == noone || !value_from.node.active || !isVisible()) return noone;
		if(_draw) drawJuncConnection(value_from, self, params); 
		return checkJuncConnection(value_from, self, params);
	}
	
	static drawConnectionMouse = function(params, _mx, _my, target = noone) {
		var ss = params.s;
		var aa = params.aa; // 1
		
		var drawCorner = type == VALUE_TYPE.action;
		if(target != noone)
			drawCorner |= target.type == VALUE_TYPE.action;
		
		var corner = PROJECT.graphConnection.line_corner * ss;
		var th     = max(1, PROJECT.graphConnection.line_width * ss);
		
		var sx = x;
		var sy = y;
		
		corner *= aa;
		th  *= aa;
		ss  *= aa;
		sx  *= aa;
		sy  *= aa;
		_mx *= aa;
		_my *= aa;
		
		var _fade = PROJECT.graphConnection.line_highlight_fade;
		var  col  = custom_color == noone? merge_color(_fade, color_display, .5) : custom_color;
		draw_set_color(col);
		
		var _action = type == VALUE_TYPE.action;
		var _output = connect_type == CONNECT_TYPE.output;
		var _drawParam = {
			corner :    corner,
			extend :    PROJECT.graphConnection.line_extend,
			fromIndex : 1,
			toIndex :   1,
			type :      LINE_STYLE.solid,
		}
		
		switch(PROJECT.graphConnection.type) {
			case 0 : 
				if(drawCorner) draw_line_width(sx, sy, _mx, _my, th); 
				else {
					if(_output) draw_line_connect(sx, sy, _mx, _my, ss, th, col, col, _drawParam);
					else		draw_line_connect(_mx, _my, sx, sy, ss, th, col, col, _drawParam);
				}
				break;
			
			case 1 : 
				if(drawCorner) {
					if(_action)	draw_line_curve_corner(_mx, _my, sx, sy, ss, th, col, col);
					else		draw_line_curve_corner(sx, sy, _mx, _my, ss, th, col, col);
				} else {
					if(_output) draw_line_curve_color(_mx, _my, sx, sy,,, ss, th, col, col);
					else		draw_line_curve_color(sx, sy, _mx, _my,,, ss, th, col, col);
				}
				break;
				
			case 2 : 
				if(drawCorner) {
					if(_action)	draw_line_elbow_corner(_mx, _my, sx, sy, ss, th, col, col, _drawParam);
					else		draw_line_elbow_corner(sx, sy, _mx, _my, ss, th, col, col, _drawParam);
				} else {
					if(_output)	draw_line_elbow_color(sx, sy, _mx, _my,,, ss, th, col, col, _drawParam);
					else		draw_line_elbow_color(_mx, _my, sx, sy,,, ss, th, col, col, _drawParam);
				}
				break;
				
			case 3 : 
				if(drawCorner) {
					if(_action)	draw_line_elbow_diag_corner(_mx, _my, sx, sy, ss, th, col, col, _drawParam);
					else		draw_line_elbow_diag_corner(sx, sy, _mx, _my, ss, th, col, col, _drawParam);
				} else {
					if(_output)	draw_line_elbow_diag_color(sx, sy, _mx, _my,,, ss, th, col, col, _drawParam);
					else		draw_line_elbow_diag_color(_mx, _my, sx, sy,,, ss, th, col, col, _drawParam);
				}
				break;
		}
		
		var _sprs = ss / 2 / THEME_SCALE;
		
		if(custom_icon != noone) {
			__draw_sprite_ext(custom_icon, draw_junction_index, _mx, _my, _sprs, _sprs, 0, c_white, 1);
			return;
		}
		
		__draw_sprite_ext(THEME.node_junctions_bg,      draw_junction_index, _mx, _my, _sprs, _sprs, 0, draw_bg, 1);
		__draw_sprite_ext(THEME.node_junctions_outline, draw_junction_index, _mx, _my, _sprs, _sprs, 0, draw_fg, 1);
	}
	
	////- EXPRESSION
	
	static setUseExpression = function(useExp) {
		INLINE
		if(expUse == useExp) return;
		expUse = useExp;
		node.triggerRender();
	}
	
	static setExpression = function(_expression) {
		expUse = true;
		expression = _expression;
		expressionUpdate();
	}
	
	static expressionUpdate = function() {
		expTree = evaluateFunctionList(expression);
		resetCache();
		node.triggerRender();
	}
	
	////- SERIALIZE
	
	static serialize = function(scale = false, preset = false) {
		var _map = {};
		
		if(visible)             _map.v              = real(visible);
		if(visible_manual != 0) _map.visible_manual = visible_manual;
		if(color != -1)         _map.color          = color;
		
		if(graph_h != 96)       _map.graph_h        = graph_h;
		_map.graph_sh  = show_graph;
		_map.graph_shs = array_clone(show_graphs);
		
		if(connect_type == CONNECT_TYPE.output) return _map;
		
		if(name_custom)                 _map.name		 = name;
		if(unit.mode != 0)              _map.unit		 = unit.mode;
		if(on_end != KEYFRAME_END.hold) _map.on_end		 = on_end;
		if(loop_range != -1)            _map.loop_range	 = loop_range;
		if(sep_axis)                    _map.sep_axis	 = sep_axis;
		
		if(draw_line_shift_x !=  0) _map.shift_x     = draw_line_shift_x;
		if(draw_line_shift_y !=  0) _map.shift_y     = draw_line_shift_y;
		if(draw_line_shift_e != -1) _map.shift_e     = draw_line_shift_e;
		if(is_modified == true)     _map.is_modified = is_modified;
		
		if(!preset && value_from) {
			_map.from_node  = value_from.node.node_id;
			_map.from_index = value_from.index;
			if(value_from.tags != 0) 
				_map.from_tag   = value_from.tags;
		}
		
		if(expUse)           _map.global_use = expUse;
		if(expression != "") _map.global_key = expression;
		if(is_anim)          _map.anim       = is_anim;
		
		if(is_modified) _map.raw_value  = animator.serialize(scale);
		
		var _animLen = array_length(animators);
		if(is_modified && _animLen) {
			var _anims   = array_create(_animLen);
			for( var i = 0; i < _animLen; i++ )
				_anims[i] = animators[i].serialize(scale);
			_map.animators    = _anims;
		}
		
		if(struct_has(display_data, "linked")) _map.linked       = display_data.linked;
		if(name_custom)                        _map.name_custom  = name_custom;
		if(bypass_junc && bypass_junc.visible) _map.bypass       = true;
		
		#region attributes
			attri   = variable_clone(attributes);
			if(struct_try_get(attri, "mapped") == 0)    					struct_remove(attri, "mapped");
			if(struct_try_get(attri, "use_project_dimension") == true)		struct_remove(attri, "use_project_dimension");
			
			if(struct_names_count(attri)) _map.attri = attri;
		#endregion
		
		return _map;
	}
	
	static applyDeserialize = function(_map, scale = false, preset = false) {
		if(_map == undefined) return;
		if(_map == noone)     return;
		if(!is_struct(_map))  return;
		
		if(!preset) {
			visible 	   = _map[$ LOADING_VERSION >= 1_18_04_0 || CLONING? "v" : "visible"] ?? 0;
			visible_manual = _map[$ "visible_manual"] ?? 0;
			color   	   = _map[$ "color"] ?? -1;
			
			graph_h   	   = _map[$ "graph_h"]  ?? 96;
			show_graph     = _map[$ "graph_sh"] ?? show_graph;
			show_graphs    = array_clone(_map[$ "graph_shs"] ?? show_graphs);
		}
		
		if(connect_type == CONNECT_TYPE.output) return;
		
		on_end		= _map[$ "on_end"]     ?? KEYFRAME_END.hold;
		loop_range	= _map[$ "loop_range"] ?? -1;
		unit.mode	= _map[$ "unit"]       ?? 0;
		expUse    	= _map[$ "global_use"] ?? false;
		expression	= _map[$ "global_key"] ?? "";
		expTree     = evaluateFunctionList(expression); 
		
		sep_axis	= _map[$ "sep_axis"] ?? false;
		setAnim(_map[$ "anim"] ?? false);
		
		draw_line_shift_x = _map[$ "shift_x"]     ??  0;
		draw_line_shift_y = _map[$ "shift_y"]     ??  0;
		draw_line_shift_e = _map[$ "shift_e"]     ?? -1;
		is_modified       = _map[$ "is_modified"] ?? true;
		
		if(struct_has(_map, "attri")) struct_append(attributes, _map.attri);
		
		if(struct_has(attributes, "use_project_dimension") && struct_has(node.load_map, "attri") && struct_has(node.load_map.attri, "use_project_dimension"))
			attributes.use_project_dimension = node.load_map.attri.use_project_dimension;
		
		if(struct_has(_map, "linked")) 
			display_data.linked = _map.linked;
			
		if(struct_has(_map, "global_name")) {
			name_custom = true;
			name = _map[$ "global_name"];
			
		} else {
			name_custom = _map[$ "name_custom"]   ?? false;
			if(name_custom) name = _map[$ "name"] ?? name;
			
		}
			
		if(struct_has(_map, "raw_value")) 
			animator.deserialize(_map[$ "raw_value"], scale);
			
		if(bypass_junc) 
			bypass_junc.visible = _map[$ "bypass"] ?? false;
		
		if(struct_has(_map, "animators")) {
			var anims = _map.animators;
			var amo = min(array_length(anims), array_length(animators));
			for( var i = 0; i < amo; i++ )
				animators[i].deserialize(anims[i], scale);
		}
		
		if(!preset) {
			con_node  = _map[$ "from_node"]  ?? -1;
			con_index = _map[$ "from_index"] ?? -1;
			con_tag   = _map[$ "from_tag"]   ?? 0;
		}
		
		if(connect_type == CONNECT_TYPE.input && index >= 0) {
			var _value = animator.getValue(0);
			node.inputs_data[index] = _value;
			node.input_value_map[$ internalName] = _value;
		}
		
		postApplyDeserialize();
		attributeApply();
		onValidate();
	}
	
	static postApplyDeserialize = function() {}
	
	static attributeApply = function() {
		if(struct_has(attributes, "mapped") && attributes.mapped) 
			mappableStep();
	}
	
	static connect = function(log = false, _nodeGroup = undefined) {
		if(con_node == -1 || con_index == -1) return true;
		
		var _node = con_node;
		if(APPENDING) {
			_node = GetAppendID(con_node);
			if(_node == noone) return true;
		}
		
		if(!ds_map_exists(PROJECT.nodeMap, _node)) {
			var txt = $"Node connect error : Node ID {_node} not found.";
			log_warning("LOAD", $"[Connect] {txt}", node);
			return false;
		}
		
		var _nd = PROJECT.nodeMap[? _node];
		var _ol = array_length(_nd.outputs);
		
		if(_nd.group != node.group) return true;
		if(_nodeGroup != undefined) {
			if(!struct_has(_nodeGroup, _node)) return true;
		}
		
		// if(log) log_warning("LOAD", $"    [Connect] Connecting {node.name} to {_nd.name}", node);
		
		switch(con_tag) {
			case VALUE_TAG.updateInTrigger  : return setFrom(_nd.updatedInTrigger);
			case VALUE_TAG.updateOutTrigger : return setFrom(_nd.updatedOutTrigger);
			case VALUE_TAG.matadata         : return setFrom(_nd.junc_meta[con_index]);
		}
		
		if(con_index >= 0 && con_index < _ol) {
			var _set = setFrom(_nd.outputs[con_index], false, true, log);
			if(_set) return true;
			
				 if(_set == -1) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Not connectable.",        node);
			else if(_set == -2) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Condition not met.",      node); 
			else                log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : General failure {_set}.", node);
			
			return false;
		} 
		
		if(con_index >= 1000) { //connect bypass
			var _inp = array_safe_get_fast(_nd.inputs, con_index - 1000, noone);
			if(_inp == noone) return false;
			
			var _set = setFrom(_inp.bypass_junc, false, true, log);
			if(_set) return true;
			
				 if(_set == -1) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} (bypass) : Not connectable.",        node);
			else if(_set == -2) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} (bypass) : Condition not met.",      node);  
			else                log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} (bypass) : General failure {_set}.", node);
			
			return false;
		}
		
		log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Output not exist [{con_index}].", node);
		
		return false;
	}
	
	////- MISC
	
	static globalExtractable = function() { return array_exists(global.GLOBALVAR_TYPES, type) && struct_find_key(global.GLOBALVAR_DISPLAY_MAP, display_type) != undefined; }
	
	static extractGlobal = function() {
		if(!globalExtractable()) return noone;
		
		var _key = $"{node.getDisplayName()}_{name}";
		    _key = string_to_var(_key);
		var _glb = node.project.globalNode;
		
		if(_glb.inputExist(_key))
			_key += string(array_length(_glb.inputs)); 
			
		var _newVal = _glb.createValue();
		
		_newVal.name = _key;
		_newVal.setType(type);
		_newVal.setDisplay(display_type, display_data);
		_newVal.editor.updateType();
		_newVal.setValue(getValue());
		_glb.step();
		
		if(!expUse) setExpression(_key);
		
		return _newVal;
	}
	
	static extractNode = function(_type = extract_node) {
		if(_type == "") return noone;
		
		var ext = nodeBuild(_type, node.x, node.y).skipDefault();
		ext.x -= ext.w + 32;
		
		for( var i = 0; i < array_length(ext.outputs); i++ )
			if(setFrom(ext.outputs[i])) break;
		
		var len = 2;
		
		switch(_type) {
			case "Node_Vector4": len++;
			case "Node_Vector3": len++;
			case "Node_Vector2": 
				for( var j = 0; j < len; j++ ) {
					var _in = ext.inputs[j];
					
					_in.setAnim(is_anim);
					_in.animator.values = [];
				}
				
				for( var i = 0; i < array_length(animator.values); i++ ) {
					var _arrVal = animator.values[i];
					
					for( var j = 0; j < len; j++ ) {
						var _in   = ext.inputs[j];
						var _kf   = _arrVal.clone(_in.animator);
						_kf.value = _kf.value[j];
						
						array_push(_in.animator.values, _kf);
					}
					
				}
				
				break;
		}
		
		ext.triggerRender();
	}
	
	static dragValue = function() {
		if(drop_key == "None") return;
		
		DRAGGING = { 
			type: drop_key, 
			data: showValue(),
		}
		
		if(type == VALUE_TYPE.path) {
			DRAGGING.data = new FileObject(DRAGGING.data);
			DRAGGING.data.getSpr();
		}
		
		if(connect_type == CONNECT_TYPE.input)
			DRAGGING.from = self;
	}
	
	static destroy = function() {
		if(error_notification != noone) {
			noti_remove(error_notification);
			error_notification = noone;
		}	
	}
	
	static cleanUp = function() {
		if(editWidget)  editWidget.free();
		if(mapWidget)   mapWidget.free();
		express_edit.free();
		
		if(bypass_junc) { bypass_junc.cleanUp(); delete bypass_junc; }
	}
		
	static toString = function() { return (connect_type == CONNECT_TYPE.input? "Input" : "Output") + $" junction {index} of [{name}]: {node}"; }
	
	static clone = function(_node) {
		var _n = new NodeValue(name, _node, connect, type, def_val, tooltip);
		    _n.setDisplay(display_type, display_data);
		
		return _n;
	}
	
}

/////FUNCTIONS

function checkJuncConnection(from, to, params) {
	if(from == noone || to == noone) return noone;
	if(!params.active || !PANEL_GRAPH.pHOVER) return noone;
	
	to.draw_line_shift_hover = false;
	
	var _s	= params.s;
	var mx	= params.mx;
	var my	= params.my;
	
	var jx  =   to.x, jy  =   to.y;
	var frx = from.x, fry = from.y;
	
	if(params.minx != 0 && params.maxx != 0) {
		if((jx < params.minx && frx < params.minx) || (jx > params.maxx && frx > params.maxx) || 
		   (jy < params.miny && fry < params.miny) || (jy > params.maxy && fry > params.maxy)) return noone;
	}

	var shx = to.draw_line_shift_x * _s;
	var shy = to.draw_line_shift_y * _s;
	
	var cx  = round((frx + jx) / 2 + shx);
	var cy  = round((fry + jy) / 2 + shy);
	var th  = max(1, PROJECT.graphConnection.line_width * _s);
	var hover, hovDist = max(th * 2, 12);
	
	var _fin = from.draw_line_shift_e > -1? from.draw_line_shift_e : from.drawLineIndex;
	var _tin = to.draw_line_shift_e   > -1? to.draw_line_shift_e   : to.drawLineIndex;
	
	var _x0 = min(jx, cx, frx) - hovDist - max(_fin, _tin) * PROJECT.graphConnection.line_extend;
	var _y0 = min(jy, cy, fry) - hovDist;
	
	var _x1 = max(jx, cx, frx) + hovDist + max(_fin, _tin) * PROJECT.graphConnection.line_extend;
	var _y1 = max(jy, cy, fry) + hovDist;
	
	var downDirection = to.type == VALUE_TYPE.action || from.type == VALUE_TYPE.action;
	var _loop   = params[$ "loop"] ?? false;
	var _chNode = params[$ "checkNode"] ?? noone;
	var _hPoint = [ 0, 0 ];
	
	if(_chNode == noone && !point_in_rectangle(mx, my, _x0, _y0, _x1, _y1)) return noone;
	
	if(_loop || from.node == to.node) {
		point_to_line_feedback(mx, my, jx, jy, frx, fry, _s, _hPoint);
		
	} else {
		
		switch(PROJECT.graphConnection.type) { 
			case 0 : 
				if(downDirection) point_to_line(mx, my, jx, jy, frx, fry, _hPoint);
				else              point_to_linear_connection(mx, my, frx, fry, jx, jy, _s, PROJECT.graphConnection.line_extend, _hPoint);
				break;
				
			case 1 : 
				if(downDirection) point_to_curve_corner(mx, my, jx, jy, frx, fry, _s, _hPoint);
				else              point_to_curve(mx, my, jx, jy, frx, fry, cx, cy, _s, _hPoint);
				break;
				
			case 2 : 
				if(downDirection) point_to_elbow_corner(mx, my, frx, fry, jx, jy, _hPoint);
				else              point_to_elbow(mx, my, frx, fry, jx, jy, cx, cy, _s, _hPoint);
				break;
				
			case 3 :
				if(downDirection) point_to_elbow_diag_corner(mx, my, frx, fry, jx, jy, _hPoint);
				else              point_to_elbow_diag(mx, my, frx, fry, jx, jy, cx, cy, _s, PROJECT.graphConnection.line_extend, _fin, _tin, _hPoint);
				break;
				
			default : return noone;
				
		}
	} 
	
	if(_chNode == noone) {
		var _dx = _hPoint[0] - mx;
		var _dy = _hPoint[1] - my;
		hover = _dx * _dx + _dy * _dy < hovDist * hovDist;
		
	} else
		hover = _chNode.pointIn(params.x, params.y, _hPoint[0], _hPoint[1], params.s);
	
	if(PANEL_GRAPH.value_focus == noone) to.draw_line_shift_hover = hover;
	return hover? self : noone;
}

function drawJuncConnection(from, to, params, _hover = 0) {
	if(from == noone || to == noone) return noone;
	
	static drawParam = {
		extend :    0,
		fromIndex : 0,
		toIndex :   0,
		corner :    0,
		type :      0,
	}
	
	var high = params.highlight;
	var bg   = params.bg;
	var aa   = params.aa;

	var _s	= params.s;
	var jx  =   to.x, jy  =   to.y;
	var frx = from.x, fry = from.y;
	
	if(params.minx != 0 && params.maxx != 0) {
		if((jx < params.minx && frx < params.minx) || (jx > params.maxx && frx > params.maxx) || 
		   (jy < params.miny && fry < params.miny) || (jy > params.maxy && fry > params.maxy)) return noone;
	}

	var shx = to.draw_line_shift_x * _s;
	var shy = to.draw_line_shift_y * _s;
	var cx  = round((frx + jx) / 2 + shx);
	var cy  = round((fry + jy) / 2 + shy);
	var th  = max(1, PROJECT.graphConnection.line_width * _s) * (1 + _hover);
	
	#region draw parameters	
		var corner = PROJECT.graphConnection.line_corner * _s;
		
		var ty = LINE_STYLE.solid;
		if(to.type == VALUE_TYPE.node || struct_try_get(params, "dashed"))
			ty = LINE_STYLE.dashed;
		
		var c0, c1;
		var _selc = to.node.branch_drawing && from.node.branch_drawing;
		
		if(high) {
			var _fade = PROJECT.graphConnection.line_highlight_fade;
			var _colr = _selc? 1 : _fade;
			
			c0 = merge_color(bg, from.custom_color == noone? from.color_display : from.custom_color, _colr);
			c1 = merge_color(bg,   to.custom_color == noone?   to.color_display :   to.custom_color, _colr);
			
			to.draw_blend_color = bg;
			to.draw_blend       = _colr;
			from.draw_blend     = max(from.draw_blend, _colr);
		} else {
			c0 = from.custom_color == noone? from.color_display : from.custom_color;
			c1 =   to.custom_color == noone?   to.color_display :   to.custom_color;
			
			to.draw_blend_color = bg;
			to.draw_blend       = -1;
		}
	#endregion
		
	var ss  = _s * aa;
	jx  *= aa;
	jy  *= aa;
	frx *= aa;
	fry *= aa;
	cx  *= aa;
	cy  *= aa;
	corner *= aa;
	th = max(1, round(th * aa));
	
	var _loop = params[$ "loop"] ?? false;
	if(_loop) { draw_line_feedback(jx, jy, frx, fry, th, c1, c0, ss); return; }
	
	var down = to.type == VALUE_TYPE.action || from.type == VALUE_TYPE.action;
	drawParam.extend    = PROJECT.graphConnection.line_extend;
	drawParam.fromIndex = from.draw_line_shift_e > -1? from.draw_line_shift_e : from.drawLineIndex;
	drawParam.toIndex   = to.draw_line_shift_e   > -1? to.draw_line_shift_e   : to.drawLineIndex;
	drawParam.corner    = corner;
	drawParam.type      = ty;
	
	switch(PROJECT.graphConnection.type) { 
		case 0 : 
			if(down)	draw_line_width_color(jx, jy, frx, fry, th, c0, c1);
			else    	draw_line_connect(frx, fry, jx, jy, ss, th, c0, c1, drawParam);
			break;
			
		case 1 : 
			if(down)	draw_line_curve_corner(frx, fry, jx, jy, ss, th, c0, c1); 
			else		draw_line_curve_color(jx, jy, frx, fry, cx, cy, ss, th, c0, c1, ty); 
			break;
			
		case 2 : 
			if(down)	draw_line_elbow_corner(frx, fry, jx, jy, ss, th, c0, c1, drawParam); 
			else		draw_line_elbow_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, drawParam); 
			break;
			
		case 3 : 
			if(down)	draw_line_elbow_diag_corner(frx, fry, jx, jy, ss, th, c0, c1, drawParam); 
			else		draw_line_elbow_diag_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, drawParam); 
			break;
	} 
}