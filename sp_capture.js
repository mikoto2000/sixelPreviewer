//
// capture.js
//
// REQUIREMENTS:
// phantomjs
//
// USEAGE:
// phantomjs capture.js HTML_PATH IMAGE_WIDTH IMAGE_PATH

// 引数解析
var system = require('system');

if (system.args.length != 4) {
  console.log("USEAGE: phantomjs capture.js HTML_PATH IMAGE_WIDTH IMAGE_PATH");
  phantom.exit();
} else {
  render();
}

function render() {
  var htmlPath = system.args[1];
  var imageWidth = system.args[2];
  var imagePath = system.args[3];

  var page = require('webpage').create();

  // 出力サイズ指定。
  // 高さは自動調整されるようなので、とりあえず 1 に。
  page.viewportSize = {
      width: imageWidth,
      height: 1
  };

  page.open(htmlPath, function() {
    // 背景を白くする。
    // phantomjs ではデフォルト透明なので、
    // javascript 実行によって対応。
    page.evaluate(function() {
      document.body.bgColor = 'white';
    });

    // 出力
    page.render(imagePath);

    // 終了
    phantom.exit();
  });
}
