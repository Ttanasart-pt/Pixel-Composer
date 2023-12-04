function GCD(num1, num2) {
	if(num1 * num2 == 0) return 0;
	
    if (num2 == 0) return num1;
    else           return GCD(num2, num1 % num2);
}

function GCDs(num1, num2) {
	if(num1 == num2)     return 0; 
	if(num1 % num2 == 0) return num2;
	if(num2 % num1 == 0) return num1;
	return 0;
}