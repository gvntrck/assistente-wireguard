<#
.SYNOPSIS
    Assistente Completo WireGuard 
.DESCRIPTION
    Script PowerShell para gerenciamento completo do WireGuard em Windows Server 2022.
.NOTES
    Autor: Giovani - gvntrck
    Versao: 2.0.0
   
#>

# Variaveis globais
$script:ConfigPath = "$env:ProgramData\WireGuard"
$script:WgPath = Find-WireGuardInstallation
$script:Logs = [System.Collections.ArrayList]::new()

# Funcao para encontrar instalacao do WireGuard
function Find-WireGuardInstallation {
    $possiblePaths = @(
        "C:\Program Files\WireGuard",
        "C:\Program Files (x86)\WireGuard",
        "${env:ProgramFiles}\WireGuard",
        "${env:ProgramFiles(x86)}\WireGuard"
    )
    
    foreach ($path in $possiblePaths) {
        $wgExe = Join-Path $path "wg.exe"
        if (Test-Path $wgExe) {
            Add-Log "WireGuard encontrado em: $path" "SUCCESS"
            return $path
        }
    }
    
    Add-Log "WireGuard nao encontrado em locais padrao" "WARNING"
    return "C:\Program Files\WireGuard"  # Default para compatibilidade
}

# Funcao para adicionar logs
function Add-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    $script:Logs.Add($logEntry) | Out-Null
}

# Funcao de validacao
function Test-IPAddress {
    param([string]$IP)
    try {
        [System.Net.IPAddress]::Parse($IP) | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-SubnetCIDR {
    param([string]$Subnet)
    if ($Subnet -notmatch '^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$') {
        return $false
    }
    
    try {
        $parts = $Subnet.Split('/')
        $ip = $parts[0]
        $cidr = [int]$parts[1]
        
        if (-not (Test-IPAddress $ip)) {
            return $false
        }
        
        return ($cidr -ge 0 -and $cidr -le 32)
    }
    catch {
        return $false
    }
}

function Test-Port {
    param([int]$Port)
    return ($Port -ge 1 -and $Port -le 65535)
}

function Test-WireGuardPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        return $false
    }
    
    $wgExe = Join-Path $Path "wg.exe"
    return (Test-Path $wgExe)
}

# Funcao de gerenciamento de chaves
function New-PrivateKey {
    try {
        $wgExe = Join-Path $script:WgPath "wg.exe"
        $privateKey = & $wgExe genkey 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "Erro ao gerar chave privada: $privateKey"
        }
        
        return $privateKey.Trim()
    }
    catch {
        throw "Erro ao gerar chave privada: $_"
    }
}

function Get-PublicKey {
    param([string]$PrivateKey)
    try {
        $wgExe = Join-Path $script:WgPath "wg.exe"
        $publicKey = $PrivateKey | & $wgExe pubkey 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "Erro ao gerar chave publica: $publicKey"
        }
        
        return $publicKey.Trim()
    }
    catch {
        throw "Erro ao gerar chave publica: $_"
    }
}

