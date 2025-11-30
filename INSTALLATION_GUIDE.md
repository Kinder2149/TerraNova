# Terra Nova — Guide d’Installation Système (INSTALLATION_GUIDE)

Version: 1.0
Scope: Projet Flutter/Dart multi-plateformes (Android, iOS, Web, Desktop optionnel)


## A. Présentation du projet
- **Nom**: Terra Nova
- **Technologie**: Flutter (Dart)
- **Objectif**: Application Flutter avec support Android (prioritaire). Dossiers présents pour Web, iOS, macOS, Windows, Linux (exécutables optionnels selon votre OS).
- **Langage/Dépendances de base**:
  - Dart SDK: constraint `^3.6.2` (pubspec)
  - Flutter SDK: compatible avec Dart >= 3.6.2 (recommandé: Flutter stable ≥ 3.27.x)
  - Dépendances Flutter: `flutter`, `cupertino_icons` (aucun plugin natif additionnel détecté)
  - Dev: `flutter_test`, `flutter_lints`

Ce guide permet à un humain ou à une IA de:
- Auditer automatiquement la machine
- Installer les outils manquants par OS
- Initialiser et vérifier Terra Nova
- Produire un rapport structuré (OK/NOT OK/actions)


## B. Prérequis par système d’exploitation

Important: Installez uniquement ce qui correspond à votre OS et aux plateformes que vous visez (mobile/web/desktop).

### Windows 10/11
- **Flutter SDK**: Flutter stable (≥ 3.27.x)
- **Dart SDK**: inclus avec Flutter
- **Android Studio** (ou Android SDK + command-line tools) pour Android
- **Java JDK 17** (recommandé pour l’Android Gradle Plugin récent)
- **Git** (gestion du repo et des outils)
- **Chrome** (exécution Flutter Web) [optionnel si vous ciblez Web]
- [Optionnel Desktop] Visual Studio 2022 avec « Desktop development with C++ » (pour build Windows)

Variables/PATH:
- `ANDROID_HOME` ou `ANDROID_SDK_ROOT` → chemin du SDK Android (ex: `C:\Users\<you>\AppData\Local\Android\Sdk`)
- `JAVA_HOME` → chemin du JDK (ex: `C:\Program Files\Java\jdk-17`)
- Ajouter au `PATH`: `flutter\bin`, `platform-tools` du SDK Android, `cmdline-tools\latest\bin` si utilisé

Installation (PowerShell, via winget):
```powershell
# Outils de base
winget install --id Git.Git -e --source winget
winget install --id Google.Chrome -e --source winget  # optionnel pour Web

# Flutter (archive zip) → option 1: via choco si disponible
# choco install flutter --version=3.27.0 -y    # ajustez version si nécessaire
# Sinon: téléchargez l’archive Flutter stable et dézippez dans C:\src\flutter

# Android Studio
winget install --id Google.AndroidStudio -e --source winget

# Java 17
winget install --id EclipseAdoptium.Temurin.17.JDK -e --source winget

# Vérification de PATH (exemples)
[Environment]::SetEnvironmentVariable('JAVA_HOME','C:\\Program Files\\Eclipse Adoptium\\jdk-17','Machine')
[Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT','C:\\Users\\%USERNAME%\\AppData\\Local\\Android\\Sdk','User')
[Environment]::SetEnvironmentVariable('Path', $Env:Path+';C:\\src\\flutter\\bin', 'User')
```

### macOS (Apple Silicon/Intel)
- **Homebrew**
- **Flutter SDK** stable (≥ 3.27.x)
- **Dart SDK**: inclus avec Flutter
- **Xcode** (App Store) pour iOS (inclure « Command Line Tools »)
- **Android Studio** (ou Android SDK) pour Android
- **Java JDK 17** (temurin) pour Android
- **Git**
- **Chrome** (Flutter Web)

Installation (zsh/bash):
```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Outils de base
brew install git temurin@17

# Flutter via archive ou via brew cask (selon préférences)
brew install --cask flutter  # ou installez manuellement l’archive Flutter stable

# Android Studio
brew install --cask android-studio

# Xcode via App Store, puis:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept

# PATH (exemples)
echo 'export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"' >> ~/.zshrc
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Linux (Ubuntu/Debian équivalent)
- **Flutter SDK** stable (≥ 3.27.x)
- **Dart SDK**: inclus avec Flutter
- **Android Studio** (ou Android SDK + cmdline-tools)
- **Java JDK 17**
- **Git**, **curl**, **unzip**
- **Chrome** (Flutter Web) ou Chromium

Installation (bash):
```bash
sudo apt update
sudo apt install -y git curl unzip zip xz-utils libglu1-mesa openjdk-17-jdk

