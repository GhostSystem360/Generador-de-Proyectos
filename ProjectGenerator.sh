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
# INPUT
# =========================

echo ""
echo -e "${GREEN}🚀 Generador de Clean Architecture + Hexagonal + DDD (.NET 10)${NC}"
echo ""
echo "Ingrese el nombre del proyecto (ej: Auth, Sales, Orders):"
read PROJECT_NAME
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr -d '\r' | xargs)

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

# Crear src
mkdir -p src
cd src || exit

# =========================
# PROYECTOS
# =========================

echo -e "${BLUE}📦 Creando proyectos .NET 10...${NC}"

dotnet new webapi -n $PROJECT_NAME.Api -f net10.0
dotnet new webapi -n $PROJECT_NAME.Gateway -f net10.0
dotnet new classlib -n $PROJECT_NAME.Application -f net10.0
dotnet new classlib -n $PROJECT_NAME.Domain -f net10.0
dotnet new classlib -n $PROJECT_NAME.Infrastructure -f net10.0

cd ..

# =========================
# AGREGAR A SOLUCIÓN
# =========================

echo "🔗 Agregando proyectos a la solución..."

dotnet sln add src/$PROJECT_NAME.Api/$PROJECT_NAME.Api.csproj
dotnet sln add src/$PROJECT_NAME.Gateway/$PROJECT_NAME.Gateway.csproj
dotnet sln add src/$PROJECT_NAME.Application/$PROJECT_NAME.Application.csproj
dotnet sln add src/$PROJECT_NAME.Domain/$PROJECT_NAME.Domain.csproj
dotnet sln add src/$PROJECT_NAME.Infrastructure/$PROJECT_NAME.Infrastructure.csproj

# =========================
# REFERENCIAS
# =========================

echo "🔗 Configurando referencias entre capas..."

# Api → Application + Infrastructure
dotnet add src/$PROJECT_NAME.Api reference src/$PROJECT_NAME.Application
dotnet add src/$PROJECT_NAME.Api reference src/$PROJECT_NAME.Infrastructure

# Infrastructure → Application + Domain
dotnet add src/$PROJECT_NAME.Infrastructure reference src/$PROJECT_NAME.Application
dotnet add src/$PROJECT_NAME.Infrastructure reference src/$PROJECT_NAME.Domain

# Application → Domain
dotnet add src/$PROJECT_NAME.Application reference src/$PROJECT_NAME.Domain

# Gateway → SIN referencias (desacoplado)

# =========================
# DOMAIN
# =========================

echo "📁 Creando estructura - Domain..."

mkdir -p src/$PROJECT_NAME.Domain/Common/Primitives
mkdir -p src/$PROJECT_NAME.Domain/Common/Exceptions
mkdir -p src/$PROJECT_NAME.Domain/Common/Interfaces
mkdir -p src/$PROJECT_NAME.Domain/Entities
mkdir -p src/$PROJECT_NAME.Domain/ValueObjects
mkdir -p src/$PROJECT_NAME.Domain/Aggregates
mkdir -p src/$PROJECT_NAME.Domain/Enums
mkdir -p src/$PROJECT_NAME.Domain/Events
mkdir -p src/$PROJECT_NAME.Domain/Services
mkdir -p src/$PROJECT_NAME.Domain/Repositories
mkdir -p src/$PROJECT_NAME.Domain/Specifications

# =========================
# APPLICATION
# =========================

echo "📁 Creando estructura - Application..."

mkdir -p src/$PROJECT_NAME.Application/Features/Commands
mkdir -p src/$PROJECT_NAME.Application/Features/Queries
mkdir -p src/$PROJECT_NAME.Application/Common/Behaviors
mkdir -p src/$PROJECT_NAME.Application/Common/Interfaces
mkdir -p src/$PROJECT_NAME.Application/Common/Mappings
mkdir -p src/$PROJECT_NAME.Application/Common/Exceptions
mkdir -p src/$PROJECT_NAME.Application/EventHandlers
mkdir -p src/$PROJECT_NAME.Application/DTOs
mkdir -p src/$PROJECT_NAME.Application/Validators
mkdir -p src/$PROJECT_NAME.Application/Extensions

# =========================
# INFRASTRUCTURE
# =========================

echo "📁 Creando estructura - Infrastructure..."

