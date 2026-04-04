#!/bin/bash

# =========================
# COLORES
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
CYAN='\033[0;36m'

# =========================
# BANNER
# =========================
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Generador Clean Architecture + Hexagonal + DDD     ║${NC}"
echo -e "${CYAN}║      .NET 10 | Production Ready | NuGet Packages       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# =========================
# FUNCIÓN PARA AGREGAR CARPETAS AL CSPROJ
# =========================

add_folders_to_csproj() {
    local csproj_path=$1
    shift
    local folders=("$@")

    # Validar archivo
    if [ ! -f "$csproj_path" ]; then
        echo "❌ csproj no encontrado: $csproj_path"
        return 1
    fi

    # Crear temp file
    local tmp_file="${csproj_path}.tmp"
    local existing_folders

    # Obtener carpetas existentes
    existing_folders=$(grep -oP '(?<=<Folder Include=")[^"]+' "$csproj_path")

    # Construir nuevas entradas sin duplicados
    local folder_entries=""
    for folder in "${folders[@]}"; do
        if ! echo "$existing_folders" | grep -qx "$folder"; then
            folder_entries="${folder_entries}    <Folder Include=\"${folder}\" />\n"
        fi
    done

    # Si no hay nuevas carpetas, salir
    if [ -z "$folder_entries" ]; then
        echo "ℹ️ No hay nuevas carpetas que agregar"
        return 0
    fi

    # Insertar ItemGroup antes del cierre de Project
    awk -v entries="$folder_entries" '
        BEGIN { inserted=0 }
        /<\/Project>/ && inserted==0 {
            print "  <ItemGroup>"
            printf "%s", entries
            print "  </ItemGroup>"
            inserted=1
        }
        { print }
    ' "$csproj_path" > "$tmp_file" && mv "$tmp_file" "$csproj_path"

    echo "✅ Carpetas agregadas correctamente"
}

# =========================
# INPUT
# =========================

echo ""
echo -e "${GREEN}🚀 Generador de Clean Architecture + Hexagonal + DDD (.NET 10)${NC}"
echo ""
echo "Ingrese el nombre del proyecto (ej: Auth, Sales, Orders):"
read -r -p "Ingrese el nombre del proyecto: " PROJECT_NAME
PROJECT_NAME=$(printf "%s" "$PROJECT_NAME" | tr -d '\r\n' | xargs)
echo "DEBUG: [$PROJECT_NAME]"

if [ -z "$PROJECT_NAME" ]; then
  echo -e "${RED}❌ El nombre del proyecto es obligatorio${NC}"
  exit 1
fi

# Validar caracteres válidos
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z]+$ ]]; then
  echo -e "${RED}❌ Nombre inválido.${NC}"
  exit 1
fi

# evitar sobrescribir
if [ -d "$PROJECT_NAME" ]; then
  echo -e "${RED}❌ El proyecto ya existe${NC}"
  exit 1
fi

echo -e "${GREEN}🚀 Creando arquitectura .NET 10 para $PROJECT_NAME...${NC}"
echo ""

# =========================
# CREAR ROOT DEL PROYECTO
# =========================

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

# Crear solución
dotnet new sln -n $PROJECT_NAME

# =========================
# PROYECTOS (directamente en raíz)
# =========================

echo -e "${BLUE}📦 Creando proyectos .NET 10...${NC}"

dotnet new webapi -n $PROJECT_NAME.Api -f net10.0
dotnet new webapi -n $PROJECT_NAME.Gateway -f net10.0
dotnet new classlib -n $PROJECT_NAME.Application -f net10.0
dotnet new classlib -n $PROJECT_NAME.Domain -f net10.0
dotnet new classlib -n $PROJECT_NAME.Infrastructure -f net10.0

# =========================
# AGREGAR A SOLUCIÓN
# =========================

echo "🔗 Agregando proyectos a la solución..."

dotnet sln add $PROJECT_NAME.Api/$PROJECT_NAME.Api.csproj
dotnet sln add $PROJECT_NAME.Gateway/$PROJECT_NAME.Gateway.csproj
dotnet sln add $PROJECT_NAME.Application/$PROJECT_NAME.Application.csproj
dotnet sln add $PROJECT_NAME.Domain/$PROJECT_NAME.Domain.csproj
dotnet sln add $PROJECT_NAME.Infrastructure/$PROJECT_NAME.Infrastructure.csproj

# =========================
# REFERENCIAS
# =========================

echo "🔗 Configurando referencias entre capas..."
# Api → Application + Infrastructure
dotnet add $PROJECT_NAME.Api reference $PROJECT_NAME.Application
dotnet add $PROJECT_NAME.Api reference $PROJECT_NAME.Infrastructure

