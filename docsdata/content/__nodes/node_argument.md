<v 1.18.0/>
This nodes allow you to add custom <a href="/misc/command_line.html">command line</a> arguments to the project. This can be useful for passing additional data to the project.

For example, in a project named "cli.pxc" if the <junc tag> value is set to "arg", then you can use the following command line arguments:

```./[pixelcomposer.exe] cli.pxc --arg 10```

This will set the value of the node output to 10.

## Properties

### <junc tag>
Tag of the argument.

### <junc type>
Whether to interpret the argument as a string or a number.

### <junc default value>
Default value of the argument.