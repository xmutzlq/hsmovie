{{flutter_js}}
{{flutter_build_config}}

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    for (const registration of registrations) {
      if (registration.scope.includes('/app/')) registration.unregister();
    }
  });
}

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: 'canvaskit/',
  },
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById('app-loading')?.remove();
  },
});
