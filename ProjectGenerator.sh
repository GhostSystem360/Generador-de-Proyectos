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
MAGENTA='\033[0;35m'

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

    # Normalizar rutas (Windows → Unix)
    normalize_path() {
        echo "$1" | sed 's#\\#/#g' | sed 's#//*#/#g'
    }

    # Crear temp file
    local tmp_file="${csproj_path}.tmp"
    local existing_folders

    # Obtener carpetas existentes (normalizadas)
    existing_folders=$(grep -oP '(?<=<Folder Include=")[^"]+' "$csproj_path" | sed 's#\\#/#g')

    # Construir nuevas entradas sin duplicados
    local folder_entries=""
    for folder in "${folders[@]}"; do
        folder=$(normalize_path "$folder")

        # Asegurar slash final (consistencia)
        [[ "$folder" != */ ]] && folder="${folder}/"

        if ! echo "$existing_folders" | grep -qx "$folder"; then
            folder_entries="${folder_entries}    <Folder Include=\"${folder}\" />\n"
        fi
    done

    # Si no hay nuevas carpetas, salir
    if [ -z "$folder_entries" ]; then
        echo "ℹ️ No hay nuevas carpetas que agregar"
        return 0
    fi

    # Insertar ItemGroup antes del cierre de Project (solo una vez)
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
read -r -p "$(echo -e "${CYAN}Nombre del proyecto ➜ ${MAGENTA}")" PROJECT_NAME
echo -e "${NC}"
PROJECT_NAME=$(printf "%s" "$PROJECT_NAME" | tr -d '\r\n' | xargs)

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

dotnet new webapi -n $PROJECT_NAME.Api -f net10.0 --use-controllers
dotnet new webapi -n $PROJECT_NAME.Gateway -f net10.0 --use-controllers
dotnet new classlib -n $PROJECT_NAME.Application -f net10.0
dotnet new classlib -n $PROJECT_NAME.Domain -f net10.0
dotnet new classlib -n $PROJECT_NAME.Infrastructure -f net10.0

echo -e "${GREEN}✅ Proyectos creado .NET 10${NC}"
echo ""
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
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}        🔗 Creando Referencias...              ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

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
# Creando Estructura de Carpetas
# =========================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}        📁 Creando Estructuras...              ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

# =========================
# DOMAIN
# =========================
echo "📁 Creando estructura - Domain..."

mkdir -p $PROJECT_NAME.Domain/Auditing
mkdir -p $PROJECT_NAME.Domain/Security
mkdir -p $PROJECT_NAME.Domain/Primitives
mkdir -p $PROJECT_NAME.Domain/Exceptions
mkdir -p $PROJECT_NAME.Domain/Interfaces
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

mkdir -p $PROJECT_NAME.Application/DTOs
mkdir -p $PROJECT_NAME.Application/Commands
mkdir -p $PROJECT_NAME.Application/Queries
mkdir -p $PROJECT_NAME.Application/Behaviors
mkdir -p $PROJECT_NAME.Application/Interfaces
mkdir -p $PROJECT_NAME.Application/Mappings
mkdir -p $PROJECT_NAME.Application/Exceptions
mkdir -p $PROJECT_NAME.Application/Models
mkdir -p $PROJECT_NAME.Application/EventHandlers
mkdir -p $PROJECT_NAME.Application/Validators
mkdir -p $PROJECT_NAME.Application/Extensions

# =========================
# INFRASTRUCTURE
# =========================

echo "📁 Creando estructura - Infrastructure..."

