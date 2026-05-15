# Bitbake Scan Target: (stub — no clone)

**Repo:** N/A — no scan target is cloned for Bitbake
**Cloned to:** (nothing)

## Why no target is cloned

The Bitbake detector requires a complete Yocto Project build environment: a `bitbake`
binary, a `bblayers.conf`, `local.conf`, and the full OE-Core layer checked out alongside
the project layers. Replicating this inside a general-purpose Docker container would add
many gigabytes of layer checkouts and a fragile build system bootstrap that is not
representative of real usage.

## How to use Bitbake detection in practice

1. Build your Yocto environment externally (e.g. on a dedicated build host or VM running
   an OE-compatible distribution such as Ubuntu 22.04).
2. Source the Yocto build environment: `source oe-init-build-env build`
3. Run Detect against the build directory from within the sourced shell:

```
java -jar /opt/blackduck/detect-11.4.2.jar \
  --blackduck.url="$BLACKDUCK_URL" \
  --blackduck.api.token="$BLACKDUCK_API_TOKEN" \
  --detect.project.name="bitbake-detect-11.4.2-test" \
  --detect.tools=DETECTOR \
  --detect.detector.search.depth=2 \
  --detect.detector.search.continue=true \
  --detect.source.path=/path/to/your/yocto/build
```

## Reference

- Detect Bitbake detector docs: https://documentation.blackduck.com/bundle/detect/page/packagemgrs/bitbake.html
- Yocto Project quick start: https://docs.yoctoproject.org/brief-yoctoprojectqs/
