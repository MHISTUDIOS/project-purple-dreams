/** @type {import('tailwindcss').Config} */

// Allows opacity with OKLCH values. (i.e. bg-background/80)
function withOpacity(variableName) {
  return ({ opacityValue }) => {
    if (opacityValue === 100)
      return `var(${variableName})`
    return `color-mix(in srgb, var(${variableName}) calc(${opacityValue} * 100%), transparent)`
  }
}

// When extending colours, withOpacity() allows support for transparency.
// Actual colours are defined in /src/styles/themes.css
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        background: withOpacity("--background"),
        border: withOpacity("--border"),
        "background-deeper": withOpacity("--background-deeper"),
        button: withOpacity("--button"),
        "button-border": withOpacity("--button-border"),
        primary: withOpacity("--primary"),
        "primary-border": withOpacity("--primary-border"),
        text: withOpacity("--text"),
        "text-muted": withOpacity("--text-muted"),
        icon: withOpacity("--icon"),
        success: "var(--success)",
        danger: "var(--danger)",
        warning: "var(--warning)",
      },
      fontFamily: {
        mono: ["Geist Mono", "monospace"],
      },
    },
  },
};
