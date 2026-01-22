#!/usr/bin/env pwsh
# =============================================================================
# Setup n8n Variables - Crea variables de entorno en n8n via SQL
# =============================================================================

Write-Host "`n🔧 Configurando variables de entorno en n8n..." -ForegroundColor Cyan

# Cargar variables del .env
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Write-Host "📂 Cargando variables desde .env..." -ForegroundColor Yellow
    Get-Content $envFile | Where-Object { $_ -match '^\s*[^#].*=.*' } | ForEach-Object {
        $parts = $_ -split '=', 2
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()
            Set-Item -Path "env:$key" -Value $value -Force
        }
    }
}

# Variables a configurar en n8n
$variables = @(
    @{key = "MESAYA_API_URL"; value = $env:MESAYA_API_URL},
    @{key = "MESAYA_WS_URL"; value = $env:MESAYA_WS_URL},
    @{key = "MESAYA_CHATBOT_URL"; value = $env:MESAYA_CHATBOT_URL},
    @{key = "MESAYA_GRAPHQL_URL"; value = $env:MESAYA_GRAPHQL_URL},
    @{key = "MESAYA_PAYMENT_URL"; value = $env:MESAYA_PAYMENT_URL},
    @{key = "PARTNER_WEBHOOK_URL"; value = $env:PARTNER_WEBHOOK_URL},
    @{key = "PARTNER_WEBHOOK_SECRET"; value = $env:PARTNER_WEBHOOK_SECRET}
)

Write-Host "`n📝 Creando variables en n8n...`n" -ForegroundColor Cyan

foreach ($var in $variables) {
    $key = $var.key
    $value = $var.value

    if ([string]::IsNullOrEmpty($value)) {
        Write-Host "  ⚠️  $key → (vacío, saltando)" -ForegroundColor Yellow
        continue
    }

    # Usar API REST de n8n para crear variables
    $createCmd = @"
docker exec mesaya-n8n sh -c "sqlite3 /home/node/.n8n/database.sqlite \"
INSERT OR REPLACE INTO variables_entity (id, key, value, type)
VALUES (
    lower(hex(randomblob(16))),
    '$key',
    '$value',
    'string'
);
\""
"@

    try {
        Invoke-Expression $createCmd | Out-Null
        Write-Host "  ✅ $key → $value" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Error creando $key : $_" -ForegroundColor Red
    }
}

Write-Host "`n🔄 Reiniciando n8n para aplicar cambios..." -ForegroundColor Yellow
docker restart mesaya-n8n | Out-Null
Start-Sleep 10

Write-Host "`n✅ Variables configuradas correctamente!`n" -ForegroundColor Green
Write-Host "📌 Verifica en n8n UI → Settings → Variables`n" -ForegroundColor Cyan
