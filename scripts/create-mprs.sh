#!/bin/bash

# Validamos variables
if [ -z "$RELEASE_BRANCH" ]; then
  echo "❌ Error: No se definió la rama de release (RELEASE_BRANCH)."
  exit 1
fi

# Preparamos el Título y Asignaciones
CLEAN_VERSION="${RELEASE_BRANCH#release/}"
PR_TITLE="Lanzamiento $CLEAN_VERSION"
PR_BODY="Liberación de cambios."
ASSIGNEES="kmponcesalgado,wjlopezc"

echo "--- Iniciando Creación de MPRS Masivos ---"
echo "📌 Rama Origen: $RELEASE_BRANCH"
echo "📌 Título PR:   $PR_TITLE"
echo "📌 Asignados:   $ASSIGNEES"

# 1. Obtener lista de repositorios Version11
repos=$(gh repo list $ORG_NAME --limit 500 --json name --jq '.[].name | select(endswith("-Version11"))')

count=0

for repo in $repos; do
  
  # 2. Verificar si la rama de release existe en este repo
  branch_check=$(gh api repos/$ORG_NAME/$repo/git/ref/heads/$RELEASE_BRANCH --jq '.object.sha' 2>/dev/null)

  if [ -z "$branch_check" ]; then
    continue
  fi

  ((count++))
  echo "[$count] Procesando: $repo"

  # --- A. PR hacia MAIN ---
  echo "   👉 Creando PR hacia MAIN..."
  gh pr create \
    --repo "$ORG_NAME/$repo" \
    --base "main" \
    --head "$RELEASE_BRANCH" \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --assignee "$ASSIGNEES" || echo "      ⚠️  (El PR hacia main ya existe o hubo un error)"

  # --- B. PR hacia DEVELOPER ---
  echo "   👉 Creando PR hacia DEVELOPER..."
  gh pr create \
    --repo "$ORG_NAME/$repo" \
    --base "developer" \
    --head "$RELEASE_BRANCH" \
    --title "$PR_TITLE (Sync)" \
    --body "$PR_BODY - Sincronización de cambios." \
    --assignee "$ASSIGNEES" || echo "      ⚠️  (El PR hacia developer ya existe o hubo un error)"

  echo "   ✅ Completado."
done

echo "------------------------------------------------"
echo "🏁 Proceso finalizado. Se generaron PRs en $count repositorios."
