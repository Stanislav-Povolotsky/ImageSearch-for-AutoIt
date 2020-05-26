// ImageSearchDLL.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include <windows.h>
#include "util.h"

#ifdef _MANAGED
#pragma managed(push, off)
#endif

extern void Answer_Clear(int final);

#ifdef _DEBUG
BOOL _DllMain(HMODULE hModule,
    DWORD  ul_reason_for_call,
    LPVOID lpReserved
)
#else
extern "C"
BOOL APIENTRY _DllMainCRTStartup( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
#endif
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_DETACH:
        Answer_Clear(1);
        break;
    }
    return TRUE;
}

#ifdef _MANAGED
#pragma managed(pop)
#endif

/*
void _tmain()
{
	int z;
	HBITMAP hbmp = LoadPicture("c:\\pic.bmp",0,0,z,0,0);
	char *answer="";
	answer = ImageSearch(0,0,1024,768,"c:\\pic.bmp");
	return;
}
*/