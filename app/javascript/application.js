// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"


// --- ADD THIS SECTION ---
if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("/service-worker")
        .then((registration) => {
            console.log("Service Worker registered with scope:", registration.scope);
        })
        .catch((error) => {
            console.error("Service Worker registration failed:", error);
        });
}
