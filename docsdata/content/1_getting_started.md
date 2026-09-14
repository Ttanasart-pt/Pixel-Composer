# Getting Started


## Download and Installation

You can purchase and download Pixel Composer from itch or Steam for $10.

- [Link to itch.io page](https://makham.itch.io/pixel-composer)
- [Link to Steam page](https://store.steampowered.com/app/2299510/Pixel_Composer)

On Steam, you can launch the program just like any other software. For itch.io version, you have to unzip the file and launch `PixelComposer.exe`

## Troubleshooting

Issues in Pixel Composer can be categorized based on severity:

- Startup Crashes
- Runtime Crashes
- Error
- Warning

In any case, if you found a problem with the software, please make a report to MakhamDev at either the itch.io page or Discord.

### Startup Crashes

The most common causes for startup crash is a preference error. Try backing up and deleting the software directory at:

- Windows: `C:\Users\[Your username]\Appdata\Local\PixelComposer`
- macOS: `~/Library/Application Support/com.Makhamdev.PixelComposer`
- Linux: `~/PixelComposer`

and restart the software.

<img-deco errors/startup>

Startup crashes are the most severe type of issue. This happens when a critical failure occurs before the crash reporter is initialized. 
This type of crash will create a "Microsoft Visual C++ Runtime Library: Runtime Error!" dialog.
If restarting doesn't work, try deleting the `C:\Users\[Your username]\Appdata\Local\PixelComposer` folder (backup the folder first if needed), then try running the software again.

Sometimes a log file `log_temp.txt` will be created in the same location as the exe file. You can attach that file with the report for extra information.

### Runtime Crashes

<img errors/runtime>

Runtime crashes are a more common crash cause by irreversible error caused while running the program. This type of crash will display crash report dialog with crash log which you
can copy and send to the developer for further investigation.

### Error

<img-deco errors/error>

General error are errors occured in the code that can be bypass without crashing. This type of error will create error popup in the program and the notification. Sometime error can cause 
GUI glitch which make the software unusable. If you encounter this type of error, you can find the log file at `%APPDATA%/Local/PixelComposer/log/log.txt`.


### Warning

<img errors/warning>

Warning are the least severe type of error that doesn't interrupt the program operation, however it may cause some node to not function properly.


## Tutorials & Resources

- [Official Youtube channels](#)
- [Patreon extra content](#)
- [Community Discord](#)