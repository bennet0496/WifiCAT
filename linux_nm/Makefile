.PHONY: build

build:
	mkdir -p out || true
	echo '#!/bin/bash' > out/wificat.bin
	echo 'F=$$(mktemp /tmp/wificat.XXXXX.sh)' >> out/wificat.bin
	echo 'C=$$(mktemp /tmp/config.XXXXX)' >> out/wificat.bin
	echo 'tail -n+`grep -anA1 ATTACHMENT1 $$0 | tail -n 1 | cut -d- -f1` $$0 | head -n+$$[`grep -n ATTACHMENT2 $$0 | cut -d: -f1 | tail -n 1`-`grep -n ATTACHMENT1 $$0 | cut -d: -f1 | tail -n 1`-1] | base64 -d | gzip -d > $$F' >> out/wificat.bin
	echo 'tail -n+`grep -anA1 ATTACHMENT2 $$0 | tail -n 1 | cut -d- -f1` $$0 | base64 -d | gzip -d > $$C' >> out/wificat.bin
	echo 'sed -i "s|source config|source $$C|g" $$F' >> out/wificat.bin
	echo 'chmod +x $$F' >> out/wificat.bin
	echo '/bin/bash $$F' >> out/wificat.bin
	echo 'rm $$F $$C' >> out/wificat.bin
	echo 'exit 0' >> out/wificat.bin
	echo 'EOF' >> out/wificat.bin
	echo 'ATTACHMENT1' >> out/wificat.bin
	gzip -c wificat.sh | base64 >> out/wificat.bin
	echo 'ATTACHMENT2' >> out/wificat.bin
	gzip -c config | base64 >> out/wificat.bin