# Flutter: archive stable
mkdir -p $HOME/tools && cd $HOME/tools
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.0-stable.tar.xz
tar xf flutter_linux_3.27.0-stable.tar.xz
echo 'export PATH="$PATH:$HOME/tools/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Android Studio (option 1: via tar/jetbrains toolbox) ou via snap (si activé)
# sudo snap install android-studio --classic

# ANDROID SDK ROOT
echo 'export ANDROID_SDK_ROOT="$HOME/Android/Sdk"' >> ~/.bashrc
source ~/.bashrc
```


## C. Script d’auto-diagnostic (à exécuter par IA ou humain)
Exécutez ces commandes et collectez la sortie pour le rapport.

Commandes de base:
```bash
flutter doctor -v
flutter --version
dart --version
java -version
git --version

# Android SDK vars
# PowerShell (Windows):
$Env:ANDROID_HOME; $Env:ANDROID_SDK_ROOT; $Env:JAVA_HOME
# bash/zsh (macOS/Linux):
echo $ANDROID_HOME; echo $ANDROID_SDK_ROOT; echo $JAVA_HOME

# Chrome (Web)
chrome --version || google-chrome --version || chromium --version || echo "Chrome non trouvé"

# Devices / émulateurs
flutter devices
```

Scripts rapides de diagnostic:
- Windows (PowerShell):
```powershell
$report = @{}
$report.flutterDoctor = (flutter doctor -v | Out-String)
$report.flutterVersion = (flutter --version | Out-String)
$report.dartVersion = (dart --version 2>&1 | Out-String)
$report.javaVersion = (java -version 2>&1 | Out-String)
$report.gitVersion = (git --version 2>&1 | Out-String)
$report.ANDROID_HOME = $Env:ANDROID_HOME
$report.ANDROID_SDK_ROOT = $Env:ANDROID_SDK_ROOT
$report.JAVA_HOME = $Env:JAVA_HOME
$report.chromeVersion = (chrome --version 2>$null) -or (google-chrome --version 2>$null) -or (chromium --version 2>$null)
$report.devices = (flutter devices | Out-String)
$report | ConvertTo-Json -Depth 4 | Out-File -Encoding utf8 installation_report.json
Write-Host "Diagnostic écrit dans installation_report.json"
```
- macOS/Linux (bash):
```bash
python3 - << 'PY'
import json, os, subprocess as sp

def run(cmd):
    try:
        return sp.check_output(cmd, shell=True, stderr=sp.STDOUT, text=True)
    except Exception as e:
        return f"ERR: {e}"

report = {}
report["flutterDoctor"] = run("flutter doctor -v")
report["flutterVersion"] = run("flutter --version")
report["dartVersion"] = run("dart --version")
report["javaVersion"] = run("java -version")
report["gitVersion"] = run("git --version")
report["ANDROID_HOME"] = os.environ.get("ANDROID_HOME", "")
report["ANDROID_SDK_ROOT"] = os.environ.get("ANDROID_SDK_ROOT", "")
report["JAVA_HOME"] = os.environ.get("JAVA_HOME", "")
report["chromeVersion"] = run("google-chrome --version || chrome --version || chromium --version")
report["devices"] = run("flutter devices")
open("installation_report.json","w",encoding="utf-8").write(json.dumps(report, ensure_ascii=False, indent=2))
print("Diagnostic écrit dans installation_report.json")
PY
```


## D. Script d’installation automatique (par OS)
Exécuter seulement ce qui convient à votre OS et vos cibles.

### Windows (PowerShell)
```powershell
# Git & Chrome (web optionnel)
winget install --id Git.Git -e --source winget
winget install --id Google.Chrome -e --source winget

# Java 17
winget install --id EclipseAdoptium.Temurin.17.JDK -e --source winget

# Android Studio
winget install --id Google.AndroidStudio -e --source winget

# Flutter (archive recommandée pour contrôle de version)
# 1) Téléchargez Flutter stable (3.27.x) depuis flutter.dev
# 2) Dézippez dans C:\src\flutter
# 3) Ajoutez C:\src\flutter\bin au PATH utilisateur

# Licences Android
yes | flutter doctor --android-licenses
```

### macOS (zsh)
```zsh
brew install git temurin@17
brew install --cask flutter
brew install --cask android-studio
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
yes | flutter doctor --android-licenses
```

### Linux (bash)
```bash
sudo apt update
sudo apt install -y git curl unzip xz-utils openjdk-17-jdk
# Installer Flutter stable (archive) puis ajouter au PATH
# Installer Android Studio (snap/classique) selon préférence
yes | flutter doctor --android-licenses
```

Après installation, redémarrez le shell/terminal pour recharger PATH.


## E. Initialisation complète du projet Terra Nova
Exécuter dans la racine du projet.

```bash
# Dépendances
flutter pub get

