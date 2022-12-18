function string_real(str) {
	var ss  = "";
	var i   = 1;
	
	while(i <= string_length(str)) {
		var ch = string_char_at(str, i);
		switch(ch) {
			case "-":	
			case "0":	
			case "1":	
			case "2":	
			case "3":	
			case "4":	
			case "5":	
			case "6":	
			case "7":	
			case "8":	
			case "9":	
				ss += ch;
				break;
		}
		i++;
	}
	return ss;
}

function string_decimal(str) {
	var ss  = "";
	var i   = 1;
	var dec = 0;
	
	if(string_pos("E", str) != 0) return "0";
	
	while(i <= string_length(str)) {
		var ch = string_char_at(str, i);
		switch(ch) {
			case ".":
				if(dec++ > 0) break;
			case "-":	
			case "0":	
			case "1":	
			case "2":	
			case "3":	
			case "4":	
			case "5":	
			case "6":	
			case "7":	
			case "8":	
			case "9":	
				ss += ch;
				break;
		}
		i++;
	}
	
	return ss;
}

function toNumber(str) {
	str = string_decimal(str);
	if(str == "") return 0;
	if(str == ".") return 0;
	if(str == "-") return 0;	
	return real(str);
}