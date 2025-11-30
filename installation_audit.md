# Terra Nova — Rapport d’installation

- **Flutter**: OK — details: 3.27.4 (stable)
- **Dart**: OK — details: 3.6.2
- **Java (JDK 17)**: OK — details: 17.0.12 (JAVA_HOME=C:\\Program Files\\Java\\jdk-17)
- **Git**: OK — details: git version 2.47.1.windows.2
- **Android SDK**: PARTIAL — details: détecté par flutter doctor à C:\\Users\\vcout\\AppData\\Local\\Android\\sdk, mais `ANDROID_SDK_ROOT`/`ANDROID_HOME` non définis
- **Licences Android**: NOT OK — action requise: yes | flutter doctor --android-licenses
- **Chrome (Web)**: OK — details: Google Chrome 142.0.7444.176
- **Xcode (macOS)**: N/A — machine Windows
- **Devices**: PARTIAL — details: Windows desktop, Chrome web détectés. Aucun device/emulateur Android listé.

## Actions automatiques proposées
- [ ] Définir `ANDROID_SDK_ROOT` (ou `ANDROID_HOME`) → C:\\Users\\vcout\\AppData\\Local\\Android\\sdk
- [ ] Accepter les licences Android: `yes | flutter doctor --android-licenses`
- [ ] (Optionnel) Installer/run un émulateur Android via Android Studio → AVD Manager
- [ ] (Optionnel Web) Rien à faire, Chrome OK

## Commandes PowerShell suggérées (Windows)
```powershell
# Définir variables d’environnement (User)
[Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT','C:\\Users\\vcout\\AppData\\Local\\Android\\Sdk','User')
# (Option) ANDROID_HOME si nécessaire
[Environment]::SetEnvironmentVariable('ANDROID_HOME','C:\\Users\\vcout\\AppData\\Local\\Android\\Sdk','User')

# Accepter les licences Android
yes | flutter doctor --android-licenses

# Vérifier l’état
flutter doctor -v
flutter devices
```

## Notes
- Après la définition des variables, ouvrir un nouveau terminal pour recharger le PATH/env.
- Pour cibler Android: démarrer un AVD depuis Android Studio (ou connecter un device réel en mode debug).
