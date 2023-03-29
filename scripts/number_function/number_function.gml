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