# Infrastructure → Application + Domain
dotnet add $PROJECT_NAME.Infrastructure reference $PROJECT_NAME.Application
dotnet add $PROJECT_NAME.Infrastructure reference $PROJECT_NAME.Domain

# Application → Domain
dotnet add $PROJECT_NAME.Application reference $PROJECT_NAME.Domain

# =========================
# DOMAIN
# =========================

echo "📁 Creando estructura - Domain..."

mkdir -p $PROJECT_NAME.Domain/Common/Primitives
mkdir -p $PROJECT_NAME.Domain/Common/Exceptions
mkdir -p $PROJECT_NAME.Domain/Common/Interfaces
mkdir -p $PROJECT_NAME.Domain/Entities
mkdir -p $PROJECT_NAME.Domain/ValueObjects
mkdir -p $PROJECT_NAME.Domain/Aggregates
mkdir -p $PROJECT_NAME.Domain/Enums
mkdir -p $PROJECT_NAME.Domain/Events
mkdir -p $PROJECT_NAME.Domain/Services
mkdir -p $PROJECT_NAME.Domain/Repositories
mkdir -p $PROJECT_NAME.Domain/Specifications

# =========================
# APPLICATION
# =========================

echo "📁 Creando estructura - Application..."

mkdir -p $PROJECT_NAME.Application/Features/Commands
mkdir -p $PROJECT_NAME.Application/Features/Queries
mkdir -p $PROJECT_NAME.Application/Common/Behaviors
mkdir -p $PROJECT_NAME.Application/Common/Interfaces
mkdir -p $PROJECT_NAME.Application/Common/Mappings
mkdir -p $PROJECT_NAME.Application/Common/Exceptions
mkdir -p $PROJECT_NAME.Application/EventHandlers
mkdir -p $PROJECT_NAME.Application/DTOs
mkdir -p $PROJECT_NAME.Application/Validators
mkdir -p $PROJECT_NAME.Application/Extensions

# =========================
# INFRASTRUCTURE
# =========================

echo "📁 Creando estructura - Infrastructure..."

mkdir -p $PROJECT_NAME.Infrastructure/Persistence/Contexts
mkdir -p $PROJECT_NAME.Infrastructure/Persistence/Configurations
mkdir -p $PROJECT_NAME.Infrastructure/Persistence/Repositories
mkdir -p $PROJECT_NAME.Infrastructure/Persistence/Interceptors
mkdir -p $PROJECT_NAME.Infrastructure/Persistence/Migrations
mkdir -p $PROJECT_NAME.Infrastructure/Persistence/Seeds
mkdir -p $PROJECT_NAME.Infrastructure/Services
mkdir -p $PROJECT_NAME.Infrastructure/External
mkdir -p $PROJECT_NAME.Infrastructure/Identity
mkdir -p $PROJECT_NAME.Infrastructure/Caching
mkdir -p $PROJECT_NAME.Infrastructure/Messaging
mkdir -p $PROJECT_NAME.Infrastructure/Logging
mkdir -p $PROJECT_NAME.Infrastructure/Extensions

# =========================
# API
# =========================

echo "📁 Creando estructura - Api..."

mkdir -p $PROJECT_NAME.Api/Controllers
mkdir -p $PROJECT_NAME.Api/Middleware
mkdir -p $PROJECT_NAME.Api/Filters
mkdir -p $PROJECT_NAME.Api/Contracts
mkdir -p $PROJECT_NAME.Api/Configurations
mkdir -p $PROJECT_NAME.Api/Extensions

# =========================
# GATEWAY
# =========================

echo "📁 Creando estructura - Gateway..."

mkdir -p $PROJECT_NAME.Gateway/Middleware
mkdir -p $PROJECT_NAME.Gateway/Configurations
mkdir -p $PROJECT_NAME.Gateway/Routes
mkdir -p $PROJECT_NAME.Gateway/Security
mkdir -p $PROJECT_NAME.Gateway/Transformers
mkdir -p $PROJECT_NAME.Gateway/HealthChecks
mkdir -p $PROJECT_NAME.Gateway/Aggregators
mkdir -p $PROJECT_NAME.Gateway/Services
mkdir -p $PROJECT_NAME.Gateway/Models
mkdir -p $PROJECT_NAME.Gateway/Constants
mkdir -p $PROJECT_NAME.Gateway/Extensions

# =========================
# AGREGAR CARPETAS A CSPROJ
# =========================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  📝 Registrando carpetas en .csproj...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

add_folders_to_csproj "$PROJECT_NAME.Domain/$PROJECT_NAME.Domain.csproj" \
    "Common\\Primitives\\" \
    "Common\\Exceptions\\" \
    "Common\\Interfaces\\" \
    "Entities\\" \
    "ValueObjects\\" \
    "Aggregates\\" \
    "Enums\\" \
    "Events\\" \
    "Services\\" \
    "Repositories\\" \
    "Specifications\\"

