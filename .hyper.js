"use strict";

module.exports = {
  config: {
    fontSize: 12,
    fontFamily: "JetBrainsMonoNL Nerd Font Mono, Cica",
    padding: "4px 14px",
    shellArgs: ["--login"],
    disableLigatures: true,
    preserveCWD: true,
    theme: "catppuccin-macchiato",
    paneNavigation: {
      hotkeys: {
        navigation: {
          left: "cmd+h",
          down: "cmd+j",
          up: "cmd+k",
          right: "cmd+l",
        },
      },
    },
    hyperBorder: {
      borderColors: ["#ed8796", "#eed49f"],
    },
    opacity: {
      focus: 0.95,
    }
  },
  plugins: [
    "@catppuccin/hyper#1.0.8",
    "hyperpower",
    "gitrocket",
    "hyper-tab-icons",
    "hyper-active-tab",
    "hyperborder",
    "hyper-pane",
    "hyper-opacity"
  ],
  keymaps: {},
};
