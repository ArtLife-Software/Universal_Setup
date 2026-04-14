# Universal Setup 通用安裝精靈

![OS](https://img.shields.io/badge/OS-Windows-blue?style=flat-square&logo=windows)
![Language](https://img.shields.io/badge/Language-AutoHotkey_v2-green?style=flat-square&logo=autohotkey)
![Locale](https://img.shields.io/badge/Locale-正體中文-orange?style=flat-square)
![License](https://img.shields.io/badge/License-GPL_v3-red?style=flat-square)
![Latest Release](https://img.shields.io/github/v/release/ArtLife-Software/Universal_Setup?style=flat-square&color=blue)
![Downloads](https://img.shields.io/github/downloads/ArtLife-Software/Universal_Setup/total?style=flat-square&logo=github)

**Universal Setup** 是一個基於 AutoHotkey v2 開發的輕量化、數據驅動型安裝框架。它旨在為綠色軟體提供標準化的安裝體驗，同時保有極高的開發彈性與系統清理能力。

## 🚀 2.0.0 版本更新重點

在 2.0.0 版本中，我們優化了安裝邏輯與反安裝的精確度：
- **視覺化檔案清單**：安裝時顯示 ListView 檔案清單，讓安裝過程完全透明。
- **動態反安裝紀錄**：安裝後自動生成 `uninstall_info.ini`，精確紀錄捷徑路徑與右鍵選單標籤。
- **深度系統整合**：支援多重右鍵選單（Context Menu）寫入與工作排程（Task Scheduler）自動啟動設定。
- **零殘留清理**：反安裝程式會依據紀錄檔，逐一移除桌面捷徑與註冊表項，真正實現綠色軟體的「不留殘骸」。

## 📂 專案結構

```text
.
├── Setup.exe              # 安裝程式核心 (由 Setup.ahk 編譯)
├── Uninstaller.exe        # 反安裝程式核心 (由 Uninstaller.ahk 編譯)
├── Install.ini            # 安裝設定檔 (定義軟體資訊、捷徑、右鍵選單)
└── Files/                 # 放置您的軟體本體 (綠色軟體目錄)
```
<img width="527" height="510" alt="Universal_Setup_2 0 0_主視窗1" src="https://github.com/user-attachments/assets/69ca79ef-8967-41e7-811d-41079ee03986" />
<img width="527" height="510" alt="Universal_Setup_2 0 0_主視窗2" src="https://github.com/user-attachments/assets/22593303-08b8-4769-af1d-1e2dd72131bd" />

## 📝 Install.ini 範例
```text
[Info]
AppName=程式名稱
StartMenuShortcutDefault=1
DesktopShortcutDefault=1
AutoRunDefault=0
NowRunDefault=0
License=程式名稱\n版本1.0.0　2026/04/14\n正體中文版　免費軟體\n由林彥丞設計　lin.yancheng@outlook.com\nhttps://github.com/ArtLife-Software\n中華民國台灣\n基於 AutoHotkey 2.0.23 創建　以 Windows 10 測試通過

[StartMenuShortcuts]
StartMenuFileList=檔案名稱1,資料夾名稱\檔案名稱2
StartMenuShortcutList=捷徑名稱1,捷徑名稱2

[DesktopShortcuts]
DesktopFileList=檔案名稱1,資料夾名稱\檔案名稱2
DesktopShortcutList=捷徑名稱1,捷徑名稱2

[Run]
RunFileList=檔案名稱1,資料夾名稱\檔案名稱2

[ContextMenu]
Enable=0
ContextMenuFileList=檔案名稱1,資料夾名稱\檔案名稱2
ContextMenuList=右鍵功能表名稱1,右鍵功能表名稱2
ForFileList=1,0
ForDirectoryList=0,1
ForDriveList=0,1
ForBackgroundList=0,1
```
