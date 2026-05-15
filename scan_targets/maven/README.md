# Maven Scan Target: spring-projects/spring-petclinic

**Repo:** https://github.com/spring-projects/spring-petclinic
**Cloned to:** /opt/scan_targets/maven/spring-petclinic

## Why this project

Spring PetClinic is the official Spring Boot sample application. It uses a single `pom.xml`
with a standard Maven project structure and a well-known, moderate-sized dependency tree.
Maven is already available in the container (`/usr/bin/mvn`), so the Maven CLI detector
will resolve the full dependency graph without any extra setup.

## Pre-scan steps

No setup required. Detect's Maven CLI detector invokes `mvn dependency:tree` internally.
Maven will download dependencies to the local repository on first run (internet access
needed, or pre-warm with `mvn dependency:go-offline`).

To pre-warm the local Maven repo (optional, speeds up scan):

```
cd /opt/scan_targets/maven/spring-petclinic
mvn -q dependency:go-offline
```

## Recommended scan.sh invocation

```
scan.sh --maven
```

Detect project name: `maven-detect-11.4.2-test`
Detectors: Maven CLI
Search depth: 2 (default)
