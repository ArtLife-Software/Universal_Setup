# 🛠️ Universal Setup (通用安裝精靈)

![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)
![Language](https://img.shields.io/badge/Language-AutoHotkey_v2-green.svg)

這是由 **ArtLife Software** 開發的通用安裝腳本。它能將您的程式，透過簡單的設定檔 (INI)，自動化封裝成具備專業安裝介面的軟體。

## ✨ 核心功能

* **自動化環境設定**：自動要求管理員權限 (Admin) 執行，確保註冊表與系統資料夾寫入正常。
* **高度配置化**：透過 `Install.ini` 即可定義軟體名稱、授權資訊、主程式路徑。
* **智能捷徑建立**：
    * 自動建立「開始功能表」與「桌面」捷徑。
    * 主程式捷徑自動以 `AppName` 命名，其餘檔案捷徑以檔名命名。
* **系統層級整合**：
    * **右鍵選單註冊**：支援將程式註冊至 Windows 右鍵選單（含圖示）。
    * **最高權限開機啟動**：透過 Windows 排程 (schtasks) 實現開機自動執行（繞過 UAC 警告）。
* **完整解除安裝支援**：安裝後自動產生 `uninstall_info.ini`，提供反安裝程式所需的清理資訊。

---

## 📂 資料夾結構

準備封裝時，請保持以下結構：
* `Setup.exe` (此腳本編譯後的執行檔)
* `Install.ini` (設定檔)
* `Files/` (此資料夾放置所有要安裝到目標路徑的程式檔案 + Uninstaller.exe)

---

## ⚙️ Install.ini 範例設定

您可以透過修改此檔案，將同一個安裝程式應用在不同的作品上：

```ini
[Info]
AppName=程式名稱
MainEXE=程式檔案名稱
AutoRunDefault=0
License=程式名稱\n版本1.0.0　2026/04/12

[ContextMenu]
Enable=0
Label=右鍵功能表名稱

[Shortcuts]
FileList=程式檔案名稱,程式檔案名稱1,程式檔案名稱2
