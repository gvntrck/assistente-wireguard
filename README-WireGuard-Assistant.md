# WireGuard Assistant v2.0.0

Assistente completo para gerenciamento do WireGuard em Windows Server 2022 com interface gráfica moderna baseada em Bootstrap e suporte completo à linha de comando.

## 🚀 Funcionalidades

### Interface Gráfica Moderna
- **Dashboard**: Visão geral em tempo real do status do WireGuard
- **Gerenciamento de Interfaces**: Configure e monitore interfaces WireGuard
- **Gerenciamento de Peers**: Adicione e gerencie clientes VPN
- **Logs em Tempo Real**: Monitoramento completo de atividades
- **Ferramentas Avançadas**: Utilitários para gerenciamento

### Principais Características
- ✅ Interface moderna com Bootstrap 5.3.8
- ✅ Design responsivo e intuitivo
- ✅ Geração automática de chaves criptográficas
- ✅ Validação de configurações
- ✅ Exportação/Importação de configurações
- ✅ Geração de QR Codes para dispositivos móveis
- ✅ Sistema de logs colorido e organizado
- ✅ Indicadores visuais de status
- ✅ Suporte a múltiplas interfaces e peers
- ✅ Interface interativa com perguntas guiadas
- ✅ Geração automática de chaves (privadas, públicas e PSK)
- ✅ Validação de entradas (IPs, portas, caminhos)
- ✅ Configuração do servidor com múltiplos clientes
- ✅ Arquivos .conf prontos para uso imediato
- ✅ Documentação completa gerada automaticamente
- ✅ Organização automática em pastas separadas

## 📋 Requisitos

- Windows Server 2022 ou Windows 10/11
- PowerShell 5.1 ou superior
- Permissões de Administrador
- WireGuard instalado em `C:\Program Files\WireGuard`
- Conexão com internet para Bootstrap CDN

## 🛠️ Instalação

### 1. Instalar o WireGuard
```powershell
# Download do instalador oficial
# https://www.wireguard.com/install/
```

### 2. Baixar o Assistente
```powershell
# Clonar ou baixar o script WireGuard-Assistente.ps1
```

### 3. Executar como Administrador
- Clique com o botão direito no script
- Selecione "Executar com PowerShell"
- Ou execute via terminal com privilégios elevados

## 🎯 Uso Rápido

### Opção 1: Interface Gráfica (Recomendado)
1. Execute o script: `.\WireGuard-Assistente.ps1`
2. Escolha a opção "1" para abrir a interface gráfica
3. Navegue pelas seções do menu lateral:
   - **Dashboard**: Visão geral em tempo real
   - **Interfaces**: Gerenciar interfaces WireGuard
   - **Peers**: Adicionar e gerenciar clientes
   - **Configuração**: Configurar nova interface ou peer
   - **Logs**: Monitorar atividades em tempo real
   - **Ferramentas**: Utilitários avançados
4. Configure sua interface e adicione peers

### Opção 2: Linha de Comando
1. Execute o script: `.\WireGuard-Assistente.ps1`
2. Escolha as opções disponíveis no menu:
   - Verificar status do WireGuard
   - Gerar par de chaves
   - Outras utilidades

### Opção 3: Assistente Clássico
Para configuração avançada com múltiplos clientes:
1. Execute o script: `.\WireGuard-Assistente.ps1`
2. Escolha a opção "4" para o assistente clássico
3. Siga as 5 etapas guiadas de configuração

## 📚 Guia de Configuração Rápida

### 1. Configurar Interface (via GUI)
- **Nome**: `wg0` (padrão)
- **Chave Privada**: Gerada automaticamente
- **Porta**: `51820` (padrão)
- **Endereço IP**: `10.0.0.1/24` (rede VPN)

### 2. Adicionar Peers (via GUI)
- **Nome**: Identificação do cliente
- **Chave Pública**: Gerada automaticamente
- **IPs Permitidos**: `10.0.0.2/32` (individual)
- **Endpoint**: `cliente.dominio.com:51820` (opcional)

### 3. Configurar Firewall
```powershell
# Permitir porta UDP do WireGuard
netsh advfirewall firewall add rule name="WireGuard" dir=in action=allow protocol=UDP localport=51820
```

### 4. Habilitar Roteamento IP
```powershell
# No Registry Editor ou PowerShell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "IPEnableRouter" -Value 1
```

## 🏗️ Arquitetura e Princípios

### SOLID Principles Implementados
- **Single Responsibility**: Cada classe tem uma responsabilidade única
  - `WireGuardValidator`: Validação de dados
  - `WireGuardKeyManager`: Gerenciamento de chaves
  - `WireGuardAssistant`: Interface principal
