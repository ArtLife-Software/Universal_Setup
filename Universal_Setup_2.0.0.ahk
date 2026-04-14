;@Ahk2Exe-SetMainIcon Universal_Setup.ico
;@Ahk2Exe-SetDescription Universal Setup
;@Ahk2Exe-SetVersion 2.0.0
;@Ahk2Exe-SetProductName Universal Setup
;@Ahk2Exe-SetProductVersion 2.0.0
;@Ahk2Exe-SetCompanyName ArtLife Software
;@Ahk2Exe-SetCopyright © 2026 林彥丞
;@Ahk2Exe-SetLanguage 0x0404

; ==============================================================================
; Universal Setup
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
SetWorkingDir(A_ScriptDir)

; 自動要求管理員權限
if !A_IsAdmin {
    try Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; --- 1. 讀取配置 ---
IniPath := A_ScriptDir "\Install.ini"
if !FileExist(IniPath) {
    SystemModalMsg("找不到 Install.ini 配置檔，請檢查！", "錯誤", "Iconx")
    ExitApp()
}

AppName      := IniRead(IniPath, "Info", "AppName", "UnknownApp")
LicenseInfo  := StrReplace(IniRead(IniPath, "Info", "License", ""), "\n", "`n")

DefDesktop  := IniRead(IniPath, "Info", "DesktopShortcutDefault", "1")
DefStart    := IniRead(IniPath, "Info", "StartMenuShortcutDefault", "1")
DefAutoRun  := IniRead(IniPath, "Info", "AutoRunDefault", "0")
DefNowRun   := IniRead(IniPath, "Info", "NowRunDefault", "0")

; --- 2. 建立介面 ---
MyGui := Gui("+AlwaysOnTop", AppName " - 安裝")
MyGui.SetFont("s10", "Microsoft JhengHei")

; --- 第一階段：授權合約 ---
Title1      := MyGui.Add("Text", "xm ym", "授權合約：")
LicenseEdit := MyGui.Add("Edit", "xm y+5 w500 h340 ReadOnly", LicenseInfo)
ChkAgree    := MyGui.Add("Checkbox", "vAgree", "我已閱讀並同意授權合約")
MyGui.SetFont("cGray")
AboutMe  := MyGui.Add("Text", "xm y+20", "Universal Setup v2.0.0")
MyGui.SetFont("cDefault")
AboutLine := MyGui.Add("Text", "x+5 yp+10 w362 h3 0x10")
BtnNext     := MyGui.Add("Button", "xm+400 y+10 w100 h35 Default", "下一步")

; --- 第二階段：安裝設定 (初始隱藏) ---
TextFileList := MyGui.Add("Text", "xm ym Hidden", "安裝檔案：")
LV           := MyGui.Add("ListView", "xm y+5 w500 h200 Checked Hidden", ["名稱", "大小", "相對路徑"])
TextPath     := MyGui.Add("Text", "xm y+15 Hidden", "安裝路徑：")
EditPath     := MyGui.Add("Edit", "xm y+5 w400 vInstallPath Hidden", A_ProgramFiles "\" AppName)
BtnBrowse    := MyGui.Add("Button", "x+10 w90 Hidden", "瀏覽...")

; 修正點：動態勾選狀態的字串拼接優化
OptStart := "xm y+15 vStartMenu Hidden " (DefStart="1" ? "Checked" : "")
ChkStartMenu := MyGui.Add("Checkbox", OptStart, "建立開始功能表捷徑")

OptDesk := "xm y+5 vDesktop Hidden " (DefDesktop="1" ? "Checked" : "")
ChkDesktop   := MyGui.Add("Checkbox", OptDesk, "建立桌面捷徑")

OptAuto := "xm y+5 vAutoRun Hidden " (DefAutoRun="1" ? "Checked" : "")
ChkAutoRun   := MyGui.Add("Checkbox", OptAuto, "設定開機時啟動")

OptNow := "xm y+5 vNowRun Hidden " (DefNowRun="1" ? "Checked" : "")
ChkNowRun    := MyGui.Add("Checkbox", OptNow, "安裝結束時啟動")

BtnInstall   := MyGui.Add("Button", "xm+400 y+40 w100 h35 Hidden", "開始安裝")

; --- 互動邏輯 ---
BtnNext.OnEvent("Click", (*) => (
    !MyGui.Submit(false).Agree ? SystemModalMsg("未同意授權合約！","警告","Iconx",MyGui.Hwnd) : ShowSecondStage()
))

ShowSecondStage() {
    Title1.Visible := LicenseEdit.Visible := ChkAgree.Visible := BtnNext.Visible := false
    TextFileList.Visible := LV.Visible := TextPath.Visible := EditPath.Visible := true
    BtnBrowse.Visible := ChkStartMenu.Visible := ChkDesktop.Visible := true
    ChkAutoRun.Visible := ChkNowRun.Visible := BtnInstall.Visible := true
    
    LV.Opt("-Redraw")
    ; 先清空 LV，避免重複執行時疊加
    LV.Delete() 
    
    SourceDir := A_ScriptDir "\Files"
    
    Loop Files, SourceDir "\*.*", "R" {
        RelDir := StrReplace(A_LoopFileDir, SourceDir, "")
        RelDir := LTrim(RelDir, "\") 
        ; 填入 LV：[檔案名稱, 大小, 相對目錄]
        LV.Add("Check", A_LoopFileName, Round(A_LoopFileSize/1024, 1) " KB", RelDir)
    }
    
    Loop LV.GetCount("Col")
        LV.ModifyCol(A_Index, "AutoHdr")
    LV.Opt("+Redraw")
    
    BtnInstall.Focus()
}

BtnBrowse.OnEvent("Click", (*) => (
    MyGui.Opt("+OwnDialogs"),
    f := DirSelect("*" . EditPath.Value, 3, "請選取 " . AppName . " 的安裝路徑"),
    f ? EditPath.Value := f : ""
))
BtnInstall.OnEvent("Click", ProcessInstall)

MyGui.Show()
BtnNext.Focus()

ProcessInstall(*) {
Set := MyGui.Submit()
    TargetDir := Set.InstallPath
    SourceBase := A_ScriptDir "\Files"
    
    SavedDesktopLnk := "" 
    RegisteredLabels := ""
    
    try {
        if !DirExist(TargetDir)
            DirCreate(TargetDir)
        
        Loop LV.GetCount() {
            ; 判斷是否勾選
            if (LV.GetNext(A_Index-1, "Checked") = A_Index) {
                FileName := LV.GetText(A_Index, 1)
                RelDir   := Trim(LV.GetText(A_Index, 3))
                
                ActualRelPath := (RelDir = "") ? FileName : RelDir "\" FileName
                
                SourceFile := SourceBase "\" ActualRelPath
                DestFile   := TargetDir "\" ActualRelPath
                
                ; 確保目標子資料夾存在
                SplitPath(DestFile, , &OutDir)
                if !DirExist(OutDir)
                    DirCreate(OutDir)
                
                ; 執行複製
                if FileExist(SourceFile)
                    FileCopy(SourceFile, DestFile, 1)
                else
                    throw Error("找不到來源檔案: " SourceFile)
            }
        }
        
        if Set.StartMenu {
            ProgDir := A_Programs "\" AppName
            if !DirExist(ProgDir)
                DirCreate(ProgDir)
        
            FList := StrSplit(IniRead(IniPath, "StartMenuShortcuts", "StartMenuFileList", ""), ",")
            SList := StrSplit(IniRead(IniPath, "StartMenuShortcuts", "StartMenuShortcutList", ""), ",")
        
            for i, SrcFile in FList {
                SrcFile := Trim(SrcFile)
                if !SrcFile
                    continue
        
                ; 1. 取得子資料夾路徑 (&SubDir) 與 原始檔名 (&FullFileName)
                SplitPath(SrcFile, &FullFileName, &SubDir)
        
                ; 2. 決定捷徑名稱：完全依照 SList，如果沒寫，就用原始檔名（含副檔名）
                LnkName := (i <= SList.Length && Trim(SList[i])) ? Trim(SList[i]) : FullFileName
        
                ; 3. 處理子資料夾路徑
                if (SubDir != "") {
                    CurrentFolder := ProgDir "\" SubDir
                    if !DirExist(CurrentFolder)
                        DirCreate(CurrentFolder)
                    TargetLnk := CurrentFolder "\" LnkName ".lnk"
                } else {
                    TargetLnk := ProgDir "\" LnkName ".lnk"
                }
        
                ; 4. 建立捷徑
                FileCreateShortcut(TargetDir "\" SrcFile, TargetLnk)
            }
            FileCreateShortcut(TargetDir "\Uninstaller.exe", ProgDir "\解除安裝 " AppName ".lnk")
        }

        if Set.Desktop {
            FList := StrSplit(IniRead(IniPath, "DesktopShortcuts", "DesktopFileList", ""), ",")
            SList := StrSplit(IniRead(IniPath, "DesktopShortcuts", "DesktopShortcutList", ""), ",")
            for i, SrcFile in FList {
                SrcFile := Trim(SrcFile)
                if !SrcFile
                    continue
                SplitPath(SrcFile, &FullFileName)
                LnkName := (i <= SList.Length && Trim(SList[i])) ? Trim(SList[i]) : FullFileName
                LnkPath := A_Desktop "\" LnkName ".lnk"
                FileCreateShortcut(TargetDir "\" SrcFile, LnkPath)
                SavedDesktopLnk .= LnkPath ","
            }
        }

        RunFiles := StrSplit(IniRead(IniPath, "Run", "RunFileList", ""), ",")
        TaskPrefix := "Startup_" . StrReplace(AppName, " ", "_")
        for i, RFile in RunFiles {
            RFile := Trim(RFile)
            if !RFile
                continue
            RPath := TargetDir "\" RFile
            if Set.AutoRun {
                TName := TaskPrefix . "_" . i
                RunWait(A_ComSpec ' /c schtasks /create /tn "' TName '" /tr "\"\"' RPath '\"\"" /sc onlogon /rl highest /f', , "Hide")
            }
            if Set.NowRun {
                try Run(RPath, TargetDir)
            }
        }

; --- 右鍵功能表註冊區塊 ---
        if (IniRead(IniPath, "ContextMenu", "Enable", "0") = "1") {
            ; 讀取配置清單
            CtxFiles := StrSplit(IniRead(IniPath, "ContextMenu", "ContextMenuFileList", ""), ",")
            CtxNames := StrSplit(IniRead(IniPath, "ContextMenu", "ContextMenuList", ""), ",")
            
            ; 讀取四種對象的開關清單
            ForFile := StrSplit(IniRead(IniPath, "ContextMenu", "ForFileList", ""), ",")
            ForDir  := StrSplit(IniRead(IniPath, "ContextMenu", "ForDirectoryList", ""), ",")
            ForDrive := StrSplit(IniRead(IniPath, "ContextMenu", "ForDriveList", ""), ",")
            ForBack := StrSplit(IniRead(IniPath, "ContextMenu", "ForBackgroundList", ""), ",")
        
            for i, FileName in CtxFiles {
                FileName := Trim(FileName)
                if !FileName
                    continue
                
                SplitPath(FileName, &PureFileName)
                
                ; 取得對應的顯示名稱，若無則用檔名
                Label := (i <= CtxNames.Length && Trim(CtxNames[i])) ? Trim(CtxNames[i]) : PureFileName
                ExePath := TargetDir "\" FileName
                
                ; 收集註冊過的 Label，用於反安裝
                RegisteredLabels .= (RegisteredLabels = "" ? "" : ",") . Label
                
                ; 定義註冊表路徑對應表
                RegTargets := [
                    ["HKEY_CLASSES_ROOT\*\shell\",           (i <= ForFile.Length ? ForFile[i] : "0"),  '"' ExePath '" "%1"'],
                    ["HKEY_CLASSES_ROOT\Directory\shell\",   (i <= ForDir.Length ? ForDir[i] : "0"),    '"' ExePath '" "%1"'],
                    ["HKEY_CLASSES_ROOT\Drive\shell\",       (i <= ForDrive.Length ? ForDrive[i] : "0"), '"' ExePath '" "%1"'],
                    ["HKEY_CLASSES_ROOT\Directory\Background\shell\", (i <= ForBack.Length ? ForBack[i] : "0"), '"' ExePath '" "%V"']
                ]
        
                for Target in RegTargets {
                    if (Trim(Target[2]) = "1") {
                        BaseKey := Target[1] . Label
                        try {
                            RegWrite(Label, "REG_SZ", BaseKey)
                            RegWrite(ExePath, "REG_SZ", BaseKey, "Icon")
                            RegWrite(Target[3], "REG_SZ", BaseKey "\command")
                        } catch {
                            ; 靜默跳過
                        }
                    }
                }
            }
        }
        
        ; --- 寫入反安裝資訊檔 ---
        InfoPath := TargetDir "\uninstall_info.ini"
        
        ; 基礎資訊
        IniWrite(AppName, InfoPath, "Config", "AppName")
        IniWrite(TargetDir, InfoPath, "Config", "InstallDir")
        
        ; 右鍵功能表相關
        IniWrite(RegisteredLabels, InfoPath, "Config", "CtxLabels") 
        
        ; 捷徑與啟動相關
        IniWrite(RunFiles.Length, InfoPath, "Config", "RunCount")
        IniWrite(Trim(SavedDesktopLnk, ","), InfoPath, "Config", "DesktopLnk")
        
        SystemModalMsg("安裝成功！", AppName, "Iconi",MyGui.Hwnd)
        ExitApp()
    } catch Error as e {
        SystemModalMsg("安裝失敗: " e.Message, "錯誤", "Iconx",MyGui.Hwnd)
    }
}

; =============================================================
; 模擬原生 MsgBox 引數的強制置頂模組
; 引數順序：Text, Title, Options, Owner (Hwnd)
; =============================================================
SystemModalMsg(Text := "", Title := "", Options := 0, Owner := 0) {
    finalOptions := 0
    
    ; 1. 安全處理 Options
    currOpt := IsSet(Options) ? Options : 0
    
    if IsNumber(currOpt) {
        finalOptions := Number(currOpt)
    } else {
        try {
            ; 使用 v2 正確的函數：StrLower
            optStr := StrLower(String(currOpt))
            
            if InStr(optStr, "iconx")
                finalOptions += 16
            else if InStr(optStr, "icon?")
                finalOptions += 32
            else if InStr(optStr, "icon!")
                finalOptions += 48
            else if InStr(optStr, "iconi")
                finalOptions += 64
                
            if InStr(optStr, "yn")
                finalOptions += 4
        } catch {
            finalOptions := 0
        }
    }

    ; 2. 強制加上 4096 (System Modal)
    finalOptions |= 4096

    ; 3. 處理 Owner
    ; 這裡用最保險的判斷：如果是物件且有 Hwnd 屬性就抓 Hwnd，否則轉成數字
    try {
        ptrOwner := (IsObject(Owner) && HasProp(Owner, "Hwnd")) ? Owner.Hwnd : Number(Owner)
    } catch {
        ptrOwner := 0
    }

    ; 4. 調用 API
    return DllCall("MessageBox", "ptr", ptrOwner, "str", String(Text), "str", String(Title), "uint", finalOptions)
}