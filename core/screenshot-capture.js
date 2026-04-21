const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  // Note: In the final native app, we might need to target the Electron window
  // but for dev/web-based debugging, we use the local port or file.
  try {
    await page.goto('http://localhost:5555');
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.screenshot({ path: 'current-ui-snapshot.png' });
    console.log('Snapshot berhasil disimpan ke current-ui-snapshot.png');
  } catch (e) {
    console.error('Snapshot failed:', e);
  } finally {
    await browser.close();
  }
})();
