<v 1.18.0/>
Insert an element into an array at a specific index.

## Properties

[proptable]
Array|The array to insert the element into.
Index|The index to insert the element at. \n
 - If the index is negative, it will count from the end of the array.\n
 - If the index is larger than the array length, the element will be appended to the end of the array.
Value|The value to insert.
Spread Array|If the value is an array, choose whether to insert each element of the array individually, or insert the entire array as nested array.
[/proptable]

If both <junc index> and <junc value> are arrays, the output will be an array with the values inserted at the specified indexes.