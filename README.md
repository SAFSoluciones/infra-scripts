# infra-scripts
Automatización centralizada para estandarización de repositorios.






################################### De aquí para abajo, está la documentación de la automatización del release.###################################

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
