<v 1.18.0/>
Get the value of an array at a specific index.

## Properties

### <junc array>
The array to get the value from.

### <junc index>
The index of the value to get.

- If the index is negative, it will count from the end of the array.
- In the is an array, the output will be an array with the values at the specified indexes.

### <junc overflow>
What to do if the index is out of bounds.

- `Clamp`: Clamp the index to the bounds of the array (or inverted bound for negative index).
- `Loop`: Wrap the index around the bounds of the array.
- `Ping Pong`: Reflect the index at the bounds of the array.