# infra-scripts
Automatización centralizada para estandarización de repositorios.

🔥

# Repositorio público 

Debido a que el ruleset(s) puefa "leer" los archivos .yml, el repositorio donde está guardado debe ser accesible. Como no está la opción "internal", la única forma de centralizarlo es hacerlo público.

¿Es peligroso? No, en este caso específico.

En este repositorio (infra-scripts) SOLO tendrás el archivo .yml con la lógica de validación (el script que dice "Si no eres x usuario, bloquea").

No hay código fuente de la empresa, ni contraseñas, ni bases de datos. Solo reglas de automatización.

Los otros repositorios (donde está el código real) seguirán siendo Privados y seguros.

🔥

# 🛡️ Gobernanza de Repositorio y Flujo de Trabajo

Este documento define los estándares de seguridad, la arquitectura de ramas y los procesos de automatización implementados en la organización para garantizar la integridad y calidad del código.

---

## 1. Arquitectura de Seguridad (Rulesets)

La protección de los repositorios está centralizada a nivel de organización mediante tres **GitHub Rulesets**. Ya no se utilizan las reglas clásicas de protección por repositorio.

| Ruleset | Ramas Afectadas | Restricciones y Políticas |
| :--- | :--- | :--- |
| **🟢 Protección Global Main** | `main` | • **Bloqueo de Escritura:** Nadie puede hacer push directo a producción.<br>• **PR Obligatorio:** Todo cambio debe entrar mediante Pull Request. |
| **🔒 Seguridad: Main & Developer** | `main`, `developer` | • **Integridad:** Prohibido eliminar la rama o hacer `force push`.<br>• **Revisión Humana:** Se requiere al menos **1 Aprobación** para fusionar.<br>• **Seguridad:** *Dismiss stale reviews* (si subes cambios nuevos, se borran las aprobaciones anteriores). |
| **✅ Validación: Rama Actualizada** | `developer` | • **Status Checks:** Exige que los workflows de CI/CD (validaciones técnicas) pasen exitosamente antes de permitir la fusión. |

> **Nota:** Existe un equipo `Admins-Bypass` para operaciones de emergencia, pero se recomienda seguir el flujo estándar siempre que sea posible.

---

## 2. Workflows de Automatización

En la carpeta `.github/workflows/` encontrarás los siguientes procesos automáticos:

### 🤖 `guardian-main.yml` (El Guardián)
Controla el tráfico de Pull Requests para proteger Producción.
* **Lógica:**
    * Si el PR apunta a `developer` 👉 **Aprueba automáticamente** (Check Verde ✅).
    * Si el PR apunta a `main` 👉 **Verifica permisos estrictos**:
        * ¿El título dice `hotfix`?
        * ¿El autor es un Admin autorizado?
    * Si no cumple las condiciones para ir a `main`, el workflow falla ⛔ y deja un comentario de bloqueo.

### 🛠️ `check-branch-status.yml`
*Sustituye al antiguo `dummy-check.yml`.*
* **Función:** Ejecuta validaciones técnicas (linting, tests, sintaxis) obligatorias.
* **Requisito:** Debe finalizar en **Success** para poder fusionar en `developer`.

---

## 3. Guía de Contribución (Git Flow)

### Paso 1: Desarrollo
* Crea tu rama de trabajo (feature/bugfix) siempre partiendo desde `developer`.
* `git checkout -b feature/mi-nueva-funcionalidad developer`

### Paso 2: Pull Request hacia Developer
1. Abre el PR apuntando a `base: developer`.
2. Espera a que el **Guardián** y los **Checks** pasen.
3. Solicita revisión a un compañero (1 aprobación requerida).
4. **Fusión:** Utiliza **Squash and Merge** para mantener un historial lineal y limpio en la rama `developer`.

### Paso 3: Despliegue a Producción (Main)
* Solo para Admins o Release Managers.
* Crea un PR de `developer` -> `main`.
* ⚠️ **IMPORTANTE:** Al momento de fusionar, asegúrate de **DESMARCAR** la opción *"Delete head branch"* (Borrar rama de origen).
    * *Razón:* Si la dejas marcada, GitHub intentará borrar la rama `developer`, lo cual debe evitarse.

---

## 4. Solución de Problemas Frecuentes (Troubleshooting)

### ❌ Error: "Required workflow did not pass" (Check fantasma)
* **Síntoma:** Aparece un check fallido buscando un archivo antiguo (ej. `dummy-check`) o una versión vieja del workflow.
* **Causa:** Tu rama está desactualizada y no tiene los cambios recientes de infraestructura.
* **Solución:** Actualiza tu rama con `developer`.
  * Opción A: Botón "Update branch" en el PR.
  * Opción B: `git pull origin developer` y luego `git push`.