mkdir -p $PROJECT_NAME.Infrastructure/Repositories
mkdir -p $PROJECT_NAME.Infrastructure/Database/SqlServer/Contexts
mkdir -p $PROJECT_NAME.Infrastructure/Database/SqlServer/Configurations
mkdir -p $PROJECT_NAME.Infrastructure/Database/SqlServer/Migrations
mkdir -p $PROJECT_NAME.Infrastructure/Database/SqlServer/Seeds
mkdir -p $PROJECT_NAME.Infrastructure/Services
mkdir -p $PROJECT_NAME.Infrastructure/Configurations
mkdir -p $PROJECT_NAME.Infrastructure/Models
mkdir -p $PROJECT_NAME.Infrastructure/Providers
mkdir -p $PROJECT_NAME.Infrastructure/Caching
mkdir -p $PROJECT_NAME.Infrastructure/Messaging
mkdir -p $PROJECT_NAME.Infrastructure/Logging
mkdir -p $PROJECT_NAME.Infrastructure/Extensions
mkdir -p $PROJECT_NAME.Infrastructure/Observability
mkdir -p $PROJECT_NAME.Infrastructure/Resilience
mkdir -p $PROJECT_NAME.Infrastructure/BackgroundJobs
mkdir -p $PROJECT_NAME.Infrastructure/Integrations

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
mkdir -p $PROJECT_NAME.Api/Responses
mkdir -p $PROJECT_NAME.Api/Errors
mkdir -p $PROJECT_NAME.Api/HealthChecks

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
mkdir -p $PROJECT_NAME.Gateway/Extensions
mkdir -p $PROJECT_NAME.Gateway/Helpers

# =========================
# AGREGAR CARPETAS A CSPROJ
# =========================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  📝 Registrando carpetas en .csproj...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

add_folders_to_csproj "$PROJECT_NAME.Domain/$PROJECT_NAME.Domain.csproj" \
    "Auditing\\" \
    "Security\\" \
    "Primitives\\" \
    "Exceptions\\" \
    "Interfaces\\" \
    "Entities\\" \
    "ValueObjects\\" \
    "Aggregates\\" \
    "Enums\\" \
    "Events\\" \
    "Services\\" \
    "Repositories\\" \
    "Specifications\\"

add_folders_to_csproj "$PROJECT_NAME.Application/$PROJECT_NAME.Application.csproj" \
    "DTOs\\" \
    "Commands\\" \
    "Queries\\" \
    "Behaviors\\" \
    "Interfaces\\" \
    "Mappings\\" \
    "Exceptions\\" \
    "Models\\" \
    "EventHandlers\\" \
    "Validators\\" \
    "Extensions\\"

add_folders_to_csproj "$PROJECT_NAME.Infrastructure/$PROJECT_NAME.Infrastructure.csproj" \
    "Repositories\\" \
    "Database\\" \
    "Database\\SqlServer\\" \
    "Database\\SqlServer\\Contexts\\" \
    "Database\\SqlServer\\Configurations\\" \
    "Database\\SqlServer\\Migrations\\" \
    "Database\\SqlServer\\Seeds\\" \
    "Configurations\\" \
    "Services\\" \
    "Models\\" \
    "Providers\\" \
    "Caching\\" \
    "Messaging\\" \
    "Logging\\" \
    "Extensions\\" \
    "Observability\\" \
    "Resilience\\" \
    "BackgroundJobs\\" \
    "Integrations\\"

add_folders_to_csproj "$PROJECT_NAME.Api/$PROJECT_NAME.Api.csproj" \
    "Controllers\\" \
    "Middleware\\" \
    "Filters\\" \
    "Contracts\\" \
    "Configurations\\" \
    "Extensions\\" \
    "Responses\\" \
    "Errors\\" \
    "HealthChecks\\"

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
    "Extensions\\" \
    "Helpers\\"

echo -e "${GREEN}✅ Carpetas registradas en archivos .csproj${NC}"

