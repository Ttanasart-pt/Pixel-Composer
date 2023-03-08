/*

 MIT License
 
 Copyright © 2021-2022 Samuel Venable
 Copyright © 2021 Lars Nilsson
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

#include "lib/cproc/cproc.hpp"

#ifdef _WIN32
#define EXPORTED_FUNCTION extern "C" __declspec(dllexport)
#else /* macOS, Linux, and BSD */
#define EXPORTED_FUNCTION extern "C" __attribute__((visibility("default")))
#endif

// execute process from the shell, return process id
EXPORTED_FUNCTION double ProcessExecute(char *command);

// execute process from the shell async, return process id
EXPORTED_FUNCTION double ProcessExecuteAsync(char *command);

//  get whether executed process has quit based on process id
EXPORTED_FUNCTION double CompletionStatusFromExecutedProcess(double procIndex);

// write to executed process standard input file descriptor based on process id
EXPORTED_FUNCTION double ExecutedProcessWriteToStandardInput(double procIndex, char *input);

// read from current process standard input file descriptor
EXPORTED_FUNCTION char *CurrentProcessReadFromStandardInput();

// read from executed process standard output file descriptor based on process id
EXPORTED_FUNCTION char *ExecutedProcessReadFromStandardOutput(double procIndex);

// free executed process standard input string based on process id
EXPORTED_FUNCTION double FreeExecutedProcessStandardInput(double procIndex);

// free executed process standard ouptut string based on process id
EXPORTED_FUNCTION double FreeExecutedProcessStandardOutput(double procIndex);

// get process id from self
EXPORTED_FUNCTION double ProcIdFromSelf();

// get parent process id from self
EXPORTED_FUNCTION double ParentProcIdFromSelf();

// get parent process id from process id
EXPORTED_FUNCTION double ParentProcIdFromProcId(double procId);

// get whether process exists based on process id
EXPORTED_FUNCTION double ProcIdExists(double procId);

// suspend process based on process id, return whether succeeded
EXPORTED_FUNCTION double ProcIdSuspend(double procId);

// resume process based on process id, return whether succeeded
EXPORTED_FUNCTION double ProcIdResume(double procId);

// kill process based on process id, return whether succeeded
EXPORTED_FUNCTION double ProcIdKill(double procId);

// get executable image file path from self
EXPORTED_FUNCTION char *ExecutableFromSelf();

// get executable image file path from process id
EXPORTED_FUNCTION char *ExeFromProcId(double procId);

// get current working directory from process id
EXPORTED_FUNCTION char *CwdFromProcId(double procId);

// get process info from process id
EXPORTED_FUNCTION double ProcInfoFromProcId(double procId);

// get specific process info from process id
EXPORTED_FUNCTION double ProcInfoFromProcIdEx(double procId, double kInfoFlags);

// free process info data from memory
EXPORTED_FUNCTION double FreeProcInfo(double procInfo);

// create a list of all process id's
EXPORTED_FUNCTION double ProcListCreate();

// get process id from process list at index
EXPORTED_FUNCTION double ProcessId(double procList, double i);

// get amount of process id's in process list
EXPORTED_FUNCTION double ProcessIdLength(double procList);

// free list of process id's from memory
EXPORTED_FUNCTION double FreeProcList(double procList);

// get executable image file path from process info data
EXPORTED_FUNCTION char *ExecutableImageFilePath(double procInfo);

// get current working directory ffrom process info data
EXPORTED_FUNCTION char *CurrentWorkingDirectory(double procInfo);

// get parent processs id from process info data
EXPORTED_FUNCTION double ParentProcessId(double procInfo);

// get child process id from process info data at index
EXPORTED_FUNCTION double ChildProcessId(double procInfo, double i);

// get amount of child processes from process info data
EXPORTED_FUNCTION double ChildProcessIdLength(double procInfo);

// get command line argument from process info data at index
EXPORTED_FUNCTION char *CommandLine(double procInfo, double i);

// get amount of command line arguments from process info data
EXPORTED_FUNCTION double CommandLineLength(double procInfo);

// get environment variable (NAME=VALUE) from process info at index
EXPORTED_FUNCTION char *Environment(double procInfo, double i);

// get amount of anvironment variables from process info at index
EXPORTED_FUNCTION double EnvironmentLength(double procInfo);

// get current working directory
EXPORTED_FUNCTION char *DirectoryGetCurrentWorking();

// set current working directory based on a given dname
EXPORTED_FUNCTION double DirectorySetCurrentWorking(char *dname);

// get the environment variable of the given name
EXPORTED_FUNCTION char *EnvironmentGetVariable(char *name);

// get whether the environment variable of the given name exists
EXPORTED_FUNCTION double EnvironmentGetVariableExists(char *name);

// set the environment variable with the given name and value
EXPORTED_FUNCTION double EnvironmentSetVariable(char *name, char *value);

// unset the environment variable with the given name
EXPORTED_FUNCTION double EnvironmentUnsetVariable(char *name);

// get temporary directory path
EXPORTED_FUNCTION char *DirectoryGetTemporaryPath();

#if defined(PROCESS_GUIWINDOW_IMPL)
// get owned window id string from process info at index
EXPORTED_FUNCTION char *OwnedWindowId(double procInfo, double i);

// get amount of owned window id's from process info at index
EXPORTED_FUNCTION double OwnedWindowIdLength(double procInfo);

// get whether a process exists based on one of its window id's
EXPORTED_FUNCTION double WindowIdExists(char *winId);

// suspend process based on one of its window id's, return whether succeeded
EXPORTED_FUNCTION double WindowIdSuspend(char *winId);

// resume process based on one of its window id's, return whether succeeded
EXPORTED_FUNCTION double WindowIdResume(char *winId);

// kill a process based on one of its window id's, return whether succeeded
EXPORTED_FUNCTION double WindowIdKill(char *winId);

// return a window id from native window handle
EXPORTED_FUNCTION char *WindowIdFromNativeWindow(void *window);
#endif
