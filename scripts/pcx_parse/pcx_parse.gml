#region symbols
	global.LOG_EXPRESSION = true;
	
	global.EQUATION_PRES = ds_map_create();
	global.EQUATION_PRES[? "+"] = 1;
	global.EQUATION_PRES[? "-"] = 1;
	global.EQUATION_PRES[? "∸"] = 9; //unary negative
	global.EQUATION_PRES[? "*"] = 2;
	global.EQUATION_PRES[? "/"] = 2;
	global.EQUATION_PRES[? "%"] = 2;
	global.EQUATION_PRES[? "$"] = 3; //power
	
	global.EQUATION_PRES[? "&"] = 5;
	global.EQUATION_PRES[? "|"] = 4;
	global.EQUATION_PRES[? "^"] = 3;
	global.EQUATION_PRES[? "<"] = 3;
	global.EQUATION_PRES[? "»"] = 6;
	global.EQUATION_PRES[? "«"] = 6;
	global.EQUATION_PRES[? "~"] = 9;
	
	global.EQUATION_PRES[? "="]  = -99;
	global.EQUATION_PRES[? "⊕"]  = -99; //+=
	global.EQUATION_PRES[? "⊖"]  = -99; //-=
	global.EQUATION_PRES[? "⊗"]  = -99; //*=
	global.EQUATION_PRES[? "⊘"]  = -99; ///=
	
	global.EQUATION_PRES[? "⩵"] = -1; //==
	global.EQUATION_PRES[? "≠"]  = -1; //!=
	global.EQUATION_PRES[? "<"]  =  0;
	global.EQUATION_PRES[? ">"]  =  0;
	global.EQUATION_PRES[? "≤"]  =  0;
	global.EQUATION_PRES[? "≥"]  =  0;
	
	global.EQUATION_PRES[? "@"] = 5; //array accerssor symbol
	
#endregion

