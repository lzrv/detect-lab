# NuGet Scan Target: dotnet-architecture/eShopOnWeb

**Repo:** https://github.com/dotnet-architecture/eShopOnWeb
**Cloned to:** /opt/scan_targets/nuget/eShopOnWeb

## Why this project

eShopOnWeb is Microsoft's official reference ASP.NET Core application. It has a `.sln` file
and multiple `.csproj` files with NuGet `PackageReference` entries. It exercises both the
NuGet Solution Native Inspector (parses `.sln`) and the NuGet Project Native Inspector
(parses `.csproj`). The dotnet SDK 9.0 is installed in the container.

## Pre-scan steps

Detect resolves NuGet packages by calling `dotnet restore`. This requires internet access
(NuGet.org) on first run. Restore is often invoked automatically, but you can pre-warm:

```
cd /opt/scan_targets/nuget/eShopOnWeb
dotnet restore --quiet
```

> Note: The solution is reached at `--detect.detector.search.depth=2` (default). If Detect
> does not find the `.sln`, verify the path inside the cloned repo and adjust search depth.

## Recommended scan.sh invocation

```
scan.sh --nuget
```

Detect project name: `nuget-detect-11.4.2-test`
Detectors: NuGet Solution Native Inspector, NuGet Project Native Inspector
Search depth: 2 (default)
