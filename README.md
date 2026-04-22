# 🛠️ Universal Setup

![OS](https://img.shields.io/badge/OS-Windows-blue?style=flat-square&logo=windows)
![Language](https://img.shields.io/badge/Language-AutoHotkey_v2-green?style=flat-square&logo=autohotkey)
![Locale](https://img.shields.io/badge/Locale-正體中文-orange?style=flat-square)
![License](https://img.shields.io/badge/License-GPL_v3-red?style=flat-square)
![Latest Release](https://img.shields.io/github/v/release/ArtLife-Software/Universal_Setup?style=flat-square&color=blue)
![Downloads](https://img.shields.io/github/downloads/ArtLife-Software/Universal_Setup/total?style=flat-square&logo=github)

**Universal Setup** 是一個基於 AutoHotkey v2 開發的通用型軟體安裝程式框架。透過簡單的 `.ini` 配置文件，開發者可以快速建立具備授權協議檢查、自定義路徑、組件分組安裝、右鍵選單註冊以及高權限自動啟動功能的專業安裝包。

## 核心特色

  * **權限管理**：自動請求系統管理員權限，確保寫入 `Program Files` 與系統註冊表無誤。
  * **多樣化安裝模式**：
    * **一般模式**：自動掃描 Files 資料夾並安裝所有內容。
    * **群組模式**：自定義組件清單（可選、必選、單選或複選）。
  * **系統整合**：支持建立桌面/開始功能表捷徑、註冊 Windows 右鍵選單（支援檔案、資料夾、磁碟機等多種標的）。
  * **高權限啟動**：透過 Windows 工作排程器 (schtasks) 實現開機後自動以管理員權限執行程式。
  * **完全卸載**：安裝時動態生成卸載資訊，確保 `Uninstaller.exe` 能精準移除所有產生的資源。

-----

## 📂 檔案架構與使用方式

在使用本框架前，請確保你的目錄結構如下：

```text
.
├── Setup.exe              # 主安裝程式（編譯後的 AHK 腳本）
├── Uninstaller.exe        # 卸載程式
├── Setup_License.txt      # 顯示於「關於」視窗的授權說明
└── Config/
    ├── Install.ini        # 核心設定檔 (定義安裝邏輯)
    ├── License.txt        # 顯示於安裝介面的授權條款 (UTF-16 LE)
    └── [GroupFiles].txt   # 若開啟群組模式，用於定義各組件的檔案清單
└── Files/
    └── [YourAppFiles]     # 存放所有要安裝到目標電腦的原始檔案路徑
```

### 使用步驟：

1.  將你的應用程式檔案放入 `Files` 資料夾（支援子資料夾結構）。
2.  編輯 `Config\Install.ini` 調整安裝邏輯。
3.  準備 `Config\License.txt`（**編碼須為 UTF-16 LE**）。
4.  將全體檔案打包後發佈。

-----

## 🛠 詳細配置指南 (Install.ini)

`Install.ini` 採用的格式為標準 Windows INI 結構，多個檔案或名稱請以 `逗號 (,)` 分隔。

### 1\. [Info] - 軟體基本資訊

| 欄位名稱 | 預設值 | 說明 |
| :--- | :--- | :--- |
| `AppName` | UnknownApp | 軟體名稱（用於 GUI 標題及預設安裝目錄名） |
| `DesktopShortcutDefault` | 1 | 是否預設勾選「建立桌面捷徑」 (1=是, 0=否) |
| `StartMenuShortcutDefault`| 1 | 是否預設勾選「建立開始功能表捷徑」 |
| `AutoRunDefault` | 0 | 是否預設勾選「開機時啟動」 |
| `NowRunDefault` | 0 | 安裝完成後是否預設勾選「立即啟動程式」 |

### 2\. [StartMenuShortcuts] & [DesktopShortcuts] - 捷徑定義

  * **`FileList`**: 欲建立捷徑的目標檔案路徑（相對於安裝後的根目錄）。
  * **`ShortcutList`**: 捷徑的顯示名稱。若省略，則使用原檔名。
  * *範例：* `StartMenuFileList=App.exe,Docs\Manual.pdf`

### 3\. [Run] - 啟動與排程

  * **`RunFileList`**: 啟動目標（相對於安裝後的根目錄）。
  * **`ScheduleList`**: 註冊於 Windows 工作排程器中的 Task 名稱（建議使用英數與底線）。
  * *註：* 此功能會自動建立 `onlogon` 觸發器並以 `Highest` 層級執行。

### 4\. [ContextMenu] - 系統右鍵選單

讓你的程式整合進 Windows 檔案總管的右鍵選單。

  * **`Enable`**: 總開關 (1=開啟, 0=關閉)。
  * **`ContextMenuFileList`**: 點擊選單時要執行的程式。
  * **`ContextMenuList`**: 選單上顯示的文字（例如：`使用 XXX 開啟`）。
  * **對象過濾 (1=顯示, 0=隱藏)**:
      * `ForFileList`: 出現在一般「檔案」右鍵。
      * `ForDirectoryList`: 出現在「資料夾」圖示右鍵。
      * `ForDriveList`: 出現在「磁碟機」圖示右鍵。
      * `ForBackgroundList`: 出現在資料夾空白處的背景選單。

### 5\. [SetupGroup] - 進階組件安裝

當安裝包包含多個選購或必選組件時使用。

  * **`GroupEnable`**: 啟用群組模式 (1=開啟，將忽略 `Files` 全掃描)。
  * **`GroupMultiSelect`**: 1 為多選模式；0 為單選模式。
  * **`GroupFileList`**: 指定 `Config` 資料夾下的 `.txt` 檔案清單。
  * **`GroupHelpList`**: 安裝界面上顯示的組件說明。
  * **`GroupRequiredList`**: 1 為「必要組件」，使用者無法取消勾選。

-----

## 📂 組件檔案清單規範 (`Config\*.txt`)

若開啟群組模式，對應的 `.txt` 檔案內容格式如下（**UTF-16 LE** 編碼）：

```text
; 範例：基本組件.txt 內容
MainApp.exe
Data\Setting.json
Resources\Logo.png
```

安裝程式會自動讀取每一行路徑，並在安裝目標路徑建立相同的子目錄結構。

-----

## 開發資訊

  * **設計開發**：**林彥丞 (ArtLife Software)**
  * **開發語言**：AutoHotkey v2.0
  * **聯絡信箱**：[lin.yancheng@outlook.com](mailto:lin.yancheng@outlook.com)
  * **社群支援**：[O & C VBA研究社](https://www.facebook.com/groups/vba.club)

## 授權協議

本專案採用 **GPL-3.0 License** 授權發佈。