### ⛔ Error: "Vas a MAIN sin permiso"
* **Síntoma:** El Guardián bloquea el PR con un comentario rojo, aunque ya cambiaste el destino a `developer`.
* **Causa:** El workflow necesita volver a ejecutarse para detectar el cambio de rama.
* **Solución:**
  1. Asegúrate de que el destino sea `developer`.
  2. Si el check no se actualiza solo, cierra el PR y ábrelo de nuevo apuntando correctamente desde el inicio.

### ⚠️ Error: Se borró la rama Developer
* **Causa:** Se realizó un merge a `main` con la opción *"Automatically delete head branches"* activa y permisos de Admin (Bypass).
* **Solución:** Un Administrador debe restaurar la rama inmediatamente desde la interfaz de GitHub ("Restore branch").

🔥

# 🚀 Automatización del Ciclo de Release (Version11)

Este repositorio contiene los scripts y flujos de trabajo (GitHub Actions) necesarios para gestionar el ciclo de vida de los lanzamientos en los más de 60 repositorios de la organización (filtrando por `*-Version11`).

## 📋 Resumen del Flujo

1.  **Creación:** Se generan ramas `release/v11...` automáticamente (o manual).
2.  **Promoción:** Se crean Pull Requests masivos hacia `main` y `developer`.
3.  **Limpieza:** Se eliminan las ramas de release una vez finalizado el ciclo.

---

## 🛠️ 1. Creación de Ramas (Release Manager)
**Archivo:** `.github/workflows/release-manager.yml`

Este flujo se encarga de revisar si existen cambios pendientes en la rama `developer` comparada con `main`. Si hay cambios, congela el código creando una rama de release.

### 🕒 Ejecución Automática
* **Cuándo:** Los días **15 y 30 de cada mes** a las 12:00 PM (Hora Honduras).
* **Acción:** Genera automáticamente una rama con la fecha actual.
    * Ejemplo: `release/v11.0.2026.01`

### 👆 Ejecución Manual (Botón de Pánico)
Si se requiere un release fuera de fecha o con un nombre específico (ej. corrección urgente `_1`).

1.  Ir a la pestaña **Actions**.
2.  Seleccionar **Release Manager (Masivo Version11)**.
3.  Clic en **Run workflow**.
4.  **Input:**
    * *Dejar vacío:* Para usar la fecha automática.
    * *Escribir versión:* Ej. `v11.0.2026.01_1`.
5.  Clic en **Run workflow**.

---

## 🚀 2. Promoción (Generar MPRS)
**Archivo:** `.github/workflows/generar-mprs-release.yml`

Este flujo se ejecuta **manualmente** una vez que el equipo de QA ha aprobado la versión. Genera los Pull Requests necesarios para llevar los cambios a producción y sincronizar desarrollo.

### Pasos para ejecutar:
1.  Ir a la pestaña **Actions**.
2.  Seleccionar **Generar MPRS Release (Masivo)**.
3.  Clic en **Run workflow**.
4.  **Input (Obligatorio):** Escribir el nombre exacto de la rama a promover.
    * Ejemplo: `release/v11.0.2026.01`
5.  Clic en **Run workflow**.

### Resultado:
* Se crea un PR hacia **`main`** (Titulo: Lanzamiento...).
* Se crea un PR hacia **`developer`** (Titulo: Lanzamiento... Sync).
* Se asigna automáticamente a: `kmponcesalgado` y `wjlopezc`.

> **Nota:** La rama no se borrará automáticamente al mezclar el primer PR gracias al Ruleset "Protección: Release".

---

## 🧹 3. Limpieza (Borrado Masivo)
**Archivo:** `.github/workflows/cleanup-branches.yml`

Este flujo se utiliza al **finalizar todo el ciclo** (cuando los PRs ya están mezclados en Main y Developer) para eliminar la basura. También sirve para eliminar ramas de prueba (`vTest...`).

### Pasos para ejecutar:
1.  Ir a la pestaña **Actions**.
2.  Seleccionar **Limpieza de Ramas (Borrado Masivo)**.
3.  Clic en **Run workflow**.
4.  **Input (Obligatorio):** Nombre de la rama a destruir.
    * Ejemplo: `release/v11.0.2026.01`
5.  Clic en **Run workflow**.

> **⚠️ Importante:** Si el borrado falla por "Protected Branch", asegúrate de que tu usuario esté en la **Bypass list** del Ruleset de la organización.

---

## ⚙️ Configuración Requerida

Para que estos scripts funcionen, se requiere:

1.  **Secret:** `GH_ORG_TOKEN` en este repositorio con permisos `repo` y `read:org`.
2.  **Ruleset:** `Protección: Release (No Borrar)` configurado en la Organización para ramas `release/*` con la opción "Restrict deletions" activa.
