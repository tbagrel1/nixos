^!t::  ; Ctrl + Alt + T
{
    Run "wt.exe"
}

^+!t:: ; Ctrl + Alt + Shift + T
{
    Run "*RunAs wt.exe"  ; Run as Administrator
}

^!n::  ; Ctrl + Alt + N
{
    Run 'wt.exe -p "NixOS"'
}