add_folders_to_csproj "$PROJECT_NAME.Application/$PROJECT_NAME.Application.csproj" \
    "Features\\Commands\\" \
    "Features\\Queries\\" \
    "Common\\Behaviors\\" \
    "Common\\Interfaces\\" \
    "Common\\Mappings\\" \
    "Common\\Exceptions\\" \
    "EventHandlers\\" \
    "DTOs\\" \
    "Validators\\" \
	"Extensions\\"

add_folders_to_csproj "$PROJECT_NAME.Infrastructure/$PROJECT_NAME.Infrastructure.csproj" \
    "Persistence\\Contexts\\" \
    "Persistence\\Configurations\\" \
    "Persistence\\Repositories\\" \
    "Persistence\\Interceptors\\" \
    "Persistence\\Migrations\\" \
    "Persistence\\Seeds\\" \
    "Services\\" \
    "External\\" \
    "Identity\\" \
    "Caching\\" \
    "Messaging\\" \
    "Logging\\" \
	"Extensions\\"

add_folders_to_csproj "$PROJECT_NAME.Api/$PROJECT_NAME.Api.csproj" \
    "Controllers\\" \
    "Middleware\\" \
    "Filters\\" \
    "Contracts\\" \
    "Configurations\\" \
	"Extensions\\"

add_folders_to_csproj "$PROJECT_NAME.Gateway/$PROJECT_NAME.Gateway.csproj" \
    "Middleware\\" \
    "Configurations\\" \
    "Routes\\" \
    "Security\\" \
    "Transformers\\" \
    "HealthChecks\\" \
    "Aggregators\\" \
    "Services\\" \
    "Models\\" \
    "Constants\\" \
	"Extensions\\"

echo -e "${GREEN}✅ Carpetas registradas en archivos .csproj${NC}"

# =========================
# CREAR CLASES EXTENSIONS POR CAPA
# =========================

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  📝 Generando clases ServicesExtensions...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

# --- Application ServicesExtensions ---
cat > $PROJECT_NAME.Application/Extensions/ApplicationServicesExtensions.cs <<EOF
using Microsoft.Extensions.DependencyInjection;

namespace ${PROJECT_NAME}.Application.Extensions;

public static class ApplicationServicesExtensions
{
    public static IServiceCollection AddApplicationServicesExtensions(this IServiceCollection services)
    {
        return services;
    }
}
EOF

# --- Infrastructure ServicesExtensions ---
cat > $PROJECT_NAME.Infrastructure/Extensions/InfrastructureServicesExtensions.cs <<EOF
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

namespace ${PROJECT_NAME}.Infrastructure.Extensions;

public static class InfrastructureServicesExtensions
{
    public static IServiceCollection AddInfrastructureServicesExtensions(this IServiceCollection services, IConfiguration configuration)
    {
        return services;
    }
}
EOF

# --- Api ServicesExtensions ---
cat > $PROJECT_NAME.Api/Extensions/ApiServicesExtensions.cs <<EOF
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

namespace ${PROJECT_NAME}.Api.Extensions;

public static class ApiServicesExtensions
{
    public static IServiceCollection AddApiServicesExtensions(this IServiceCollection services, IConfiguration configuration)
    {
        return services;
    }
}
EOF

echo -e "${GREEN}✅ Clases ServicesExtensions creadas en cada capa${NC}"

# =========================
# PAQUETES NUGET
# =========================

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  📦 Instalando paquetes NuGet...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""

# =========================
# PAQUETES NUGET - APPLICATION
# =========================
echo -e "${BLUE}📦 Application layer...${NC}"
cd $PROJECT_NAME.Application

dotnet add package Microsoft.Extensions.DependencyInjection.Abstractions

# Logging
dotnet add package Microsoft.Extensions.Logging.Abstractions

echo -e "${GREEN}✅ Application packages installed${NC}"
cd ..

# =========================
# PAQUETES NUGET - INFRASTRUCTURE
# =========================
echo ""
echo -e "${BLUE}📦 Infrastructure layer...${NC}"
cd $PROJECT_NAME.Infrastructure

# Entity Framework Core
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Microsoft.Extensions.DependencyInjection

# JWT
dotnet add package Microsoft.IdentityModel.Tokens
dotnet add package System.IdentityModel.Tokens.Jwt

# Logging
dotnet add package Microsoft.Extensions.Logging.Abstractions

echo -e "${GREEN}✅ Infrastructure packages installed${NC}"
cd ..

# =========================
# PAQUETES NUGET - API
# =========================
echo ""
echo -e "${BLUE}📦 Api layer...${NC}"
cd $PROJECT_NAME.Api

