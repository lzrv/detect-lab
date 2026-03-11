## Usage

```
docker build -t detect-lab:0.1 .
docker run -v "$(pwd)/env.sh:/opt/blackduck/env.sh" -it detect-lab:0.1 bash
./detect.sh
```

## NPM Detector test

The image includes [Express.js](https://github.com/expressjs/express) as a
sample NPM project in `/opt/scan_targets/express`.

To prepare and scan the NPM target:

```
# Inside the running container
cd /opt/scan_targets/express
npm install
cd /opt/blackduck

# Edit application.properties to point to the express project:
#   detect.source.path=/opt/scan_targets/express
#   detect.tools=DETECTOR

./detect.sh
```
