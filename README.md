# Bili Share Link Cleaner

中文 | English

[Chrome Web Store](https://chromewebstore.google.com/detail/fmoffogeilchfilofdkccphjadfoacnp)

## 簡介 / Overview

一個 Chrome/Edge Manifest V3 瀏覽器擴充套件。打開 Bilibili 後，使用網站的分享/複製功能時，擴充套件會把剪貼簿內容清理成可直接訪問的影片網址。

A Chrome/Edge Manifest V3 browser extension. When you copy a share link from Bilibili, it cleans the clipboard text and keeps only the usable video URL.

範例 / Example:

```text
【Video title】 https://www.bilibili.com/video/BV1CC5R6aEV7/?share_source=copy_web&vd_source=819e5e0ae730f2e8fdbc457167f6e480
```

會變成 / Becomes:

```text
https://www.bilibili.com/video/BV1CC5R6aEV7/
```

## 安裝 / Installation

1. 打開 Chrome 或 Edge 的擴充套件管理頁。
2. 開啟「開發人員模式」。
3. 點「載入未封裝項目」。
4. 選擇這個資料夾：`Z:\code\bilisharelink`

1. Open the extensions management page in Chrome or Edge.
2. Enable Developer mode.
3. Click Load unpacked.
4. Select this folder: `Z:\code\bilisharelink`

## 功能 / Features

- 支援 `www.bilibili.com/video/...`、`m.bilibili.com/video/...` 等 Bilibili 影片網址。
- 移除 `share_source`、`vd_source`、`spm_id_from` 等常見分享與追蹤參數。
- 如果剪貼簿裡只有一個 Bilibili 影片分享網址，會只保留乾淨網址。
- 如果文字裡有多個 Bilibili 影片網址，會保留原文字並清理每個影片網址。
- 所有處理都在瀏覽器本機完成，不收集、不儲存、不上傳資料。

- Supports Bilibili video URLs such as `www.bilibili.com/video/...` and `m.bilibili.com/video/...`.
- Removes common share and tracking parameters such as `share_source`, `vd_source`, and `spm_id_from`.
- If the clipboard contains one Bilibili video share link, only the clean URL is kept.
- If the text contains multiple Bilibili video URLs, the original text is preserved while each video URL is cleaned.
- All processing happens locally in the browser. No data is collected, stored, or uploaded.

## 開發 / Development

Run tests:

```bash
npm test
```

Generate extension icons and Chrome Web Store listing assets:

```bash
npm run assets
```

`assets/icons/` contains runtime icons required by the extension and is committed to GitHub.

`store-assets/` contains Chrome Web Store listing images only. It is generated locally and is not committed to GitHub.

## Chrome Web Store

上架連結 / Published listing:

https://chromewebstore.google.com/detail/fmoffogeilchfilofdkccphjadfoacnp

上架文案、隱私欄位、權限說明和素材路徑整理在 `STORE_LISTING.md`。

The Chrome Web Store listing copy, privacy fields, permission justification, and asset paths are documented in `STORE_LISTING.md`.

隱私政策整理在 `PRIVACY.md`。

The privacy policy is documented in `PRIVACY.md`.
