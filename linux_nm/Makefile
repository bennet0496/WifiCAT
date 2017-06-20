.PHONY: build

build:
	mkdir -p out || true
	echo '#!/bin/bash' > out/wificat.bin
	echo 'F=$$(mktemp /tmp/wificat.XXXXX.sh)' >> out/wificat.bin
	echo 'tail -n+`grep -anA1 EOF $$0 | tail -n 1 | cut -d- -f1` $$0  | gzip -d > $$F' >> out/wificat.bin
	echo 'chmod +x $$F' >> out/wificat.bin
	echo '/bin/bash $$F' >> out/wificat.bin
	echo 'rm $$F' >> out/wificat.bin
	echo 'exit 0' >> out/wificat.bin
	echo 'EOF' >> out/wificat.bin
	gzip -c wificat.sh >> out/wificat.bin