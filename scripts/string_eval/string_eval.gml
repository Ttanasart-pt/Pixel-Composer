#region data
	global.EQUATION_PRES    = ds_map_create();
	global.EQUATION_PRES[? "+"] = 1;
	global.EQUATION_PRES[? "-"] = 1;
	global.EQUATION_PRES[? "∸"] = 9; //unary negative
	global.EQUATION_PRES[? "*"] = 2;
	global.EQUATION_PRES[? "/"] = 2;
	global.EQUATION_PRES[? "$"] = 3;
	
	global.EQUATION_PRES[? "&"] = 5;
	global.EQUATION_PRES[? "|"] = 4;
	global.EQUATION_PRES[? "^"] = 3;
	global.EQUATION_PRES[? "<"] = 3;
	global.EQUATION_PRES[? "»"] = 6;
	global.EQUATION_PRES[? "«"] = 6;
	global.EQUATION_PRES[? "~"] = 9;
	
	global.EQUATION_PRES[? "="] = -1; //==
	global.EQUATION_PRES[? "≠"] = -1; //!=
	global.EQUATION_PRES[? "<"] =  0;
	global.EQUATION_PRES[? ">"] =  0;
	global.EQUATION_PRES[? "≤"] =  0;
	global.EQUATION_PRES[? "≥"] =  0;
	
	global.EQUATION_PRES[? "@"] = 5; //array accerssor symbol
	
	global.FUNCTIONS    = ds_map_create();
	global.FUNCTIONS[? "sin"]    = [ ["radian"], function(val) { return sin(val[0]); } ];
	global.FUNCTIONS[? "cos"]    = [ ["radian"], function(val) { return cos(val[0]); } ];
	global.FUNCTIONS[? "tan"]    = [ ["radian"], function(val) { return tan(val[0]); } ];
	global.FUNCTIONS[? "abs"]    = [ ["number"], function(val) { return abs(val[0]); } ];
	global.FUNCTIONS[? "round"]  = [ ["number"], function(val) { return round(val[0]); } ];
	global.FUNCTIONS[? "ceil"]   = [ ["number"], function(val) { return ceil(val[0]);  } ];
	global.FUNCTIONS[? "floor"]  = [ ["number"], function(val) { return floor(val[0]); } ];
	
	global.FUNCTIONS[? "wiggle"] = [ ["time", "frequency", "octave", "seed"],	function(val) { 
																					return wiggle(0, 1, array_safe_get(val, 1), 
																										array_safe_get(val, 0), 
																										array_safe_get(val, 3, 0), 
																										array_safe_get(val, 2, 1)); 
																				} ];
#endregion

function functionStringClean(fx) {
	var ch = "", ind = 0, len = string_length(fx);
	var _fx = "", str = false;
	while(ind++ <= len) {
		ch = string_char_at(fx, ind);
		
		if(ch == " ") {
			if(str)
				_fx += ch;
		} else
			_fx += ch;
			
		if(ch == "\"")
			str = !str;
	}
	
	fx = _fx;
	
	
	fx = string_replace_all(fx, "\n", "");
	fx = string_replace_all(fx, "**", "$");
	fx = string_replace_all(fx, "<<", "«");
	fx = string_replace_all(fx, ">>", "»");
	
	fx = string_replace_all(fx, "==", "=");
	fx = string_replace_all(fx, "!=", "≠");
	fx = string_replace_all(fx, "<>", "≠");
	fx = string_replace_all(fx, ">=", "≥");
	fx = string_replace_all(fx, "<=", "≤");
	
	fx = string_replace_all(fx, "[", "@["); //add array accessor symbol arr[i] = arr@[i] = arr @ (i)
	
	return fx;
}

