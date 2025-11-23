import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        vapidPublic: String,
        postUrl: String
    }

    connect() {
        // If the browser doesn't support this, hide the button immediately.
        if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
            this.element.remove();
        }
    }

    async subscribe() {
        // 1. Wait for the Service Worker (Rails 8 installs it automatically)
        const registration = await navigator.serviceWorker.ready;

        try {
            // 2. The Handshake with the Browser Vendor
            const subscription = await registration.pushManager.subscribe({
                userVisibleOnly: true,
                // Convert the VAPID key from Base64 to Binary
                applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicValue)
            });

            // 3. Send the keys to our Rails Backend
            await fetch(this.postUrlValue, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify(subscription)
            });

            alert("Subscribed successfully!");
        } catch (error) {
            console.error("Unable to subscribe to push", error);
        }
    }

    // The Helper: Converts VAPID key for the browser
    urlBase64ToUint8Array(base64String) {
        const padding = "=".repeat((4 - base64String.length % 4) % 4);
        const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
        const rawData = window.atob(base64);
        const outputArray = new Uint8Array(rawData.length);
        for (let i = 0; i < rawData.length; ++i) {
            outputArray[i] = rawData.charCodeAt(i);
        }
        return outputArray;
    }
}