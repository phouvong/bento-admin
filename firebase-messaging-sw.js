importScripts('https://www.gstatic.com/firebasejs/8.3.2/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.3.2/firebase-messaging.js');

firebase.initializeApp({
    apiKey: "AIzaSyBV4ueEuzRBy0Yehx-OvUi68pHznhGnT0E",
    authDomain: "bento-delivery-service.firebaseapp.com",
    projectId: "bento-delivery-service",
    storageBucket: "bento-delivery-service.firebasestorage.app",
    messagingSenderId: "787586896333",
    appId: "1:787586896333:web:f6fead1c4225e3e0c6b484",
    measurementId: "G-HP95SH6F7R"
});

const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    return self.registration.showNotification(payload.data.title, {
        body: payload.data.body ? payload.data.body : '',
        icon: payload.data.icon ? payload.data.icon : ''
    });
});