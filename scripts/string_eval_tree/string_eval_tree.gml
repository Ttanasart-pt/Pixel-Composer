#region evaluator
	function __funcTree(symbol, l = noone, r = noone) constructor {
		self.symbol = symbol;
		self.l = l;
		self.r = r;
		isFunc = false;
		
		static getVal = function(val, inp = 0) {
			if(is_struct(val)) return val.eval();
			if(is_real(val))   return val;
			
			var splt = string_splice(val, "[");
			var key  = splt[0];
			var _val = 0;
			
			if(key == "value") {
				_val = inp;
				for( var i = 1; i < array_length(splt); i++ ) {
					if(!is_array(_val)) break;
				
					var _ind = toNumber(splt[i]);
					_val = array_safe_get(_val, _ind, 0);
				}
			} else
				_val = nodeGetData(val);
			
			return _val;
		}
		
		static _validate = function(val) {
			if(is_real(val))   return true;
			if(is_struct(val)) return val.validate();
			
			var splt = string_splice(val, "[");
			if(splt[0] == "value") return true;
			
			var strs = string_splice(val, ".");
			if(array_length(strs) == 0) return false;
			if(array_length(strs) == 1) {
				var splt = string_splice(val, "[");
				return GLOBAL.inputExist(splt[0]);
			}
			
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
			if(!ds_map_exists(NODE_NAME_MAP, key)) return false;
		
			var node = NODE_NAME_MAP[? key];
			var splt = string_splice(strs[1], "[");
			if(array_length(splt) < 2) return false;
			
			var mmap = splt[0] == "inputs"? node.inputMap : node.outputMap;
			if(array_length(splt) < 2) return false;
			
			var mkey = string_replace_all(string_replace(splt[1], "]", ""), "\"", "");
			return ds_map_exists(mmap, mkey);
		}
		
		static validate = function() {
			return _validate(l) && _validate(r);
		}
		
		static eval = function(inp = 0) {
			var v1 = getVal(l, inp);
			var v2 = getVal(r, inp);
			
			//print("symbol " + string(symbol));
			//print("l  : " + string(l));
			//print("r  : " + string(r));
			//print("v1 : " + string(v1));
			//print("v2 : " + string(v2));
			//print("====================");
			
			switch(symbol) {
				case "+": return v1 + v2;
				case "-": return v1 - v2;
				case "*": return v1 * v2;
				case "^": return power(v1, v2);
				case "/": return v1 / v2;
				
				case "sin"   : return sin(v1);
				case "cos"   : return cos(v1);
				case "tan"   : return tan(v1);
				case "abs"	 : return abs(v1);
				case "round" : return round(v1);
				case "ceil"	 : return ceil(v1);
				case "floor" : return floor(v1);
			}
			
			return v1;
		}
	}

	function evaluateFunctionTree(fx) {
		var pres = global.EQUATION_PRES;
		var vl   = ds_stack_create();
		var op   = ds_stack_create();
		
		fx = string_replace_all(fx,  " ", "");
		fx = string_replace_all(fx, "\n", "");
		
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
			} else {
				var vsl = "";
				
				while(l <= len) {
					cch = string_char_at(fx, l);
					if(ds_map_exists(pres, cch) || cch == ")" || cch == "(") break;
					
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
			case "+": 
				if(ds_stack_size(vl) >= 2) return new __funcTree("+", ds_stack_pop(vl), ds_stack_pop(vl));	
			case "-": 
				if(ds_stack_size(vl) >= 2) return new __funcTree("-", ds_stack_pop(vl), ds_stack_pop(vl));	
				else					   return new __funcTree("-", ds_stack_pop(vl), 0);	
			case "*": 
				if(ds_stack_size(vl) >= 2) return new __funcTree("*", ds_stack_pop(vl), ds_stack_pop(vl));
			case "^": 
				if(ds_stack_size(vl) >= 2) return new __funcTree("^", ds_stack_pop(vl), ds_stack_pop(vl));
			case "/": 
				if(ds_stack_size(vl) >= 2) return new __funcTree("/", ds_stack_pop(vl), ds_stack_pop(vl));
			
			default: return new __funcTree(operator, ds_stack_pop(vl));
		}
		
		return noone;
	}
#endregion