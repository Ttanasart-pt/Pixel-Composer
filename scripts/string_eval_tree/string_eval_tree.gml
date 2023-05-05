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
		
		static getVal = function(val, inp = 0, getStr = false) {
			if(is_struct(val)) return val.eval();
			if(is_real(val))   return val;
			
			var _val = 0;
			if(val == "value")  _val = inp;
			else if(getStr)		_val = val;
			else				_val = nodeGetData(val, getStr);
			
			return _val;
		}
		
		static _validate = function(val) {
			if(is_real(val))   return true;
			if(is_struct(val)) return val.validate();

			if(val == "value") return true;
			if(GLOBAL.inputExist(val)) return true;
			
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
				case "|": return _validate(l);
			}
			
			return _validate(l) && _validate(r);
		}
		
		static _isAnimated = function(val) {
			if(is_real(val))   return EXPRESS_TREE_ANIM.none;
			if(is_struct(val)) return val._isAnimated();
			
			if(val == "value") return EXPRESS_TREE_ANIM.base_value;
			if(GLOBAL.inputExist(val)) {
				var _inp = GLOBAL.getInput(val);
				if(_inp.is_anim) return EXPRESS_TREE_ANIM.animated;
			}
			
			return EXPRESS_TREE_ANIM.none;
		}
		
		static isAnimated = function() {
			var anim = EXPRESS_TREE_ANIM.none;
			anim = max(anim, _isAnimated(l));
			if(symbol != "|")
				anim = max(anim, _isAnimated(r));
			
			return anim;
		}
		
		static eval = function(inp = 0) {
			var v1 = getVal(l, inp);
			var v2 = getVal(r, inp, symbol == "|");
			
			//print("symbol " + string(symbol));
			//print("l  : " + string(l));
			//print("r  : " + string(r));
			//print("v1 : " + string(v1));
			//print("v2 : " + string(v2));
			//print("====================");
			
			//print($"{string(v1)} {symbol} {string(v2)}");
			
			switch(symbol) {
				
				case "+": return (is_real(v1) && is_real(v2))? v1 + v2		 : 0;
				case "-": return (is_real(v1) && is_real(v2))? v1 - v2		 : 0;
				case "*": return (is_real(v1) && is_real(v2))? v1 * v2		 : 0;
				case "^": return (is_real(v1) && is_real(v2))? power(v1, v2) : 0;
				case "/": return (is_real(v1) && is_real(v2))? v1 / v2       : 0;
				case "|": 
					var val = is_real(v2)? array_safe_get(v1, v2) : ds_map_try_get(v1, v2);
					if(is_struct(val) && instanceof(val) == "NodeValue")
						val = val.getValue();
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
		
		fx = string_replace_all(fx,  " ", "");
		fx = string_replace_all(fx, "\n", "");
		fx = string_replace_all(fx, "[", "|["); //add array accessor symbol arr[i] = arr|[i] = arr | (i)
		
		var len = string_length(fx);
		var l   = 1;
		var ch, cch;
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			
			if(ds_map_exists(pres, ch)) { //symbol is operator
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					if(pres[? ch] > pres[? ds_stack_top(op)] || ds_stack_top(op) == "(") ds_stack_push(op, ch);
					else {
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
						case "e":  ds_stack_push(vl, 2.71828);	break;
						case "pi": ds_stack_push(vl, pi);		break;
						default :  ds_stack_push(vl, isNumber(vsl)? toNumber(vsl) : vsl); break;
					}
				}
			}
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
			case "-": //deal with preceeding megative number -5
				if(ds_stack_size(vl) >= 2) return new __funcTree("-", ds_stack_pop(vl), ds_stack_pop(vl));	
				else					   return new __funcTree("-", ds_stack_pop(vl), 0);	
				
			case "+": //binary operators
			case "*": 
			case "^": 
			case "/": 
			case "|": 
				if(ds_stack_size(vl) >= 2) return new __funcTree(operator, ds_stack_pop(vl), ds_stack_pop(vl));	
			
			default: return new __funcTree(operator, ds_stack_pop(vl));
		}
		
		return noone;
	}
#endregion