- **Open/Closed**: Extensível sem modificar código existente
- **Liskov Substitution**: Subclasses podem substituir classes base
- **Interface Segregation**: Interfaces específicas e coesas
- **Dependency Inversion**: Depende de abstrações, não de implementações

### Clean Code Aplicado
- Nomes descritivos e significativos
- Funções pequenas e focadas
- Comentários explicativos quando necessário
- Formatação consistente

### DRY (Don't Repeat Yourself)
- Código reutilizável
- Funções auxiliares para validações
- Componentes compartilhados

### KISS (Keep It Simple, Stupid)
- Soluções simples e diretas
- Interface intuitiva
- Mínima complexidade técnica

## 📁 Estrutura do Projeto

```
WireGuard-Assistant/
├── WireGuard-Assistente.ps1    # Script principal com interface gráfica
├── README-WireGuard-Assistant.md # Esta documentação
└── WireGuard-Configs/          # Saída de configurações
    ├── Servidor/
    │   └── wg0.conf
    ├── Clientes/
    │   ├── Cliente-1.conf
    │   ├── Cliente-2.conf
    │   └── ...
    └── RESUMO-E-INSTRUCOES.txt
```

## 🔧 Classes Principais

### WireGuardValidator
Validação de dados de entrada:
- Endereços IP
- Subnets CIDR
- Portas
- Caminhos do WireGuard

### WireGuardKeyManager
Gerenciamento de chaves criptográficas:
- Geração de chaves privadas
- Geração de chaves públicas
- Geração de PSK (Pre-Shared Keys)

### WireGuardAssistant
Classe principal da interface:
- Gestão do formulário Windows
- Integração com HTML/JavaScript
- Comunicação PowerShell-JavaScript

### 3. Responda as Perguntas

O assistente fará perguntas em 5 etapas:

#### **Etapa 1: Localização do WireGuard**
- Caminho dos executáveis (padrão: `C:\Program Files\WireGuard`)

#### **Etapa 2: Configuração do Servidor**
- IP público do servidor (ex: `203.0.113.1`)
- Porta UDP (padrão: `51820`)
- IP interno na VPN (padrão: `10.0.0.1`)
- Subnet da VPN (padrão: `10.0.0.0/24`)
- Interface de rede (padrão: `Ethernet`)
- Servidores DNS (padrão: `1.1.1.1, 1.0.0.1`)

#### **Etapa 3: Configuração dos Clientes**
- Quantidade de clientes (1-50)
- Usar PSK? (S/N)

#### **Etapas 4 e 5: Geração Automática**
- O script gera todas as chaves e arquivos automaticamente

## 📁 Estrutura de Saída

Após a execução, será criada a seguinte estrutura:

```
WireGuard-Configs/
├── Servidor/
│   └── wg0.conf                    # Configuração do servidor
├── Clientes/
│   ├── Cliente-1.conf              # Configuração do cliente 1
│   ├── Cliente-2.conf              # Configuração do cliente 2
│   └── ...
└── RESUMO-E-INSTRUCOES.txt         # Resumo completo e próximos passos
```

## 🔧 Configuração do Servidor

Após gerar os arquivos:

### 1. Copiar Configuração

```powershell
# Copie o arquivo wg0.conf para o diretório do WireGuard
Copy-Item ".\WireGuard-Configs\Servidor\wg0.conf" -Destination "C:\Program Files\WireGuard\Data\Configurations\"
```

### 2. Configurar Firewall

```powershell
# Permitir porta UDP do WireGuard (substitua 51820 pela sua porta)
netsh advfirewall firewall add rule name="WireGuard" dir=in action=allow protocol=UDP localport=51820
```

### 3. Habilitar Roteamento IP

```powershell
# Habilitar encaminhamento de IP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "IPEnableRouter" -Value 1

# Reiniciar para aplicar
Restart-Computer
```

### 4. Iniciar Túnel

Opção 1 - **GUI do WireGuard**:
- Abra o WireGuard
- Clique em "Importar túnel(s) do arquivo"
- Selecione `wg0.conf`
- Clique em "Ativar"

Opção 2 - **Linha de Comando**:
```powershell
# Instalar como serviço
wireguard.exe /installtunnelservice "C:\Program Files\WireGuard\Data\Configurations\wg0.conf"
```

### 5. Verificar Status

```powershell
# Ver status do túnel
wg show

# Deve mostrar algo como:
# interface: wg0
#   public key: [sua chave pública]
#   private key: (hidden)
#   listening port: 51820
#
# peer: [chave pública do cliente]
#   allowed ips: 10.0.0.2/32
```

## 📱 Configuração dos Clientes

### Windows

