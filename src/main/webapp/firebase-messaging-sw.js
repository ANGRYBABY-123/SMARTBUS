/* firebase-messaging-sw.js
 * CommuteSafe – Firebase Cloud Messaging Service Worker
 *
 * This file MUST be served from the web root (not under WEB-INF).
 * It handles background push notifications when the app is not in focus.
 *
 * The Firebase config below is safe to be public – it identifies your
 * Firebase project but access is controlled by Security Rules & API key restrictions.
 *
 * Replace the placeholder values with your actual Firebase project config.
 * You can find them in: Firebase Console → Project Settings → Your apps (Web)
 */

importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// NOTE: The service worker cannot read from the DOM or make servlet calls,
// so we embed the config here. Keep it in sync with what you set in web.xml.
// Placeholders are replaced at build time or you can set them here directly.
const FIREBASE_CONFIG = {
  apiKey:            self.__FIREBASE_API_KEY__            || 'YOUR_FIREBASE_API_KEY',
  authDomain:        self.__FIREBASE_AUTH_DOMAIN__        || 'YOUR_PROJECT_ID.firebaseapp.com',
  projectId:         self.__FIREBASE_PROJECT_ID__         || 'YOUR_FIREBASE_PROJECT_ID',
  messagingSenderId: self.__FIREBASE_MESSAGING_SENDER_ID__ || 'YOUR_MESSAGING_SENDER_ID',
  appId:             self.__FIREBASE_APP_ID__             || 'YOUR_FIREBASE_APP_ID'
};

firebase.initializeApp(FIREBASE_CONFIG);

const messaging = firebase.messaging();

// Handle background push messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw] Received background message:', payload);

  const notificationTitle  = (payload.notification && payload.notification.title)
    || (payload.data && payload.data.title)
    || 'CommuteSafe';
  const notificationBody   = (payload.notification && payload.notification.body)
    || (payload.data && payload.data.body)
    || 'You have a new update.';
  const notificationIcon   = '/favicon.ico';
  const clickUrl           = (payload.data && payload.data.click_action)
    || payload.fcmOptions?.link
    || '/';

  const options = {
    body:  notificationBody,
    icon:  notificationIcon,
    badge: notificationIcon,
    data:  { url: clickUrl },
    tag:   (payload.data && payload.data.tag) || 'commutesafe',
    renotify: true,
    vibrate: [200, 100, 200]
  };

  return self.registration.showNotification(notificationTitle, options);
});

// When the user clicks the notification, open / focus the app
self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  const url = (event.notification.data && event.notification.data.url) || '/';
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      for (const client of clientList) {
        if (client.url.includes(url) && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) return clients.openWindow(url);
    })
  );
});
