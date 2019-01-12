# How To Patch PE

In oder to add a function to exe

1. Change `exe`, `h = LoadLibraryA("my.dll")`; `p = GetProcAddress(h, "MyFunc")` finally call p 

2. use C/C++ write my.dll, export My Func

`PeExp` look up for `msgbox.exe`'s input table