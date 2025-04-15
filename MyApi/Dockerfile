# Base runtime image (ASP.NET 8)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
# USER $APP_UID  # Removed for compatibility with Jenkins build
USER root
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Build image with SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"
COPY . .
WORKDIR "/src/MyApi"
RUN dotnet build "MyApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the app
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "MyApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyApi.dll"]
