#include <Windows.h>
#include "KDMAPI.h"

#define MAKEBYTE(l,h)	((l) | ((h) << 4))

namespace KDMAPI {
  HMODULE dll_handle = nullptr;
  uint32_t(__stdcall* SendDirectData)(unsigned long msg);
  int(__stdcall* TerminateKDMAPIStream)();

  void Init() {
    // This block of code is from WinMMWRP
    wchar_t omnimidi_dir[MAX_PATH];
    memset(omnimidi_dir, 0, sizeof(omnimidi_dir));
    GetSystemDirectoryW(omnimidi_dir, MAX_PATH);
    wcscat_s(omnimidi_dir, L"\\OmniMIDI\\OmniMIDI.dll");
    dll_handle = LoadLibraryW(L"OmniMIDI.dll");
    if (!dll_handle) {
      dll_handle = LoadLibraryW(omnimidi_dir);
      if (!dll_handle)
        throw "OmniMIDI not found!";
    }

    auto InitializeKDMAPIStream = (BOOL(WINAPI *)())GetProcAddress(dll_handle, "InitializeKDMAPIStream");
    if (!InitializeKDMAPIStream())
      throw "KDMAPI init failed!";

    auto IsKDMAPIAvailable = (BOOL(WINAPI*)())GetProcAddress(dll_handle, "IsKDMAPIAvailable");
    if (!IsKDMAPIAvailable())
      throw "OmniMIDI was found, but KDMAPI isn't enabled.";

    SendDirectData = (MMRESULT(*)(DWORD))GetProcAddress(dll_handle, "SendDirectData");
    TerminateKDMAPIStream = (BOOL(*)())GetProcAddress(dll_handle, "TerminateKDMAPIStream");

    for (int i = 0; i < 16; i++) {
      SendDirectData(MAKELONG(MAKEWORD(MAKEBYTE(i, 0x0C), 1), MAKEWORD(0, 0)));
    }
  }

  void Destroy() {
    TerminateKDMAPIStream();
  }
}