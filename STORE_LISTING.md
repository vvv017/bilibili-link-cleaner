# Chrome Web Store Listing Draft

## Product Name

Bili Share Link Cleaner

## Short Description

Automatically cleans Bilibili share links copied from the website.

## Detailed Description

Bili Share Link Cleaner removes extra title text and tracking parameters from Bilibili video share links when you copy them from the Bilibili website.

Example:

`https://www.bilibili.com/video/BV1CC5R6aEV7/?share_source=copy_web&vd_source=...`

becomes:

`https://www.bilibili.com/video/BV1CC5R6aEV7/`

Main features:

- Cleans Bilibili video share links locally in your browser.
- Removes common share and tracking parameters such as `share_source`, `vd_source`, and `spm_id_from`.
- Keeps the canonical video URL that can still be opened normally.
- Does not collect data, make network requests, or use remote code.

## Category

Productivity

## Language

English

## Single Purpose Statement

This extension cleans Bilibili video share links copied from Bilibili pages and keeps only the usable canonical video URL.

## Permission Justification

Content script access to `*.bilibili.com` is required so the extension can intercept Bilibili's copy/share action and rewrite the copied text locally before it reaches the clipboard. The extension does not request access to other websites.

## Remote Code Declaration

No. This extension does not load or execute remote code.

## Data Usage Declaration

This extension does not collect, store, transmit, sell, or share user data. Clipboard text is processed locally only when copied on Bilibili pages.

## Required Graphic Assets

- Store icon: `store-assets/store-icon-128.png`
- Screenshot: `store-assets/screenshot-1280x800.png`
- Small promo tile: `store-assets/promo-small-440x280.png`

## Optional Graphic Assets

- Marquee promo tile: `store-assets/promo-marquee-1400x560.png`
