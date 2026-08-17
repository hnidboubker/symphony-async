# TUnit + BDD environment bootstrap for Windows PowerShell

$ErrorActionPreference = "SilentlyContinue"
Write-Host "Installing TUnit BDD test environment..." -ForegroundColor Green

dotnet tool install --global tunit
dotnet restore

Write-Host "BDD environment ready." -ForegroundColor Green
Write-Host "Run: dotnet tunit --test-project <your-test-project>" -ForegroundColor Yellow