#region parser
	function functionStringClean(fx) {
		static __BRACKETS = [ "(", "[" ];
		
		var ch = "", ind = 0, len = string_length(fx);
		var _fx = "", str = false;
		var _prevSym = true;
		
		while(ind++ <= len) {
			ch = string_char_at(fx, ind);
			
			if(ch == " ") {
				if(str) _fx += ch;
			} else {
				if(ch == "-" && _prevSym)
					_fx += $"0∸";
				else 
					_fx += ch;
				
				_prevSym = ds_map_exists(global.EQUATION_PRES, ch) || array_exists(__BRACKETS, ch); 
			}
			
			if(ch == "\"")
				str = !str;
		}
	
		fx = _fx;
		
		fx = string_replace_all(fx, "\n", "");
		fx = string_replace_all(fx, "**", "$");
		fx = string_replace_all(fx, "<<", "«");
		fx = string_replace_all(fx, ">>", "»");
	
		fx = string_replace_all(fx, "==", "⩵");
		fx = string_replace_all(fx, "!=", "≠");
		fx = string_replace_all(fx, "<>", "≠");
		fx = string_replace_all(fx, ">=", "≥");
		fx = string_replace_all(fx, "<=", "≤");
	
		fx = string_replace_all(fx, "++", "⊕1");
		fx = string_replace_all(fx, "--", "⊖1");
	
		fx = string_replace_all(fx, "+=", "⊕");
		fx = string_replace_all(fx, "-=", "⊖");
		fx = string_replace_all(fx, "*=", "⊗");
		fx = string_replace_all(fx, "/=", "⊘");
		
		fx = string_replace_all(fx, "]", ",］");
	
		fx = string_trim(fx);
	
		return fx;
	}
	
	function functionStrip(fx) {
		var el_st = 1;
		var el_ed = 1;
		
		for( var i = 1; i <= string_length(fx); i++ ) {
			var cch = string_char_at(fx, i);
			if(cch == "(") {
				el_st = i + 1;
				break;
			}
		}
		
		for( var i = string_length(fx); i >= 1; i-- ) {
			var cch = string_char_at(fx, i);
			if(cch == ")") {
				el_ed = i;
				break;
			}
		}
		
		return string_copy(fx, el_st, el_ed - el_st)
	}
	
	function evaluateFunctionList(fx) {
		fx = string_replace_all(fx, "{", "\n{\n");
		fx = string_replace_all(fx, "}", "\n}\n");
		
		var fxs = string_split(fx, "\n", true);
		
		var flist = new __funcList();
		
		var call_st = ds_stack_create();
		var blok_st = ds_stack_create();
		ds_stack_push(call_st, flist);
		
		for( var i = 0, n = array_length(fxs); i < n; i++ ) {
			var _fx = functionStringClean(fxs[i]);
			//print($"Eval line {i}: {_fx} [stack size = {ds_stack_size(call_st)}]");
			
			if(_fx == "" || _fx == "{") continue;
			if(_fx == "}") {
				ds_stack_pop(call_st);
				continue;
			}
			
			var _fx_sp = string_split(_fx, "(");
			var _cmd   = string_trim(_fx_sp[0]);
			var _cond  = functionStrip(_fx);
			
			switch(_cmd) {
				case "if":
					var con_if = new __funcIf();
					con_if.condition = evaluateFunctionTree(_cond);
					ds_stack_top(call_st).addFunction(con_if);
					ds_stack_push(call_st, con_if.if_true);
					ds_stack_push(blok_st, con_if);
					continue;
				case "elseif":
					var con_if = ds_stack_pop(blok_st);
					var con_elif = new __funcIf();
					con_elif.condition = evaluateFunctionTree(_cond);
					
					con_if.if_false.addFunction(con_elif);
					ds_stack_push(call_st, con_elif.if_true);
					ds_stack_push(blok_st, con_elif);
					continue;
				case "else":
					var con_if = ds_stack_pop(blok_st);
					
					ds_stack_push(call_st, con_if.if_false);
					continue;
				case "for":
					var con_for = new __funcFor();
					var cond    = string_splice(_cond, ":");
					if(array_length(cond) == 2) {
						con_for.itr_array = true;
						con_for.cond_arr  = evaluateFunctionTree(cond[1]);
						
						cond[0]  = string_trim(cond[0]);
						var _itr = string_split(cond[0], ",");
						if(array_length(_itr) == 1)
							con_for.cond_iter = cond[0];
						else if(array_length(_itr) == 2) {
							con_for.cond_indx = string_trim(_itr[0]);
							con_for.cond_iter = string_trim(_itr[1]);
						}
					} else if(array_length(cond) == 3) {
						con_for.itr_array = false;
						con_for.cond_init = evaluateFunctionTree(cond[0]);
						con_for.cond_iter = evaluateFunctionTree(cond[1]);
						con_for.cond_term = evaluateFunctionTree(cond[2]);
					}
					ds_stack_top(call_st).addFunction(con_for);
					ds_stack_push(call_st, con_for.action);
					continue;
			}
			
			if(ds_stack_empty(call_st)) {
				print("Block stack empty, how?");
			} else {
				var _top = ds_stack_top(call_st);
				_top.addFunction(evaluateFunctionTree(_fx));
			}
		}
		
		ds_stack_destroy(call_st);
		ds_stack_destroy(blok_st);
		
		return flist;
	}
	
	function evaluateFunctionTree(fx) {
		static __BRACKETS = [ "(", ")", "[", "]", "］" ];
		
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
		
		printIf(global.LOG_EXPRESSION, $"===== Evaluating function: {fx} =====");
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			
			printIf(global.LOG_EXPRESSION, $"Analyzing {ch}");
			
			if(ds_map_exists(pres, ch)) { //symbol is operator
				last_push = "op";
				
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					var _top = ds_stack_top(op);
					if(_top == "(" || ds_map_exists(global.FUNCTIONS, _top) || pres[? ch] > pres[? _top]) {
						ds_stack_push(op, ch);
					} else {
						while(pres[? ch] <= pres[? ds_stack_top(op)] && !ds_stack_empty(op))
							ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
						ds_stack_push(op, ch);
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
				if(last_push == "vl") {									// Get array member | a[1]
					ds_stack_push(op, "@");
					ds_stack_push(op, ch);
				} else													// Create array member | a = [1]
					ds_stack_push(op, [ "{", ds_stack_size(vl) ]);
				
				last_push = "op";
				l++;
			} else if (ch == "］") {
				while(!ds_stack_empty(op)) {
					var _top = ds_stack_pop(op);
					if(_top == "[") break;
					if(is_array(_top) && _top[0] == "{") {
						var arr = [];
						while(ds_stack_size(vl) > _top[1])
							array_insert(arr, 0, ds_stack_pop(vl));
						
						ds_stack_push(vl, new __funcTree("【", arr));
						break;
					}
					
					ds_stack_push(vl, buildFuncTree(_top, vl));
				}
				
				last_push = "vl";
				l++;
			} else if (ch == ",") {
				while(!ds_stack_empty(op)) {
					var _top = ds_stack_top(op);
					if(_top == "[" || _top == "(" || _top == "〚" || (is_array(_top) && _top[0] == "{")) break;
					
					var _top = ds_stack_pop(op);
					ds_stack_push(vl, buildFuncTree(_top, vl));
				}
				
				last_push = "op";
				l++;
			} else {
				var vsl = "";
				
				while(l <= len) {
					cch = string_char_at(fx, l);
					if(ds_map_exists(pres, cch) || array_exists(__BRACKETS, cch)) break;
					if(cch == ",")
						break;
					
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
			
			printIf(global.LOG_EXPRESSION, $"\tvl = {ds_stack_to_array(vl)}\n\top = {ds_stack_to_array(op)}");
			
			_ch = ch;
		}
		
		while(!ds_stack_empty(op)) 
			ds_stack_push(vl, buildFuncTree(ds_stack_pop(op), vl));
		
		var tree = ds_stack_empty(vl)? noone : ds_stack_pop(vl);
		
		ds_stack_destroy(op);
		ds_stack_destroy(vl);
		
		if(!is_struct(tree))
			tree = new __funcTree("", tree);
		
		printIf(global.LOG_EXPRESSION, tree);
		printIf(global.LOG_EXPRESSION, "");
		
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
			case "@": 
				var _v1 = ds_stack_pop(vl);
				var _v2 = ds_stack_pop(vl);
				return new __funcTree(operator, _v2, _v1);	
			
			case "-":
			case "∸":
			
			case "+": //binary operators
			case "*": 
			case "$": 
			case "/": 
			case "%": 
			
			case "|": 
			case "&": 
			case "^": 
			case "»": 
			case "«": 
			
			case "=": 
			case "⩵": 
			case "≠": 
			case "≤": 
			case "≥": 
			case "<": 
			case ">": 
			
			case "⊕": 
			case "⊖": 
			case "⊗": 
			case "⊘": 
				
				if(ds_stack_size(vl) >= 2) {
					var _v1 = ds_stack_pop(vl);
					var _v2 = ds_stack_pop(vl);
					return new __funcTree(operator, _v2, _v1);	
				}
			
			default: return new __funcTree(operator, ds_stack_pop(vl));
		}
		
		return noone;
	}
#endregion