1. Instale o WireGuard
2. Abra o WireGuard GUI
3. Clique em "Importar túnel(s) do arquivo"
4. Selecione o arquivo `Cliente-X.conf`
5. Clique em "Ativar"

### Linux

```bash
# Copiar configuração
sudo cp Cliente-1.conf /etc/wireguard/wg0.conf

# Iniciar túnel
sudo wg-quick up wg0

# Verificar status
sudo wg show

# Habilitar na inicialização
sudo systemctl enable wg-quick@wg0
```

### Android/iOS

1. Instale o app WireGuard
2. Toque em "+" → "Criar do arquivo ou arquivo"
3. Selecione o arquivo `Cliente-X.conf`
4. Ative a conexão

**Dica**: Você pode gerar QR codes para facilitar:
```powershell
# No servidor, instale qrencode
# Gere QR code do cliente
qrencode -t ansiutf8 < Cliente-1.conf
```

## 🧪 Testes de Conectividade

### Do Cliente para o Servidor

```powershell
# Ping no IP VPN do servidor
ping 10.0.0.1
```

### Do Servidor para o Cliente

```powershell
# Ping no IP VPN do cliente
ping 10.0.0.2
```

### Verificar Roteamento

```powershell
# No cliente, verificar rota padrão
route print

# Testar acesso à internet através da VPN
curl ifconfig.me
```

## 🔒 Segurança

### Boas Práticas

- ✅ **Mantenha as chaves privadas seguras** - Nunca compartilhe
- ✅ **Use PSK** para camada adicional de segurança
- ✅ **Limite AllowedIPs** - Use apenas as redes necessárias
- ✅ **Firewall configurado** - Permita apenas a porta WireGuard
- ✅ **Backup seguro** - Guarde as configurações em local protegido
- ✅ **Rotação de chaves** - Considere trocar chaves periodicamente

### Compartilhamento de Configurações

⚠️ **NUNCA** envie arquivos `.conf` por:
- Email não criptografado
- Mensagens de texto
- Serviços de compartilhamento públicos

✅ **Use**:
- Transferência presencial (USB)
- Canais criptografados (Signal, WhatsApp)
- Compartilhamento seguro de arquivos (Bitwarden Send, etc.)

## 🐛 Solução de Problemas

### Servidor não inicia

```powershell
# Verificar se a porta está em uso
netstat -ano | findstr :51820

# Verificar logs do WireGuard
Get-Content "C:\Program Files\WireGuard\Data\log.bin"
```

### Cliente não conecta

1. **Verificar firewall** - Porta UDP liberada?
2. **Verificar IP público** - Está correto no cliente?
3. **Verificar chaves** - Pública do servidor está correta?
4. **Testar conectividade** - `Test-NetConnection -ComputerName [IP_SERVIDOR] -Port 51820`

### Sem acesso à internet

```powershell
# No servidor, verificar NAT/roteamento
Get-NetNat
Get-NetIPInterface

# Verificar se o encaminhamento está habilitado
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "IPEnableRouter"
```

### Peer não aparece

```powershell
# Verificar handshake
wg show wg0 latest-handshakes

# Se não houver handshake recente, verificar:
# 1. Chaves públicas corretas em ambos os lados
# 2. Endpoint correto no cliente
# 3. Firewall permitindo tráfego UDP
```

## 📚 Recursos Adicionais

