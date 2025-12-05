# App Links Setup

## Android - assetlinks.json

Criar arquivo em `https://yourdomain.com/.well-known/assetlinks.json`:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.flutterbase",
      "sha256_cert_fingerprints": [
        "YOUR_SHA256_FINGERPRINT"
      ]
    }
  }
]
```

### Obter SHA256 Fingerprint

```bash
# Debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release
keytool -list -v -keystore your-release-key.keystore -alias your-alias
```

### AndroidManifest.xml

```xml
<activity android:name=".MainActivity">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="https"
            android:host="yourdomain.com"
            android:pathPrefix="/app" />
    </intent-filter>
</activity>
```

## iOS - apple-app-site-association

Criar arquivo em `https://yourdomain.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.example.flutterbase",
        "paths": ["/app/*", "/share/*"]
      }
    ]
  }
}
```

### Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>flutterbase</string>
        </array>
    </dict>
</array>
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

### Entitlements

Adicionar Associated Domains:
- `applinks:yourdomain.com`

## Testando

```bash
# Android
adb shell am start -a android.intent.action.VIEW -d "https://yourdomain.com/app/home"

# iOS Simulator
xcrun simctl openurl booted "https://yourdomain.com/app/home"
```
