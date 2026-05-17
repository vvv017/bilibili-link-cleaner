# Bili Share Link Cleaner

一個 Chrome/Edge Manifest V3 瀏覽器擴充套件。打開 Bilibili 後，使用網站的分享/複製功能時，擴充套件會把剪貼簿內容清理成可直接訪問的影片網址。

例如：

```text
【这怎么楞多减速带？异环车辆撞人MOD分享/补档】 https://www.bilibili.com/video/BV1CC5R6aEV7/?share_source=copy_web&vd_source=819e5e0ae730f2e8fdbc457167f6e480
```

會變成：

```text
https://www.bilibili.com/video/BV1CC5R6aEV7/
```

## 安裝

1. 打開 Chrome 或 Edge 的擴充套件管理頁。
2. 開啟「開發人員模式」。
3. 點「載入未封裝項目」。
4. 選擇這個資料夾：`Z:\code\bilisharelink`

## 功能範圍

- 支援 `www.bilibili.com/video/...`、`m.bilibili.com/video/...` 等 Bilibili 影片網址。
- 會移除 `share_source`、`vd_source`、`spm_id_from` 等分享追蹤參數。
- 如果剪貼簿裡只有一個 Bilibili 影片分享網址，會只保留乾淨網址。
- 如果文字裡有多個 Bilibili 影片網址，會保留原文字並清理每個影片網址。

## 開發測試

```bash
npm test
```

## 生成素材

```bash
npm run assets
```

這會生成：

- 擴充套件圖示：`assets/icons/`
- Chrome Web Store 上架素材：`store-assets/`

`assets/icons/` 是擴充套件執行時需要的檔案，會提交到 GitHub。`store-assets/` 只用於 Chrome Web Store 後台上架，預設不提交到 GitHub。

## 打包 Chrome Web Store ZIP

```bash
npm run package
```

輸出檔案會在 `dist/`，例如：

```text
dist/bili-share-link-cleaner-0.1.0.zip
```

這個 ZIP 是要上傳到 Chrome Web Store Developer Dashboard 的套件。

## 推到 GitHub

```bash
git init
git add .
git commit -m "Initial Bili share link cleaner extension"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/bili-share-link-cleaner.git
git push -u origin main
```

## Chrome Web Store 上架資料

上架文案、隱私欄位、權限說明和素材路徑整理在 `STORE_LISTING.md`。

隱私政策整理在 `PRIVACY.md`。
