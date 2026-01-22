#!/usr/bin/env pwsh

# Script AUTOMATIZADO para importar workflows usando Docker exec
# Este método NO requiere API keys ni autenticación
# Uso: .\import-workflows-docker.ps1

$CONTAINER_NAME = "mesaya-n8n"
$WORKFLOWS_DIR = "/home/node/workflows"

# Workflows a importar (TODOS los workflows obligatorios)
$workflows = @(
    "payment-handler.json",
    "partner-handler.json",
    "mcp-input-handler.json",
    "daily-report.json"
)

Write-Host "`n🚀 IMPORTACIÓN AUTOMATIZADA DE WORKFLOWS" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

# Verificar que el contenedor esté corriendo
Write-Host "🔍 Verificando contenedor n8n..." -ForegroundColor Yellow
$containerStatus = docker ps --filter "name=$CONTAINER_NAME" --format "{{.Status}}" 2>$null

if (-not $containerStatus) {
    Write-Host "❌ Error: Contenedor $CONTAINER_NAME no está corriendo`n" -ForegroundColor Red
    Write-Host "   Inicialo con:" -ForegroundColor Yellow
    Write-Host "   docker compose up -d`n" -ForegroundColor White
    exit 1
}

Write-Host "✅ Contenedor está corriendo`n" -ForegroundColor Green

# Listar workflows existentes en n8n para evitar duplicados
Write-Host "🔍 Verificando workflows ya importados en n8n..." -ForegroundColor Yellow
$existingWorkflowsOutput = docker exec $CONTAINER_NAME n8n list:workflow 2>&1
$existingWorkflowNames = @()

if ($existingWorkflowsOutput) {
    # Parsear nombres de workflows existentes
    $existingWorkflowsOutput | ForEach-Object {
        if ($_ -match "MesaYA - (.+)") {
            $existingWorkflowNames += "MesaYA - $($matches[1])"
        }
    }
}

if ($existingWorkflowNames.Count -gt 0) {
    Write-Host "   📋 Encontrados $($existingWorkflowNames.Count) workflows ya importados" -ForegroundColor Gray
} else {
    Write-Host "   📋 No hay workflows importados aún" -ForegroundColor Gray
}
Write-Host ""

# Listar workflows en el contenedor
Write-Host "📁 Workflows disponibles en el contenedor:" -ForegroundColor Cyan
docker exec $CONTAINER_NAME ls -1 $WORKFLOWS_DIR 2>$null | ForEach-Object {
    Write-Host "   - $_" -ForegroundColor Gray
}
Write-Host ""

$successCount = 0
$errorCount = 0
$skippedCount = 0
$importedWorkflows = @()

# Mapeo de archivos a nombres de workflows
$workflowNames = @{
    "payment-handler.json" = "MesaYA - Payment Handler"
    "partner-handler.json" = "MesaYA - Partner Handler"
    "mcp-input-handler.json" = "MesaYA - MCP Input Handler"
    "daily-report.json" = "MesaYA - Reporte Diario de Reservaciones"
}

foreach ($workflow in $workflows) {
    $filePath = "$WORKFLOWS_DIR/$workflow"
    $workflowName = $workflowNames[$workflow]

    # Verificar si el workflow ya existe
    if ($existingWorkflowNames -contains $workflowName) {
        Write-Host "⏭️  Saltando: $workflow" -ForegroundColor Yellow
        Write-Host "   (ya existe '$workflowName')`n" -ForegroundColor Gray
        $skippedCount++
        continue
    }

    # Ejecutar importación en el contenedor
    $output = docker exec $CONTAINER_NAME n8n import:workflow --input=$filePath 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "   ✅ Importado exitosamente" -ForegroundColor Green
        $successCount++
        $importedWorkflows += $workflow
        Write-Host ""
    } else {
        # Verificar si el error es por duplicado
        if ($output -match "already exists" -or $output -match "duplicate") {
            Write-Host "   ⏭️  Ya existe (saltando)" -ForegroundColor Yellow
            Write-Host ""
        } else {
            Write-Host "   ❌ Error: $output" -ForegroundColor Red
            Write-Host ""
            $errorCount++
        }
    }
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "📊 RESUMEN DE IMPORTACIÓN" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "   ✅ Importados: $successCount" -ForegroundColor Green
Write-Host "   ⏭️  Saltados (ya existían): $skippedCount" -ForegroundColor Yellow
Write-Host "   ❌ Errores: $errorCount`n" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Gray" })

if ($successCount -gt 0) {
    Write-Host "🎉 WORKFLOWS IMPORTADOS EXITOSAMENTE`n" -ForegroundColor Green
    Write-Host "Workflows importados:" -ForegroundColor Cyan
    foreach ($w in $importedWorkflows) {
        Write-Host "   ✓ $w" -ForegroundColor White
    }
  elseif ($skippedCount -gt 0 -and $errorCount -eq 0 -and $successCount -eq 0) {
    Write-Host "ℹ️  TODOS LOS WORKFLOWS YA ESTÁN IMPORTADOS`n" -ForegroundColor Cyan
    Write-Host "No se importó nada porque todos ya existen en n8n." -ForegroundColor Gray
    Write-Host "Si necesitas reimportarlos, elimínalos primero desde la UI de n8n.`n" -ForegroundColor Gray
}   Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📍 PRÓXIMOS PASOS" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "1. Abre n8n: http://localhost:5678" -ForegroundColor White
Write-Host "2. Login: admin / mesaya_n8n_2024" -ForegroundColor White
Write-Host "3. Verifica que los workflows estén en la lista" -ForegroundColor White
Write-Host "4. ACTIVA cada workflow (toggle en la UI)" -ForegroundColor Yellow
Write-Host "5. Configura las credenciales necesarias:" -ForegroundColor White
Write-Host "   - SMTP (para emails)" -ForegroundColor Gray
Write-Host "   - Telegram Bot (para MCP Handler)" -ForegroundColor Gray
Write-Host "   - Email IMAP (para MCP Handler)`n" -ForegroundColor Gray

if ($errorCount -gt 0) {
    Write-Host "⚠️  Algunos workflows tuvieron errores" -ForegroundColor Yellow
    Write-Host "   Revisa los mensajes arriba para más detalles`n" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✨ ¡Todo listo! Los workflows están importados en n8n`n" -ForegroundColor Green
    exit 0
}
