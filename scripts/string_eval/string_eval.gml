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
	
	global.EQUATION_PRES[? "sin"]   = 5;
	global.EQUATION_PRES[? "cos"]   = 5;
	global.EQUATION_PRES[? "tan"]   = 5;
	global.EQUATION_PRES[? "abs"]   = 5;
	global.EQUATION_PRES[? "round"] = 5;
	global.EQUATION_PRES[? "ceil"]  = 5;
	global.EQUATION_PRES[? "floor"] = 5;
#endregion

function functionStringClean(fx) {
	//fx = string_replace_all(fx,  " ", "");
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
		isFunc = false;
		
		static _string = function(str) {
			return string_char_at(str, 1) == "\"" && 
				string_char_at(str, string_length(str)) == "\"";
		}
		
		static _string_trim = function(str) {
			return _string(str)? string_copy(str, 2, string_length(str) - 2) : string(str);
		}
		
		static getVal = function(val, params = {}, getStr = false) {
			if(is_struct(val)) return val.eval();
			if(is_real(val))   return val;
			
			if(struct_has(params, val))
				return struct_try_get(params, val);
			
			if(getStr)
				return val;
			
			if(_string(string_trim(val)))
				return string_trim(val);
			
			return nodeGetData(val);
		}
		
		static _validate = function(val) {
			if(is_real(val))   return true;
			if(is_string(val)) return true;
			if(is_struct(val)) return val.validate();

			if(val == "value") return true;
			if(GLOBAL_NODE.inputExist(val)) return true;
			
			var strs = string_splice(val, ".");
			if(array_length(strs) < 2) return false;
			
			if(strs[0] == "Project") {
				switch(strs[1]) {
					case "frame" :		
					case "frameTotal" : 
					case "fps" :		
						return true;
				}
				return false;
			}
			
			var key = strs[0];
			return ds_map_exists(NODE_NAME_MAP, key);
		}
		
		static validate = function() {
			switch(symbol) {
				case "@": return _validate(l);
			}
			
			return _validate(l) && _validate(r);
		}
		
		static _isAnimated = function(val) {
			if(is_real(val))   return EXPRESS_TREE_ANIM.none;
			if(is_struct(val)) return val._isAnimated();
			
			if(val == "value") return EXPRESS_TREE_ANIM.base_value;
			if(GLOBAL_NODE.inputExist(val)) {
				var _inp = GLOBAL_NODE.getInput(val);
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
			var v1 = getVal(l, params);
			var v2 = getVal(r, params, symbol == "@");
			
			//print($"|{v1}|{symbol}|{v2}|");
			//print($"symbol : {symbol}");
			//print($"l      : {l}");
			//print($"r      : {r}");
			//print("====================");
			
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
				case "/": return (is_real(v1) && is_real(v2))? v1 / v2       : 0;
				
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
				
				case "@": 
					var val = is_real(v2)? array_safe_get(v1, v2) : 0;
					return val;
				
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
		
		fx = functionStringClean(fx);
		
		var len = string_length(fx);
		var l   = 1;
		var ch  = "";
		var cch = "";
		var _ch = "";
		var in_str = false;
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			if(ch == " ") {
				l++;
				continue;
			}
			
			if(ds_map_exists(pres, ch)) { //symbol is operator
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					if(pres[? ch] > pres[? ds_stack_top(op)] || ds_stack_top(op) == "(") ds_stack_push(op, ch);
					else {
						if(ch == "-" && ds_map_exists(pres, _ch)) ch = "∸"; //unary negative
						
						while(pres[? ch] <= pres[? ds_stack_top(op)] && !ds_stack_empty(op))
							ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
						ds_stack_push(op, ch);
					}
				}
				
				l++;
			} else if (ch == "(") {
				ds_stack_push(op, ch);
				l++;
			} else if (ch == ")") {
				while(ds_stack_top(op) != "(" && !ds_stack_empty(op)) {
					ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
				}
				ds_stack_pop(op);
				l++;
			//} else if (ch == "\"") {
			//	l++;
			//	var str = "";
			//	while(l <= len) {
			//		cch = string_char_at(fx, l);
			//		if(cch == "\"") break;
					
			//		str += cch;
			//		l++;
			//	}
			//	ds_stack_push(vl, str);
			} else if (ch == "[") {
				ds_stack_push(op, ch);
				l++;
			} else if (ch == "]") {
				while(ds_stack_top(op) != "[" && !ds_stack_empty(op))
					ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
				
				ds_stack_pop(op);
				l++;
			} else {
				var vsl = "";
				
				while(l <= len) {
					cch = string_char_at(fx, l);
					if(ds_map_exists(pres, cch) || array_exists(__BRACKETS, cch)) break;
					
					vsl += cch;
					l++;
				}
				
				if(vsl == "") continue;
				
				if(ds_map_exists(pres, vsl)) {
					ds_stack_push(op, vsl);
				} else {
					switch(vsl) {
						case "e" : ds_stack_push(vl, 2.71828);	break;
						case "pi": ds_stack_push(vl, pi);		break;
						default  : ds_stack_push(vl, isNumber(vsl)? toNumber(vsl) : vsl); break;
					}
				}
			}
			
			_ch = ch;
		}
		
		while(!ds_stack_empty(op)) 
			ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
		ds_stack_destroy(op);
		
		var tree = ds_stack_empty(vl)? noone : ds_stack_pop(vl)
		ds_stack_destroy(vl);
		
		if(is_string(tree))
			tree = new __funcTree("", tree);
		
		return tree;
	}
	
	function buildFuncTree(operator, vl) {
		if(ds_stack_empty(vl)) return noone;
		
		switch(operator) {
			case "-": //deal with preceeding negative number -5
				if(ds_stack_size(vl) >= 2) {
					var _v1 = ds_stack_pop(vl);
					var _v2 = ds_stack_pop(vl);
					return new __funcTree("-", _v2, _v1);	
				} else
					return new __funcTree("-", ds_stack_pop(vl), 0);	
				
			case "+": //binary operators
			case "*": 
			case "$": 
			case "/": 
			case "@": 
			
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