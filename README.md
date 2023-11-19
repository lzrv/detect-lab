```
docker build -t detect-lab:0.1 .
docker run -v "$(pwd)/env.sh:/opt/synopsys/env.sh" -it detect-lab:0.1 bash
./detect.sh
```
