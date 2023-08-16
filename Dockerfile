FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-server
WORKDIR /src
COPY ["Server/LoLTimer.Server.csproj", "server/"]
COPY ["Client/LoLTimer.Client.csproj", "client/"]
COPY ["Shared/LoLTimer.Shared.csproj", "shared/"]
RUN dotnet restore "server/LoLTimer.Server.csproj"
COPY . .
WORKDIR /src
RUN dotnet build "server/LoLTimer.Server.csproj" -c Release -o /app/build

FROM build-server AS publish-server
RUN dotnet publish "server/LoLTimer.Server.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish-server /app/publish .
ENTRYPOINT ["dotnet", "LoLTimer.Server.dll"]