# Swagger
dotnet add package Swashbuckle.AspNetCore

# JWT
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer

# ✅ Serilog 
dotnet add package Serilog
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
dotnet add package Serilog.Enrichers.Environment
dotnet add package Serilog.Enrichers.Thread

echo -e "${GREEN}✅ Api packages installed${NC}"
cd ..

# =========================
# PAQUETES NUGET - GATEWAY
# =========================
echo ""
echo -e "${BLUE}📦 Gateway layer...${NC}"
cd $PROJECT_NAME.Gateway

# YARP
dotnet add package Yarp.ReverseProxy

# JWT
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer

# Serilog
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
dotnet add package Serilog.Enrichers.Environment

echo -e "${GREEN}✅ Gateway packages installed${NC}"
cd ..

# =========================
# CREAR .gitignore
# =========================

echo ""
echo -e "${BLUE}📝 Creando .gitignore...${NC}"

cat > .gitignore << 'EOF'
# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/

# Visual Studio
.vs/
.vscode/
*.suo
*.user
*.userosscache
*.sln.docstates

# Rider
.idea/
*.sln.iml

# User-specific files
*.rsuser

# NuGet
*.nupkg
*.snupkg
packages/
.nuget/

# Test results
[Tt]est[Rr]esult*/
[Bb]uild[Ll]og.*
*.trx

# Database
*.mdf
*.ldf
*.ndf

# Others
*.cache
*.log
*.sqlite
*.db
appsettings.Development.json
appsettings.Local.json
EOF

echo -e "${GREEN}✅ .gitignore creado${NC}"

# =========================
# RESTORE Y BUILD
# =========================

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🔨 Compilando proyecto...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""

dotnet restore
BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
  dotnet build --no-restore
  BUILD_RESULT=$?
fi


# =========================
# OUTPUT FINAL
# =========================

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}   Arquitectura .NET 10 creada correctamente   ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${GREEN}Proyectos creados (net10.0):${NC}"
echo -e "  ${BLUE}✔${NC} $PROJECT_NAME.Domain"
echo -e "  ${BLUE}✔${NC} $PROJECT_NAME.Application"
echo -e "  ${BLUE}✔${NC} $PROJECT_NAME.Infrastructure"
echo -e "  ${BLUE}✔${NC} $PROJECT_NAME.Api"
echo -e "  ${BLUE}✔${NC} $PROJECT_NAME.Gateway"
echo ""

echo -e "${GREEN}Referencias configuradas:${NC}"
echo -e "  ${BLUE}✔${NC} Api → Application + Infrastructure"
echo -e "  ${BLUE}✔${NC} Infrastructure → Application + Domain"
echo -e "  ${BLUE}✔${NC} Application → Domain"
echo -e "  ${BLUE}✔${NC} Gateway (desacoplado)"
echo ""

echo -e "${GREEN}Paquetes instalados:${NC}"
echo -e "  ${BLUE}✔${NC} Infrastructure: EF Core, Serilog, JWT"
echo -e "  ${BLUE}✔${NC} Api: JWT, Swagger, Serilog"
echo -e "  ${BLUE}✔${NC} Gateway: YARP, JWT, Serilog"
echo ""

echo -e "${GREEN}Arquitectura aplicada:${NC}"
echo -e "  ${BLUE}✔${NC} Clean Architecture"
echo -e "  ${BLUE}✔${NC} Hexagonal (Ports & Adapters)"
echo -e "  ${BLUE}✔${NC} Domain-Driven Design (DDD)"
echo -e "  ${BLUE}✔${NC} SOLID + CQRS"
echo ""

if [ $BUILD_RESULT -eq 0 ]; then
  echo -e "${GREEN}✅ Compilación exitosa${NC}"
else
  echo -e "${YELLOW}⚠️  Advertencia: Hubo problemas en la compilación${NC}"
  echo -e "${YELLOW}    Ejecuta 'dotnet build' para ver detalles${NC}"
fi

echo ""
echo -e "${YELLOW}📚 Próximos pasos:${NC}"
echo -e "  ${BLUE}1.${NC} cd $PROJECT_NAME"
echo -e "  ${BLUE}2.${NC} Configurar connection strings en appsettings.json"
echo -e "  ${BLUE}3.${NC} Crear DbContext en Infrastructure/Persistence/Contexts"
echo -e "  ${BLUE}4.${NC} dotnet ef migrations add InitialCreate -p $PROJECT_NAME.Infrastructure -s $PROJECT_NAME.Api"
echo -e "  ${BLUE}5.${NC} Empezar a codear 🚀"
echo ""

echo -e "${CYAN}╔═════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Proyecto $PROJECT_NAME listo para .NET 10      ║${NC}"
echo -e "${CYAN}╚═════════════════════════════════════════════════════╝${NC}"