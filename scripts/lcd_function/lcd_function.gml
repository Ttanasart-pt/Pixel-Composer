function gcd(num1, num2) {
   var a = abs(num1);
   var b = abs(num2);
   
   while (b != 0) {
      var temp = b;
      b = a % b;
      a = temp;
   }
   
   return a;
}