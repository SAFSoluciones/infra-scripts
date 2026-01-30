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

📋 Gobernanza, Seguridad y Flujo de Trabajo
Este repositorio opera bajo una arquitectura de seguridad centralizada mediante GitHub Rulesets y Workflows de Validación. El objetivo es mantener un historial limpio, asegurar la calidad del código y prevenir errores humanos en ramas críticas.

1. Arquitectura de Ramas (Rulesets)
La protección de ramas ya no se gestiona individualmente en cada repositorio, sino a través de 3 Rulesets globales de la organización:

Ruleset,Alcance,Objetivo y Restricciones
🛡️ Protección Global Main,main,Control de Flujo: Evita escrituras directas. Nadie puede hacer push directo a producción; todo debe pasar por Pull Request.

🔐 Seguridad: Main & Developer,"main, developer",Integridad:• Prohibido borrar la rama o hacer force push.• Revisión Obligatoria: Se requiere al menos 1 aprobación humana para fusionar.• Seguridad: Descarta aprobaciones obsoletas si se sube código nuevo (Dismiss stale reviews).

✅ Validación: Rama Actualizada,developer,"Calidad: Exige que los workflows de CI/CD (linting, tests) pasen exitosamente antes de permitir la fusión (Status Check Required)."

🔥

2. Workflows de Automatización (.github/workflows)
Estos archivos controlan las validaciones automáticas en cada Pull Request.

A. guardian-main.yml (El Guardián de Producción) Este workflow actúa como un "portero" inteligente para proteger la rama main.

Función: Se ejecuta en cada PR.

Lógica:

Válvula de Escape: Si el PR va dirigido a developer, el guardián aprueba automáticamente (Exit 0).

Protección de Main: Si el PR va dirigido a main, verifica:

¿Es un Hotfix? (El título contiene hotfix).

¿Es un Admin autorizado? (Lista blanca de usuarios).

Bloqueo: Si no cumple lo anterior, el workflow falla ⛔ y deja un comentario indicando que se debe apuntar a developer.

B. check-branch-status.yml (Validación de Código) Sustituye al antiguo dummy-check.yml.

Función: Asegura que el código cumpla con los estándares técnicos.

Lógica: Ejecuta pruebas unitarias, linters o validaciones de sintaxis. Es un requisito obligatorio (Status Check) para poder fusionar en developer.

3. Flujo de Trabajo Recomendado (Git Flow)
Para evitar bloqueos y mantener el orden, sigue este ciclo:

Desarrollo:

Crea una rama feature/ o fix/ desde developer.

Trabaja en tus cambios.

Integración (Hacia Developer):

Abre un Pull Request hacia developer.

El Guardián te dará luz verde ✅.

Espera a que pasen los checks automáticos.

Solicita revisión a un compañero (1 aprobación requerida).

Fusión: Se utiliza Squash Merge para mantener un historial lineal y limpio.

Despliegue (Hacia Main):

Solo los Administradores o procesos de Release crean PRs de developer hacia main.

⚠️ Importante: Al fusionar hacia main, desactivar la opción "Delete head branch" para evitar borrar developer accidentalmente.

4. Solución de Problemas Comunes
Error: "Required workflow did not pass" en una rama vieja:

Causa: La rama tiene una versión antigua de los workflows o busca archivos eliminados (dummy-check).

Solución: Actualiza tu rama con developer (git pull origin developer o botón "Update branch").

Error: "Vas a MAIN sin permiso" (El Guardián falla):

Causa: El PR apunta a main y no es un hotfix.

Solución: Edita el PR (botón "Edit" junto al título) y cambia la "Base branch" a developer. El Guardián se actualizará automáticamente.

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