# =========================
# CREAR CLASES EXTENSIONS POR CAPA
# =========================

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  📝 Generando clases ServicesExtensions.......${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

# =========================================
# --- Application ServicesExtensions ---
# =========================================
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

# =========================================
# --- Infrastructure ServicesExtensions ---
# =========================================
cat > $PROJECT_NAME.Infrastructure/Extensions/InfrastructureServicesExtensions.cs <<EOF
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.DependencyInjection;
using ${PROJECT_NAME}.Infrastructure.Configurations;
using ${PROJECT_NAME}.Infrastructure.Services;
using ${PROJECT_NAME}.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Options;
using System.Text;

namespace ${PROJECT_NAME}.Infrastructure.Extensions;

public static class InfrastructureServicesExtensions
{
    public static IServiceCollection AddInfrastructureServicesExtensions(this IServiceCollection services, IConfiguration config)
    {
        services.AddOptions<Jwt>()
                .Bind(config.GetSection(Jwt.SectionName))
                .Validate(jwt => !string.IsNullOrWhiteSpace(jwt.Key), "Jwt:Key is required")
                .Validate(jwt => jwt.Key.Length >= 32, "Jwt:Key must be at least 256 bits")
                .Validate(jwt => !string.IsNullOrWhiteSpace(jwt.Issuer), "Jwt:Issuer is required")
                .Validate(jwt => !string.IsNullOrWhiteSpace(jwt.Audience), "Jwt:Audience is required")
                .ValidateOnStart();
        services.AddScoped<IJwt, JwtService>();
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();
        services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme).Configure<IOptions<Jwt>>((options, jwtOptions) =>
        {
            var jwt = jwtOptions.Value;
            options.RequireHttpsMetadata = true; //Producción debe ir True
            options.SaveToken = false;
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = jwt.ValidateIssuer,
                ValidateAudience = jwt.ValidateAudience,
                ValidateLifetime = jwt.ValidateLifetime,
                ValidateIssuerSigningKey = jwt.ValidateIssuerSigningKey,
                ValidIssuer = jwt.Issuer,
                ValidAudience = jwt.Audience,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Key)),
                ClockSkew = TimeSpan.FromMinutes(jwt.ClockSkewInMinutes)
            };
        });
        services.AddAuthorization();
        return services;
    }
}
EOF

# ==============================
# --- Api ServicesExtensions ---
# ==============================
cat > $PROJECT_NAME.Api/Extensions/ApiServicesExtensions.cs <<EOF
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.OpenApi;
using Serilog.Events;
using Serilog;

namespace ${PROJECT_NAME}.Api.Extensions;

public static class ApiServicesExtensions
{
    public static IServiceCollection AddApiServicesExtensions(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers(options => { var policy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build(); options.Filters.Add(new AuthorizeFilter(policy)); options.SuppressImplicitRequiredAttributeForNonNullableReferenceTypes = true; });
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(options => options.SwaggerDoc("v1", new OpenApiInfo { Title = "${PROJECT_NAME} API", Version = "v1" }));
        return services;
    }

    public static WebApplicationBuilder AddLoggingServicesExtensions(this WebApplicationBuilder builder)
    {
        var basePath = Path.Combine(Directory.GetCurrentDirectory(), "logs");
        Directory.CreateDirectory(basePath);

        Log.Logger = new LoggerConfiguration()
            .ReadFrom.Configuration(builder.Configuration)
            .Enrich.FromLogContext()
            .Enrich.WithMachineName()
            .Enrich.WithEnvironmentName()
            .Enrich.WithThreadId()
            .Enrich.WithProperty("Application", builder.Environment.ApplicationName)
            .Enrich.WithProperty("Environment", builder.Environment.EnvironmentName)
            .MinimumLevel.Information()
            .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
            .MinimumLevel.Override("System", LogEventLevel.Warning)
            .WriteTo.Async(a => a.File(
                Path.Combine(basePath, "log-.txt"),
                rollingInterval: RollingInterval.Day,
                retainedFileCountLimit: 31,
                rollOnFileSizeLimit: true,
                shared: true,
                outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss} [{Level:u3}] {Message:lj} {NewLine}{Exception}")
             .WriteTo.Console();
            .CreateLogger();
        builder.Host.UseSerilog();
        return builder;
    }

    public static WebApplication PipelineServicesExtensions(this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI(options =>
            {
                options.SwaggerEndpoint("/swagger/v1/swagger.json", "${PROJECT_NAME} API v1");
                options.DefaultModelsExpandDepth(-1);
                options.RoutePrefix = string.Empty;
                options.DisplayRequestDuration();
                options.EnableTryItOutByDefault();
                options.DocExpansion(Swashbuckle.AspNetCore.SwaggerUI.DocExpansion.None);
            });
        }

        app.UseHttpsRedirection();
        app.UseAuthentication();
        app.UseAuthorization();
        app.MapControllers();

        return app;
    }
}

