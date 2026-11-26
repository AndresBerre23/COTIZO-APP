# Publicación en Google Play

Identificador de la app: `ec.coti.app` (D-023). Una vez publicado no se puede cambiar.

## 1. Crear la clave de publicación (una sola vez)

La clave firma todas las versiones futuras. Si se pierde, no se puede actualizar la app. Guárdala fuera del repositorio y haz una copia de seguridad, junto con sus contraseñas.

```powershell
keytool -genkey -v -keystore C:/claves/coti-publicacion.jks -keyalg RSA -keysize 2048 -validity 10000 -alias coti
```

`keytool` viene con el JDK que usa Android Studio. Si no está en la ruta, búscalo en `Android Studio/jbr/bin`.

## 2. Configurar la firma

1. Copia `android/key.properties.ejemplo` como `android/key.properties`.
2. Completa la ruta del `.jks`, el alias y las contraseñas.

`key.properties`, `*.jks` y `*.keystore` están en `android/.gitignore`. Si falta `key.properties`, el release se firma con la clave de depuración y Gradle muestra un aviso. Ese archivo solo sirve para pruebas y Google Play lo rechaza.

## 3. Versión

Sube `version` en `pubspec.yaml` antes de cada publicación. Por ejemplo, de `1.0.0+1` a `1.0.1+2`: el número después de `+` debe crecer siempre.

## 4. Compilar

```powershell
flutter build appbundle --release
```

El archivo para Google Play queda en `build/app/outputs/bundle/release/app-release.aab`.

## Antes de publicar

- Probar en un teléfono real (P-006).
- Preparar la política de privacidad. Coti guarda los datos solo en el teléfono, pero usa cámara, galería e internet para Wikimedia.
