const MentionsInput = function (el, options) {
  this.el = el;
  this.settings = Object.assign({}, MentionsInput.defaults, options);
  this.triggerChar = this.settings.triggerChar.charCodeAt(0);
  this.mentionsOverlay = null;
  this.mentionsList = null;
  this.highlightedMention = null;

  this.init();
};

MentionsInput.defaults = {
  triggerChar: "@",
  mentionsData: [],
};

MentionsInput.prototype = {
  init: function () {
    // Create the mentions overlay and list
    this.mentionsOverlay = document.createElement("div");
    this.mentionsOverlay.className = "mentions-input-overlay";
    this.mentionsOverlay.style.display = "none";
    this.el.parentNode.insertBefore(this.mentionsOverlay, this.el.nextSibling);

    this.mentionsList = document.createElement("ul");
    this.mentionsList.className = "mentions-input-list";
    this.mentionsOverlay.appendChild(this.mentionsList);

    // Bind event listeners
    this.el.addEventListener("input", this.onInput.bind(this));
    this.el.addEventListener("keydown", this.onKeyDown.bind(this));
    this.el.addEventListener("blur", this.onBlur.bind(this));
  },

  onInput: function (event) {
    const inputVal = this.el.value;
    const cursorPos = this.el.selectionStart;
    const textBeforeCursor = inputVal.slice(0, cursorPos);
    const lastTriggerCharPos = textBeforeCursor.lastIndexOf(this.settings.triggerChar);

    if (lastTriggerCharPos >= 0) {
      const mentionSearchString = textBeforeCursor.slice(lastTriggerCharPos + 1);

      // Filter the mentions data by the search string
      const matchingMentions = this.settings.mentionsData.filter(function (mention) {
        return mention.name.toLowerCase().indexOf(mentionSearchString.toLowerCase()) >= 0;
      });

      if (matchingMentions.length) {
        // Position the mentions overlay and list
        const coords = this.getCaretCoordinates(cursorPos);
        this.mentionsOverlay.style.top = coords.top + "px";
        this.mentionsOverlay.style.left = coords.left + "px";
        this.mentionsOverlay.style.display = "block";

        // Populate the mentions list
        this.mentionsList.innerHTML = "";
        for (let i = 0; i < matchingMentions.length; i++) {
          const mention = matchingMentions[i];
          const li = document.createElement("li");
          li.innerHTML = mention.name;
          li.setAttribute("data-mention-id", mention.id);
          this.mentionsList.appendChild(li);
        }

        // Highlight the first mention in the list
        this.highlightedMention = this.mentionsList.firstChild;
        this.highlightedMention.classList.add("highlighted");
      } else {
        this.hideMentionsOverlay();
      }
    } else {
      this.hideMentionsOverlay();
    }
  },

  onKeyDown: function (event) {
    if (this.mentionsOverlay.style.display === "block") {
      if (event.keyCode === 38) {
        // Up arrow
        event.preventDefault();
        if (this.highlightedMention && this.highlightedMention.previousSibling) {
          this.highlightedMention.classList.remove("highlighted");
          this.highlightedMention = this.highlightedMention.previousSibling;
          this.highlightedMention.classList.add("highlighted");
        }
      } else if (event.keyCode === 40) {
        // Down arrow
        event.preventDefault();
        if (this.highlightedMention && this.highlightedMention.nextSibling) {
          this.highlightedMention.classList.remove
          this.highlightedMention = this.highlightedMention.nextSibling;
          this.highlightedMention.classList.add("highlighted");
        }
      } else if (event.keyCode === 13) {
        // Enter
        event.preventDefault();
        if (this.highlightedMention) {
          const mentionId = this.highlightedMention.getAttribute("data-mention-id");
          const mentionName = this.highlightedMention.innerHTML;
          const cursorPos = this.el.selectionStart;
          const textBeforeCursor = this.el.value.slice(0, cursorPos);
          const lastTriggerCharPos = textBeforeCursor.lastIndexOf(this.settings.triggerChar);

          if (lastTriggerCharPos >= 0) {
            const mentionString =
              this.settings.triggerChar + mentionName.slice(0, mentionName.length - 1) + " ";

            // Replace the mention search string with the selected mention
            this.el.value =
              textBeforeCursor.slice(0, lastTriggerCharPos) + mentionString + inputVal.slice(cursorPos);
            this.el.setSelectionRange(
              lastTriggerCharPos + mentionString.length,
              lastTriggerCharPos + mentionString.length
            );
          }
        }

        this.hideMentionsOverlay();
      } else if (event.keyCode === 27) {
        // Esc
        event.preventDefault();
        this.hideMentionsOverlay();
      }
    } else {
      if (event.keyCode === this.triggerChar) {
        // Trigger character
        this.onInput(event);
      }
    }
  },

  onBlur: function () {
    this.hideMentionsOverlay();
  },

  getCaretCoordinates: function (position) {
    const div = document.createElement("div");
    div.innerHTML = this.el.value.slice(0, position);
    div.style.position = "absolute";
    div.style.visibility = "hidden";
    div.style.whiteSpace = "pre-wrap";
    div.style.width = this.el.offsetWidth + "px";
    div.style.fontSize = window.getComputedStyle(this.el).getPropertyValue("font-size");
    div.style.fontFamily = window.getComputedStyle(this.el).getPropertyValue("font-family");
    this.el.parentNode.insertBefore(div, this.el);

    const span = document.createElement("span");
    span.innerHTML = this.el.value.slice(position) || ".";
    div.appendChild(span);

    const coords = {
      top: span.offsetTop + parseInt(window.getComputedStyle(span).getPropertyValue("font-size"), 10),
      left: span.offsetLeft,
    };

    this.el.parentNode.removeChild(div);

    return coords;
  },

  hideMentionsOverlay: function () {
    this.mentionsOverlay.style.display = "none";
    this.mentionsList.innerHTML = "";
    this.highlightedMention = null;
  },
};

