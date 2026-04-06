<v 1.18.0/>
Insert an element into an array at a specific index.

## Properties

### <junc array>
The array to insert the element into.

### <junc index>
The index to insert the element at. 

- If the index is negative, it will count from the end of the array.
- If the index is larger than the array length, the element will be appended to the end of the array.

### <junc value>
The value to insert.

### <junc spread array>
If the value is an array, choose whether to insert each element of the array individually, or insert the entire array as nested array.

If both <junc index> and <junc value> are arrays, the output will be an array with the values inserted at the specified indexes.