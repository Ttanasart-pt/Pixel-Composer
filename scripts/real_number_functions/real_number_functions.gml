function GCD(num1, num2) {
	if(num1 * num2 == 0) return 1;
	
	var n1 = max(num1, num2);
	var n2 = min(num1, num2);
	var nn = n1 % n2;
	
	if(nn == 0) return n2;
    return GCD(n2, nn);
}

function GCDs(num1, num2) {
	if(num1 == num2)     return 0; 
	if(num1 % num2 == 0) return num2;
	if(num2 % num1 == 0) return num1;
	return 0;
}