// Attach the mentionsInput plugin to the global object
window.mentionsInput = function (el, options) {
  return new MentionsInput(el, options);
};
function MentionsInput(el, options) {
  this.el = el;
  this.settings = {
    onDataRequest: null,
    displayTpl: '<li class="mention-item"><span class="mention-name">{name}</span></li>',
    triggerChar: "@",
  };

  if (typeof options === "object") {
    Object.assign(this.settings, options);
  }

  // Create a wrapper element for the textarea
  this.wrapperEl = document.createElement("div");
  this.wrapperEl.className = "mentions-wrapper";
  this.el.parentNode.insertBefore(this.wrapperEl, this.el);
  this.wrapperEl.appendChild(this.el);

  // Create the mentions overlay
  this.mentionsOverlay = document.createElement("div");
  this.mentionsOverlay.className = "mentions-overlay";
  this.wrapperEl.appendChild(this.mentionsOverlay);

  // Create the mentions list
  this.mentionsList = document.createElement("ul");
  this.mentionsList.className = "mentions-list";
  this.mentionsOverlay.appendChild(this.mentionsList);

  // Bind event listeners
  this.el.addEventListener("input", this.onInput.bind(this));
  this.el.addEventListener("keydown", this.onKeyDown.bind(this));
  this.el.addEventListener("blur", this.onBlur.bind(this));
}

