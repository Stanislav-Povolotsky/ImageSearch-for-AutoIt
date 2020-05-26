/*

ImageSearchDLL Module Test

Author: Stanislav Povolotsky (stas.dev[at]povolotsky.info).

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

*/

#include "stdafx.h"
#include "CppUnitTest.h"
#include "resource.h"
using namespace Microsoft::VisualStudio::CppUnitTestFramework;

typedef char* (WINAPI *pfnImageSearch_t)(int aLeft, int aTop, int aRight, int aBottom, char *aImageFile);

namespace
{
    const HMODULE GetCurrentModule()
    {
        MEMORY_BASIC_INFORMATION mbi = { 0 };
        ::VirtualQuery(GetCurrentModule, &mbi, sizeof(mbi));
        return reinterpret_cast<HMODULE>(mbi.AllocationBase);
    }

    HBITMAP LoadResBMP(DWORD dwResID)
    {
        static HINSTANCE s_hInst = (HINSTANCE)GetCurrentModule();
        HBITMAP bmp = (HBITMAP)LoadImageW(s_hInst,
            MAKEINTRESOURCE(dwResID),
            0, 0, 0, LR_DEFAULTSIZE);
        return bmp;
    }
};

namespace ImageSearchDLLUnitTest
{
    TEST_CLASS(ImageSearchDLLMainTest)
    {
        static HINSTANCE s_hLib;
        static pfnImageSearch_t ImageSearch;
        static HBITMAP s_bmpDesktop;
        static HBITMAP s_bmpImageToFind_smile;
        static HBITMAP s_bmpImageToFind_stone;

    public:
        TEST_CLASS_INITIALIZE(InitClass)
        {
            const LPCWSTR sDLLName =
                L"ImageSearchDLL"
#ifdef _WIN64
                L"x64"
#else
                L"x86"
#endif
                L".dll";
            s_hLib = ::LoadLibraryW(sDLLName);
            if (!s_hLib) {
                Assert::Fail(L"Unable to load DLL");
            }
            ImageSearch = (pfnImageSearch_t)GetProcAddress(s_hLib, "ImageSearch");
            if (!ImageSearch) {
                Assert::Fail(L"Unable to find ImageSearch function");
            }
            HINSTANCE hInst = (HINSTANCE)GetCurrentModule();
            s_bmpDesktop = LoadResBMP(IDB_BITMAP_DESKTOP);
            s_bmpImageToFind_smile = LoadResBMP(IDB_BITMAP_IMGAGE_TO_FIND_1);
            s_bmpImageToFind_stone = LoadResBMP(IDB_BITMAP_IMGAGE_TO_FIND_2);
            if (!s_bmpDesktop || !s_bmpImageToFind_smile || !s_bmpImageToFind_stone) {
                Assert::Fail(L"Unable to load image from resource");
            }
        }
        TEST_CLASS_CLEANUP(CleanupClass)
        {
            if (s_hLib) {
                ::FreeLibrary(s_hLib);
                s_hLib = NULL;
            }
        }
        TEST_METHOD(TestBase)
        {
            std::string sRes;
            std::stringstream ss;
            std::string sArg;
            DWORD dwTransparentColor = 0xEA00F6;

            ss << 
                "*Img" << std::hex << "0x" << s_bmpImageToFind_smile << " " <<
                "*DesktopImg" << std::hex << "0x" << s_bmpDesktop << " " <<
                "NONE";
            sArg = ss.str();
            sRes = ImageSearch(0, 0, 1024, 1024, const_cast<char*>(sArg.c_str()));
            Assert::AreEqual("1|47|310|21|22", sRes.c_str());

            ss.str("");
            ss <<
                "*Trans" << std::hex << "0x" << dwTransparentColor << " " <<
                "*Img" << std::hex << "0x" << s_bmpImageToFind_stone << " " <<
                "*DesktopImg" << std::hex << "0x" << s_bmpDesktop << " " <<
                "NONE";
            sArg = ss.str();
            sRes = ImageSearch(0, 0, 1024, 1024, const_cast<char*>(sArg.c_str()));
            Assert::AreEqual("1|45|52|31|28", sRes.c_str());

            ss.str("");
            ss <<
                "*M " << 
                "*Trans" << std::hex << "0x" << dwTransparentColor << " " <<
                "*Img" << std::hex << "0x" << s_bmpImageToFind_stone << " " <<
                "*DesktopImg" << std::hex << "0x" << s_bmpDesktop << " " <<
                "NONE";
            sArg = ss.str();
            sRes = ImageSearch(0, 0, 1024, 1024, const_cast<char*>(sArg.c_str()));
            Assert::AreEqual("1|"
                "45|52|31|28|"  "87|52|31|28|"  "129|52|31|28|"  "171|52|31|28|"
                "45|88|31|28|"  "87|88|31|28|"  "129|88|31|28|"  "171|88|31|28|"
                "45|124|31|28|" "87|124|31|28|" "129|124|31|28|" "171|124|31|28|"
                "45|160|31|28|" "87|160|31|28|" "129|160|31|28|" "171|160|31|28|"
                "45|196|31|28|" "87|196|31|28|" "129|196|31|28|" "171|196|31|28|"
                "45|232|31|28|" "87|232|31|28|" "129|232|31|28|" "171|232|31|28|"
                "45|268|31|28", sRes.c_str());
        }
    };

    HINSTANCE ImageSearchDLLMainTest::s_hLib = NULL;
    pfnImageSearch_t ImageSearchDLLMainTest::ImageSearch = NULL;
    HBITMAP ImageSearchDLLMainTest::s_bmpDesktop = NULL;
    HBITMAP ImageSearchDLLMainTest::s_bmpImageToFind_smile = NULL;
    HBITMAP ImageSearchDLLMainTest::s_bmpImageToFind_stone = NULL;
};