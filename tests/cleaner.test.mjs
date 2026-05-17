import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import vm from "node:vm";

const source = await readFile(new URL("../src/cleaner-core.js", import.meta.url), "utf8");
const context = vm.createContext({
  URL,
  globalThis: {}
});

vm.runInContext(source, context);

const { cleanClipboardText, normalizeBilibiliVideoUrl } = context.globalThis.BiliShareCleaner;

assert.equal(
  cleanClipboardText(
    "【这怎么楞多减速带？异环车辆撞人MOD分享/补档】 https://www.bilibili.com/video/BV1CC5R6aEV7/?share_source=copy_web&vd_source=819e5e0ae730f2e8fdbc457167f6e480"
  ),
  "https://www.bilibili.com/video/BV1CC5R6aEV7/"
);

assert.equal(
  cleanClipboardText("https://www.bilibili.com/video/BV1CC5R6aEV7/?spm_id_from=333.1007"),
  "https://www.bilibili.com/video/BV1CC5R6aEV7/"
);

assert.equal(
  cleanClipboardText("看看這個 https://www.bilibili.com/video/BV1CC5R6aEV7/?share_source=copy_web。"),
  "https://www.bilibili.com/video/BV1CC5R6aEV7/"
);

assert.equal(
  cleanClipboardText("原文 https://www.bilibili.com/video/BV1CC5R6aEV7/ 和 https://www.bilibili.com/video/av12345/?vd_source=abc"),
  "原文 https://www.bilibili.com/video/BV1CC5R6aEV7/ 和 https://www.bilibili.com/video/av12345/"
);

assert.equal(
  normalizeBilibiliVideoUrl("https://m.bilibili.com/video/bv1CC5R6aEV7/?share_medium=android")?.normalized,
  "https://www.bilibili.com/video/BV1CC5R6aEV7/"
);

assert.equal(cleanClipboardText("https://example.com/video/BV1CC5R6aEV7/?share_source=copy_web"), "https://example.com/video/BV1CC5R6aEV7/?share_source=copy_web");

console.log("cleaner tests passed");
