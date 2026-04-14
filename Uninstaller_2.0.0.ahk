;@Ahk2Exe-SetMainIcon Uninstaller.ico
;@Ahk2Exe-SetDescription Uninstaller
;@Ahk2Exe-SetVersion 2.0.0
;@Ahk2Exe-SetProductName Uninstaller
;@Ahk2Exe-SetProductVersion 2.0.0
;@Ahk2Exe-SetCompanyName ArtLife Software
;@Ahk2Exe-SetCopyright © 2026 林彥丞
;@Ahk2Exe-SetLanguage 0x0404

; ==============================================================================
; Uninstaller
; 版本2.0.0
; 2.0.0版 2026/04/14
; 1.0.0版 2026/04/11
; 初建 2026/04/11
;
; 正體中文版
; 免費軟體
;
; 由林彥丞設計
; lin.yancheng@outlook.com
; https://github.com/ArtLife-Software
; 中華民國台灣
;
; 基於 AutoHotkey 2.0.23 創建
; 以 Windows 10 測試通過
; ==============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

if !A_IsAdmin {
    try Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

InfoPath := A_ScriptDir "\uninstall_info.ini"
if !FileExist(InfoPath) {
    MsgBox "找不到反安裝資訊，請手動刪除資料夾。", "錯誤", "Iconx"
    ExitApp()
}

; --- 1. 讀取各項紀錄 ---
AppName    := IniRead(InfoPath, "Config", "AppName", "Unknown App")
InstallDir := IniRead(InfoPath, "Config", "InstallDir", "")
RunCount   := IniRead(InfoPath, "Config", "RunCount", 0)
LnkList    := IniRead(InfoPath, "Config", "DesktopLnk", "")
CtxLabels  := IniRead(InfoPath, "Config", "CtxLabels", "")

if MsgBox("確定要徹底移除 [" AppName "] 嗎？", "解除安裝", "YesNo Icon?") = "No"
    ExitApp()

try {
    ; 2. 清除開機排程
    TaskPrefix := "Startup_" . StrReplace(AppName, " ", "_")
    Loop RunCount {
        RunWait(A_ComSpec ' /c schtasks /delete /tn "' TaskPrefix '_' A_Index '" /f', , "Hide")
    }

    ; 3. 清除開始功能表
    if DirExist(A_Programs "\" AppName)
        DirDelete(A_Programs "\" AppName, 1)

    ; 4. 清除桌面捷徑
    if (LnkList != "") {
        Loop Parse, LnkList, "," {
            if FileExist(A_LoopField)
                FileDelete(A_LoopField)
        }
    }

    ; 5. 清除右鍵功能表 (使用多重標籤清除)
    if (CtxLabels != "") {
        RootKeys := [
            "HKEY_CLASSES_ROOT\*\shell\",
            "HKEY_CLASSES_ROOT\Directory\shell\",
            "HKEY_CLASSES_ROOT\Drive\shell\",
            "HKEY_CLASSES_ROOT\Directory\Background\shell\"
        ]
        Loop Parse, CtxLabels, "," {
            Label := Trim(A_LoopField)
            if !Label
                continue
            for RootKey in RootKeys
                try RegDeleteKey(RootKey . Label)
        }
    }

    MsgBox(AppName " 環境已清理完成，即將刪除程式檔案。", "完成", "Iconi")

    ; 6. 自我毀滅 (確保 CMD 不會鎖定資料夾)
    ; 先切換 CMD 運作目錄到 Temp，再回頭刪除安裝目錄
    Run(A_ComSpec ' /c timeout /t 3 & cd /d ' A_Temp ' & rd /s /q "' InstallDir '"', , "Hide")

} catch Error as e {
    MsgBox("清理出錯: " e.Message, "錯誤", "Iconx")
}

ExitApp()