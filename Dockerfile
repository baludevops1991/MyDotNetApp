# ============================================================
# Build Stage
# ============================================================

# Use the official .NET 10 SDK image.
# This image contains the .NET SDK required to restore,
# build, and publish the application.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

# Set the working directory inside the container.
WORKDIR /src

# Copy the entire application source code into the container.
COPY . .

# Restore all NuGet dependencies required by the project.
RUN dotnet restore "MyDotNetApp.csproj"

# Build and publish the application in Release mode.
# The published files are placed in /app/publish.
RUN dotnet publish "MyDotNetApp.csproj" \
    -c Release \
    -o /app/publish \
    --no-restore


# ============================================================
# Runtime Stage
# ============================================================

# Use the smaller ASP.NET Core runtime image.
# The SDK is not required at runtime, so this keeps the
# final Docker image smaller.
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

# Set the application's working directory.
WORKDIR /app

# Copy only the published application from the build stage.
# This prevents source code and SDK files from being included
# in the final image.
COPY --from=build /app/publish .

# Document that the application listens on port 8080.
EXPOSE 8080

# Configure ASP.NET Core to listen on port 8080.
ENV ASPNETCORE_HTTP_PORTS=8080

# Start the ASP.NET Core application when the container starts.
ENTRYPOINT ["dotnet", "MyDotNetApp.dll"]