# Nettoyage (si besoin)
flutter clean

# Génération de code (si build_runner est ajouté ultérieurement)
# flutter pub run build_runner build --delete-conflicting-outputs

# Liste des devices
flutter devices

# Run rapide (Android, Web)
# Android (device réel/émulateur):
flutter run -d android

# Web (Chrome):
flutter config --enable-web  # si non déjà activé
flutter run -d chrome
```

Notes Android:
- Ouvrez Android Studio → SDK Manager → Installez: « Android SDK Platform », « Android SDK Platform-Tools », « Android SDK Build-Tools », images d’émulateurs si besoin.
- Vérifiez minSdk/targetSdk: ce projet utilise les valeurs Flutter par défaut via le plugin (voir `android/app/build.gradle`).


## F. Procédure de vérification automatisée
La procédure suivante doit être exécutée par l’IA ou un humain pour valider l’installation.

Checks:
- Compatibilité de versions:
  - `flutter --version` → Flutter stable compatible Dart ≥ 3.6.2
  - `dart --version` → Dart ≥ 3.6.2
- Android SDK présent: `ANDROID_SDK_ROOT` ou `ANDROID_HOME` défini et dossier existant
- Licences Android acceptées: `yes | flutter doctor --android-licenses`
- `flutter doctor -v` sans erreurs bloquantes (Android toolchain OK, Chrome OK si web, Xcode OK si iOS/macOS)
- `flutter pub get` réussi
- `flutter devices` liste au moins une cible (ou `chrome` si Web)
- Build test:
  - `flutter build apk --debug` (Android)
  - `flutter build web` (Web) [optionnel]

Résultats attendus:
- Si un item échoue → marquer NOT OK et proposer l’action à exécuter (voir section D/B).


## G. Rapport final attendu (format et génération)
Objectif: fournir un diagnostic structuré pour nouvelle machine.

Étapes d’exécution (IA ou humain):
1. Lire ce fichier `INSTALLATION_GUIDE.md`.
2. Exécuter la section "C. Script d’auto-diagnostic" pour produire `installation_report.json`.
3. Interpréter le JSON et produire un rapport Markdown `installation_audit.md` avec le format ci-dessous.

Format du rapport:
```markdown
# Terra Nova — Rapport d’installation

- **Flutter**: OK/NOT OK — details: <version/sortie>
- **Dart**: OK/NOT OK — details: <version>
- **Java (JDK 17)**: OK/NOT OK — details: <version>
- **Git**: OK/NOT OK — details: <version>
- **Android SDK**: OK/NOT OK — details: ANDROID_SDK_ROOT=<path>
- **Licences Android**: OK/NOT OK — action: yes | flutter doctor --android-licenses
- **Chrome (Web)**: OK/NOT OK — details: <version> (optionnel si Web non ciblé)
- **Xcode (macOS)**: OK/NOT OK — details (optionnel si iOS ciblé)
- **Devices**: OK/NOT OK — details: sortie `flutter devices`

## Actions automatiques proposées
- [ ] Installer/mettre à jour Flutter → voir section D
- [ ] Installer Android Studio / SDK → voir section D
- [ ] Configurer JAVA_HOME / ANDROID_SDK_ROOT → voir section B
- [ ] Accepter licences Android
- [ ] Activer Web: flutter config --enable-web (si Web)
- [ ] Relancer terminal pour charger PATH
```

Critères d’évaluation automatique:
- Marquer OK si la commande correspondante renvoie une version adéquate et `flutter doctor` ne signale pas d’erreur bloquante.
- Marquer NOT OK sinon, et inclure la commande exacte de remédiation depuis ce guide.


## Annexe — Références de ce projet
- pubspec.yaml:
  - `environment: sdk: ^3.6.2`
  - deps: `cupertino_icons`, `flutter`
  - assets: `assets/dev_init.json`
- android/app/build.gradle:
  - `minSdk`, `targetSdk`, `compileSdk` pilotés par Flutter


## Notes importantes
- Évitez d’installer des composants non nécessaires à votre cible (ex: Xcode si vous ne faites pas iOS).
- Ce guide suppose l’usage du canal stable de Flutter. Adaptez la version si nécessaire.
- Après toute installation, ouvrez un nouveau terminal avant de relancer les vérifications.
