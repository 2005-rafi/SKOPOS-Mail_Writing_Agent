/**
 * SKOPOS Lightweight Rich Markdown & Text Formatting Engine
 * Safely converts Markdown, code blocks, lists, and line breaks into sanitized HTML.
 * Also provides pristine plain-text extraction for clipboard operations.
 */

const MarkdownRenderer = {
  /**
   * Pre-cleans raw HTML break tags (like <br>, <br/>, &lt;br&gt;) and carriage returns.
   */
  normalizeText(text) {
    if (!text) return "";
    let str = String(text);
    // Replace raw or entity-encoded HTML line breaks with standard newlines
    str = str.replace(/<br\s*\/?>/gi, "\n");
    str = str.replace(/&lt;br\s*\/?&gt;/gi, "\n");
    str = str.replace(/<\/?p\s*>/gi, "\n\n");
    str = str.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
    return str;
  },

  /**
   * Safe HTML character escaping to prevent XSS.
   */
  escapeHtml(text) {
    if (!text) return "";
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  },

  /**
   * Render markdown and text into rich HTML.
   */
  render(rawText) {
    if (!rawText) return "";

    const normalized = this.normalizeText(rawText).trim();
    if (!normalized) return "";

    // 1. Extract and preserve code blocks using placeholders
    const codeBlocks = [];
    let processed = normalized.replace(/```([a-zA-Z0-9_-]*)\n([\s\S]*?)```/g, (match, lang, code) => {
      const id = `__CODE_BLOCK_${codeBlocks.length}__`;
      codeBlocks.push({ lang: (lang || "code").trim(), code: code.trim() });
      return id;
    });

    // 2. Escape HTML for everything outside code blocks
    processed = this.escapeHtml(processed);

    // 3. Process block elements line by line
    const lines = processed.split("\n");
    const outputBlocks = [];
    let currentList = null; // { type: 'ul' | 'ol', items: [] }
    let currentParagraph = [];

    const flushParagraph = () => {
      if (currentParagraph.length > 0) {
        const pText = currentParagraph.join("<br>");
        outputBlocks.push(`<p class="md-para">${this.renderInline(pText)}</p>`);
        currentParagraph = [];
      }
    };

    const flushList = () => {
      if (currentList) {
        const tag = currentList.type;
        const itemsHtml = currentList.items
          .map((item) => `<li class="md-list-item">${this.renderInline(item)}</li>`)
          .join("");
        outputBlocks.push(`<${tag} class="md-list ${tag === "ol" ? "md-ol" : "md-ul"}">${itemsHtml}</${tag}>`);
        currentList = null;
      }
    };

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const trimmed = line.trim();

      // Check for code block placeholder
      if (trimmed.startsWith("__CODE_BLOCK_") && trimmed.endsWith("__")) {
        flushParagraph();
        flushList();
        outputBlocks.push(trimmed);
        continue;
      }

      // Empty line -> paragraph separator
      if (!trimmed) {
        flushParagraph();
        flushList();
        continue;
      }

      // Headings (# Header)
      const headingMatch = trimmed.match(/^(#{1,4})\s+(.+)$/);
      if (headingMatch) {
        flushParagraph();
        flushList();
        const level = headingMatch[1].length;
        const hText = this.renderInline(headingMatch[2]);
        outputBlocks.push(`<h${level + 2} class="md-heading md-h${level}">${hText}</h${level + 2}>`);
        continue;
      }

      // Blockquotes (> Quote)
      if (trimmed.startsWith("&gt; ")) {
        flushParagraph();
        flushList();
        const quoteText = this.renderInline(trimmed.substring(5).trim());
        outputBlocks.push(`<blockquote class="md-quote">${quoteText}</blockquote>`);
        continue;
      }

      // Horizontal Rule (--- or ***)
      if (/^(\-{3,}|\*{3,})$/.test(trimmed)) {
        flushParagraph();
        flushList();
        outputBlocks.push('<hr class="md-divider">');
        continue;
      }

      // Unordered list item (- or *)
      const ulMatch = trimmed.match(/^[\*\-]\s+(.+)$/);
      if (ulMatch) {
        flushParagraph();
        if (!currentList || currentList.type !== "ul") {
          flushList();
          currentList = { type: "ul", items: [] };
        }
        currentList.items.push(ulMatch[1]);
        continue;
      }

      // Ordered list item (1. 2.)
      const olMatch = trimmed.match(/^(\d+)\.\s+(.+)$/);
      if (olMatch) {
        flushParagraph();
        if (!currentList || currentList.type !== "ol") {
          flushList();
          currentList = { type: "ol", items: [] };
        }
        currentList.items.push(olMatch[2]);
        continue;
      }

      // Standard text line -> accumulate into current paragraph
      currentParagraph.push(trimmed);
    }

    flushParagraph();
    flushList();

    let finalHtml = outputBlocks.join("");

    // 4. Restore preserved code blocks with styled syntax wrapper
    codeBlocks.forEach((block, idx) => {
      const placeholder = `__CODE_BLOCK_${idx}__`;
      const escapedCode = this.escapeHtml(block.code);
      const codeHtml = `
        <div class="code-block-wrapper">
          <div class="code-block-header">
            <span class="code-block-lang">${this.escapeHtml(block.lang)}</span>
            <button type="button" class="btn-copy-code" onclick="MarkdownRenderer.copyCodeBlock(this)">Copy Code</button>
          </div>
          <pre class="code-block-pre"><code>${escapedCode}</code></pre>
        </div>
      `;
      finalHtml = finalHtml.replace(placeholder, codeHtml);
    });

    return finalHtml;
  },

  /**
   * Render inline styling: bold, italic, strikethrough, inline code.
   */
  renderInline(text) {
    if (!text) return "";
    let str = text;

    // Inline code: `code`
    str = str.replace(/`([^`]+)`/g, '<code class="md-inline-code">$1</code>');

    // Bold: **bold** or __bold__
    str = str.replace(/\*\*([^*]+)\*\*/g, '<strong class="md-bold">$1</strong>');
    str = str.replace(/__([^_]+)__/g, '<strong class="md-bold">$1</strong>');

    // Italic: *italic* or _italic_
    str = str.replace(/\*([^*]+)\*/g, '<em class="md-italic">$1</em>');
    str = str.replace(/_([^_]+)_/g, '<em class="md-italic">$1</em>');

    // Strikethrough: ~~del~~
    str = str.replace(/~~([^~]+)~~/g, '<del class="md-strike">$1</del>');

    return str;
  },

  /**
   * Copy button handler for embedded code blocks.
   */
  copyCodeBlock(buttonEl) {
    const wrapper = buttonEl.closest(".code-block-wrapper");
    if (!wrapper) return;
    const codeEl = wrapper.querySelector("code");
    if (!codeEl) return;
    const rawText = codeEl.textContent || "";
    navigator.clipboard.writeText(rawText).then(() => {
      const orig = buttonEl.textContent;
      buttonEl.textContent = "Copied!";
      setTimeout(() => {
        buttonEl.textContent = orig;
      }, 2000);
    });
  },

  /**
   * Strips all markdown and HTML tags to generate pristine plaintext for clipboard.
   */
  toPlainText(text) {
    if (!text) return "";
    let str = this.normalizeText(text);

    // Strip code fence markers but keep code
    str = str.replace(/```[a-zA-Z0-9_-]*\n([\s\S]*?)```/g, "$1");

    // Strip inline markdown markers
    str = str.replace(/`([^`]+)`/g, "$1");
    str = str.replace(/\*\*([^*]+)\*\*/g, "$1");
    str = str.replace(/__([^_]+)__/g, "$1");
    str = str.replace(/\*([^*]+)\*/g, "$1");
    str = str.replace(/_([^_]+)_/g, "$1");
    str = str.replace(/~~([^~]+)~~/g, "$1");

    // Strip HTML tags if any remain
    str = str.replace(/<[^>]*>/g, "");

    // Normalize whitespace
    str = str.replace(/\n{3,}/g, "\n\n");
    return str.trim();
  },
};
