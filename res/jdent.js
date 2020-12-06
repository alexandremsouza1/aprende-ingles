// NODE_PATH='/app/node_modules' node jdent.js

const jdenticon = require("jdenticon");
const fs = require("fs");

// Custom identicon style
// https://jdenticon.com/icon-designer.html?config=feff15ff0148324d28501b5a
jdenticon.configure({
  hues: [227],
  lightness: {
      color: [0.17, 1.00],
      grayscale: [0.54, 1.00]
  },
  saturation: {
      color: 1.00,
      grayscale: 1.00
  },
  backColor: "#f00"
});

const png = jdenticon.toPng("Aprende-Inglés!App1", 1024);
fs.writeFileSync("./favicon.png", png);
