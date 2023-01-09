#region evaluator
	function functionTree(_val, _child) constructor {
		val   = _val;
		child = _child;
		
		function eval(_x, _n) {
			switch(val) {
				case "+"	: if(array_length(child) >= 2) return child[0].eval(_x, _n) + child[1].eval(_x, _n);
				case "-"	: if(array_length(child) >= 2) return child[0].eval(_x, _n) - child[1].eval(_x, _n);
				case "*"	: if(array_length(child) >= 2) return child[0].eval(_x, _n) * child[1].eval(_x, _n);	
				case "/"	: if(array_length(child) >= 2) return child[0].eval(_x, _n) / child[1].eval(_x, _n);
			
				case "sin"	: if(array_length(child) >= 1) return sin(child[0].eval(_x, _n));
				case "cos"	: if(array_length(child) >= 1) return cos(child[0].eval(_x, _n));
				case "tan"	: if(array_length(child) >= 1) return tan(child[0].eval(_x, _n));
				
				case "pi"	: return pi;
				case "x"	:
				case "t"	: return _x;
				case "n"	: return _n;
				
				default     : return toNumber(val);
			}
			
			return 0;
		}
	}
	
	function buildTree(_op, vl) {
		var ch = [];
		
		switch(_op) {
			case "+": 
			case "-": 
			case "*": 
			case "/": 
				if(ds_stack_size(vl) >= 2) ch = [ds_stack_pop(vl), ds_stack_pop(vl)]; break;
			
			case "sin": 
			case "cos": 
			case "tan": 
				if(ds_stack_size(vl) >= 1) ch = [ds_stack_pop(vl)]; break;
		}
		
		return new functionTree(_op, ch);	
	}
	
	function functionGraph(fx) {
		static pres = ds_map_create();
		pres[? "+"] = 1;
		pres[? "-"] = 1;
		pres[? "*"] = 2;
		pres[? "/"] = 2;
		pres[? "sin"] = 5;
		pres[? "cos"] = 5;
		pres[? "tan"] = 5;
		
		var vl = ds_stack_create();
		var op = ds_stack_create();
		
		fx = string_replace_all(fx, " ", "");
		var len = string_length(fx);
		var l  = 1;
		var ch, cch;
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			
			if(ds_map_exists(pres, ch)) {
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					if(pres[? ch] > pres[? ds_stack_top(op)] || ds_stack_top(op) == "(") ds_stack_push(op, ch);
					else {
						while(pres[? ch] <= pres[? ds_stack_top(op)] && !ds_stack_empty(op)) {
							ds_stack_push(vl, buildTree(ds_stack_pop(op), vl));
						}
						ds_stack_push(op, ch);
					}
				}
				l++;
			} else if (ch == "(") {
				ds_stack_push(op, ch);
				l++;
			} else if (ch == ")") {
				while(ds_stack_top(op) != "(" && !ds_stack_empty(op)) {
					ds_stack_push(vl, buildTree(ds_stack_pop(op), vl));
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
				
				if(ds_map_exists(pres, vsl)) {
					ds_stack_push(op, vsl);
				} else {
					ds_stack_push(vl, new functionTree(vsl, []));
				}
			}
		}
		
		while(!ds_stack_empty(op)) {
			ds_stack_push(vl, buildTree(ds_stack_pop(op), vl));
		}
		
		ds_stack_destroy(op);
		
		return ds_stack_empty(vl)? new functionTree("", []) : ds_stack_pop(vl);
	}
	
	function evaluateFunction(fx, params = {}) {
		static pres = ds_map_create();
		pres[? "+"] = 1;
		pres[? "-"] = 1;
		pres[? "*"] = 2;
		pres[? "/"] = 2;
		pres[? "sin"] = 5;
		pres[? "cos"] = 5;
		pres[? "tan"] = 5;
		
		var vl = ds_stack_create();
		var op = ds_stack_create();
		
		fx = string_replace_all(fx, " ", "");
		fx = string_replace_all(fx, "\n", "");
		
		var len = string_length(fx);
		var l  = 1;
		var ch, cch;
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			
			if(ds_map_exists(pres, ch)) {
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					if(pres[? ch] > pres[? ds_stack_top(op)] || ds_stack_top(op) == "(") ds_stack_push(op, ch);
					else {
						while(pres[? ch] <= pres[? ds_stack_top(op)] && !ds_stack_empty(op)) {
							ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
						}
						ds_stack_push(op, ch);
					}
				}
				
				l++;
			} else if (ch == "(") {
				ds_stack_push(op, ch);
				l++;
			} else if (ch == ")") {
				while(ds_stack_top(op) != "(" && !ds_stack_empty(op)) {
					ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
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
						case "e":  ds_stack_push(vl, 2.71828); break;
						case "pi": ds_stack_push(vl, pi); break;
						
						default :  
							if(variable_struct_exists(params, vsl)) 
								ds_stack_push(vl, variable_struct_get(params, vsl));
							else 
								ds_stack_push(vl, toNumber(vsl));
						break;
					}
				}
			}
		}
		
		while(!ds_stack_empty(op)) {
			ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
		}
		ds_stack_destroy(op);
		
		return ds_stack_empty(vl)? 0 : ds_stack_pop(vl);
	}
	
	function evalToken(operator, vl) {
		if(ds_stack_empty(vl)) return 0;
		switch(operator) {
			case "+": if(ds_stack_size(vl) >= 2) return ds_stack_pop(vl) + ds_stack_pop(vl);	
			case "-": 
				if(ds_stack_size(vl) >= 2)		 return -ds_stack_pop(vl) + ds_stack_pop(vl);
				else							 return -ds_stack_pop(vl);
			case "*": if(ds_stack_size(vl) >= 2) return ds_stack_pop(vl) * ds_stack_pop(vl);	
			case "/": 
				if(ds_stack_size(vl) >= 2) {
					var _d = ds_stack_pop(vl);
					if(_d == 0) return 0;
					return ds_stack_pop(vl) / _d;
				}
			
			case "sin": if(ds_stack_size(vl) >= 1) return sin(ds_stack_pop(vl));
			case "cos": if(ds_stack_size(vl) >= 1) return cos(ds_stack_pop(vl));
			case "tan": if(ds_stack_size(vl) >= 1) return tan(ds_stack_pop(vl));
		}
		
		return 0;
	}
#endregion