EOF

echo -e "${GREEN}✅ Clases ServicesExtensions creadas en cada capa${NC}"


# =========================
# IJWT
# =========================
cat > $PROJECT_NAME.Application/Interfaces/IJwt.cs <<EOF
namespace ${PROJECT_NAME}.Application.Interfaces;

public interface IJwt
{
    string GenerateAccessToken(Guid userId, string email, IEnumerable<string> roles);
    string GenerateRefreshToken();
}
EOF

# =========================
# JWT CONFIG
# =========================
cat > $PROJECT_NAME.Infrastructure/Configurations/Jwt.cs <<EOF
using System.ComponentModel.DataAnnotations;

namespace ${PROJECT_NAME}.Infrastructure.Configurations;

public sealed class Jwt
{
    public const string SectionName = "Jwt";

    [Required(ErrorMessage = "Jwt:Key es requerida")]
    [MinLength(32, ErrorMessage = "Jwt:Key debe tener al menos 32 caracteres")]
    public string Key { get; init; } = string.Empty;

    [Required(ErrorMessage = "Jwt:Issuer es requerido")]
    public string Issuer { get; init; } = string.Empty;

    [Required(ErrorMessage = "Jwt:Audience es requerido")]
    public string Audience { get; init; } = string.Empty;

    public bool ValidateIssuer { get; init; } = true;
    public bool ValidateAudience { get; init; } = true;
    public bool ValidateLifetime { get; init; } = true;
    public bool ValidateIssuerSigningKey { get; init; } = true;

    [Range(0, 60, ErrorMessage = "Jwt:ClockSkewInMinutes debe estar entre 0 y 60")]
    public int ClockSkewInMinutes { get; init; } = 0;

    [Range(1, 1440, ErrorMessage = "Jwt:AccessTokenExpirationMinutes debe estar entre 1 y 1440")]
    public int AccessTokenExpirationMinutes { get; init; } = 15;

    [Range(1, 365, ErrorMessage = "Jwt:RefreshTokenExpirationDays debe estar entre 1 y 365")]
    public int RefreshTokenExpirationDays { get; init; } = 7;
}
EOF

# =========================
# JWT SERVICE
# =========================
cat > $PROJECT_NAME.Infrastructure/Services/JwtService.cs <<EOF
using ${PROJECT_NAME}.Infrastructure.Configurations;
using ${PROJECT_NAME}.Application.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Options;
using System.Security.Cryptography;
using System.Security.Claims;
using System.Text;

namespace ${PROJECT_NAME}.Infrastructure.Services;

public sealed class JwtService : IJwt
{
    private readonly Jwt _config;

    public JwtService(IOptionsSnapshot<Jwt> options)
    {
        _config = options.Value;
    }

    public string GenerateAccessToken(Guid userId, string email, IEnumerable<string> roles)
    {
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(JwtRegisteredClaimNames.Email, email)
        };

        claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config.Key));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _config.Issuer,
            audience: _config.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_config.AccessTokenExpirationMinutes),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public string GenerateRefreshToken()
    {
        var bytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(bytes);
        return Convert.ToBase64String(bytes);
    }
}
EOF

# =========================
# REFRESH TOKEN MODEL
# =========================
cat > $PROJECT_NAME.Infrastructure/Models/RefreshToken.cs <<EOF
namespace ${PROJECT_NAME}.Infrastructure.Models;

public sealed class RefreshToken
{
    public string Token { get; set; } = string.Empty;
    public Guid UserId { get; set; }
    public DateTime Expiration { get; set; }
}
EOF


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
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
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
# LIMPIEZA ARCHIVOS .HTTP
# =========================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🧹 Eliminando archivos .http innecesarios...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

find $PROJECT_NAME.Api -type f -name "*.http" -delete
find $PROJECT_NAME.Gateway -type f -name "*.http" -delete

