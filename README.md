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

# 🛡️ Gobernanza y Automatización de Repositorios (DevSecOps)

Este documento describe la arquitectura de gobernanza implementada en la organización para estandarizar el flujo de desarrollo, proteger las ramas críticas y automatizar el mantenimiento.

## 1. Workflow Centralizado: "El Guardián" (`guardian-main.yml`)

Este script actúa como una barrera de seguridad inteligente en todos los Pull Requests. Se encuentra alojado en el repositorio `infra-scripts` y es reutilizado por toda la organización.

- **Ubicación:** `infra-scripts/.github/workflows/guardian-main.yml`
- **Disparadores (Triggers):** Se ejecuta cuando un PR es creado (`opened`), editado (`edited`), reabierto (`reopened`) o cuando se sube código nuevo (`synchronize`).

### 🧠 Lógica de Decisión

El Guardián evalúa el destino del PR y toma decisiones automáticas:

| Rama Destino | Acción del Guardián | Resultado |
| :--- | :--- | :--- |
| **`developer`** | **Modo Pasivo:** Detecta que es un entorno de desarrollo seguro. | ✅ **Aprueba (Check Verde)** automáticamente. Sirve para limpiar errores previos. |
| **`main`** | **Modo Activo:** Verifica permisos estrictos. | 🔒 **Analiza condiciones:** <br>1. ¿Es Admin? ➡ Pasa ✅<br>2. ¿Es Hotfix? ➡ Pasa ✅<br>3. ¿Ninguno? ➡ **Bloquea ❌** y deja comentario. |

---

## 2. GitHub Rulesets (Reglas Globales)

Se ha configurado un **Ruleset** a nivel de Organización para aplicar políticas de seguridad sin necesidad de configurar repositorio por repositorio.

- **Nombre de la Regla:** `Protección Global Main` (o Estandarización).
- **Alcance:** Aplica a `All repositories` (Todos los repositorios) o lista `Target`.
- **Ramas Protegidas (Target Branches):**
  1. `Default` (Generalmente `main`).
  2. `developer` (Incluida explícitamente para permitir la ejecución del Guardián).

### ⚙️ Reglas Aplicadas

1.  **Require workflows to pass:**
    * Obliga a que el workflow `guardian-main.yml` se ejecute y termine exitosamente (Verde ✅) antes de permitir un Merge.
2.  **Restrict deletions:**
    * Impide que cualquier usuario (incluso admins, dependiendo de la config) borre accidentalmente las ramas `main` o `developer`.

---

## 3. Política de Limpieza (Ramas de Vida Corta)

Para mantener la higiene de los repositorios y evitar la acumulación de ramas obsoletas, se ha activado la siguiente política automática:

- **Configuración:** `Automatically delete head branches` (Activo).
- **Comportamiento:**
    * Cuando un Pull Request se fusiona (Merge) exitosamente hacia `developer` o `main`, la rama de origen (ej: `feature/SS5-1234`) **se elimina automáticamente**.
    * **Excepción:** Las ramas protegidas por el Ruleset (`developer`, `main`) no se borran gracias a la regla *Restrict deletions*.

---

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
