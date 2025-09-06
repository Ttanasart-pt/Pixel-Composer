#region
	enum MATH_OPERATOR {
		add,      //  0
		subtract, //  1
		multiply, //  2
		divide,   //  3
		power,    //  4
		root,     //  5
			
		sin,      //  6
		cos,      //  7
		tan,      //  8
			
		modulo,   //  9
			
		floor,    // 10
		ceiling,  // 11
		round,    // 12
		
		lerp,     // 13
		abs,      // 14
		
		clamp,    // 15
		snap,     // 16
		fract,    // 17
		
		map,
		
		length,
	}
	
	global.node_math_keys     = [	"add", "subtract", "multiply", "divide", "power", "root", 
									"+", "-", "*", "/", "^", 
	                        		"sin", "cos", "tan", "modulo", "round", 
	                        		"ceiling", "floor", "lerp", "abs", "fract", 
	                        		"clamp", "snap", "map" ];
	              
	global.node_math_keys_map = [	MATH_OPERATOR.add,     MATH_OPERATOR.subtract, MATH_OPERATOR.multiply, MATH_OPERATOR.divide, MATH_OPERATOR.power, MATH_OPERATOR.root, 
									MATH_OPERATOR.add,     MATH_OPERATOR.subtract, MATH_OPERATOR.multiply, MATH_OPERATOR.divide, MATH_OPERATOR.power, 
	                        		MATH_OPERATOR.sin,     MATH_OPERATOR.cos,      MATH_OPERATOR.tan,      MATH_OPERATOR.modulo, MATH_OPERATOR.round, 
	                        		MATH_OPERATOR.ceiling, MATH_OPERATOR.floor,    MATH_OPERATOR.lerp,     MATH_OPERATOR.abs,    MATH_OPERATOR.fract, 
	                        		MATH_OPERATOR.clamp,   MATH_OPERATOR.snap,     MATH_OPERATOR.map, ];
	
	global.node_math_names    = [  /* 0 -  9*/ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", "Sin", "Cos", "Tan", "Modulo", 
								   /*10 - 20*/ "Floor", "Ceil", "Round", "Lerp", "Abs", "Clamp", "Snap", "Fract", "Map", ];
	
	global.node_math_scroll   = array_create_ext(array_length(global.node_math_names), function(i) /*=>*/ {return new scrollItem(global.node_math_names[i], s_node_math_operators, i)});
	
	function Node_create_Math(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Math(_x, _y, _group);
		node.skipDefault();
	
		var ind = array_find(global.node_math_keys, query);
		if(ind != -1) node.inputs[0].skipDefault().setValue(global.node_math_keys_map[ind]);
	
		return node;
	}

	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Math", "Type > Toggle",   "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue((_n.inputs[0].getValue() + 1) % array_length(global.node_math_scroll)); });
		addHotkey("Node_Math", "Type > Add",      "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(0); });
		addHotkey("Node_Math", "Type > Subtract", "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(1); });
		addHotkey("Node_Math", "Type > Multiply", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(2); });
		addHotkey("Node_Math", "Type > Divide",   "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(3); });
		
		addHotkey("Node_Math", "Angle Unit > Toggle", "N", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue(!_n.inputs[3].setValue()); });
		addHotkey("Node_Math", "To Integer > Toggle", "I", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue(!_n.inputs[4].setValue()); });
	});
#endregion

