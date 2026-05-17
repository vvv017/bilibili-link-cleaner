(() => {
  "use strict";

  const cleaner = globalThis.BiliShareCleaner;
  const INSTALLED_KEY = "__BILI_SHARE_LINK_CLEANER_INSTALLED__";

  if (!cleaner || globalThis[INSTALLED_KEY]) {
    return;
  }

  globalThis[INSTALLED_KEY] = true;

  let copyEventActive = false;

  function cleanText(value) {
    return typeof value === "string" ? cleaner.cleanClipboardText(value) : value;
  }

  function markCopyEventActive() {
    copyEventActive = true;
    setTimeout(() => {
      copyEventActive = false;
    }, 0);
  }

  function patchClipboardWriteText() {
    const clipboard = navigator.clipboard;

    if (!clipboard || typeof clipboard.writeText !== "function") {
      return;
    }

    const originalWriteText = clipboard.writeText;

    if (originalWriteText.__biliShareCleanerPatched) {
      return;
    }

    const patchedWriteText = function patchedWriteText(text) {
      return originalWriteText.call(this, cleanText(text));
    };

    patchedWriteText.__biliShareCleanerPatched = true;

    try {
      Object.defineProperty(clipboard, "writeText", {
        configurable: true,
        writable: true,
        value: patchedWriteText
      });
    } catch {
      const prototype = Object.getPrototypeOf(clipboard);

      if (!prototype || typeof prototype.writeText !== "function") {
        return;
      }

      const originalPrototypeWriteText = prototype.writeText;

      Object.defineProperty(prototype, "writeText", {
        configurable: true,
        writable: true,
        value(text) {
          return originalPrototypeWriteText.call(this, cleanText(text));
        }
      });
    }
  }

  function patchClipboardWrite() {
    const clipboard = navigator.clipboard;

    if (!clipboard || typeof clipboard.write !== "function" || typeof ClipboardItem !== "function") {
      return;
    }

    const originalWrite = clipboard.write;

    if (originalWrite.__biliShareCleanerPatched) {
      return;
    }

    async function cleanClipboardItems(items) {
      return Promise.all(
        Array.from(items || []).map(async (item) => {
          if (!item || !Array.isArray(item.types) || !item.types.includes("text/plain")) {
            return item;
          }

          const plainBlob = await item.getType("text/plain");
          const plainText = await plainBlob.text();
          const cleanedText = cleaner.cleanClipboardText(plainText);

          if (cleanedText === plainText) {
            return item;
          }

          const clipboardPayload = {};

          for (const type of item.types) {
            clipboardPayload[type] =
              type === "text/plain" ? new Blob([cleanedText], { type: "text/plain" }) : item.getType(type);
          }

          if (cleaner.isSingleCleanUrl(cleanedText)) {
            clipboardPayload["text/uri-list"] = new Blob([cleanedText], { type: "text/uri-list" });
          }

          return new ClipboardItem(clipboardPayload);
        })
      );
    }

    const patchedWrite = async function patchedWrite(items) {
      const patchedItems = await cleanClipboardItems(items);

      return originalWrite.call(this, patchedItems);
    };

    patchedWrite.__biliShareCleanerPatched = true;

    try {
      Object.defineProperty(clipboard, "write", {
        configurable: true,
        writable: true,
        value: patchedWrite
      });
    } catch {
      const prototype = Object.getPrototypeOf(clipboard);

      if (!prototype || typeof prototype.write !== "function") {
        return;
      }

      const originalPrototypeWrite = prototype.write;

      Object.defineProperty(prototype, "write", {
        configurable: true,
        writable: true,
        async value(items) {
          const patchedItems = await cleanClipboardItems(items);
          return originalPrototypeWrite.call(this, patchedItems);
        }
      });
    }
  }

  function patchDataTransferSetData() {
    if (!globalThis.DataTransfer || !DataTransfer.prototype || typeof DataTransfer.prototype.setData !== "function") {
      return;
    }

    const prototype = DataTransfer.prototype;
    const originalSetData = prototype.setData;

    if (originalSetData.__biliShareCleanerPatched) {
      return;
    }

    const patchedSetData = function patchedSetData(format, data) {
      const nextData =
        copyEventActive && cleaner.isTextClipboardFormat(format) && typeof data === "string"
          ? cleaner.cleanClipboardText(data)
          : data;

      return originalSetData.call(this, format, nextData);
    };

    patchedSetData.__biliShareCleanerPatched = true;

    Object.defineProperty(prototype, "setData", {
      configurable: true,
      writable: true,
      value: patchedSetData
    });
  }

  function installCopyFallback() {
    document.addEventListener(
      "copy",
      (event) => {
        markCopyEventActive();

        const clipboardData = event.clipboardData;

        if (!clipboardData) {
          return;
        }

        const existingText = clipboardData.getData("text/plain") || globalThis.getSelection?.().toString() || "";
        const cleanedText = cleaner.cleanClipboardText(existingText);

        if (cleanedText === existingText) {
          return;
        }

        clipboardData.setData("text/plain", cleanedText);

        if (cleaner.isSingleCleanUrl(cleanedText)) {
          clipboardData.setData("text/uri-list", cleanedText);
        }

        event.preventDefault();
      },
      true
    );
  }

  patchClipboardWriteText();
  patchClipboardWrite();
  patchDataTransferSetData();
  installCopyFallback();
})();
