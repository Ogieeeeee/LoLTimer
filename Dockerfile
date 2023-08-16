FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-server
WORKDIR /src
COPY ["Server/LoLTimer.Server.csproj", "Server/"]
COPY ["Client/LoLTimer.Client.csproj", "Client/"]
COPY ["Shared/LoLTimer.Shared.csproj", "Shared/"]
RUN dotnet restore "./Server/LoLTimer.Server.csproj"
COPY . .
WORKDIR /src
RUN dotnet build "./Server/LoLTimer.Server.csproj" -c Release -o /app/build

FROM build-server AS publish-server
RUN dotnet publish "./Server/LoLTimer.Server.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish-server /app/publish .
ENTRYPOINT ["dotnet", "LoLTimer.Server.dll"]

FROM httpd:2.4
COPY --from=publish-server /app/publish/wwwroot  /usr/local/apache2/htdocs/