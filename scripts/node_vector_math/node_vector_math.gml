#region
	enum VMATH_OPERATOR {
		add,      //  0
		subtract, //  1
		multiply, //  2
		divide,   //  3
		power,    //  4
		root,     //  5
	}
	
	global.node_vmath_keys     = [	"add", "subtract", "multiply", "divide", "power", "root", ];
	              
	global.node_vmath_keys_map = [	VMATH_OPERATOR.add,     VMATH_OPERATOR.subtract, VMATH_OPERATOR.multiply, VMATH_OPERATOR.divide, VMATH_OPERATOR.power, VMATH_OPERATOR.root, ];
	
	global.node_vmath_names    = [  /* 0 -  9*/ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", ];
	
	global.node_vmath_scroll   = array_create_ext(array_length(global.node_vmath_names), function(i) /*=>*/ {return new scrollItem(global.node_vmath_names[i], s_node_math_operators, i)});
	
	function Node_create_VMath(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Vector_Math(_x, _y, _group).skipDefault();
		
		var ind = array_find(global.node_vmath_keys, query);
		if(ind != -1) node.inputs[0].skipDefault().setValue(global.node_vmath_keys_map[ind]);
		
		return node;
	}

	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Vector_Math", "Type > Toggle",   "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue((_n.inputs[0].getValue() + 1) % array_length(global.node_vmath_scroll)); });
		addHotkey("Node_Vector_Math", "Type > Add",      "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(0); });
		addHotkey("Node_Vector_Math", "Type > Subtract", "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(1); });
		addHotkey("Node_Vector_Math", "Type > Multiply", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(2); });
		addHotkey("Node_Vector_Math", "Type > Divide",   "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(3); });
	});
#endregion

function Node_Vector_Math(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name     = "Vector Math";
	color    = COLORS.node_blend_number;
	doUpdate = doUpdateLite;
	setDimension(96, 48);
	__mode   = noone;
	
	newInput(0, nodeValue_Enum_Scroll("Type", 0, global.node_vmath_scroll)).rejectArray();
	
	////- =Values
	newInput(5, nodeValue_Int(   "Dimension", 2 ));
	newInput(1, nodeValue_Float( "a", 0 )).setVisible(true, true);
	newInput(2, nodeValue_Float( "b", 0 )).setVisible(true, true);
	
	////- =Settings
	newInput(3, nodeValue_Bool( "Degree Angle", true ));
	newInput(4, nodeValue_Bool( "Scalar B",     true ));
	// inputs 5
		
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, 0)).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0, 
		[ "Values",   false ], 5, 1, 2, 
		[ "Settings", false ], 3, 4, 
	];
	
	////- Nodes
	
	use_mod = 0;
	use_deg = false;
	
	static onValueUpdate = function(index = noone) {
		if(index != 0) return;
		
		var _type = inputs[0].getValue();
		setDisplayName(array_safe_get(global.node_vmath_names, _type, ""), false);
	}
	
	static eval = function(a, b) {
		var vecl = array_length(a);
		var ress = array_create(vecl);
		
		for( var i = 0; i < vecl; i++ ) {
			var _a = a[i];
			var _b = b[i];
			
			switch(use_mod) {
				case VMATH_OPERATOR.add :		ress[i] = _a + _b;              break;
				case VMATH_OPERATOR.subtract :	ress[i] = _a - _b;              break;
				case VMATH_OPERATOR.multiply :	ress[i] = _a * _b;              break;
				case VMATH_OPERATOR.divide :	ress[i] = _b == 0? 0 : _a / _b; break;
				
				case MATH_OPERATOR.power :		ress[i] = _b >= 0? power(_a, _b) : 1 / power(_a, -_b); break;
				case MATH_OPERATOR.root :		ress[i] = _b <= 0? 0 : power(_a, 1 / _b);              break;
		
			}
		}
		
		return ress;
	}
	
	static update = function(frame = CURRENT_FRAME) { 
		use_mod = inputs[0].getValue();
		use_deg = inputs[3].getValue();
		
		var l   = inputs[5].getValue();
		var a   = inputs[1].getValue();
		var b   = inputs[2].getValue();
		
		var sb  = inputs[4].getValue();
		
		var da = array_get_depth(a);
		     if(da == 0) a = [array_create(l, a)];
		else if(da == 1) a = [a];
		
		var db = array_get_depth(b);
		     if(db == 0) b = [array_create(l, b)];
		else if(db == 1) {
			if(sb) {
				var _b = array_create(array_length(b));
				for( var i = 0, n = array_length(b); i < n; i++ )
					_b[i] = array_create(l, b[i]);
				b = _b;
				
			} else b = [b];
		}
		
		var al = array_length(a);
		var bl = array_length(b);
		var _amo = max(al, bl);
		var _out = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var _a = array_verify(a[i % al], l);
			var _b = array_verify(b[i % bl], l);
			
			_out[i] = eval(_a, _b);
		}
		
		if(_amo == 1) _out = _out[0];
		
		outputs[0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "";
		var typ = use_mod;
		
		switch(typ) {
			case VMATH_OPERATOR.add :      str = "+"; break;
			case VMATH_OPERATOR.subtract : str = "-"; break;
			case VMATH_OPERATOR.multiply : str = "*"; break;
			case VMATH_OPERATOR.divide :   str = "/"; break;
			default: str = string_lower(global.node_vmath_names[typ]);
		}
		
		var bbox = draw_bbox;
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss * 0.8, ss * 0.8, 0);
	}
}