echo "✅ Archivos .http eliminados"

# =========================
# VALIDAR PUERTO LIBRE
# =========================
is_port_free() {
    ! lsof -i :$1 >/dev/null 2>&1
}

# =========================
# GENERAR PUERTO LIBRE
# =========================

generate_free_port() {
    local port
    local attempts=0

    while [ $attempts -lt 50 ]; do
        port=$(shuf -i 7000-7999 -n 1)

        if is_port_free "$port"; then
            echo "$port"
            return
        fi

        attempts=$((attempts + 1))
    done

    echo "❌ No se pudo encontrar puerto libre" >&2
    exit 1
}

# =============================
# GENERAR PUERTOS HTTPS LIBRES
# =============================

API_PORT=$(generate_free_port)

# Garantizar que Gateway sea diferente y libre
while true; do
    GATEWAY_PORT=$(generate_free_port)
    [ "$GATEWAY_PORT" -ne "$API_PORT" ] && break
done

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🌐 Api HTTPS Port: $API_PORT                ${NC}"
echo -e "${CYAN}  🌐 Gateway HTTPS Port: $GATEWAY_PORT        ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

# =========================
# REEMPLAZAR launchSettings.json - API
# =========================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🧹 Reemplazando launchSettings.json en Api...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

cat > $PROJECT_NAME.Api/Properties/launchSettings.json <<EOF
{
  "\$schema": "https://json.schemastore.org/launchsettings.json",
  "profiles": {
    "https": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "https://localhost:${API_PORT}",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
EOF

echo "✅ launchSettings.json actualizado en Api"

# =========================
# REEMPLAZAR launchSettings.json - GATEWAY (opcional recomendado)
# =========================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🧹 Reemplazando launchSettings.json en Gateway...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo "🧹 Reemplazando launchSettings.json en Gateway..."

cat > $PROJECT_NAME.Gateway/Properties/launchSettings.json <<EOF
{
  "\$schema": "https://json.schemastore.org/launchsettings.json",
  "profiles": {
    "https": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "https://localhost:${GATEWAY_PORT}",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
EOF

echo "✅ launchSettings.json actualizado en Gateway"

# =========================
# OBTENER HOSTNAME
# =========================
HOST_NAME=$(hostname 2>/dev/null)

if [ -z "$HOST_NAME" ]; then
    HOST_NAME="localhost"
fi

echo "🖥️ Hostname detectado: $HOST_NAME"

# =========================
# DETECTAR INSTANCIA SQL SERVER
# =========================

detect_sql_instance() {
    reg_output=$(reg query "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" 2>/dev/null)

   if [ -z "$reg_output" ]; then
        echo ""
        return
    fi

    instance=$(echo "$reg_output" | awk '/REG_SZ/ {print $1}' | head -n 1)
    echo "$instance"
}

SQL_INSTANCE=$(detect_sql_instance)
echo "🧠 SQL Instance detectada: $SQL_INSTANCE"
echo ""

# =========================
# CONSTRUIR SERVER
# =========================
if [ "$SQL_INSTANCE" = "MSSQLSERVER" ] || [ -z "$SQL_INSTANCE" ]; then
    DB_SERVER="localhost"
else
    DB_SERVER="${HOST_NAME}\\${SQL_INSTANCE}"
fi

# Fallback seguro
if [ -z "$DB_SERVER" ]; then
    DB_SERVER="localhost\\SQLEXPRESS"
fi

echo "🗄️ SQL Server (raw): $DB_SERVER"
echo ""

# =========================
# 🔥 FIX CRÍTICO (JSON ESCAPE)
# =========================

DB_SERVER=$(printf '%s' "$DB_SERVER" | sed 's/\\/\\\\/g')

echo "🗄️ SQL Server (escaped): $DB_SERVER"
echo ""

# =========================
# GENERAR JWT KEY SEGURA
# =========================
JWT_KEY=$(openssl rand 64 | openssl base64 | tr -d '\r\n')
echo "\"Key\": \"$JWT_KEY\""

echo "🔐 JWT Key generada"
echo ""

# =========================
# REEMPLAZAR appsettings.json - API
# =========================

echo "🧹 Reemplazando appsettings.json en Api..."

cat > $PROJECT_NAME.Api/appsettings.json <<EOF
{
  "ConnectionStrings": {
    "SqlServer": "Server=${DB_SERVER};Database=${PROJECT_NAME};User Id=sa;Password=0930929104;MultipleActiveResultSets=True;TrustServerCertificate=True;Encrypt=True;"
  },
  "Cors": {
    "AllowedOrigins": [
      "https://localhost:3000"
    ]
  },
  "Jwt": {
    "Key": "${JWT_KEY}",
    "Issuer": "${PROJECT_NAME}",
    "Audience": "${PROJECT_NAME}",
    "ValidateIssuer": true,
    "ValidateAudience": true,
    "ValidateLifetime": true,
    "ValidateIssuerSigningKey": true,
    "ClockSkewInMinutes": 0,
    "AccessTokenExpirationMinutes": 15,
    "RefreshTokenExpirationDays": 7
  },
   "Serilog": {
    "Using": [ "Serilog.Sinks.Console", "Serilog.Sinks.File" ],
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Information",
        "Microsoft.AspNetCore": "Warning"
      }
    },
    "WriteTo": [
      {
        "Name": "Console"
      },
      {
        "Name": "File",
        "Args": {
          "path": "logs/log-.json",
          "rollingInterval": "Day",
          "formatter": "Serilog.Formatting.Json.JsonFormatter",
          "retainedFileCountLimit": 30,
          "fileSizeLimitBytes": 100000000
        }
      }
    ],
    "Enrich": [ "FromLogContext", "WithMachineName" ],
    "Properties": {
      "Application": "${PROJECT_NAME}"
    }
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
EOF

echo "✅ appsettings.json actualizado en Api"

# =========================
# REEMPLAZAR PROGRAM.CS - API
# =========================

echo "🧹 Reemplazando Program.cs en Api..."

cat > $PROJECT_NAME.Api/Program.cs <<EOF
using ${PROJECT_NAME}.Api.Extensions;
using ${PROJECT_NAME}.Application.Extensions;
using ${PROJECT_NAME}.Infrastructure.Extensions;
using Serilog;

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.AddLoggingServicesExtensions();

    Log.Information("\U0001F680 Starting application ${PROJECT_NAME} API...");

    builder.Services.AddApiServicesExtensions(builder.Configuration);
    builder.Services.AddApplicationServicesExtensions();
    builder.Services.AddInfrastructureServicesExtensions(builder.Configuration);

    var app = builder.Build();

    app.PipelineServicesExtensions();

    await app.RunAsync();
}
catch (Exception ex) when (ex is not OperationCanceledException)
{
    Log.Fatal("La aplicacion fallo durante el arranque. Revisa el error registrado previamente.");
    Log.Debug(ex, "Detalle tecnico completo del error de arranque");
    throw;
}
finally
{
    await Log.CloseAndFlushAsync();
}
EOF

echo "✅ Program.cs actualizado en Api"

# =========================
# LIMPIEZA DEPENDENCIAS (SAFE)
# =========================

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}   🧹 Eliminando dependencias innecesarias... ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

remove_package_if_exists() {
    local project_path=$1
    local package_name=$2

    if [ ! -d "$project_path" ]; then
        echo "⚠️ Carpeta no existe: $project_path"
        return
    fi

    cd "$project_path" || return

    if dotnet list package | grep -q "$package_name"; then
        dotnet remove package "$package_name"
        echo "✅ Eliminado $package_name en $project_path"
    else
        echo "ℹ️ $package_name no está instalado en $project_path"
    fi

    cd - > /dev/null || return
}

# Ejecutar limpieza
remove_package_if_exists "${PROJECT_NAME}.Api" "Microsoft.AspNetCore.OpenApi"
#remove_package_if_exists "${PROJECT_NAME}.Gateway" "Microsoft.AspNetCore.OpenApi"

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