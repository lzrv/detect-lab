```
docker build -t detect-lab:0.1 .
docker run -v "$(pwd)/secrets.sh:/opt/synopsys/secrets.sh" -it detect-lab:0.1 bash
./detect.sh
```
