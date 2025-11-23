// 1. Listen for the Push event
self.addEventListener("push", async (event) => {
    // The server sends JSON. We parse it here.
    const data = event.data.json();

    const options = {
        body: data.body,
        icon: "/icon.png", // Ensure you have an icon in /public
        data: { url: data.url } // We stash the URL here to use it later
    };

    // This keeps the worker alive until the notification is actually shown
    event.waitUntil(
        self.registration.showNotification(data.title, options)
    );
});

// 2. Listen for the Click event
self.addEventListener("notificationclick", (event) => {
    // Close the notification immediately
    event.notification.close();

    // Open the URL we stashed in the data object above
    event.waitUntil(
        clients.openWindow(event.notification.data.url)
    );
});