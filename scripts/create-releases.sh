#!/bin/bash
# Archivo: scripts/create-releases.sh

# Validamos que existan las variables necesarias
if [ -z "$GH_TOKEN" ]; then
  echo "❌ Error: No se detectó el token de GitHub (GH_TOKEN)."
  exit 1
fi

# --- CONFIGURACIÓN AJUSTADA ---
BASE_BRANCH="developer"   # <--- CORREGIDO: Antes decía "develop"
PROD_BRANCH="main"

echo "--- Iniciando Release Masivo (Solo Version11): $VERSION_NAME ---"

# 1. Filtramos solo repositorios que terminen en "-Version11"
#    Limit 500 para cubrir tus 136 repositorios de sobra.
repos=$(gh repo list $ORG_NAME --limit 500 --json name --jq '.[].name | select(endswith("-Version11"))')

count=0

for repo in $repos; do
  ((count++))
  echo "[$count] Analizando: $repo"
  
  # 2. Comparamos 'main' contra 'developer'
  diff_status=$(gh api repos/$ORG_NAME/$repo/compare/$PROD_BRANCH...$BASE_BRANCH --jq '.status' 2>/dev/null)

  if [[ "$diff_status" == "ahead" || "$diff_status" == "diverged" ]]; then
      echo "   ✅ Cambios detectados en $BASE_BRANCH. Creando rama $VERSION_NAME..."
      
      # 3. Obtenemos el SHA de 'developer'
      sha=$(gh api repos/$ORG_NAME/$repo/git/ref/heads/$BASE_BRANCH --jq '.object.sha')
      
      if [ -z "$sha" ]; then
         echo "   ❌ Error: No se encontró la rama $BASE_BRANCH en este repo."
         continue
      fi

      # 4. Creamos la rama release/v11... apuntando a ese SHA
      gh api repos/$ORG_NAME/$repo/git/refs \
        -f ref="refs/heads/release/$VERSION_NAME" \
        -f sha="$sha" > /dev/null 2>&1
      
      if [ $? -eq 0 ]; then
        echo "   🚀 Rama 'release/$VERSION_NAME' creada exitosamente."
      else
        echo "   ⚠️  No se pudo crear (¿Ya existe la rama?)."
      fi

  elif [[ "$diff_status" == "identical" ]]; then
      echo "   zzz Sin cambios pendientes (developer == main)."
  else
      # Esto pasa si no existe la rama developer o main en el repo
      echo "   ⚠️  No se pudo comparar (¿Faltan ramas base?)."
  fi
done

echo "--- Proceso Finalizado. Se revisaron $count repositorios. ---"
