<v 1.18.0/>
This node is used to control the playback of the animations using triggers. Noted that modifying playback in runtime can cause problem with animation exporter. So this node shoud be use for live update or 
still image rendering only.

## Triggers

<table class="cc4060">
    <tr>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><junc toggle play / pause></td>
        <td>Switch between play and pause state.</td>
    </tr>
    <tr>
        <td><junc pause></td>
        <td>Pause the animation.</td>
    </tr>
    <tr>
        <td><junc resume></td>
        <td>Resume the animation.</td>
    </tr>
    <tr>
        <td><junc play from beginning></td>
        <td>Play the animation from the beginning.</td>
    </tr>
    <tr>
        <td><junc play once></td>
        <td>Play the animation once.</td>
    </tr>
    <tr>
        <td><junc skip frames></td>
        <td>Skip by <junc skip frames count> frames.</td>
    </tr>
</table>