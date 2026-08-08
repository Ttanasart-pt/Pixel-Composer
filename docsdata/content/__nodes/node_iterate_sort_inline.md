Iterate through the input array and sort the elements based on the condition defined by node graph. The sorting is done by checking 2 value whether to swap or not. 
For example, if you want to sort array of number in ascending order, you can check the return value of a <node compare> node with the condition `a > b`. If the return value is true, the two value will be swapped, thus putting the smaller value in front of the larger one.

The system comes with 2 nodes:

 - <node Node_Iterator_Sort_Inline_Input> A node outputing a pair of values to be checked.
 - <node Node_Iterator_Sort_Inline_Output> A node for receiving the result whether to swap or not.
