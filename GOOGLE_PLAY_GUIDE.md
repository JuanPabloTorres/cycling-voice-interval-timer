# Guía para Subir RidePulse a Google Play Console

## ✅ Archivos Preparados

### App Bundle Firmado
```
build\app\outputs\bundle\release\app-release.aab
```
**Tamaño**: ~25 MB (aproximadamente)
**Firma**: ✅ Configurada con keystore

### Keystore
```
C:\Users\juanp\ridepulse-release-key.jks
```
⚠️ **IMPORTANTE**: Guarda este archivo de manera segura. Si lo pierdes, no podrás actualizar la app en Google Play.

**Credenciales del Keystore:**
- Alias: `ridepulse`
- Password: `ridepulse2026`

---

## 📋 Pasos para Subir a Google Play Console

### 1. Crear la Aplicación

1. Ve a [Google Play Console](https://play.google.com/console)
2. Clic en **"Crear app"**
3. Completa los datos iniciales:
   - **Nombre de la app**: RidePulse
   - **Idioma predeterminado**: Inglés (EE.UU.)
   - **Tipo de app**: App
   - **Gratis o de pago**: Gratis

### 2. Completar la Ficha de Play Store

#### Descripción Corta (máximo 80 caracteres)
```
Voice-guided interval timer designed for cyclists
```

#### Descripción Completa (máximo 4000 caracteres)
```
RidePulse - Your Personal Cycling Interval Timer

Transform your cycling training with RidePulse, the intelligent interval timer designed specifically for cyclists. Get real-time voice guidance through your workout intervals while keeping your eyes on the road.

KEY FEATURES:

🚴 Custom Interval Plans
• Create unlimited training plans
• Set work and rest intervals
• Configure warmup and cooldown periods
• Repeat intervals as needed

🔊 Voice Coaching
• Clear voice announcements for each interval
• No need to look at your phone
• Adjustable voice settings
• Spanish TTS support

⏱️ Smart Timer
• Large, easy-to-read display
• Runs in background with notification support
• Shows remaining time in notification bar
• Resume from where you left off

🎯 Designed for Cyclists
• One-handed operation
• High contrast display for outdoor visibility
• Works while screen is off
• No distractions while riding

PERFECT FOR:
• Interval training
• HIIT workouts
• Structured cycling sessions
• Endurance training
• Sprint intervals

Stay focused on your ride, let RidePulse handle the timing!

Built by cyclists, for cyclists. 🚴‍♂️
```

#### Capturas de Pantalla Requeridas

**Teléfono (Mínimo 2, recomendado 4-8)**
- Resolución: 1080 x 2400 o similar
- Formato: PNG o JPEG

Capturas sugeridas:
1. Lista de planes (Plans Screen)
2. Timer en ejecución (Run Timer Screen)
3. Configuración de voz (Voice Settings)
4. Banner de timer activo en home

**Instrucciones para tomar capturas**:
1. Ejecuta la app en Android Studio con tu dispositivo
2. Navega a cada pantalla
3. Presiona Power + Volume Down para capturar
4. Las capturas estarán en la galería del teléfono

#### Ícono de la Aplicación
- **Archivo**: `assets/icon/ridepulse3.png`
- **Tamaño requerido**: 512 x 512 px
- **Formato**: PNG de 32 bits

#### Feature Graphic (Banner)
- **Tamaño**: 1024 x 500 px
- **Formato**: PNG o JPEG
- **Nota**: Necesitas crear este gráfico con el logo y nombre de RidePulse

### 3. Categorización

- **App**: App
- **Categoría**: Salud y Fitness
- **Etiquetas**: cycling, interval timer, HIIT, workout, fitness

### 4. Clasificación de Contenido

1. Ir a **Clasificación de contenido**
2. Completar cuestionario:
   - ¿La app contiene violencia? **No**
   - ¿La app contiene contenido sexual? **No**
   - ¿Permite interacción entre usuarios? **No**
   - ¿Comparte ubicación? **No**
3. Resultado esperado: **PEGI 3 / Everyone**

### 5. Política de Privacidad

⚠️ **REQUERIDO**: Necesitas una URL pública con tu política de privacidad.

**Opción rápida**: Crea un documento en Google Docs o GitHub Pages con este contenido básico:

```markdown
# Política de Privacidad - RidePulse

Última actualización: 22 de enero de 2026

## Recopilación de datos
RidePulse NO recopila, almacena ni comparte ningún dato personal del usuario.

## Datos locales
Todos los planes de entrenamiento y configuraciones se almacenan localmente en su dispositivo.

## Permisos
- Notificaciones: Para mostrar el timer en la barra de notificaciones
- Wake Lock: Para mantener la pantalla encendida durante el entrenamiento

## Contacto
Para preguntas sobre esta política, contacta: [tu_email@ejemplo.com]
```

Luego publica la URL en Google Play Console.

### 6. Público Objetivo

1. **Rango de edad objetivo**: 13+
2. **Atractivo para niños**: No

### 7. Información de Contacto

- **Email**: [Tu email]
- **Sitio web** (opcional): [Tu sitio web o repositorio GitHub]
- **Teléfono** (opcional)

### 8. Crear Versión de Producción

1. Ve a **Producción** en el menú lateral
2. Clic en **Crear nueva versión**
3. **Subir el App Bundle**:
   - Arrastra `app-release.aab` o selecciónalo
4. **Nombre de la versión**: 1 (versionCode)
5. **Notas de la versión**:

```
Primera versión de RidePulse
• Creación de planes de intervalos personalizados
• Guía de voz en tiempo real
• Timer persistente con notificaciones
• Configuración de voz ajustable
• Diseño optimizado para ciclistas
```

6. Clic en **Siguiente** y **Guardar**

### 9. Revisión y Publicación

1. Google Play Console verificará que todos los campos estén completos
2. Revisa toda la información
3. Clic en **Enviar para revisión**

⏳ **Tiempo de revisión**: Usualmente 1-3 días laborables

---

## 📱 Información Técnica

### Detalles del App Bundle

- **Application ID**: `com.ridepulse.app`
- **Version Code**: 1
- **Version Name**: 1.0.0
- **Min SDK**: API 23 (Android 6.0)
- **Target SDK**: API 36 (Android 15)

### Permisos Utilizados

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

---

## 🔄 Actualizaciones Futuras

Para subir una nueva versión:

1. Actualiza `versionCode` y `versionName` en `build.gradle.kts`
2. Ejecuta:
   ```bash
   cd cycling_voice_interval_timer
   flutter build appbundle --release
   ```
3. Sube el nuevo `.aab` en **Producción** → **Nueva versión**

---

## ⚠️ Notas Importantes

1. **Keystore**: 
   - Haz backup de `ridepulse-release-key.jks`
   - Guarda las credenciales en un lugar seguro
   - No las compartas en git (ya está en .gitignore)

2. **Cuenta de Desarrollador**:
   - Se requiere pago único de $25 USD
   - Necesitas una cuenta de Google

3. **Tiempo de Revisión**:
   - Primera publicación: 1-7 días
   - Actualizaciones: 1-3 días

---

## ✅ Checklist Final

Antes de enviar a revisión, verifica:

- [ ] App Bundle subido (`app-release.aab`)
- [ ] Mínimo 2 capturas de pantalla
- [ ] Ícono 512x512 px
- [ ] Feature graphic 1024x500 px
- [ ] Descripción corta y completa
- [ ] Política de privacidad URL
- [ ] Clasificación de contenido completada
- [ ] Información de contacto
- [ ] Categoría y etiquetas
- [ ] Público objetivo configurado

---

**¡Listo para publicar! 🚀**

Si tienes dudas durante el proceso, consulta la [documentación oficial de Google Play](https://support.google.com/googleplay/android-developer).