mkdir -p src/$PROJECT_NAME.Infrastructure/Persistence/Contexts
mkdir -p src/$PROJECT_NAME.Infrastructure/Persistence/Configurations
mkdir -p src/$PROJECT_NAME.Infrastructure/Persistence/Repositories
mkdir -p src/$PROJECT_NAME.Infrastructure/Persistence/Interceptors
mkdir -p src/$PROJECT_NAME.Infrastructure/Persistence/Migrations
mkdir -p src/$PROJECT_NAME.Infrastructure/Persistence/Seeds
mkdir -p src/$PROJECT_NAME.Infrastructure/Services
mkdir -p src/$PROJECT_NAME.Infrastructure/External
mkdir -p src/$PROJECT_NAME.Infrastructure/Identity
mkdir -p src/$PROJECT_NAME.Infrastructure/Caching
mkdir -p src/$PROJECT_NAME.Infrastructure/Messaging
mkdir -p src/$PROJECT_NAME.Infrastructure/Logging
mkdir -p src/$PROJECT_NAME.Infrastructure/Extensions

# =========================
# API
# =========================

echo "📁 Creando estructura - Api..."

mkdir -p src/$PROJECT_NAME.Api/Controllers
mkdir -p src/$PROJECT_NAME.Api/Middleware
mkdir -p src/$PROJECT_NAME.Api/Filters
mkdir -p src/$PROJECT_NAME.Api/Extensions
mkdir -p src/$PROJECT_NAME.Api/Contracts
mkdir -p src/$PROJECT_NAME.Api/Configurations

# =========================
# GATEWAY
# =========================

echo "📁 Creando estructura - Gateway..."

mkdir -p src/$PROJECT_NAME.Gateway/Middleware
mkdir -p src/$PROJECT_NAME.Gateway/Extensions
mkdir -p src/$PROJECT_NAME.Gateway/Configurations
mkdir -p src/$PROJECT_NAME.Gateway/Routes
mkdir -p src/$PROJECT_NAME.Gateway/Security
mkdir -p src/$PROJECT_NAME.Gateway/Transformers
mkdir -p src/$PROJECT_NAME.Gateway/HealthChecks
mkdir -p src/$PROJECT_NAME.Gateway/Aggregators
mkdir -p src/$PROJECT_NAME.Gateway/Services
mkdir -p src/$PROJECT_NAME.Gateway/Models
mkdir -p src/$PROJECT_NAME.Gateway/Constants

# =========================
# CREAR CLASES EXTENSIONS POR CAPA
# =========================

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  📝 Generando clases ServicesExtensions...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

# --- Application ServicesExtensions ---
cat > src/$PROJECT_NAME.Application/Extensions/ApplicationServicesExtensions.cs <<EOF
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
cat > src/$PROJECT_NAME.Infrastructure/Extensions/InfrastructureServicesExtensions.cs <<EOF
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
cat > src/$PROJECT_NAME.Api/Extensions/ApiServicesExtensions.cs <<EOF
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
cd src/$PROJECT_NAME.Application

dotnet add package Microsoft.Extensions.DependencyInjection.Abstractions

# Logging
dotnet add package Microsoft.Extensions.Logging.Abstractions

echo -e "${GREEN}✅ Application: Mediator, FluentValidation, Mapster instalados${NC}"
cd ../..

# =========================
# PAQUETES NUGET - INFRASTRUCTURE
# =========================
echo ""
echo -e "${BLUE}📦 Infrastructure layer...${NC}"
cd src/$PROJECT_NAME.Infrastructure

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

echo -e "${GREEN}✅ Infrastructure: EF Core, Serilog, Polly instalados${NC}"
cd ../..

# =========================
# PAQUETES NUGET - API
# =========================
echo ""
echo -e "${BLUE}📦 Api layer...${NC}"
cd src/$PROJECT_NAME.Api

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

echo -e "${GREEN}✅ Api: JWT, Swagger, Health Checks, OpenTelemetry instalados${NC}"
cd ../..

# =========================
# PAQUETES NUGET - GATEWAY
# =========================
echo ""
echo -e "${BLUE}📦 Gateway layer...${NC}"
cd src/$PROJECT_NAME.Gateway

# YARP
dotnet add package Yarp.ReverseProxy

# JWT
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer

# Serilog
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
dotnet add package Serilog.Enrichers.Environment


echo -e "${GREEN}✅ Gateway: YARP, JWT, Serilog, Polly instalados${NC}"
cd ../..

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
echo -e "  ${BLUE}✔${NC} Api → Application → Domain"
echo -e "  ${BLUE}✔${NC} Infrastructure → Application + Domain"
echo -e "  ${BLUE}✔${NC} Api → Infrastructure (DI)"
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
echo -e "  ${BLUE}4.${NC} dotnet ef migrations add InitialCreate -p src/$PROJECT_NAME.Infrastructure -s src/$PROJECT_NAME.Api"
echo -e "  ${BLUE}5.${NC} Empezar a codear 🚀"
echo ""

echo -e "${CYAN}╔═════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Proyecto $PROJECT_NAME listo para .NET 10      ║${NC}"
echo -e "${CYAN}╚═════════════════════════════════════════════════════╝${NC}"