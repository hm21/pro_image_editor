/* https://docs.flutter.dev/platform-integration/web/bootstrapping */

{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    serviceWorkerSettings: {
        serviceWorkerVersion: {{flutter_service_worker_version}},
    },
    onEntrypointLoaded: function (engineInitializer) {
      engineInitializer.initializeEngine({
        useColorEmoji: true,
        renderer: 'canvaskit'
      }).then(function (appRunner) {
        appRunner.runApp();
      });
    }
});


window.addEventListener('flutter-first-frame', function () {
  var loadingScreen = document.getElementById('loading-screen');
  if (loadingScreen) {
    loadingScreen.style.display = 'none';
    loadingScreen.remove();
  }
});