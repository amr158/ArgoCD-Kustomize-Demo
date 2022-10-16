FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine as build
WORKDIR /app
COPY application/. .
RUN dotnet restore
RUN dotnet publish -o /app/published-app

FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine as runtime
WORKDIR /app
COPY --from=build /app/published-app /app
ENV COMPlus_EnableDiagnostics=0
RUN adduser -u 11000 -D user1
RUN chown user1:user1 /app
ENV ASPNETCORE_URLS=http://*:8080
EXPOSE 8080
USER 11000
ENTRYPOINT [ "dotnet", "/app/web-api.dll" ]