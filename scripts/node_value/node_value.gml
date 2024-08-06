function nodeValue(_name, _node, _connect, _type, _value, _tooltip = "") { return new NodeValue(_name, _node, _connect, _type, _value, _tooltip); }
function nodeValueMap(_name, _node, _junc = noone)						 { return new NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone).setVisible(false, false).setMapped(_junc); }
function nodeValueGradientRange(_name, _node, _junc = noone)			 { return new NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 1, 0 ])
																						.setDisplay(VALUE_DISPLAY.gradient_range).setVisible(false, false).setMapped(_junc); }
																						
function nodeValueSeed(_node, _type) { 
	var _val = new NodeValue("Seed", _node, JUNCTION_CONNECT.input, _type, seed_random(6), "");
	__node_seed_input_value = _val;
	_val.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() /*=>*/ { randomize(); __node_seed_input_value.setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	return _val; 
}

function NodeValue(_name, _node, _connect, _type, _value, _tooltip = "") constructor {
	static DISPLAY_DATA_KEYS = [ "linked", "angle_display", "bone_id", "unit", "atlas_crop" ];
	
	#region ---- main ----
		active  = true;
		from    = noone;
		node    = _node;
		x	    = node.x;
		y       = node.y;
		rx      = x;
		ry      = y;
		
		index   = _connect == JUNCTION_CONNECT.input? ds_list_size(node.inputs) : ds_list_size(node.outputs);
		type    = _type;
		forward = true;
		_initName = _name;
		
		node.will_setHeight = true;
		
		static updateName = function(_name) {
			name         = _name;
			internalName = string_to_var(name);
			name_custom  = true;
		} updateName(_name);
		
		name_custom = false;
		
		if(struct_has(node, "inputMap")) {
				 if(_connect == JUNCTION_CONNECT.input)  node.inputMap[?  internalName] = self;
			else if(_connect == JUNCTION_CONNECT.output) node.outputMap[? internalName] = self;
		}
		
		tooltip        = _tooltip;
		editWidget     = noone;
		editWidgetRaw  = noone;
		graphWidget    = noone;
		graphWidgetH   = 0;
		graphWidgetP   = new widgetParam(0, 0, 0, 0, 0);
		mapWidget      = noone;
		active_tooltip = "";
		
		tags = VALUE_TAG.none;
		
		is_dummy   = false;
		dummy_get  = noone;
		dummy_undo = -1;
		dummy_redo = -1;
	#endregion
	
	#region ---- connection ----
		connect_type    = _connect;
		value_from      = noone;
		value_from_loop = noone;
		
		value_to      = [];
		value_to_loop = [];
		
		accept_array = true;
		array_depth  = 0;
		auto_connect = true;
		setFrom_condition = -1;
		
		onSetFrom = noone;
		onSetTo   = noone;
	#endregion
	
	#region ---- animation ----
		if(_type == VALUE_TYPE.color) {
			if(is_array(_value)) for( var i = 0, n = array_length(_value); i < n; i++ ) _value[i] = cola(_value[i]);
			else                 _value = cola(_value);
		}
		
		key_inter   = CURVE_TYPE.linear;
		
		is_anim		= false;
		sep_axis	= false;
		animable    = true;
		sepable		= is_array(_value) && array_length(_value) > 1;
		animator	= new valueAnimator(_value, self, false);
		animators	= [];
		
		if(is_array(_value))
		for( var i = 0, n = array_length(_value); i < n; i++ ) {
			animators[i] = new valueAnimator(_value[i], self, true);
			animators[i].index = i;
		}
		
		on_end		= KEYFRAME_END.hold;
		loop_range  = -1;
	#endregion
	
	#region ---- value ----
		def_val	    = variable_clone(_value);
		def_length  = is_array(def_val)? array_length(def_val) : 0;
		def_depth   = array_get_depth(def_val);
		unit		= new nodeValueUnit(self);
		def_unit    = VALUE_UNIT.constant;
		dyna_depo   = ds_list_create();
		value_tag   = "";
		
		is_modified = false;
		cache_value = [ false, false, undefined, undefined ];
		cache_array = [ false, false ];
		use_cache   = true;
		record_value = true;
		
		process_array = true;
		dynamic_array = false;
		validateValue = true;
		runInUI       = false;
		
		fullUpdate = false;
		
		attributes = {};
		
		node.inputs_data[index] = _value;
		node.input_value_map[$ internalName] = _value;
		
		__curr_get_val = [ 0, 0 ];
		
		validator = noone;
	#endregion
	
	#region ---- draw ----
		draw_line_shift_x	  = 0;
		draw_line_shift_y	  = 0;
		draw_line_thick		  = 1;
		draw_line_shift_hover = false;
		draw_line_blend       = 1;
		draw_line_feed		  = false;
		drawLineIndex		  = 1;
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
		
		__overlay_hover   = [];
		overlay_draw_text = true;
		
		graph_selecting   = false;
	#endregion
	
	#region ---- timeline ----
		show_graph	= false;
		show_graphs = array_create(array_safe_length(_value));
		graph_h		= ui(96);
	#endregion
	
	#region ---- inspector ----
		visible = _connect == JUNCTION_CONNECT.output || _type == VALUE_TYPE.surface || _type == VALUE_TYPE.path || _type == VALUE_TYPE.PCXnode;
		show_in_inspector = true;
		visible_in_list   = true;
	
		display_type = VALUE_DISPLAY._default;
		if(_type == VALUE_TYPE.curve)			display_type = VALUE_DISPLAY.curve;
		else if(_type == VALUE_TYPE.d3vertex)	display_type = VALUE_DISPLAY.d3vertex;
		
		display_data		= {};
		display_attribute	= noone;
		
		popup_dialog = noone;
	#endregion
	
	#region ---- graph ----
		value_validation = VALIDATION.pass;
		error_notification = noone;
		
		extract_node = "";
	#endregion
	
	#region ---- expression ----
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
	
	#region ---- serialization ----
		con_node  = -1;
		con_index = -1;
	#endregion
	
	/////============= META =============
	
	static setDummy = function(get_node, _dummy_undo = -1, _dummy_redo = -1) { #region
		is_dummy  = true;
		dummy_get = get_node;
		
		dummy_undo = _dummy_undo;
		dummy_redo = _dummy_redo;
		
		return self;
	} #endregion
	
	static setActive = function(_active, _tooltip) { #region
		INLINE
		active = _active;
		active_tooltip = _tooltip;
		
		return self;
	} #endregion
	
	static setWindows = function() { #region
		INLINE
		setActive(OS == os_windows, "Not available on MacOS");
		
		return self;
	} #endregion
	
	static nonValidate = function() { #region
		validateValue = false;
		return self;
	} #endregion
	
	static nonForward = function() { #region
		forward = false;
		return self;
	} #endregion
	
	/////============= NAME =============
	
	static getName = function() { #region
		if(name_custom) return name;
		return __txt_junction_name(instanceof(node), connect_type, index, name);
	} #endregion
	
	static setName = function(_name) { #region
		INLINE
		name = _name;
		return self;
	} #endregion
	
	/////============= VALUE ============
	
	static setType = function(_type) {
		if(type == _type) return false;
		
		type = _type;
		draw_junction_index = type;
		
		return true;
	}
	
	static setDefault = function(vals) { #region
		if(LOADING || APPENDING) return self;
		
		ds_list_clear(animator.values);
		for( var i = 0, n = array_length(vals); i < n; i++ )
			ds_list_add(animator.values, new valueKey(vals[i][0], vals[i][1], animator));
			
		return self;
	} #endregion
	
	static resetValue = function() { #region
		unit.mode = def_unit;
		setValue(unit.apply(variable_clone(def_val))); 
		attributes.mapped = false;
		
		is_modified = false; 
	} #endregion
	
	static setUnitRef = function(ref, mode = VALUE_UNIT.constant) { #region
		express_edit.side_button = unit.triggerButton;
		
		if(editWidget) {
			editWidget.unit = unit;
			
			if(is_instanceof(editWidget, textBox))
				editWidget.side_button = unit.triggerButton;
		}
		
		unit.reference  = ref;
		unit.mode		= mode;
		def_unit        = mode;
		cache_value[0]  = false;
		
		return self;
	} #endregion
	
	static setValidator = function(val) {
		validator = val;
		
		return self;
	}
	
	static rejectArray     = function()       { accept_array = false; return self; } 
	static setArrayDepth   = function(aDepth) { array_depth = aDepth; return self; }
	static setArrayDynamic = function()       { dynamic_array = true; return self; }
	
	static rejectArrayProcess = function() { #region
		process_array = false;
		return self;
	} #endregion
	
	static setDropKey = function() { #region
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
	} setDropKey(); #endregion
	
	mappedJunc  = noone;
	mapped_vec4 = false;
	
	static setMappable = function(index, vec4 = false) { #region
		attributes.mapped     = false;
		attributes.map_index  = index;
		mapped_vec4 = vec4;
		
		mapButton = button(function() { 
						attributes.mapped = !attributes.mapped;
						
						if(type == VALUE_TYPE.integer || type == VALUE_TYPE.float) {
							if(attributes.mapped) setValue(mapped_vec4? [ 0, 0, 0, 0 ] : [ 0, 0 ]);
							else                  setValue(def_val);
							setArrayDepth(attributes.mapped);
						}
						
						node.triggerRender(); 
					})
				.setIcon( THEME.value_use_surface, [ function() { return attributes.mapped; } ], COLORS._main_icon )
				.setTooltip("Toggle map");
		
		switch(type) {
			case VALUE_TYPE.gradient :
				mapWidget = noone;
				break;
				
			default : 
				mapWidget = vec4? 
					new vectorRangeBox(4, TEXTBOX_INPUT.number, function(val, index) { return setValueDirect(val, index); }) : 
					new rangeBox(         TEXTBOX_INPUT.number, function(val, index) { return setValueDirect(val, index); });
				mapWidget.side_button = mapButton;
				break;
		}
		
		editWidget.side_button = mapButton;
		
		return self;
	} #endregion
	
	static setMapped = function(junc) { #region
		mappedJunc = junc;
		isTimelineVisible = function() { INLINE return is_anim && value_from == noone && mappedJunc.attributes.mapped; }
		return self;
	} #endregion
	
	static mappableStep = function() { #region
		editWidget = mapWidget && attributes.mapped? mapWidget : editWidgetRaw;
		setArrayDepth(attributes.mapped);
		
		var inp = node.inputs[| attributes.map_index];
		var vis = attributes.mapped && show_in_inspector;
		
		if(inp.visible != vis) {
			inp.visible = vis;
			node.refreshNodeDisplay();
		}
		
	} #endregion
	
	/////========== ANIMATION ==========
	
	static setAnimable = function(_anim) { #region
		animable = _anim;
		return self;
	} #endregion
	
	static isAnimable = function() { #region
		if(type == VALUE_TYPE.PCXnode)				 return false;
		if(display_type == VALUE_DISPLAY.text_array) return false;
		return animable;
	} #endregion
	
	static setAnim = function(anim, record = false) { #region
		if(is_anim == anim) return;
		if(record) {
			recordAction(ACTION_TYPE.custom, function(data) {
				setAnim(data.is_anim);
				data.is_anim = !data.is_anim;
			}, { anim: is_anim });
		}
		is_anim = anim;
		
		if(is_anim) {
			if(ds_list_empty(animator.values))
				ds_list_add(animator.values, new valueKey(CURRENT_FRAME, animator.getValue(), animator));
			animator.values[| 0].time = CURRENT_FRAME;
			animator.updateKeyMap();
			
			for( var i = 0, n = array_length(animators); i < n; i++ ) {
				if(ds_list_empty(animators[i].values))
					ds_list_add(animators[i].values, new valueKey(CURRENT_FRAME, animators[i].getValue(), animators[i]));
				animators[i].values[| 0].time = CURRENT_FRAME;
				animators[i].updateKeyMap();
			}
		} else {
			var _val = animator.getValue();
			ds_list_clear(animator.values);
			animator.values[| 0] = new valueKey(0, _val, animator);
			animator.updateKeyMap();
			
			for( var i = 0, n = array_length(animators); i < n; i++ ) {
				var _val = animators[i].getValue();
				ds_list_clear(animators[i].values);
				animators[i].values[| 0] = new valueKey(0, _val, animators[i]);
				animators[i].updateKeyMap();
			}
		}
		
		if(type == VALUE_TYPE.gradient && struct_has(attributes, "map_index")) 
			node.inputs[| attributes.map_index + 1].setAnim(anim);
		
		node.refreshTimeline();
	} #endregion
		
	/////============ DISPLAY ===========
	
	static setVisible = function(inspector) {
		var v = visible;
		
		if(connect_type == JUNCTION_CONNECT.input) {
			show_in_inspector = inspector;
			visible = argument_count > 1? argument[1] : visible;
		} else 
			visible = inspector;
			
		node.will_setHeight |= visible != v;
		return self;
	}
	
	static setDisplay = function(_type = VALUE_DISPLAY._default, _data = {}) { #region
		display_type	  = _type;
		display_data	  = _data;
		resetDisplay();
		
		return self;
	} #endregion
	
	static resetDisplay = function() { #region //////////////////// RESET DISPLAY ////////////////////
		editWidget = noone;
		switch(display_type) {
			case VALUE_DISPLAY.button : #region
				var _onClick;
				
				if(struct_has(display_data, "onClick"))
					_onClick = method(node, display_data.onClick);
				else 
					_onClick = function() { setAnim(true); setValueDirect(true); };
				
				editWidget   = button(_onClick).setText(struct_try_get(display_data, "name", "Trigger"));
				runInUI      = struct_try_get(display_data, "UI", false);
				
				visible = false;
				rejectArray();
				
				return; #endregion
		}
		
		switch(type) {
			case VALUE_TYPE.float :
			case VALUE_TYPE.integer :
				var _txt = TEXTBOX_INPUT.number;
				
				switch(display_type) { 
					case VALUE_DISPLAY._default :		#region
						editWidget = new textBox(_txt, function(val) { return setValueInspector(val); } );
						
						if(struct_has(display_data, "unit"))		 editWidget.unit			= display_data.unit;
						if(struct_has(display_data, "front_button")) editWidget.front_button	= display_data.front_button;
						
						extract_node = "Node_Number";
						break; #endregion
						
					case VALUE_DISPLAY.range :			#region
						editWidget = new rangeBox(_txt, function(val, index) { return setValueInspector(val, index); } );
						
						if(!struct_has(display_data, "linked")) display_data.linked = false;
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get_fast(global.displaySuffix_Range, i);
						
						extract_node = "Node_Number";
						break; #endregion
						
					case VALUE_DISPLAY.vector :			#region
						var val = animator.getValue();
						var len = array_length(val);
						
						if(len <= 4) {
							editWidget = new vectorBox(len, function(val, index) { return setValueInspector(val, index); }, unit );
							
							if(struct_has(display_data, "label"))		 editWidget.axis	    = display_data.label;
							if(struct_has(display_data, "linkable"))	 editWidget.linkable    = display_data.linkable;
							if(struct_has(display_data, "per_line"))	 editWidget.per_line    = display_data.per_line;
							if(struct_has(display_data, "linked"))		 editWidget.linked      = display_data.linked;
							
							if(len == 2) {
								var _dim = struct_try_get(display_data, "useGlobal", true);
								extract_node = [ "Node_Vector2", "Node_Path" ];
								
								if(_dim && array_equals(def_val, DEF_SURF)) {
									value_tag = "dimension";
									node.attributes.use_project_dimension = true;
									editWidget.side_button = button(function() {
										node.attributes.use_project_dimension = !node.attributes.use_project_dimension;
										node.triggerRender();
									}).setIcon(THEME.node_use_project, 0, COLORS._main_icon).setTooltip("Use project dimension");
								}
							} else if(len == 3)
								extract_node = "Node_Vector3";
							else if(len == 4)
								extract_node = "Node_Vector4";
						}
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + string(array_safe_get_fast(global.displaySuffix_Axis, i));
						
						break; #endregion
						
					case VALUE_DISPLAY.vector_range :	#region
						var val = animator.getValue();
						
						editWidget = new vectorRangeBox(array_length(val), _txt, function(val, index) { return setValueInspector(val, index); }, unit );
						
						
						if(!struct_has(display_data, "linked")) display_data.linked = false;
						if(!struct_has(display_data, "ranged")) display_data.ranged = false;
						
							 if(array_length(val) == 2) extract_node = "Node_Vector2";
						else if(array_length(val) == 3) extract_node = "Node_Vector3";
						else if(array_length(val) == 4) extract_node = "Node_Vector4";
							
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + string(array_safe_get_fast(global.displaySuffix_VecRange, i));
						
						break; #endregion
						
					case VALUE_DISPLAY.rotation :		#region
						var _step = struct_try_get(display_data, "step", -1); 
						
						editWidget = new rotator(function(val) {
							return setValueInspector(val);
						}, _step );
						
						extract_node = "Node_Number";
						break; #endregion
						
					case VALUE_DISPLAY.rotation_range : #region
						editWidget = new rotatorRange(function(val, index) { return setValueInspector(val, index); } );
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get_fast(global.displaySuffix_Range, i);
						
						extract_node = "Node_Vector2";
						break; #endregion
						
					case VALUE_DISPLAY.rotation_random : #region
						editWidget = new rotatorRandom(function(val, index) { return setValueInspector(val, index); } );
						
						extract_node = "Node_Vector2";
						break; #endregion
						
					case VALUE_DISPLAY.slider :			#region
						var _range = struct_try_get(display_data, "range", [ 0, 1 ]);
						
						editWidget = new textBox(TEXTBOX_INPUT.number, function(val) { return setValueInspector(toNumber(val)); } )
										.setSlideRange(_range[0], _range[1]);
						
						if(struct_has(display_data, "update_stat"))
							editWidget.update_stat = display_data.update_stat;
						
						extract_node = "Node_Number";
						break; #endregion
						
					case VALUE_DISPLAY.slider_range :	#region
						var _range = struct_try_get(display_data, "range", [ 0, 1, 0.01 ]);
						
						editWidget = new sliderRange(_range[2], type == VALUE_TYPE.integer, [ _range[0], _range[1] ], 
							function(val, index) { return setValueInspector(val, index); } );
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get_fast(global.displaySuffix_Range, i);
						
						extract_node = "Node_Vector2";
						break; #endregion
						
					case VALUE_DISPLAY.area :			#region
						editWidget = new areaBox(function(val, index) { return setValueInspector(val, index); }, unit);
						
						editWidget.onSurfaceSize = struct_try_get(display_data, "onSurfaceSize", noone);
						editWidget.showShape     = struct_try_get(display_data, "useShape", true);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get_fast(global.displaySuffix_Area, i, "");
						
						extract_node = "Node_Area";
						break; #endregion
						
					case VALUE_DISPLAY.padding :		#region
						editWidget = new paddingBox(function(val, index) { return setValueInspector(val, index); }, unit);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get_fast(global.displaySuffix_Padding, i);
						
						extract_node = "Node_Vector4";
						break; #endregion
						
					case VALUE_DISPLAY.corner :			#region
						editWidget = new cornerBox(function(val, index) { return setValueInspector(val, index); }, unit);
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = " " + array_safe_get_fast(global.displaySuffix_Padding, i);
						
						extract_node = "Node_Vector4";
						break; #endregion
						
					case VALUE_DISPLAY.puppet_control : #region
						editWidget = new controlPointBox(function(val, index) { return setValueInspector(val, index); });
						
						extract_node = "";
						break; #endregion
						
					case VALUE_DISPLAY.enum_scroll :	#region
						if(!is_struct(display_data)) display_data = { data: display_data };
						var choices = __txt_junction_data(instanceof(node), connect_type, index, display_data.data);
						
						editWidget = new scrollBox(choices, function(val) /*=>*/ { if(val == -1) return; return setValueInspector(toNumber(val)); } );
						
						if(struct_has(display_data, "update_hover")) editWidget.update_hover = display_data.update_hover;
						if(struct_has(display_data, "horizontal"))   editWidget.horizontal   = display_data.horizontal;
						if(struct_has(display_data, "item_pad"))     editWidget.item_pad     = display_data.item_pad;
						if(struct_has(display_data, "text_pad"))     editWidget.text_pad     = display_data.text_pad;
						
						rejectConnect();
						key_inter    = CURVE_TYPE.cut;
						extract_node = "";
						break; #endregion
						
					case VALUE_DISPLAY.enum_button :	#region
						if(!is_struct(display_data)) display_data = { data: display_data };
						var choices = __txt_junction_data(instanceof(node), connect_type, index, display_data.data);
						
						editWidget = new buttonGroup(choices, function(val) { return setValueInspector(val); } );
						
						rejectConnect();
						key_inter    = CURVE_TYPE.cut;
						extract_node = "";
						break; #endregion
						
					case VALUE_DISPLAY.matrix :			#region
						editWidget = new matrixGrid(_txt, display_data.size, function(val, index) { return setValueInspector(val, index); }, unit );
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {i}";
						
						extract_node = "";
						break; #endregion
						
					case VALUE_DISPLAY.boolean_grid : #region
						editWidget = new matrixGrid(_txt, display_data.size, function(val, index) { return setValueInspector(val, index); }, unit );
						
						for( var i = 0, n = array_length(animators); i < n; i++ )
							animators[i].suffix = $" {i}";
						
						extract_node = "";
						break; #endregion
						
					case VALUE_DISPLAY.transform :		#region
						editWidget = new transformBox(function(val, index) { return setValueInspector(val, index); });
						
						extract_node = "Node_Transform_Array";
						break; #endregion
						
					case VALUE_DISPLAY.toggle :			#region
						editWidget = new toggleGroup(display_data.data, function(val) { return setValueInspector(val); } );
						
						rejectConnect();
						key_inter    = CURVE_TYPE.cut;
						extract_node = "";
						break; #endregion
						
					case VALUE_DISPLAY.d3quarternion :	#region
						editWidget = new quarternionBox(function(val, index) { return setValueInspector(val, index); });
						
						extract_node = "Node_Vector4";
						display_data.angle_display = QUARTERNION_DISPLAY.euler;
						break; #endregion
						
					case VALUE_DISPLAY.path_anchor :	#region
						editWidget = new pathAnchorBox(function(val, index) { return setValueInspector(val, index); });
						
						extract_node = "Node_Path_Anchor";
						break; #endregion
						
				}
				
				if(editWidget && struct_has(editWidget, "setSlideType")) editWidget.setSlideType(type == VALUE_TYPE.integer);
				break;
				
			case VALUE_TYPE.boolean :	 #region
				if(name == "Active") editWidget = new checkBoxActive(function() { return setValueInspector(!animator.getValue()); } );
				else				 editWidget = new checkBox(      function() { return setValueInspector(!animator.getValue()); } );
				
				key_inter    = CURVE_TYPE.cut;
				extract_node = "Node_Boolean";
				break; #endregion
				
			case VALUE_TYPE.color :		 #region
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget = new buttonColor(function(color) { return setValueInspector(color); } );
						
						graph_h		 = ui(16);
						extract_node = "Node_Color";
						break;
						
					case VALUE_DISPLAY.palette :
						editWidget = new buttonPalette(function(color) { return setValueInspector(color); } );
						
						extract_node = "Node_Palette";
						break;
				}
				break; #endregion
				
			case VALUE_TYPE.gradient :	 #region
				editWidget = new buttonGradient(function(gradient) { return setValueInspector(gradient); } );
						
				extract_node = "Node_Gradient_Out";
				break; #endregion
				
			case VALUE_TYPE.path :		 #region
				switch(display_type) {
					case VALUE_DISPLAY.path_array :
						editWidget = new pathArrayBox(self, display_data.filter, function(path) { setValueInspector(path); } );
						break;
						
					case VALUE_DISPLAY.path_load :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) { setValueInspector(str); } );
							
						editWidget.align = fa_left;
						editWidget.side_button = button(function() { 
							var path = display_data.filter == "dir"? get_directory("") : get_open_filename_pxc(display_data.filter, "");
							key_release();
							if(path == "") return noone;
							return setValueInspector(path);
						}, THEME.button_path_icon);
						
						extract_node = "Node_String";
						break;
						
					case VALUE_DISPLAY.path_save :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) { setValueInspector(str); } );
						
						editWidget.align = fa_left;
						editWidget.side_button = button(function() { 
							var path = get_save_filename_pxc(display_data.filter, "");
							key_release();
							if(path == "") return noone;
							return setValueInspector(path);
						}, THEME.button_path_icon);
						
						extract_node = "Node_String";
						break;
						
					case VALUE_DISPLAY.path_font :
						editWidget = new fontScrollBox( function(val) { return setValueInspector(FONT_INTERNAL[val]); } );
						break;
				}
				break; #endregion
				
			case VALUE_TYPE.curve :		 #region
				display_type = VALUE_DISPLAY.curve;
				editWidget = new curveBox(function(_modified) { return setValueInspector(_modified); });
				break; #endregion
				
			case VALUE_TYPE.text :		 #region
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget = new textArea(TEXTBOX_INPUT.text, function(str) { return setValueInspector(str); });
						extract_node = "Node_String";
						break;
						
					case VALUE_DISPLAY.text_box :
						editWidget = new textBox(TEXTBOX_INPUT.text, function(str) { return setValueInspector(str); });
						extract_node = "Node_String";
						break;
					
					case VALUE_DISPLAY.codeLUA :
						editWidget = new textArea(TEXTBOX_INPUT.text, function(str) { return setValueInspector(str); });
						
						editWidget.font = f_code;
						editWidget.format = TEXT_AREA_FORMAT.codeLUA;
						editWidget.min_lines = 4;
						extract_node = "Node_String";
						break;
						
					case VALUE_DISPLAY.codeHLSL:
						editWidget = new textArea(TEXTBOX_INPUT.text, function(str) { return setValueInspector(str); });
						
						editWidget.autocomplete_server	 = hlsl_autocomplete_server;
						editWidget.function_guide_server = hlsl_function_guide_server;
						editWidget.parser_server		 = hlsl_document_parser;
						editWidget.autocomplete_object	 = node;
						
						editWidget.font      = f_code;
						editWidget.format    = TEXT_AREA_FORMAT.codeHLSL;
						editWidget.min_lines = 4;
						extract_node = "Node_String";
						break;
						
					case VALUE_DISPLAY.text_tunnel :
						editWidget = new textArea(TEXTBOX_INPUT.text, function(str) { return setValueInspector(str); });
						
						editWidget.autocomplete_server	 = tunnel_autocomplete_server;
						
						extract_node = "Node_String";
						break;
					
					case VALUE_DISPLAY.text_array :
						editWidget = new textArrayBox(function() { return animator.values[| 0].value; }, display_data.data, function() { node.doUpdate(); });
						break;
				}
				break; #endregion
				
			case VALUE_TYPE.d3Material : #region
				editWidget = new materialBox(function(ind) { 
					var res = setValueInspector(ind); 
					node.triggerRender();
					return res;
				} );
				
				if(!struct_has(display_data, "atlas")) display_data.atlas = true;
				show_in_inspector = true;
				extract_node = "Node_Canvas";
				break; #endregion
				
			case VALUE_TYPE.surface :	 #region
				editWidget = new surfaceBox(function(ind) { return setValueInspector(ind); } );
				
				if(!struct_has(display_data, "atlas")) display_data.atlas = true;
				show_in_inspector = true;
				extract_node = "Node_Canvas";
				break; #endregion
				
			case VALUE_TYPE.pathnode :	 #region
				extract_node = "Node_Path";
				break; #endregion
		}
		
		if(is_struct(display_data) && struct_has(display_data, "side_button") && editWidget.side_button == noone)
			editWidget.side_button = display_data.side_button;
		
		editWidgetRaw = editWidget;
		if(editWidget) graphWidget = editWidget.clone();
		
		for( var i = 0, n = ds_list_size(animator.values); i < n; i++ ) {
			animator.values[| i].ease_in_type   = key_inter;
			animator.values[| i].ease_out_type  = key_inter;
		}
		
		setDropKey();
	} resetDisplay(); #endregion
	
	/////============ RENDER ============
	
	static isRendered = function() {
		if(type == VALUE_TYPE.node)	return true;
		
		if(value_from == noone) return true;
		
		var controlNode = value_from.from? value_from.from : value_from.node;
		if(!controlNode.active)			  return true;
		if(!controlNode.isRenderActive()) return true;
		
		return controlNode.rendered;
	}
	
	static isActiveDynamic = function() {
		INLINE
		
		if(value_from_loop)     return true;
		if(value_from != noone) return false;
		
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
	static isDynamic = function() {
		INLINE
		
		if(__init_dynamic)    { __init_dynamic = false; return true; }
		if(!IS_PLAYING)         return true;
		if(value_from_loop)     return true;
		if(value_from != noone) return true;
		
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
	
	/////============= CACHE ============
	
	static uncache = function() { #region
		use_cache = false;
		return self;
	} #endregion
	
	static resetCache = function() { cache_value[0] = false; }
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		
		if(applyUnit && display_type == VALUE_DISPLAY.d3quarternion && display_data.angle_display == QUARTERNION_DISPLAY.euler)
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
			
			return is_real(value)? new gradientObject(value) : new gradientObject(cola(c_black));
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
		
		if(typeNumeric(typeFrom) && type == VALUE_TYPE.color) return value >= 1? value : make_color_rgb(value * 255, value * 255, value * 255);
		
		if(typeFrom == VALUE_TYPE.boolean && type == VALUE_TYPE.text) return value? "true" : "false";
		
		if(type == VALUE_TYPE.integer || type == VALUE_TYPE.float) {
			if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
			
			value = applyUnit? unit.apply(value, arrIndex) : value;
			
			if(value_tag == "dimension")
				for( var i = 0, n = array_length(value); i < n; i++ ) value[i] = clamp(value[i], 0, 8192);
			
			if(validator != noone) value = validator.validate(value);
			
			return value;
		}
		
		if(type == VALUE_TYPE.surface && connect_type == JUNCTION_CONNECT.input && !is_surface(value) && def_val == USE_DEF)
			return DEF_SURFACE;
		
		return value;
	}
	
	static getStaticValue = function() { INLINE return ds_list_empty(animator.values)? 0 : animator.values[| 0].value; } 
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		draw_junction_index = type;
		if(type == VALUE_TYPE.trigger)
			return _getValue(_time, false, 0, false);
		
		if(useCache && use_cache) {
			var cache_hit = cache_value[0];
			cache_hit &= !isActiveDynamic(_time) || cache_value[1] == _time;
			cache_hit &= cache_value[2] != undefined;
			cache_hit &= cache_value[3] == applyUnit;
			cache_hit &= connect_type == JUNCTION_CONNECT.input;
			cache_hit &= unit.reference == noone || unit.mode == VALUE_UNIT.constant;
			
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
		var nod = __curr_get_val[1];
		
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(connect_type == JUNCTION_CONNECT.output) return val;
		
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
		
		arr[@ 0] = __getAnimValue(_time);
		arr[@ 1] = self;
		
		if(value_from_loop && value_from_loop.bypassConnection() && value_from_loop.junc_out)
			value_from_loop.getValue(arr);
			
		else if(value_from && value_from != self)
			value_from.getValueRecursive(arr, _time);
		
		if(!expUse || !expTree.validate()) return;
			
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
		if(!is_array(def_val))
			return val;
			
		if(isDynamicArray()) 
			return val;
		
		if(isArray(val))
			return val;
		
		if(!is_array(val))
			return array_create(def_length, val);
		
		if(array_length(val) < def_length)
			array_resize(val, def_length);
		
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		
		if(value_tag == "dimension" && node.attributes.use_project_dimension)
			return PROJECT.attributes.surface_dimension;
		
		if(!is_anim) {
			if(sep_axis) {
				var val = array_create(array_length(animators));
				for( var i = 0, n = array_length(animators); i < n; i++ )
					val[i] = animators[i].processType(animators[i].values[| 0].value);
				return val;
			}
			
			if(ds_list_empty(animator.values)) return 0;
			
			return animator.processType(animator.values[| 0].value);
		}
		
		if(sep_axis) {
			var val = [];
			for( var i = 0, n = array_length(animators); i < n; i++ )
				val[i] = animators[i].getValue(_time);
			return val;
		} 
		
		return animator.getValue(_time);
	}
	
	static isTimelineVisible = function() { INLINE return is_anim && value_from == noone; }
	
	show_val = [];
	static showValue = function() { ////showValue
		INLINE
		
		var val = 0;
		
		if(value_from != noone || is_anim || expUse) 
			val = getValue(CURRENT_FRAME, false);
			
		else if(sep_axis) {
			show_val = array_verify(show_val, array_length(animators));
			for( var i = 0, n = array_length(animators); i < n; i++ )
				show_val[i] = ds_list_empty(animators[i].values)? 0 : animators[i].processType(animators[i].values[| 0].value);
			val = show_val;
		} else 
			val = ds_list_empty(animator.values)? 0 : animator.processType(animator.values[| 0].value);
		
		return val;
	}
	
	static unitConvert = function(mode) {
		var _v = animator.values;
		
		for( var i = 0; i < ds_list_size(_v); i++ )
			_v[| i].value = unit.convertUnit(_v[| i].value, mode);
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
		var _cac = val == undefined;
		
		if(_cac) {
			if(cache_array[0]) return cache_array[1];
			val = getValue();
			cache_array[0] = true;
		}
		
		var _dep = __array_get_depth(val) > array_depth + typeArray(display_type);
		if(_cac) cache_array[1] = _dep;
		return _dep;
	}
	
	static arrayLength = function(val = undefined) {
		val ??= getValue();
		
		if(!isArray(val)) 
			return -1;
		
		if(array_depth == 0 && !typeArray(display_type)) 
			return array_length(val);
		
		var ar     = val;
		var _depth = max(0, array_depth + typeArray(display_type) - 1);
		repeat(_depth)
			ar = ar[0];
		
		return array_length(ar);
	}
	
	/////============== SET =============
	
	static onValidate = function() { #region
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
		
		node.onValidate();
		
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
	} #endregion
	
	static setValue = function(val = 0, record = true, time = CURRENT_FRAME, _update = true) { ////Set value
		val = unit.invApply(val);
		return setValueDirect(val, noone, record, time, _update);
	}
	
	static overrideValue = function(_val) { #region
		ds_list_clear(animator.values);
		ds_list_add(animator.values, new valueKey(0, _val, animator));
		
		for( var i = 0, n = array_length(animators); i < n; i++ ) {
			ds_list_clear(animators[i].values);
			ds_list_add(animators[i].values, new valueKey(0, array_safe_get_fast(_val, i), animators[i]));
		}
	} #endregion
	
	static setValueInspector = function(_val = 0, index = noone, time = CURRENT_FRAME) { #region
		INLINE
		
		var res = false;
		var val = unit.invApply(_val);
		
		if(PANEL_INSPECTOR && PANEL_INSPECTOR.inspectGroup == 1) {
			var ind = self.index;
			
			for( var i = 0, n = array_length(PANEL_INSPECTOR.inspectings); i < n; i++ ) {
				var _node = PANEL_INSPECTOR.inspectings[i];
				if(ind >= ds_list_size(_node.inputs)) continue;
				
				var r = _node.inputs[| ind].setValueDirect(val, index);
				if(_node == node) res = r;
			}
		} else {
			res = setValueDirect(val, index, time);
		}
			
		return res;
	} #endregion
	
	static setValueDirect = function(val = 0, index = noone, record = true, time = CURRENT_FRAME, _update = true) {
		is_modified = true;
		var updated = false;
		var _val    = val;
		var _inp    = connect_type == JUNCTION_CONNECT.input;
			
		record &= record_value;
			
		if(sep_axis) {
			if(index == noone) {
				for( var i = 0, n = array_length(animators); i < n; i++ )
					updated |= animators[i].setValue(val[i], _inp && record, time); 
			} else
				updated = animators[index].setValue(val, _inp && record, time);
				
		} else {
			if(index != noone) {
				_val = animator.getValue(time);
				if(_inp) _val = variable_clone(_val); 
				
				_val[index] = val;
			}
			
			updated = animator.setValue(_val, _inp && record, time);
		}
		
		if(type == VALUE_TYPE.gradient)				updated = true;
		if(display_type == VALUE_DISPLAY.palette)   updated = true;
		
		for( var i = 0, n = array_length(value_to_loop); i < n; i++ )
			value_to_loop[i].updateValue();
		
		if(connect_type == JUNCTION_CONNECT.input && self.index >= 0) {
			var _val = animator.getValue(time);
			
			// setInputData(self.index, _val);
			node.inputs_data[self.index]         = _val;
			node.input_value_map[$ internalName] = _val;
		}
		
		if(!updated) return false;
		
		if(value_tag == "dimension")
			node.attributes.use_project_dimension = false;
		
		draw_junction_index = type;
		if(type == VALUE_TYPE.surface) {
			var _sval = val;
			if(is_array(_sval) && !array_empty(_sval))
				_sval = _sval[0];
				
			if(is_instanceof(_sval, SurfaceAtlas))
				draw_junction_index = VALUE_TYPE.atlas;
		}
		
		if(connect_type == JUNCTION_CONNECT.output) {
			if(self.index == 0) {
				node.preview_value = getValue();
				node.preview_array = $"[{array_shape(node.preview_value)}]";
			}
			return;
		}
		
		if(tags == VALUE_TAG.updateInTrigger || tags == VALUE_TAG.updateOutTrigger) return true;
		
		if(_update) {
			if(!IS_PLAYING) node.triggerRender();
			node.valueUpdate(self.index);
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
		return json_beautify(val);
	}
	
	static setString = function(str) {
		if(connect_type == JUNCTION_CONNECT.output) return;
		if(type == VALUE_TYPE.text) { setValue(str); return; }
		
		var _dat = json_try_parse(str);
		
		if(typeArray(display_type) && !is_array(_dat))
			_dat = [ _dat ];
		
		setValue(_dat);
	}
	
	/////=========== CONNECT ===========
	
	static rejectConnect = function() { #region
		auto_connect = false;
		return self;
	} #endregion
	
	static isConnectable = function(_valueFrom, checkRecur = true, _log = false) { 
		
		if(_valueFrom == -1 || _valueFrom == undefined || _valueFrom == noone) {
			if(_log) noti_warning($"LOAD: Cannot set node connection from {_valueFrom} to {name} of node {node.name}.",, node);
			return -1;
		}
		
		if(_valueFrom == value_from) {
			if(_log) noti_warning("whaT");
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
	
	static setFrom = function(_valueFrom, _update = true, checkRecur = true, log = false) { ////Set from
		
		if(is_dummy && dummy_get != noone) {
			var _targ    = dummy_get();
			dummy_target = _targ;
			UNDO_HOLDING = true;
			var _res     = _targ.setFrom(_valueFrom, _update, checkRecur, log);
			UNDO_HOLDING = false;
			
			recordAction(ACTION_TYPE.junction_connect, self, [ _targ, _valueFrom ]);
			return _res;
		}
		
		if(_valueFrom == noone)
			return removeFrom();
		
		run_in(2, function() /*=>*/ { updateColor(getValue()); });
		var conn = isConnectable(_valueFrom, checkRecur, log);
		if(conn < 0) return conn;
		
		if(setFrom_condition != -1 && !setFrom_condition(_valueFrom)) 
			return -2;
		
		if(value_from != noone)
			array_remove(value_from.value_to, self);
		
		var _o = animator.getValue();
		recordAction(ACTION_TYPE.junction_connect, self, value_from);
		value_from = _valueFrom;
		array_push(_valueFrom.value_to, self);
		
		node.valueUpdate(index, _o);
		if(_update && connect_type == JUNCTION_CONNECT.input) {
			node.valueFromUpdate(index);
			node.triggerRender();
			node.clearCacheForward();
			
			UPDATE |= RENDER_TYPE.partial;
		}
		
		cache_array[0] = false;
		cache_value[0] = false;
		
		if(!LOADING) {
			draw_line_shift_x	= 0;
			draw_line_shift_y	= 0;
			PROJECT.modified	= true;
		}
		
		RENDER_ALL_REORDER
		
		if(onSetFrom != noone)			onSetFrom(_valueFrom);
		if(_valueFrom.onSetTo != noone) _valueFrom.onSetTo(self);
		
		return true;
	}
	
	static removeFrom = function(_remove_list = true) {
		run_in(2, function() /*=>*/ { updateColor(getValue()); });
		
		recordAction(ACTION_TYPE.junction_disconnect, self, value_from);
		if(_remove_list && value_from != noone)
			array_remove(value_from.value_to, self);	
		value_from = noone;
		
		if(connect_type == JUNCTION_CONNECT.input)
			node.valueFromUpdate(index);
		node.clearCacheForward();
		
		PROJECT.modified = true;
						
		RENDER_ALL_REORDER
		
		return false;
	}
	
	static removeFromLoop = function(_remove_list = true) { #region
		if(value_from_loop != noone)
			value_from_loop.destroy();
		
		PROJECT.modified = true;
	} #endregion
	
	static checkConnection = function(_remove_list = true) { #region
		if(value_from == noone) return;
		if(value_from.node.active) return;
		
		removeFrom(_remove_list);
	} #endregion
	
	static searchNodeBackward = function(_node) { #region
		if(node == _node) return true;
		for(var i = 0; i < ds_list_size(node.inputs); i++) {
			var _in = node.inputs[| i].value_from;
			if(_in && _in.searchNodeBackward(_node))
				return true;
		}
		return false;
	} #endregion
	
	static hasJunctionFrom = function() { INLINE return value_from != noone || value_from_loop != noone; }
	
	static getJunctionTo = function() { #region
		var _junc_to = [];
		
		for(var i = 0; i < array_length(value_to); i++) {
			var _to = value_to[i];
			if(!_to.node.active || _to.value_from == noone) continue; 
			if(_to.value_from != self) continue;
			
			array_push(_junc_to, _to);
		}
		
		return _junc_to;
	} #endregion
	
	/////============= DRAW =============
	
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(type != VALUE_TYPE.integer && type != VALUE_TYPE.float) return -1;
		if(value_from != noone) return -1;
		if(expUse) return -1;
		
		var arc = 9;
		
		switch(display_type) {
			case VALUE_DISPLAY._default :
			case VALUE_DISPLAY.slider :
				var _angle = argument_count > arc + 0? argument[arc + 0] : 0;
				var _scale = argument_count > arc + 1? argument[arc + 1] : 1;
				var _spr   = argument_count > arc + 2? argument[arc + 2] : 0;
				return preview_overlay_scalar(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _angle, _scale, _spr);
						
			case VALUE_DISPLAY.rotation :
				var _rad = argument_count >  arc + 0? argument[ arc + 0] : 64;
				return preview_overlay_rotation(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad);
						
			case VALUE_DISPLAY.vector :
				var _typ = argument_count > arc + 0? argument[arc + 0] : 0;
				var _sca = argument_count > arc + 1? argument[arc + 1] : 1;
				return preview_overlay_vector(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _typ);
				
			case VALUE_DISPLAY.gradient_range :
				var _dim = argument[arc];
				
				if(mappedJunc.attributes.mapped)
					return preview_overlay_gradient_range(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _dim);
				break;
						
			case VALUE_DISPLAY.area :
				var _flag = argument_count > arc + 0? argument[arc + 0] : 0b0011;
				return preview_overlay_area(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, struct_try_get(display_data, "onSurfaceSize"));
						
			case VALUE_DISPLAY.puppet_control :
				return preview_overlay_puppet(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		}
		
		return -1;
	} #endregion
	
	static drawJunction_fast = function(_s, _mx, _my) {
		INLINE
		
		var hov  = PANEL_GRAPH.pHOVER && (PANEL_GRAPH.node_hovering == noone || PANEL_GRAPH.node_hovering == node);
		var _d   = node.junction_draw_hei_y * _s;
		var _hov = hov && point_in_rectangle(_mx, _my, x - 6 * _s, y - _d / 2, x + 6 * _s, y + _d / 2 - 1);
		var _aa  = 0.75 + (!is_dummy * 0.25);
		hover_in_graph = _hov;
		
		draw_set_color(draw_fg);
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
	
	static drawJunction = function(_s, _mx, _my) {
		_s /= 2;
		
		var hov        = PANEL_GRAPH.pHOVER && (PANEL_GRAPH.node_hovering == noone || PANEL_GRAPH.node_hovering == node);
		var _d         = node.junction_draw_hei_y * _s;
		var is_hover   = hov && point_in_rectangle(_mx, _my, x - _d, y - _d, x + _d - 1, y + _d - 1);
		hover_in_graph = is_hover;
		
		if(is_dummy) {
			__draw_sprite_ext(THEME.node_junction_add, is_hover, x, y, _s, _s, 0, c_white, 0.5 + 0.5 * is_hover);
			
		} else if(type == VALUE_TYPE.action) {
			var _cbg = c_white;
			
			if(draw_blend != -1)
				_cbg = merge_color(draw_blend_color, _cbg, draw_blend);
		
			__draw_sprite_ext(THEME.node_junction_inspector, is_hover, x, y, _s, _s, 0, _cbg, 1);
			
		} else {
			var _cbg = draw_bg;
			var _cfg = draw_fg;
			
			if(draw_blend != -1) {
				_cbg = merge_color(draw_blend_color, _cbg, draw_blend);
				_cfg = merge_color(draw_blend_color, _cfg, draw_blend);
			}
			
			var _bgS, _fgS;
			
			if(_s > .5) {
				_bgS = THEME.node_junctions_bg_x2;
				_fgS = is_hover? THEME.node_junctions_outline_hover_x2 : THEME.node_junctions_outline_x2;
				
			} else {
				_bgS = THEME.node_junctions_bg;
				_fgS = is_hover? THEME.node_junctions_outline_hover : THEME.node_junctions_outline;
				_s  *= 2;
			}
			
			if(graph_selecting)
				__draw_sprite_ext(THEME.node_junction_selecting, 0, x, y, _s, _s, 0, _cfg, .8);
			graph_selecting   = false;
			
			__draw_sprite_ext(_bgS, draw_junction_index, x, y, _s, _s, 0, _cbg, 1);
			
			gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
			__draw_sprite_ext(_fgS, draw_junction_index, x, y, _s, _s, 0, _cfg, 1);
			gpu_set_blendmode(bm_normal);
		}
		
		return is_hover;
	}
	
	static drawNameBG = function(_s) {
		var _f = node.previewable? f_p1 : f_p3;
		draw_set_text(_f, fa_left, fa_center);
		
		var tw = string_width(name) + 32;
		var th = string_height(name) + 16;
		
		if(type == VALUE_TYPE.action) {
			var tx = x;
			draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, tx - tw / 2, y - th, tw, th, c_white, 0.5);
			
		} else if(connect_type == JUNCTION_CONNECT.input) {
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
		
		var _f = node.previewable? f_p1 : f_p3;
		
		draw_set_text(_f, fa_left, fa_center, _draw_cc);
		draw_set_alpha(_draw_aa);
		
		if(type == VALUE_TYPE.action) {
			var tx = x;
			draw_set_text(_f, fa_center, fa_center, _draw_cc);
			draw_text_add(tx, y - (line_get_height() + 16) / 2, name);
			
		} else if(connect_type == JUNCTION_CONNECT.input) {
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
	
	static drawConnectionsRaw = function(params = {}) { return drawJuncConnection(value_from, self, params); }
	static drawConnections    = function(params = {}) {
		if(value_from == noone || !value_from.node.active || !isVisible()) 
			return noone;
		return drawJuncConnection(value_from, self, params);
	}
	
	static drawConnectionMouse = function(params, _mx, _my, target) { #region
		var ss = params.s;
		var aa = params.aa; // 1
		
		var drawCorner = type == VALUE_TYPE.action;
		if(target != noone)
			drawCorner |= target.type == VALUE_TYPE.action;
		
		var corner = PREFERENCES.connection_line_corner * ss;
		var th     = max(1, PREFERENCES.connection_line_width * ss);
		
		var sx = x;
		var sy = y;
		
		corner *= aa;
		th  *= aa;
		ss  *= aa;
		sx  *= aa;
		sy  *= aa;
		_mx *= aa;
		_my *= aa;
		
		var col = color_display;
		draw_set_color(col);
		
		var _action = type == VALUE_TYPE.action;
		var _output = connect_type == JUNCTION_CONNECT.output;
		
		switch(PREFERENCES.curve_connection_line) {
			case 0 : draw_line_width(sx, sy, _mx, _my, th); break;
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
					if(_action)	draw_line_elbow_corner(_mx, _my, sx, sy, ss, th, col, col, corner);
					else		draw_line_elbow_corner(sx, sy, _mx, _my, ss, th, col, col, corner);
				} else {
					if(_output)	draw_line_elbow_color(sx, sy, _mx, _my,,, ss, th, col, col, corner);
					else		draw_line_elbow_color(_mx, _my, sx, sy,,, ss, th, col, col, corner);
				}
				break;
			case 3 : 
				if(drawCorner) {
					if(_action)	draw_line_elbow_diag_corner(_mx, _my, sx, sy, ss, th, col, col, corner);
					else		draw_line_elbow_diag_corner(sx, sy, _mx, _my, ss, th, col, col, corner);
				} else {
					if(_output)	draw_line_elbow_diag_color(sx, sy, _mx, _my,,, ss, th, col, col, corner);
					else		draw_line_elbow_diag_color(_mx, _my, sx, sy,,, ss, th, col, col, corner);
				}
				break;
		}
	} #endregion
	
	static isVisible = function() { #region
		if(!node.active) return false;
		
		if(connect_type == JUNCTION_CONNECT.output)
			return visible || !array_empty(value_to);
		
		if(value_from) return true;
		if(!visible)   return false;
		
		if(index == -1) return true;
		
		return visible_in_list;
	} #endregion
	
	/////========== EXPRESSION ==========
	
	static setUseExpression = function(useExp) { #region
		INLINE
		if(expUse == useExp) return;
		expUse = useExp;
		node.triggerRender();
	} #endregion
	
	static setExpression = function(_expression) { #region
		expUse = true;
		expression = _expression;
		expressionUpdate();
	} #endregion
	
	static expressionUpdate = function() { #region
		expTree = evaluateFunctionList(expression);
		resetCache();
		node.triggerRender();
	} #endregion
	
	/////=========== SERIALIZE ===========
	
	static serialize = function(scale = false, preset = false) { #region
		var _map = {};
		
		_map.visible = visible;
		_map.color   = color;
		
		if(connect_type == JUNCTION_CONNECT.output) 
			return _map;
		
		_map.name		= name;
		_map.on_end		= on_end;
		_map.loop_range	= loop_range;
		_map.unit		= unit.mode;
		_map.sep_axis	= sep_axis;
		_map.shift_x	= draw_line_shift_x;
		_map.shift_y	= draw_line_shift_y;
		_map.is_modified= is_modified;
		
		if(!preset && value_from) {
			_map.from_node  = value_from.node.node_id;
			
			if(value_from.tags != 0) _map.from_index = value_from.tags;
			else					 _map.from_index = value_from.index;
		} else {
			_map.from_node  = -1;
			_map.from_index = -1;
		}
		
		_map.global_use = expUse;
		_map.global_key = expression;
		_map.anim		= is_anim;
		
		_map.raw_value  = animator.serialize(scale);
		
		var _anims = [];
		for( var i = 0, n = array_length(animators); i < n; i++ )
			array_push(_anims, animators[i].serialize(scale));
		_map.animators    = _anims;
		_map.display_data = display_data;
		_map.attributes   = attributes;
		_map.name_custom  = name_custom;
		
		return _map;
	} #endregion
	
	static applyDeserialize = function(_map, scale = false, preset = false) { #region
		if(_map == undefined) return;
		if(_map == noone)     return;
		if(!is_struct(_map))  return;
		
		visible = struct_try_get(_map, "visible", visible);
		color   = struct_try_get(_map, "color", -1);
		
		if(connect_type == JUNCTION_CONNECT.output) 
			return;
		
		//print($"        > Applying deserialize to junction {name} 0");
		on_end		= struct_try_get(_map, "on_end");
		loop_range	= struct_try_get(_map, "loop_range", -1);
		unit.mode	= struct_try_get(_map, "unit");
		expUse    	= struct_try_get(_map, "global_use");
		expression	= struct_try_get(_map, "global_key");
		expTree     = evaluateFunctionList(expression); 
		
		sep_axis	= struct_try_get(_map, "sep_axis");
		setAnim(struct_try_get(_map, "anim"));
		
		draw_line_shift_x = struct_try_get(_map, "shift_x");
		draw_line_shift_y = struct_try_get(_map, "shift_y");
		is_modified       = struct_try_get(_map, "is_modified", true);
		
		struct_append(attributes, struct_try_get(_map, "attributes"))
		name_custom = struct_try_get(_map, "name_custom", false);
		if(name_custom) name = struct_try_get(_map, "name", name);
		
		animator.deserialize(struct_try_get(_map, "raw_value"), scale);
		
		if(struct_has(_map, "animators")) {
			var anims = _map.animators;
			var amo = min(array_length(anims), array_length(animators));
			for( var i = 0; i < amo; i++ )
				animators[i].deserialize(anims[i], scale);
		}
		
		if(!preset) {
			con_node  = struct_try_get(_map, "from_node",  -1);
			con_index = struct_try_get(_map, "from_index", -1);
		}
		
		if(struct_has(_map, "display_data")) {
			for( var i = 0, n = array_length(DISPLAY_DATA_KEYS); i < n; i++ )
				struct_try_override(display_data, _map.display_data, DISPLAY_DATA_KEYS[i]);
		}
		
		if(connect_type == JUNCTION_CONNECT.input && index >= 0) {
			var _value = animator.getValue(0);
			node.inputs_data[index] = _value;
			node.input_value_map[$ internalName] = _value;
		}
		
		attributeApply();
		onValidate();
	} #endregion
	
	static attributeApply = function() { #region
		if(struct_has(attributes, "mapped") && attributes.mapped) 
			mappableStep();
	} #endregion
	
	static connect = function(log = false) { #region
		//print($"{node} | {con_node} : {con_index}");
		
		if(con_node == -1 || con_index == -1)
			return true;
		
		var _node = con_node;
		if(APPENDING) {
			_node = GetAppendID(con_node);
			if(_node == noone)
				return true;
		}
		
		if(!ds_map_exists(PROJECT.nodeMap, _node)) {
			var txt = $"Node connect error : Node ID {_node} not found.";
			log_warning("LOAD", $"[Connect] {txt}", node);
			return false;
		}
		
		var _nd = PROJECT.nodeMap[? _node];
		var _ol = ds_list_size(_nd.outputs);
		
		if(log) log_warning("LOAD", $"[Connect] Reconnecting {node.name} to {_nd.name}", node);
		
		     if(con_index == VALUE_TAG.updateInTrigger)  return setFrom(_nd.updatedInTrigger);
		else if(con_index == VALUE_TAG.updateOutTrigger) return setFrom(_nd.updatedOutTrigger);
		else if(con_index < _ol) {
			var _set = setFrom(_nd.outputs[| con_index], false, true);
			if(_set) return true;
			
				 if(_set == -1) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Not connectable.", node);
			else if(_set == -2) log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Condition not met.", node); 
			
			return false;
		}
		
		log_warning("LOAD", $"[Connect] Connection conflict {node.name} to {_nd.name} : Output not exist.", node);
		return false;
	} #endregion
	
	/////============= MISC =============
	
	static extractNode = function(_type = extract_node) { #region
		if(_type == "") return noone;
		
		var ext = nodeBuild(_type, node.x, node.y);
		ext.x -= ext.w + 32;
		
		for( var i = 0; i < ds_list_size(ext.outputs); i++ ) {
			if(setFrom(ext.outputs[| i])) break;
		}
		
		var animFrom = animator.values;
		var len = 2;
		
		switch(_type) {
			case "Node_Vector4": len++;
			case "Node_Vector3": len++;
			case "Node_Vector2": 
				for( var j = 0; j < len; j++ ) {
					var animTo = ext.inputs[| j].animator;
					var animLs = animTo.values;
					
					ext.inputs[| j].setAnim(is_anim);
					ds_list_clear(animLs);
				}
				
				for( var i = 0; i < ds_list_size(animFrom); i++ ) {
					for( var j = 0; j < len; j++ ) {
						var animTo = ext.inputs[| j].animator;
						var animLs = animTo.values;
						var a = animFrom[| i].clone(animTo);
						
						a.value = a.value[j];
						ds_list_add(animLs, a);
					}
				}
				break;
			case "Node_Path": 
				break;
			default:
				var animTo = ext.inputs[| 0].animator;
				var animLs = animTo.values;
				
				ext.inputs[| 0].setAnim(is_anim);
				ds_list_clear(animLs);
				
				for( var i = 0; i < ds_list_size(animFrom); i++ )
					ds_list_add(animLs, animFrom[| i].clone(animTo));
				break;
		}
		
		ext.doUpdate();
	} #endregion
	
	static dragValue = function() { #region
		if(drop_key == "None") return;
		
		DRAGGING = { 
			type: drop_key, 
			data: showValue(),
		}
		
		if(type == VALUE_TYPE.path) {
			DRAGGING.data = new FileObject(node.name, DRAGGING.data);
			DRAGGING.data.getSpr();
		}
		
		if(connect_type == JUNCTION_CONNECT.input)
			DRAGGING.from = self;
	} #endregion
	
	static destroy = function() { #region
		if(error_notification != noone) {
			noti_remove(error_notification);
			error_notification = noone;
		}	
	} #endregion
	
	static cleanUp = function() {}
		
	static toString = function() { return (connect_type == JUNCTION_CONNECT.input? "Input" : "Output") + $" junction {index} of [{name}]: {node}"; }
}

/////========== FUNCTIONS ==========
	
function drawJuncConnection(from, to, params) { #region
	#region parameters
		var log  = params.log;
		var high = params.highlight;
		var bg   = params.bg;
		var aa   = params.aa;
	
		var _x	= params.x;
		var _y	= params.y;
		var _s	= params.s;
		var mx	= params.mx;
		var my	= params.my;
		var _active   = params.active;
		var cur_layer = params.cur_layer;
		var max_layer = params.max_layer;
		
		var hovering = noone;
	
		var jx  = to.x;
		var jy  = to.y;
			
		var frx = from.x;
		var fry = from.y;
			
		var fromIndex = from.drawLineIndex;
		var toIndex   = to.drawLineIndex;
		
		var _loop = struct_try_get(params, "loop");
		
		if(params.minx != 0 && params.maxx != 0) {
			var minx = params.minx;
			var miny = params.miny;
			var maxx = params.maxx;
			var maxy = params.maxy;
		
			if(jx < minx && frx < minx) return noone;
			if(jx > maxx && frx > maxx) return noone;
				
			if(jy < miny && fry < miny) return noone;
			if(jy > maxy && fry > maxy) return noone;
		}
	
		var shx = to.draw_line_shift_x * _s;
		var shy = to.draw_line_shift_y * _s;
		
		var cx  = round((frx + jx) / 2 + shx);
		var cy  = round((fry + jy) / 2 + shy);
			
		var hover = false;
		var th    = max(1, PREFERENCES.connection_line_width * _s);
		to.draw_line_shift_hover = false;
			
		var downDirection = to.type == VALUE_TYPE.action || from.type == VALUE_TYPE.action;
		// if(downDirection) print($"{to} : {from}");
	#endregion
	
	#region +++++ CHECK HOVER +++++
		var hovDist = max(th * 2, 6);
		
		if(PANEL_GRAPH.pHOVER) {
			if(_loop || from.node == to.node) {
				hover = distance_line_feedback(mx, my, jx, jy, frx, fry, _s) < hovDist;
			} else {
				switch(PREFERENCES.curve_connection_line) { 
					case 0 : 
						hover = distance_to_line(mx, my, jx, jy, frx, fry) < hovDist;
						break;
					case 1 : 
						if(downDirection) hover = distance_to_curve_corner(mx, my, jx, jy, frx, fry, _s) < hovDist;
						else              hover = distance_to_curve(mx, my, jx, jy, frx, fry, cx, cy, _s) < hovDist;
						
						if(PANEL_GRAPH.value_focus == noone)
							to.draw_line_shift_hover = hover;
						break;
					case 2 : 
						if(downDirection) hover = distance_to_elbow_corner(mx, my, frx, fry, jx, jy) < hovDist;
						else              hover = distance_to_elbow(mx, my, frx, fry, jx, jy, cx, cy, _s, fromIndex, toIndex) < hovDist;
					
						if(PANEL_GRAPH.value_focus == noone)
							to.draw_line_shift_hover = hover;
						break;
					case 3 :
						if(downDirection) hover  = distance_to_elbow_diag_corner(mx, my, frx, fry, jx, jy) < hovDist;
						else              hover  = distance_to_elbow_diag(mx, my, frx, fry, jx, jy, cx, cy, _s, fromIndex, toIndex) < hovDist;
					
						if(PANEL_GRAPH.value_focus == noone)
							to.draw_line_shift_hover = hover;
						break;
				}
			} 
		}
				
		if(_active && hover)
			hovering = self;
	#endregion
	
	#region draw parameters	
		var thicken = false;
		thicken |= PANEL_GRAPH.nodes_junction_d == self;
		thicken |= _active && PANEL_GRAPH.junction_hovering == self && PANEL_GRAPH.value_focus == noone;
		thicken |= instance_exists(o_dialog_add_node) && o_dialog_add_node.junction_hovering == self;
	
		th *= thicken? 2 : 1;
			
		var corner = PREFERENCES.connection_line_corner * _s;
		
		var ty = LINE_STYLE.solid;
		if(to.type == VALUE_TYPE.node || struct_try_get(params, "dashed"))
			ty = LINE_STYLE.dashed;
		
		var c0, c1;
		var _selc = to.node.branch_drawing && from.node.branch_drawing;
	
		if(high) {
			var _fade = PREFERENCES.connection_line_highlight_fade;
			var _colr = _selc? 1 : _fade;
			
			c0 = merge_color(bg, from.color_display, _colr);
			c1 = merge_color(bg, to.color_display,	 _colr);
			
			to.draw_blend_color = bg;
			to.draw_blend       = _colr;
			from.draw_blend     = max(from.draw_blend, _colr);
		} else {
			c0 = from.color_display;
			c1 = to.color_display;
			
			to.draw_blend_color = bg;
			to.draw_blend       = -1;
		}
	#endregion
		
	#region +++++ DRAW LINE +++++
		var ss  = _s * aa;
		jx  *= aa;
		jy  *= aa;
		frx *= aa;
		fry *= aa;
		th  *= aa;
		cx  *= aa;
		cy  *= aa;
		corner *= aa;
		th = max(1, round(th));
		
		draw_set_color(c0);
		
		if(_loop || from.node == to.node) {
			draw_line_feedback(jx, jy, frx, fry, th, c1, c0, ss);
		} else {
			switch(PREFERENCES.curve_connection_line) { 
				case 0 : 
					if(ty == LINE_STYLE.solid)	draw_line_width_color(jx, jy, frx, fry, th, c1, c0);
					else						draw_line_dashed_color(jx, jy, frx, fry, th, c1, c0, 6 * ss);
					break;
				case 1 : 
					if(downDirection)	draw_line_curve_corner(jx, jy, frx, fry, ss, th, c0, c1); 
					else				draw_line_curve_color(jx, jy, frx, fry, cx, cy, ss, th, c0, c1, ty); 
					break;
				case 2 : 
					if(downDirection)	draw_line_elbow_corner(frx, fry, jx, jy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
					else				draw_line_elbow_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
					break;
				case 3 : 
					if(downDirection)	draw_line_elbow_diag_corner(frx, fry, jx, jy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
					else				draw_line_elbow_diag_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, corner, fromIndex, toIndex, ty); 
					break;
			} 
		}
	#endregion
		
	return hovering;
} #endregion