# Funcao para gerar par de chaves
function New-KeyPair {
    try {
        if (-not (Test-WireGuardPath $script:WgPath)) {
            throw "WireGuard nao encontrado ou nao acessivel"
        }
        
        $privateKey = New-PrivateKey
        $publicKey = Get-PublicKey $privateKey
        
        Add-Log "Par de chaves gerado com sucesso" "SUCCESS"
        
        return @{
            PrivateKey = $privateKey
            PublicKey = $publicKey
            Success = $true
        }
    }
    catch {
        Add-Log "Erro ao gerar chaves: $_" "ERROR"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Funcao para obter status do WireGuard
function Get-WireGuardStatus {
    try {
        $service = Get-Service -Name "WireGuard" -ErrorAction SilentlyContinue
        if ($service) {
            return @{
                Status = $service.Status
                CanStart = $service.Status -eq "Stopped"
                CanStop = $service.Status -eq "Running"
            }
        } else {
            return @{
                Status = "NotInstalled"
                CanStart = $false
                CanStop = $false
            }
        }
    } catch {
        return @{
            Status = "Error"
            CanStart = $false
            CanStop = $false
        }
    }
}

# Funcao para mostrar dashboard
function Show-Dashboard {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                    WIREGUARD ASSISTANT v2.0.0" -ForegroundColor Cyan
    Write-Host "                  Windows Server 2022 - Dashboard" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Status do WireGuard
    $status = Get-WireGuardStatus
    Write-Host "--- STATUS DO SERVICO ---" -ForegroundColor Yellow
    Write-Host "Servico WireGuard: " -NoNewline -ForegroundColor White
    
    switch ($status.Status) {
        "Running" { Write-Host "Online" -ForegroundColor Green }
        "Stopped" { Write-Host "Parado" -ForegroundColor Yellow }
        "NotInstalled" { Write-Host "Nao Instalado" -ForegroundColor Red }
        default { Write-Host "Erro" -ForegroundColor Red }
    }
    
    Write-Host "Caminho do WireGuard: $script:WgPath" -ForegroundColor White
    Write-Host "Status do Caminho: " -NoNewline -ForegroundColor White
    if (Test-WireGuardPath $script:WgPath) {
        Write-Host "OK" -ForegroundColor Green
    } else {
        Write-Host "Nao encontrado" -ForegroundColor Red
    }
    Write-Host ""
    
    # Interfaces configuradas
    Write-Host "--- INTERFACES CONFIGURADAS ---" -ForegroundColor Yellow
    $interfaces = Get-ChildItem -Path $script:ConfigPath -Filter "*.conf" -ErrorAction SilentlyContinue
    
    if ($interfaces) {
        Write-Host "Interfaces encontradas: $($interfaces.Count)" -ForegroundColor White
        foreach ($interface in $interfaces) {
            Write-Host "  - $($interface.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Host "Nenhuma interface configurada encontrada" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Logs recentes
    Write-Host "--- LOGS RECENTES ---" -ForegroundColor Yellow
    $recentLogs = $script:Logs | Select-Object -Last 5
    if ($recentLogs) {
        foreach ($log in $recentLogs) {
            $color = switch ($log) {
                { $_ -match "\[SUCCESS\]" } { "Green" }
                { $_ -match "\[ERROR\]" } { "Red" }
                { $_ -match "\[WARNING\]" } { "Yellow" }
                default { "Gray" }
            }
            Write-Host $log -ForegroundColor $color
        }
    } else {
        Write-Host "Nenhum log recente" -ForegroundColor Gray
    }
    Write-Host ""
}

# Funcao para configurar interface
function Set-InterfaceConfig {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                   CONFIGURAÇÃO DE INTERFACE" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Nome da interface
    $interfaceName = Read-Host "Nome da interface (ex: wg0)"
    if ([string]::IsNullOrWhiteSpace($interfaceName)) {
        $interfaceName = "wg0"
    }
    
    # Gerar ou usar chave privada existente
    $useGeneratedKey = Read-Host "Deseja gerar um novo par de chaves? (S/N)"
    if ($useGeneratedKey -eq "S") {
        $keyPair = New-KeyPair
        if ($keyPair.Success) {
            $privateKey = $keyPair.PrivateKey
            $publicKey = $keyPair.PublicKey
            Write-Host "Chave privada gerada: $privateKey" -ForegroundColor Green
            Write-Host "Chave publica gerada: $publicKey" -ForegroundColor Cyan
        } else {
            Write-Host "Erro ao gerar chaves: $($keyPair.Error)" -ForegroundColor Red
            return $false
        }
    } else {
        $privateKey = Read-Host "Insira a chave privada existente"
        if ([string]::IsNullOrWhiteSpace($privateKey)) {
            Write-Host "Chave privada e obrigatoria" -ForegroundColor Red
            return $false
        }
    }
    
    # Porta de escuta
    $portInput = Read-Host "Porta de escuta (padrão: 51820)"
    if ([string]::IsNullOrWhiteSpace($portInput)) {
        $portInput = "51820"
    }
    
    try {
        $port = [int]$portInput
    }
    catch {
        Write-Host "Porta deve ser um numero valido" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Port $port)) {
        Write-Host "Porta invalida" -ForegroundColor Red
        return $false
    }
    
    # Endereco IP
    $address = Read-Host "Endereco IP da interface (ex: 10.0.0.1/24)"
    if (-not (Test-SubnetCIDR $address)) {
        Write-Host "Endereco IP invalido" -ForegroundColor Red
        return $false
    }
    
    # Criar arquivo de configuracao
    $configContent = "[Interface]
PrivateKey = $privateKey
Address = $address
ListenPort = $port

SaveConfig = true"
    
    $configPath = Join-Path -Path $script:ConfigPath -ChildPath "$interfaceName.conf"
    
    try {
        # Criar diretorio se nao existir
        if (-not (Test-Path $script:ConfigPath)) {
            New-Item -Path $script:ConfigPath -ItemType Directory -Force | Out-Null
        }
        
        # Salvar configuracao
        $configContent | Out-File -FilePath $configPath -Encoding UTF8 -Force
        
        Add-Log "Interface '$interfaceName' configurada com sucesso" "SUCCESS"
        Write-Host "Interface '$interfaceName' configurada em: $configPath" -ForegroundColor Green
        return $true
    }
    catch {
        Add-Log "Erro ao salvar configuracao: $_" "ERROR"
        Write-Host "Erro ao salvar configuracao: $_" -ForegroundColor Red
        return $false
    }
}

# Funcao para adicionar peer
function Add-PeerConfig {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                         ADICIONAR PEER" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Listar interfaces existentes
    $interfaces = Get-ChildItem -Path $script:ConfigPath -Filter "*.conf" -ErrorAction SilentlyContinue
    if (-not $interfaces) {
        Write-Host "Nenhuma interface configurada encontrada. Configure uma interface primeiro." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return $false
    }
    
    Write-Host "Interfaces disponiveis:" -ForegroundColor White
    for ($i = 0; $i -lt $interfaces.Count; $i++) {
        Write-Host "$($i + 1). $($interfaces[$i].Name)" -ForegroundColor Gray
    }
    
    $interfaceChoice = Read-Host "Escolha a interface (numero)"
    if ($interfaceChoice -match '^\d+$' -and [int]$interfaceChoice -ge 1 -and [int]$interfaceChoice -le $interfaces.Count) {
        $selectedInterface = $interfaces[[int]$interfaceChoice - 1]
    } else {
        Write-Host "Escolha invalida" -ForegroundColor Red
        return $false
    }
    
    # Nome do peer
    $peerName = Read-Host "Nome do peer (ex: Cliente-1)"
    if ([string]::IsNullOrWhiteSpace($peerName)) {
        $peerName = "Cliente-$(Get-Random -Maximum 999)"
    }
    
    # Chave publica
    $publicKey = Read-Host "Chave publica do peer"
    if ([string]::IsNullOrWhiteSpace($publicKey)) {
        Write-Host "Chave publica e obrigatoria" -ForegroundColor Red
        return $false
    }
    
    # IPs permitidos
    $allowedIPs = Read-Host "IPs permitidos (ex: 10.0.0.2/32)"
    if ([string]::IsNullOrWhiteSpace($allowedIPs)) {
        $allowedIPs = "10.0.0.2/32"
    }
    
    # Adicionar peer ao arquivo de configuracao
    $peerConfig = "

[Peer]
# $peerName
PublicKey = $publicKey
AllowedIPs = $allowedIPs"
    
    try {
        Add-Content -Path $selectedInterface.FullName -Value $peerConfig -Encoding UTF8
        Add-Log "Peer '$peerName' adicionado a interface '$($selectedInterface.Name)'" "SUCCESS"
        Write-Host "Peer '$peerName' adicionado com sucesso" -ForegroundColor Green
        return $true
    }
    catch {
        Add-Log "Erro ao adicionar peer: $_" "ERROR"
        Write-Host "Erro ao adicionar peer: $_" -ForegroundColor Red
        return $false
    }
}

# Funcao para mostrar logs
function Show-Logs {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                             LOGS" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ($script:Logs.Count -gt 0) {
        foreach ($log in $script:Logs) {
            $color = switch ($log) {
                { $_ -match "\[SUCCESS\]" } { "Green" }
                { $_ -match "\[ERROR\]" } { "Red" }
                { $_ -match "\[WARNING\]" } { "Yellow" }
                default { "Gray" }
            }
            Write-Host $log -ForegroundColor $color
        }
    } else {
        Write-Host "Nenhum log registrado" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Pressione qualquer tecla para continuar..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Funcao principal do menu
function Show-MainMenu {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "                    WIREGUARD ASSISTANT v2.0.0" -ForegroundColor Cyan
    Write-Host "                Windows Server 2022 - Console Mode" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "--- MENU PRINCIPAL ---" -ForegroundColor Yellow
    Write-Host "1. Dashboard" -ForegroundColor White
    Write-Host "2. Configurar Interface" -ForegroundColor White
    Write-Host "3. Adicionar Peer" -ForegroundColor White
    Write-Host "4. Gerar Par de Chaves" -ForegroundColor White
    Write-Host "5. Ver Status do WireGuard" -ForegroundColor White
    Write-Host "6. Ver Logs" -ForegroundColor White
    Write-Host "7. Sair" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Escolha uma opcao"
    
    switch ($choice) {
        "1" { 
            Show-Dashboard
            Write-Host ""
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" { 
            Set-InterfaceConfig
            Start-Sleep -Seconds 2
        }
        "3" { 
            Add-PeerConfig
            Start-Sleep -Seconds 2
        }
        "4" { 
            Clear-Host
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host "                     GERADOR DE CHAVES" -ForegroundColor Cyan
            Write-Host "=====================================================================" -ForegroundColor Cyan
            Write-Host ""
            
            $keyPair = New-KeyPair
            if ($keyPair.Success) {
                Write-Host "Chave Privada:" -ForegroundColor Yellow
                Write-Host $keyPair.PrivateKey -ForegroundColor Green
                Write-Host ""
                Write-Host "Chave Publica:" -ForegroundColor Yellow
                Write-Host $keyPair.PublicKey -ForegroundColor Cyan
            } else {
                Write-Host "Erro: $($keyPair.Error)" -ForegroundColor Red
            }
            
            Write-Host ""
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" { 
            Clear-Host
            $status = Get-WireGuardStatus
            Write-Host "Status do WireGuard: $($status.Status)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
        "6" { 
            Show-Logs
        }
        "7" { 
            return $false
        }
        default { 
            Write-Host "Opcao invalida!" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    
    return $true
}

# Ponto de entrada principal
try {
    # Pausa inicial para debugging
    Write-Host "Iniciando WireGuard Assistant v2.0.0..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    
    # Verificar se esta rodando como administrador
    $currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Este script precisa ser executado como Administrador!" -ForegroundColor Red
        Write-Host "Clique com o botao direito e selecione Executar como administrador" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
    
    # Inicializar logs
    Add-Log "WireGuard Assistant v2.0.0 iniciado" "SUCCESS"
    Add-Log "Sistema operacional: $env:OS" "INFO"
    Add-Log "Versao do PowerShell: $($PSVersionTable.PSVersion)" "INFO"
    
    # Loop principal
    do {
        $continue = Show-MainMenu
    } while ($continue)
    
    Write-Host "WireGuard Assistant encerrado. Ate logo!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
catch {
    Write-Host "ERRO CRITICO AO EXECUTAR O SCRIPT:" -ForegroundColor Red
    Write-Host "$_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Detalhes do erro:" -ForegroundColor Yellow
    Write-Host "Linha: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Gray
    Write-Host "Comando: $($_.InvocationInfo.Line)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
