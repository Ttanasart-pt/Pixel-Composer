function convertBase(str, fromBase, toBase) {
    // Convert the input string to decimal first
    var decimalNum = 0;
    var len = string_length(str);
	
    for (var i = 1; i <= len; i++) {
        var digit = string_char_at(str, len - i + 1);
        var value = 0;
        if (digit >= "0" && digit <= "9")
            value = ord(digit) - ord("0");
        else if (digit >= "A" && digit <= "Z")
            value = ord(digit) - ord("A") + 10;
        else if (digit >= "a" && digit <= "z")
            value = ord(digit) - ord("a") + 10;
        
        decimalNum += value * power(fromBase, i - 1);
    }
    
    // Convert the decimal number to the new base
    var newStr = "";
    while (decimalNum > 0) {
        var digit = decimalNum % toBase;
        if (digit < 10)
            newStr = chr(digit + ord("0")) + newStr;
        else
            newStr = chr(digit - 10 + ord("A")) + newStr;
        decimalNum = floor(decimalNum / toBase);
    }
    
    return newStr;
}

function saturate(_x) { return clamp(_x, 0, 1); }

function smoothstep(t)        { return t * t * (3.0 - 2.0 * t); }
function smoothstep_cubic(t)  { return t < 0.5? 4 * t * t * t : 1 - power(-2 * t + 2, 3) / 2; }
function smoothstep_bounce(t) {
	var c1 = 1.70158;
	var c3 = c1 + 1;
	return 1 + c3 * power(t - 1, 3) + c1 * power(t - 1, 2);
}


function min_index() {
	var _min = infinity;
	var _ind = 0;
	
	for( var i = 0; i < argument_count; i++ )
		if(argument[i] < _min) { _min = argument[i]; _ind = i; }
	
	return _ind;
}

function max_index() {
	var _max = -infinity;
	var _ind = 0;
	
	for( var i = 0; i < argument_count; i++ )
		if(argument[i] > _max) { _max = argument[i]; _ind = i; }
	
	return _ind;
}

function toDecimal(num) { return num == 0? 0 : num / power(10, 1 + floor(log10(num))); }