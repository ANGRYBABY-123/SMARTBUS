// SmartBus – Full Smoke Test
// Tests every major page and flow as ADMIN
// Run: node playwright/smoke-test.js
// Run against live site: APP_URL=https://your-app.onrender.com node playwright/smoke-test.js

const { chromium } = require('playwright');

const BASE_URL = process.env.APP_URL || 'https://smartbus.onrender.com';
const EMAIL    = process.env.TEST_EMAIL || 'Maetsok01@gmail.com';
const PASSWORD = process.env.TEST_PASS  || 'M@sydo123';
const SS_DIR   = 'playwright/screenshots';

let passed = 0;
let failed = 0;
const failures = [];

async function check(name, fn) {
    try {
        await fn();
        console.log(`   ✓ ${name}`);
        passed++;
    } catch (e) {
        console.error(`   ✗ ${name}: ${e.message}`);
        failures.push({ name, error: e.message });
        failed++;
    }
}

async function goto(page, path) {
    await page.goto(`${BASE_URL}${path}`, { waitUntil: 'domcontentloaded', timeout: 60000 });
}

async function screenshot(page, name) {
    await page.screenshot({ path: `${SS_DIR}/${name}.png`, fullPage: true });
}

(async () => {
    const browser = await chromium.launch({ headless: true, slowMo: 100 });
    const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
    const page    = await context.newPage();

    console.log(`\n========================================`);
    console.log(` SmartBus Smoke Test`);
    console.log(` Target: ${BASE_URL}`);
    console.log(`========================================\n`);

    // ── 1. LOGIN PAGE ─────────────────────────────────────────────────────
    console.log('[ 1 ] Login Page');
    await check('Login page loads', async () => {
        await goto(page, '/users/login');
        await page.waitForSelector('input[name="email"]', { timeout: 15000 });
        await screenshot(page, '01-login');
    });

    await check('Wrong password shows error', async () => {
        await goto(page, '/users/login');
        const form = page.locator('form[action*="/users/login"]');
        await form.locator('input[name="email"]').fill(EMAIL);
        await form.locator('input[name="password"]').fill('wrongpassword');
        await form.locator('button[type="submit"]').click();
        await page.waitForTimeout(2000);
        const url = page.url();
        const hasError = url.includes('/login') || await page.locator('.alert, [class*="error"], [class*="alert"]').count() > 0;
        if (!hasError) throw new Error('Expected error but got: ' + url);
        await screenshot(page, '02-login-error');
    });

    await check('Admin login succeeds', async () => {
        await goto(page, '/users/login');
        const form = page.locator('form[action*="/users/login"]');
        await form.locator('input[name="email"]').fill(EMAIL);
        await form.locator('input[name="password"]').fill(PASSWORD);
        await Promise.all([
            page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 30000 }),
            form.locator('button[type="submit"]').click(),
        ]);
        const url = page.url();
        // Must reach dashboard — staying on /login means login FAILED
        if (url.includes('/login')) {
            const errorText = await page.locator('.alert, [class*="alert"]').first().textContent().catch(() => 'no error element');
            throw new Error('Login FAILED. Page error: ' + errorText.trim() + ' URL: ' + url);
        }
        if (!url.includes('/dashboard')) {
            throw new Error('Unexpected redirect after login: ' + url);
        }
        await screenshot(page, '03-dashboard');
    });

    // ── 2. DASHBOARD ──────────────────────────────────────────────────────
    console.log('\n[ 2 ] Dashboard');
    await check('Dashboard loads', async () => {
        await goto(page, '/dashboard');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '04-dashboard-full');
    });

    // ── 3. USERS ──────────────────────────────────────────────────────────
    console.log('\n[ 3 ] Users');
    await check('Users list page loads', async () => {
        await goto(page, '/users');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '05-users');
    });

    await check('New user form loads', async () => {
        await goto(page, '/users/new');
        await page.waitForSelector('form', { timeout: 10000 });
        await screenshot(page, '06-user-form');
    });

    // ── 4. BUSES ──────────────────────────────────────────────────────────
    console.log('\n[ 4 ] Buses');
    await check('Buses list page loads', async () => {
        await goto(page, '/buses');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '07-buses');
    });

    await check('New bus form loads', async () => {
        await goto(page, '/buses/new');
        await page.waitForSelector('form', { timeout: 10000 });
        await screenshot(page, '08-bus-form');
    });

    // ── 5. ROUTES ─────────────────────────────────────────────────────────
    console.log('\n[ 5 ] Routes');
    await check('Routes list page loads', async () => {
        await goto(page, '/routes');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '09-routes');
    });

    await check('New route form loads', async () => {
        await goto(page, '/routes/new');
        await page.waitForSelector('form', { timeout: 10000 });
        await screenshot(page, '10-route-form');
    });

    // ── 6. STOPS ──────────────────────────────────────────────────────────
    console.log('\n[ 6 ] Stops');
    await check('Stops list page loads', async () => {
        await goto(page, '/stops');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '11-stops');
    });

    await check('New stop form loads', async () => {
        await goto(page, '/stops/new');
        await page.waitForSelector('form', { timeout: 10000 });
        await screenshot(page, '12-stop-form');
    });

    // ── 7. SCHEDULES ──────────────────────────────────────────────────────
    console.log('\n[ 7 ] Schedules');
    await check('Schedules list page loads', async () => {
        await goto(page, '/schedules');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '13-schedules');
    });

    // ── 8. TRIPS ──────────────────────────────────────────────────────────
    console.log('\n[ 8 ] Trips');
    await check('Trips list page loads', async () => {
        await goto(page, '/trips');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '14-trips');
    });

    // ── 9. WEEKLY SCHEDULE ────────────────────────────────────────────────
    console.log('\n[ 9 ] Weekly Schedule');
    await check('Weekly schedule page loads', async () => {
        await goto(page, '/weekly-schedule');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '15-weekly-schedule');
    });

    // ── 10. FORGOT PASSWORD ───────────────────────────────────────────────
    console.log('\n[ 10 ] Forgot Password');
    await check('Forgot password page loads', async () => {
        await goto(page, '/users/forgot-password');
        await page.waitForSelector('form', { timeout: 10000 });
        await screenshot(page, '16-forgot-password');
    });

    // ── 11. ERROR PAGES ───────────────────────────────────────────────────
    console.log('\n[ 11 ] Error Pages');
    await check('404 page loads for unknown route', async () => {
        await goto(page, '/this-page-does-not-exist-xyz');
        await page.waitForSelector('body', { timeout: 10000 });
        await screenshot(page, '17-404');
    });

    // ── 12. LOGOUT ────────────────────────────────────────────────────────
    console.log('\n[ 12 ] Logout');
    await check('Logout redirects to login', async () => {
        await goto(page, '/users/logout');
        await page.waitForTimeout(2000);
        const url = page.url();
        if (!url.includes('/login')) throw new Error('Expected /login after logout. Got: ' + url);
        await screenshot(page, '18-logout');
    });

    // ── SUMMARY ───────────────────────────────────────────────────────────
    await browser.close();

    console.log('\n========================================');
    console.log(` RESULTS: ${passed} passed, ${failed} failed`);
    console.log(`========================================`);

    if (failures.length > 0) {
        console.log('\nFAILED CHECKS:');
        failures.forEach(f => console.log(`  ✗ ${f.name}\n    ${f.error}`));
        console.log('\nScreenshots saved to playwright/screenshots/');
        process.exitCode = 1;
    } else {
        console.log('\nAll checks passed! Screenshots saved to playwright/screenshots/');
    }
})();