function Node_Math(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Math";
	color		= COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Enum_Scroll("Type", 0, global.node_math_scroll)).rejectArray();
	
	////- Values
	
	newInput(1, nodeValue_Float( "a", 0)).setVisible(true, true);
	newInput(2, nodeValue_Float( "b", 0)).setVisible(true, true);
	newInput(5, nodeValue_Float( "Amount", 0));
	newInput(6, nodeValue_Vec2(  "From", [ 0, 1 ]));
	newInput(7, nodeValue_Vec2(  "To", [ 0, 1 ]));
	
	////- Settings
		
	newInput(3, nodeValue_Bool( "Degree Angle",  true));
	newInput(4, nodeValue_Bool( "To integer", false));
	newInput(8, nodeValue_Bool( "Output Vector", false));
	
	// inputs 9
		
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, 0));
	
	input_display_list = [ 0, 
		["Values",   false], 1, 2, 5, 6, 7, 
		["Settings", false], 3, 4, 8, 
	];
	
	use_mod = 0;
	use_deg = false;
	
	static onValueUpdate = function(index = noone) {
		if(index != 0) return;
		
		var _type = inputs[0].getValue();
		setDisplayName(array_safe_get(global.node_math_names, _type, ""), false);
	}
	
	static _eval = function(a, b, c, f, t) {
		switch(use_mod) {
			case MATH_OPERATOR.add :		return a + b;    
			case MATH_OPERATOR.subtract :	return a - b;
			case MATH_OPERATOR.multiply :	return a * b;
			case MATH_OPERATOR.divide :		return b == 0? 0 : a / b;
				
			case MATH_OPERATOR.power :		return b >= 0? power(a, b) : 1 / power(a, -b);
			case MATH_OPERATOR.root :		return b <= 0? 0 : power(a, 1 / b);
			
			case MATH_OPERATOR.sin :		return (use_deg? dsin(a) : sin(a)) * b;
			case MATH_OPERATOR.cos :		return (use_deg? dcos(a) : cos(a)) * b;
			case MATH_OPERATOR.tan :		return (use_deg? dtan(a) : tan(a)) * b;
			case MATH_OPERATOR.modulo :		return safe_mod(a, b);
			
			case MATH_OPERATOR.floor :		return floor(a);
			case MATH_OPERATOR.ceiling :	return ceil(a);
			case MATH_OPERATOR.round :		return round(a);
			
			case MATH_OPERATOR.lerp :		return lerp(a, b, c);
			case MATH_OPERATOR.abs :		return abs(a);
			
			case MATH_OPERATOR.clamp :		return clamp(a, b, c);
			case MATH_OPERATOR.snap :		return value_snap(a, b);
			case MATH_OPERATOR.fract :		return frac(a);
			
			case MATH_OPERATOR.map :		return lerp(t[0], t[1], (a - f[0]) / (f[1] - f[0]));
		}
		return 0;
	}
	
	static evalArray = function(a, b, c, f, t) {
		var _as = is_array(a);
		var _bs = is_array(b);
		var _cs = is_array(c);
		
		if(!_as && !_bs && !_cs)
			return _eval(a, b, c, f, t);
		
		if(!_as) a = [ a ];
		if(!_bs) b = [ b ];
		if(!_cs) c = [ c ];
		
		var al = array_length(a);
		var bl = array_length(b);
		var cl = array_length(c);
		
		var amo = max(al, bl, cl);
		var val = array_create(amo);
		
		for( var i = 0; i < amo; i++ ) 
			val[i] = evalArray( 
				array_safe_get(a, i,, ARRAY_OVERFLOW.loop), 
				array_safe_get(b, i,, ARRAY_OVERFLOW.loop),
				array_safe_get(c, i,, ARRAY_OVERFLOW.loop),
				f, t, 
			);
		
		return val;
	}
	
	__mode   = noone;
	doUpdate = doUpdateLite;
	static update = function(frame = CURRENT_FRAME) { 
		
		use_mod = inputs[0].getValue();
		use_deg = inputs[3].getValue();
		
		var a   = inputs[1].getValue();
		var b   = inputs[2].getValue();
		var c   = inputs[5].getValue();
		var f   = inputs[6].getValue();
		var t   = inputs[7].getValue();
		
		var vc = inputs[8].getValue();
		var ty = vc? VALUE_DISPLAY.vector : VALUE_DISPLAY._default
		if(outputs[0].display_type != ty) outputs[0].setDisplay(ty);
		
		outputs[0].setValue(evalArray(a, b, c, f, t));
		
		if(__mode == use_mod) return;
		__mode = use_mod;
	
		inputs[1].name = "a";
		inputs[2].name = "b";
		
		inputs[2].setVisible(false, false);
		inputs[3].setVisible(false, false);
		inputs[5].setVisible(false, false);
		inputs[6].setVisible(false, false);
		inputs[7].setVisible(false, false);
		
		switch(use_mod) {
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[3].setVisible(true);
				break;
				
			case MATH_OPERATOR.map :
				inputs[6].setVisible(true, true);
				inputs[7].setVisible(true, true);
				break;
		}
		
		switch(use_mod) {
			case MATH_OPERATOR.round :
			case MATH_OPERATOR.floor :
			case MATH_OPERATOR.ceiling :
				inputs[4].setVisible(true);
				
				var int = getInputData(4);
				if(int) outputs[0].setType(VALUE_TYPE.integer);
				else	outputs[0].setType(VALUE_TYPE.float);
				break;
				
			default:
				inputs[4].setVisible(false);
				
				outputs[0].setType(VALUE_TYPE.float);
				break;
		}
		
		switch(use_mod) {
			case MATH_OPERATOR.add :
			case MATH_OPERATOR.subtract :
			case MATH_OPERATOR.multiply :
			case MATH_OPERATOR.divide :
			case MATH_OPERATOR.power :
			case MATH_OPERATOR.root :	
			case MATH_OPERATOR.modulo :	
				inputs[2].setVisible(true, true);
				break;
				
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[2].name = "Amplitude";
				
				inputs[2].setVisible(true, true);
				break;
				
			case MATH_OPERATOR.lerp :
				inputs[1].name = "From";
				inputs[2].name = "To";
				inputs[5].name = "Amount";
				
				inputs[2].setVisible(true, true);
				inputs[5].setVisible(true, true);
				inputs[5].editWidget.setSlideRange(0, 1);
				break;
				
			case MATH_OPERATOR.clamp :
				inputs[2].name = "Min";
				inputs[5].name = "Max";
				
				inputs[2].setVisible(true, true);
				inputs[5].setVisible(true, true);
				inputs[5].editWidget.slide_range = noone;
				break;
				
			case MATH_OPERATOR.snap :
				inputs[2].name = "Snap";
				
				inputs[2].setVisible(true, true);
				break;
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "";
		var typ = getInputData(0);
		
		switch(typ) {
			case MATH_OPERATOR.add :		str = "+"; break;
			case MATH_OPERATOR.subtract :	str = "-"; break;
			case MATH_OPERATOR.multiply :	str = "*"; break;
			case MATH_OPERATOR.divide :		str = "/"; break;
			default: str = string_lower(global.node_math_names[typ]);
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss * 0.8, ss * 0.8, 0);
	}
}