- [Documentação Oficial WireGuard](https://www.wireguard.com/)
- [WireGuard Quick Start](https://www.wireguard.com/quickstart/)
- [WireGuard no Windows](https://www.wireguard.com/install/)
- [Conceitos de Roteamento](https://www.wireguard.com/#conceptual-overview)

## 🔄 Atualizações e Manutenção

### Adicionar Novo Cliente

1. Execute o assistente novamente
2. Ou adicione manualmente no `wg0.conf` do servidor:

```ini
[Peer]
PublicKey = [chave_publica_do_novo_cliente]
AllowedIPs = 10.0.0.X/32
```

3. Recarregue a configuração:
```powershell
# Desativar e reativar o túnel no WireGuard GUI
# Ou via comando:
wg syncconf wg0 <(wg-quick strip wg0)
```

### Remover Cliente

1. Remova a seção `[Peer]` correspondente do `wg0.conf`
2. Recarregue a configuração

### Backup das Configurações

```powershell
# Criar backup
$backupDate = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "C:\Backups\WireGuard-$backupDate"
Copy-Item ".\WireGuard-Configs" -Destination $backupPath -Recurse

# Comprimir backup
Compress-Archive -Path $backupPath -DestinationPath "$backupPath.zip"
```

## 📝 Notas Importantes

- O script requer **permissões de Administrador**
- IPs dos clientes são gerados automaticamente incrementando o último octeto
- Por padrão, `AllowedIPs = 0.0.0.0/0` roteia todo o tráfego pela VPN
- Para rotear apenas tráfego da VPN, altere para `AllowedIPs = 10.0.0.0/24`
- `PersistentKeepalive = 25` mantém a conexão ativa através de NAT

## 🎨 Interface e Design

### Personalização Visual
- **Cores**: Gradiente roxo (#667eea → #764ba2)
- **Framework**: Bootstrap 5.3.8
- **Ícones**: Bootstrap Icons v1.11.0
- **Design**: Responsivo e moderno
- **Animações**: Transições suaves e indicadores animados

### Componentes da Interface
- **Sidebar**: Menu lateral navegável
- **Cards**: Informações organizadas visualmente
- **Tables**: Listas de interfaces e peers
- **Forms**: Configurações com validação
- **Logs**: Terminal estilizado com cores
- **Dashboard**: Métricas em tempo real

## 📊 Monitoramento e Logs

### Sistema de Logs
- **Níveis**: INFO, SUCCESS, WARNING, ERROR
- **Cores**: Azul, verde, laranja, vermelho
- **Timestamp**: Data e hora precisos
- **Auto-scroll**: Sempre no último log
- **Exportação**: Possível exportar logs

### Métricas em Tempo Real
- Status do serviço WireGuard
- Número de interfaces ativas
- Total de peers conectados
- Tráfego de rede (upload/download)
- Atividade recente (últimas 5 ações)

## 🛡️ Segurança

### Melhores Práticas Implementadas
- ✅ Chaves privadas nunca expostas em logs
- ✅ Validação rigorosa de entrada
- ✅ PSK opcional para camada extra de segurança
- ✅ Configurações armazenadas em local seguro
- ✅ Interface executada como Administrador

### Recomendações de Segurança
- Faça backup regular das configurações
- Mantenha o WireGuard atualizado
- Use PSK para ambientes críticos
- Monitore logs regularmente
- Compartilhe configurações por canais seguros

## 🚨 Solução de Problemas

### Problemas Comuns

#### Erro: "Este script precisa ser executado como Administrador"
**Solução**: Execute o PowerShell como Administrador

#### Erro: "WireGuard não encontrado"
**Solução**: Instale o WireGuard no caminho padrão ou verifique o diretório

#### Interface não carrega
**Solução**: Verifique a conexão com internet para Bootstrap CDN

#### Chaves não geram
**Solução**: Verifique permissões do diretório do WireGuard

### Logs de Depuração
```powershell
# Verificar status do serviço
Get-Service -Name "WireGuard"

# Verificar interfaces configuradas
wg show

# Testar conectividade
ping 10.0.0.1
```

## 🔄 Atualizações e Manutenção

### Versão 2.0.0 (Atual)
- ✨ Interface gráfica completa com Bootstrap
- ✨ Dashboard em tempo real
- ✨ Sistema de logs avançado
- ✨ Validação aprimorada
- ✨ Design responsivo
- ✨ Animações e transições
- ✨ Arquitetura SOLID implementada

### Planejado para v2.1.0
- 🔄 Integração com Active Directory
- 🔄 Templates de configuração
- 🔄 Backup automático
- 🔄 Monitoramento avançado

## 📞 Suporte e Comunidade

### Documentação Adicional
- [WireGuard Documentation](https://www.wireguard.com/docs/)
- [Windows Server Networking](https://docs.microsoft.com/en-us/windows-server/networking/)
- [PowerShell Scripting](https://docs.microsoft.com/en-us/powershell/)

### Canais de Suporte
- GitHub Issues para reportar problemas
- Wiki com exemplos e tutoriais
- Fórum para dúvidas e discussões

### Para Problemas Imediatos
1. Verifique a seção de **Solução de Problemas**
2. Consulte o arquivo `RESUMO-E-INSTRUCOES.txt` gerado
3. Revise os logs do WireGuard e do assistente
4. Use o modo console se a interface GUI falhar

## 📝 Notas de Desenvolvimento

### Stack Tecnológico
- **Backend**: PowerShell 5.1+
- **Frontend**: HTML5, CSS3, JavaScript
- **Framework UI**: Bootstrap 5.3.8
- **Ícones**: Bootstrap Icons 1.11.0
- **Arquitetura**: Orientada a Objetos (Classes PowerShell)

### Performance
- Código otimizado para resposta rápida
- Lazy loading de componentes
- Cache de configurações
- Validação client-side e server-side

---

**Versão**: 2.0.0  
**Autor**: Assistente Windsurf  
**Data**: 2025-01-28  
**Framework**: Bootstrap 5.3.8  
**Princípios**: SOLID, Clean Code, DRY, KISS
