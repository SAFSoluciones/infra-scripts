#!/bin/bash

# Validamos variables
if [ -z "$BRANCH_TO_DELETE" ]; then
  echo "❌ Error: No se definió la rama a eliminar (BRANCH_TO_DELETE)."
  exit 1
fi

echo "--- Iniciando Eliminación Masiva ---"
echo "🗑️  Rama objetivo: $BRANCH_TO_DELETE"

# Nota: El Ruleset impide borrar, PERO los Admins o Tokens con permisos de Admin
# suelen poder saltarse reglas si se configura el 'Bypass list' en el Ruleset.
# Si el script falla por 'Protected Branch', tendrás que agregar tu App/Token al Bypass list del Ruleset momentáneamente.

repos=$(gh repo list $ORG_NAME --limit 500 --json name --jq '.[].name | select(endswith("-Version11"))')

count=0

for repo in $repos; do
  ((count++))
  echo "[$count] Procesando: $repo"

  # Intentamos borrar la referencia
  # La API devuelve error si la rama no existe, así que silenciamos un poco el output feo
  gh api -X DELETE "repos/$ORG_NAME/$repo/git/refs/heads/$BRANCH_TO_DELETE" > /dev/null 2>&1
  
  if [[ $? -eq 0 ]]; then
      echo "   ✅ Eliminada exitosamente."
  else
      # Verificamos si es porque no existía o por permiso
      exists=$(gh api "repos/$ORG_NAME/$repo/git/refs/heads/$BRANCH_TO_DELETE" 2>/dev/null)
      if [ -z "$exists" ]; then
         echo "   💨 No existía (ya borrada o nunca creada)."
      else
         echo "   ❌ Falló el borrado (¿Bloqueado por Ruleset?). Revisa permisos."
      fi
  fi
done

echo "------------------------------------------------"
echo "🏁 Limpieza finalizada."