#region evaluator
	enum EXPRESS_TREE_ANIM {
		none,
		base_value,
		animated
	}
	
	function __funcTree(symbol, l = noone, r = noone) constructor {
		self.symbol = symbol;
		self.l = l;
		self.r = r;
		dependency = [];
		
		static _string = function(str) {
			return string_char_at(str, 1) == "\"" && 
				string_char_at(str, string_length(str)) == "\"";
		}
		
		static _string_trim = function(str) {
			return _string(str)? string_copy(str, 2, string_length(str) - 2) : string(str);
		}
		
		static getVal = function(val, params = {}, getRaw = false) {
			if(is_struct(val)) return val.eval(params);
			if(is_real(val))   return val;
			if(is_string(val)) val = string_trim(val);
			
			if(struct_has(params, val))
				return struct_try_get(params, val);
			
			if(getRaw) return val;
			
			if(_string(string_trim(val)))
				return string_trim(val);
			
			return nodeGetData(val);
		}
		
		static _validate = function(val) {
			if(is_real(val))   return true;
			if(is_string(val)) return true;
			if(is_struct(val)) return val.validate();

			if(val == "value") return true;
			if(PROJECT.globalNode.inputExist(val)) return true;
			
			var strs = string_splice(val, ".");
			if(array_length(strs) < 2) return false;
			
			if(strs[0] == "Project")
				return ds_map_exists(PROJECT_VARIABLES, strs[1]);
			
			if(!ds_map_exists(PROJECT.nodeNameMap, strs[0]))
				return false;
			
			array_push_unique(dependency, strs[0])	
			return true;
		}
		
		static validate = function() {
			dependency = [];
			
			if(ds_map_exists(global.FUNCTIONS, symbol)) {
				if(!is_array(l)) return false;
				for( var i = 0; i < array_length(l); i++ )
					if(!_validate(l[i])) return false;
				return true;
			}
				
			switch(symbol) {
				case "@": return _validate(l);
				case "【": return true;
				case "":  return true;
			}
			
			return _validate(l) && _validate(r);
		}
		
		static _isAnimated = function(val) {
			if(is_real(val))   return EXPRESS_TREE_ANIM.none;
			if(is_struct(val)) return val._isAnimated();
			
			if(val == "value") return EXPRESS_TREE_ANIM.base_value;
			if(PROJECT.globalNode.inputExist(val)) {
				var _inp = PROJECT.globalNode.getInput(val);
				if(_inp.is_anim) return EXPRESS_TREE_ANIM.animated;
			}
			
			return EXPRESS_TREE_ANIM.none;
		}
		
		static isAnimated = function() {
			var anim = EXPRESS_TREE_ANIM.none;
			anim = max(anim, _isAnimated(l));
			if(symbol != "@")
				anim = max(anim, _isAnimated(r));
			
			return anim;
		}
		
		static eval = function(params = {}) {
			if(ds_map_exists(global.FUNCTIONS, symbol)) {
				if(!is_array(l)) return 0;
				
				var _fn = global.FUNCTIONS[? symbol];
				var _ev = _fn[1];
				var _l  = array_create(array_length(l));
				
				for( var i = 0; i < array_length(l); i++ )
					_l[i] = getVal(l[i], params);
					
				var res = _ev(_l);
				//print($"Function {symbol}{_l} = {res}");
				//print("====================");
				
				return res;
			}
			
			var v1 = getVal(l, params, symbol == "【");
			var v2 = getVal(r, params);
			
			var res = 0;
			
			if(symbol == "") {
				res = v1;
			} else if(symbol == "【") { //array builder
				res = array_create(array_length(v1));
				for( var i = 0; i < array_length(res); i++ )
					res[i] = getVal(v1[i], params);
			} else if(symbol == "@") {
				res = is_real(v2)? array_safe_get(v1, v2) : 0;
			} else if(is_array(v1) && !is_array(v2)) {
				res = array_create(array_length(v1));
				for( var i = 0; i < array_length(res); i++ )
					res[i] = eval_real(array_safe_get(v1, i), v2);
			} else if(!is_array(v1) && is_array(v2)) {
				res = array_create(array_length(v2));
				for( var i = 0; i < array_length(res); i++ )
					res[i] = eval_real(v1, array_safe_get(v2, i));
			} else if(is_array(v1) && is_array(v2)) {
				res = array_create(max(array_length(v1), array_length(v2)));
				for( var i = 0; i < array_length(res); i++ )
					res[i] = eval_real(array_safe_get(v1, i), array_safe_get(v2, i));
			} else 
				res = eval_real(v1, v2);
			
			//print($"|{v1}|{symbol}|{v2}| = {res}");
			//print($"symbol : {symbol}");
			//print($"l      : | {typeof(l)} |{l}|");
			//print($"r      : | {typeof(r)} |{r}|");
			//print("====================");
			
			return res;
		}
		
		static eval_real = function(v1, v2) {
			switch(symbol) {
				case "+": 
					if(_string(v1) || _string(v2))
						return _string_trim(v1) + _string_trim(v2);
					if(is_real(v1) && is_real(v2))
						return v1 + v2;
					return 0;
				case "-": return (is_real(v1) && is_real(v2))? v1 - v2		 : 0;
				case "∸": return is_real(v1)? -v1 : 0;
				case "*": return (is_real(v1) && is_real(v2))? v1 * v2		 : 0;
				case "$": return (is_real(v1) && is_real(v2))? power(v1, v2) : 0;
				case "/": return (is_real(v1) && is_real(v2) && v2 != 0)? v1 / v2 : 0;
				
				case "&": return (is_real(v1) && is_real(v2))? v1 & v2       : 0;
				case "|": return (is_real(v1) && is_real(v2))? v1 | v2       : 0;
				case "^": return (is_real(v1) && is_real(v2))? v1 ^ v2       : 0;
				case "«": return (is_real(v1) && is_real(v2))? v1 << v2      : 0;
				case "»": return (is_real(v1) && is_real(v2))? v1 >> v2      : 0;
				case "~": return  is_real(v1)? ~v1 : 0;
				
				case "=": return (is_real(v1) && is_real(v2))? v1 == v2      : 0;
				case "≠": return (is_real(v1) && is_real(v2))? v1 != v2      : 0;
				case "≤": return (is_real(v1) && is_real(v2))? v1 <= v2      : 0;
				case "≥": return (is_real(v1) && is_real(v2))? v1 >= v2      : 0;
				case ">": return (is_real(v1) && is_real(v2))? v1 > v2       : 0;
				case "<": return (is_real(v1) && is_real(v2))? v1 < v2       : 0;
				
				case "sin"   : return is_real(v1)? sin(v1)    : 0;
				case "cos"   : return is_real(v1)? cos(v1)    : 0;
				case "tan"   : return is_real(v1)? tan(v1)    : 0;
				case "abs"	 : return is_real(v1)? abs(v1)    : 0;
				case "round" : return is_real(v1)? round(v1)  : 0;
				case "ceil"	 : return is_real(v1)? ceil(v1)   : 0;
				case "floor" : return is_real(v1)? floor(v1)  : 0;
			}
			
			return v1;
		}
	}

	function evaluateFunctionTree(fx) {
		static __BRACKETS = [ "(", ")", "[", "]" ];
		
		var pres = global.EQUATION_PRES;
		var vl   = ds_stack_create();
		var op   = ds_stack_create();
		var last_push = "";
		
		fx = functionStringClean(fx);
		
		var len = string_length(fx);
		var l   = 1;
		var ch  = "";
		var cch = "";
		var _ch = "";
		var in_str = false;
		
		//print($"===== Function: {fx} =====");
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			
			if(ds_map_exists(pres, ch)) { //symbol is operator
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					var _top = ds_stack_top(op);
					if(_top == "(" || ds_map_exists(global.FUNCTIONS, _top) || pres[? ch] > pres[? _top]) {
						ds_stack_push(op, ch);
						last_push = "op";
					} else {
						if(ch == "-" && ds_map_exists(pres, _ch)) ch = "∸"; //unary negative
						
						while(pres[? ch] <= pres[? ds_stack_top(op)] && !ds_stack_empty(op))
							ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
						ds_stack_push(op, ch);
						last_push = "op";
					}
				}
				
				l++;
			} else if (ch == "(") {
				if(last_push == "fn")	ds_stack_push(op, [ "〚", ds_stack_size(vl) ]);
				else					ds_stack_push(op, ch);
				last_push = "op";
				l++;
			} else if (ch == ")") {
				while(!ds_stack_empty(op)) {
					var _top = ds_stack_pop(op);
					if(_top == "(") break;
					if(is_array(_top) && _top[0] == "〚") {
						var arr = [];
						while(ds_stack_size(vl) > _top[1])
							array_insert(arr, 0, ds_stack_pop(vl));
						
						ds_stack_push(vl, new __funcTree(ds_stack_pop(op), arr));
						break;
					}
					
					ds_stack_push(vl, buildFuncTree(_top, vl));
				}
				
				last_push = "vl";
				l++;
			} else if (ch == "[") {
				if(last_push == "vl")	ds_stack_push(op, ch);
				else					ds_stack_push(op, [ "{", ds_stack_size(vl) ]);
				last_push = "op";
				l++;
			} else if (ch == "]") {
				while(!ds_stack_empty(op)) {
					var _top = ds_stack_pop(op);
					if(_top == "[") break;
					if(is_array(_top) && _top[0] == "{") {
						var arr = [];
						while(ds_stack_size(vl) > _top[1])
							array_insert(arr, 0, ds_stack_pop(vl));
						ds_stack_push(vl, arr);
						break;
					}
					
					ds_stack_push(vl, buildFuncTree(_top, vl));
				}
				
				last_push = "vl";
				l++;
			} else if (ch == ",") {
				while(!ds_stack_empty(op)) {
					var _top = ds_stack_top(op);
					if(_top == "[" || _top == "(" || (is_array(_top) && _top[0] == "{")) break;
					
					ds_stack_push(vl, buildFuncTree(_top, vl));
				}
				
				last_push = "vl";
				l++;
			} else {
				var vsl = "";
				
				while(l <= len) {
					cch = string_char_at(fx, l);
					if(ds_map_exists(pres, cch) || array_exists(__BRACKETS, cch)) break;
					if(cch == ",") {
						l++;
						break;
					}
					
					vsl += cch;
					l++;
				}
				
				if(vsl == "") continue;
				
				if(ds_map_exists(global.FUNCTIONS, vsl)) { //function
					ds_stack_push(op, vsl);
					last_push = "fn";
				} else {
					vsl = string_trim(vsl);
					switch(vsl) {
						case "e" : ds_stack_push(vl, 2.71828);	break;
						case "pi": ds_stack_push(vl, pi);		break;
						default  : ds_stack_push(vl, isNumber(vsl)? toNumber(vsl) : vsl); break;
					}
					
					last_push = "vl";
				}
			}
			
			_ch = ch;
		}
		
		while(!ds_stack_empty(op)) 
			ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
		ds_stack_destroy(op);
		
		var tree = ds_stack_empty(vl)? noone : ds_stack_pop(vl)
		ds_stack_destroy(vl);
		
		if(!is_struct(tree))
			tree = new __funcTree("", tree);
		
		//print(tree);
		//print("");
		
		return tree;
	}
	
	function buildFuncTree(operator, vl) {
		if(ds_stack_empty(vl)) return noone;
		
		if(ds_map_exists(global.FUNCTIONS, operator)) {
			if(ds_stack_empty(vl)) 
				return noone;
				
			var _v1 = ds_stack_pop(vl);
			return new __funcTree(operator, _v1);
		}
		
		switch(operator) {
			case "-": //deal with preceeding negative number -5
				if(ds_stack_size(vl) >= 2) {
					var _v1 = ds_stack_pop(vl);
					var _v2 = ds_stack_pop(vl);
					return new __funcTree("-", _v2, _v1);	
				} else
					return new __funcTree("-", ds_stack_pop(vl), 0);	
				
			case "@": 
				var _v1 = ds_stack_pop(vl);
				if(is_array(_v1))
					return new __funcTree("【", _v1);	
				else {
					var _v2 = ds_stack_pop(vl);
					return new __funcTree(operator, _v2, _v1);	
				}
				
			case "+": //binary operators
			case "*": 
			case "$": 
			case "/": 
			
			case "|": 
			case "&": 
			case "^": 
			case "»": 
			case "«": 
			
			case "=": 
			case "≠": 
			case "≤": 
			case "≥": 
			case "<": 
			case ">": 
			
				if(ds_stack_size(vl) >= 2) {
					var _v1 = ds_stack_pop(vl);
					var _v2 = ds_stack_pop(vl);
					return new __funcTree(operator, _v2, _v1);	
				}
			
			default: return new __funcTree(operator, ds_stack_pop(vl));
		}
		
		return noone;
	}
	
	function evaluateFunction(fx, params = {}) {
		if(isNumber(fx)) return toNumber(fx);
		return evaluateFunctionTree(fx).eval(params);
	}
#endregion