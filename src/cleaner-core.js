(() => {
  "use strict";

  const URL_RE = /https?:\/\/[^\s<>"']+/giu;
  const TRAILING_PUNCTUATION_RE = /[\])}>.,!?;:'"，。、！？；：」』》】）]+$/u;
  const VIDEO_ID_RE = /^(BV[0-9A-Za-z]+|av\d+)$/i;
  const SHARE_PARAM_RE = /(?:^|[?&#])(share_source|vd_source|spm_id_from|from_spmid|share_medium|unique_k|bbid|ts)=/i;

  function stripTrailingPunctuation(value) {
    let output = value.trim();

    while (TRAILING_PUNCTUATION_RE.test(output) && !output.endsWith("/")) {
      output = output.replace(TRAILING_PUNCTUATION_RE, "");
    }

    return output;
  }

  function isBilibiliHost(hostname) {
    const host = hostname.toLowerCase();
    return host === "bilibili.com" || host.endsWith(".bilibili.com");
  }

  function normalizeVideoId(videoId) {
    if (/^bv/i.test(videoId)) {
      return `BV${videoId.slice(2)}`;
    }

    return videoId;
  }

  function normalizeBilibiliVideoUrl(rawValue) {
    if (typeof rawValue !== "string") {
      return null;
    }

    const candidate = stripTrailingPunctuation(rawValue);
    let url;

    try {
      url = new URL(candidate);
    } catch {
      return null;
    }

    if (!isBilibiliHost(url.hostname)) {
      return null;
    }

    const parts = url.pathname.split("/").filter(Boolean);
    const videoIndex = parts.findIndex((part) => part.toLowerCase() === "video");
    const videoId = videoIndex >= 0 ? parts[videoIndex + 1] : "";

    if (!VIDEO_ID_RE.test(videoId || "")) {
      return null;
    }

    const normalizedVideoId = normalizeVideoId(videoId);

    return {
      original: candidate,
      normalized: `https://www.bilibili.com/video/${normalizedVideoId}/`,
      hasNoise: Boolean(url.search || url.hash || SHARE_PARAM_RE.test(candidate))
    };
  }

  function findBilibiliVideoUrls(text) {
    return Array.from(text.matchAll(URL_RE))
      .map((match) => {
        const normalized = normalizeBilibiliVideoUrl(match[0]);

        if (!normalized) {
          return null;
        }

        return {
          index: match.index,
          token: match[0],
          ...normalized
        };
      })
      .filter(Boolean);
  }

  function isOnlyUrlText(text, hit) {
    return stripTrailingPunctuation(text) === hit.original;
  }

  function looksLikeBilibiliShareText(text, hit) {
    const trimmed = text.trim();

    return (
      hit.hasNoise ||
      SHARE_PARAM_RE.test(trimmed) ||
      /^【[^】]{1,200}】\s*https?:\/\//u.test(trimmed)
    );
  }

  function cleanClipboardText(text) {
    if (typeof text !== "string" || !text.includes("bilibili.com/video")) {
      return text;
    }

    const hits = findBilibiliVideoUrls(text);

    if (hits.length === 0) {
      return text;
    }

    if (
      hits.length === 1 &&
      (isOnlyUrlText(text.trim(), hits[0]) || looksLikeBilibiliShareText(text, hits[0]))
    ) {
      return hits[0].normalized;
    }

    let output = "";
    let cursor = 0;

    for (const hit of hits) {
      const suffix = hit.token.slice(hit.original.length);
      output += text.slice(cursor, hit.index);
      output += `${hit.normalized}${suffix}`;
      cursor = hit.index + hit.token.length;
    }

    output += text.slice(cursor);
    return output;
  }

  function isTextClipboardFormat(format) {
    const normalized = String(format || "").toLowerCase();
    return normalized === "text" || normalized === "text/plain" || normalized === "text/uri-list";
  }

  function isSingleCleanUrl(value) {
    return /^https:\/\/www\.bilibili\.com\/video\/(?:BV[0-9A-Za-z]+|av\d+)\/$/i.test(value);
  }

  globalThis.BiliShareCleaner = Object.freeze({
    cleanClipboardText,
    findBilibiliVideoUrls,
    isSingleCleanUrl,
    isTextClipboardFormat,
    normalizeBilibiliVideoUrl
  });
})();