MentionsInput.prototype = {
  onInput: function (event) {
    const cursorPos = this.el.selectionStart;
    const textBeforeCursor = this.el.value.slice(0, cursorPos);
    const lastTriggerCharPos = textBeforeCursor.lastIndexOf(this.settings.triggerChar);

    if (lastTriggerCharPos >= 0) {
      const mentionSearchString = textBeforeCursor.slice(lastTriggerCharPos + 1);
      const mentionSearchIndex = lastTriggerCharPos + 1;
      const coords = this.getCaretCoordinates(mentionSearchIndex);
      this.mentionsOverlay.style.top = coords.top + "px";
      this.mentionsOverlay.style.left = coords.left + "px";

      if (typeof this.settings.onDataRequest === "function") {
        this.settings.onDataRequest(mentionSearchString, (mentions) => {
          this.showMentionsOverlay(mentions, mentionSearchIndex);
        });
      }
    } else {
      this.hideMentionsOverlay();
    }
  },

  showMentionsOverlay: function (mentions, mentionSearchIndex) {
    this.mentionsList.innerHTML = "";

    if (mentions.length) {
      mentions.forEach((mention) => {
        const mentionEl = document.createElement("li");
        mentionEl.className = "mention-item";
        mentionEl.innerHTML = this.settings.displayTpl.replace("{name}", mention.name);
        mentionEl.setAttribute("data-mention-id", mention.id);
        this.mentionsList.appendChild(mentionEl);
      });

      this.highlightedMention = this.mentionsList.firstChild;
      this.highlightedMention.classList.add("highlighted");
      this.mentionsOverlay.style.display = "block";
    } else {
      this.hideMentionsOverlay();
    }
  },

  onKeyDown: function (event) {
    const inputVal = this.el.value;

    if (this.mentionsOverlay.style.display === "block") {
      if (event.keyCode === 38) {
        // Up arrow
        event.preventDefault();
        if (this.highlightedMention && this.highlightedMention.previousSibling) {
          this.highlightedMention.classList.remove("highlighted");
          this.highlightedMention = this.highlightedMention.previousSibling;
          this.highlightedMention.classList.add("highlighted");
        }
      } else if (event.keyCode === 40) {
        // Down arrow
        event.preventDefault();
        if (this.highlightedMention && this.highlightedMention.nextSibling) {
          this.highlightedMention.classList.remove("highlighted");
          this.highlightedMention = this.highlightedMention.nextSibling;
          this.highlightedMention.classList.add("highlighted");
        }
      } else if (event.keyCode === 13) {
        // Enter
        event.preventDefault();
        if (this.highlightedMention) {
          const mentionId = this.highlightedMention.getAttribute("data-mention-id");
          const textBeforeTrigger = inputVal.slice(0, this.highlightedMentionIndex - 1);
          const textAfterTrigger = inputVal.slice(this.getCaretPosition() + 1);
          this.el.value = textBeforeTrigger + "@" + mentionId + " " + textAfterTrigger;
          this.hideMentionsOverlay();
        }
      } else if (event.keyCode === 27) {
        // Esc
        event.preventDefault();
        this.hideMentionsOverlay();
      }
    }
  },

  onBlur: function () {
    setTimeout(() => {
      this.hideMentionsOverlay();
    }, 200);
  },

  hideMentionsOverlay: function () {
    this.mentionsOverlay.style.display = "none";
    this.highlightedMention = null;
  },

  getCaretPosition: function () {
    return this.el.selectionEnd;
  },

  getCaretCoordinates: function (mentionSearchIndex) {
    const el = this.el;
    const startPos = el.getBoundingClientRect();
    const style = window.getComputedStyle ? getComputedStyle(el) : el.currentStyle;
    const padding = {
      top: parseInt(style.paddingTop, 10),
      right: parseInt(style.paddingRight, 10),
      bottom: parseInt(style.paddingBottom, 10),
      left: parseInt(style.paddingLeft, 10),
    };
    const border = {
      top: parseInt(style.borderTopWidth, 10),
      right: parseInt(style.borderRightWidth, 10),
      bottom: parseInt(style.borderBottomWidth, 10),
      left: parseInt(style.borderLeftWidth, 10),
    };
    const contentOffset = {
      top: el.offsetTop + padding.top + border.top,
      left: el.offsetLeft + padding.left + border.left,
    };
    const coords = {
      top: contentOffset.top,
      left: contentOffset.left,
      height: el.offsetHeight,
    };

    if (mentionSearchIndex >= 0) {
      const preCaretRange = document.createRange();
      const preCaretSel = window.getSelection();
      preCaretRange.setStart(el.firstChild, mentionSearchIndex);
      preCaretRange.setEnd(el.firstChild, mentionSearchIndex);
      const rangeRect = preCaretRange.getBoundingClientRect();
      const caretOffset = {
        top: rangeRect.top - startPos.top,
        left: rangeRect.left - startPos.left,
      };
      coords.top += caretOffset.top;
      coords.left += caretOffset.left;
    }

    return coords;
  },
};

// Attach the mentionsInput plugin to the window object
window.mentionsInput = function (el, options) {
  return new MentionsInput(el, options);
};
