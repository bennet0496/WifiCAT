#!/bin/bash

SSID=sample-ssid

SSID_TO_DELETE=sample-unsecure-ssid

PAIRWISE=ccmp
GROUP_CIPHER=ccmp
ANON_ID=anonymous
SUBJ_ALT_MATCH=test.example.com
CA_CERT="
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIBJjANBgkqhkiG9w0BAQUFADBxMQswCQYDVQQGEwJERTEc
MBoGA1UEChMTRGV1dHNjaGUgVGVsZWtvbSBBRzEfMB0GA1UECxMWVC1UZWxlU2Vj
IFRydXN0IENlbnRlcjEjMCEGA1UEAxMaRGV1dHNjaGUgVGVsZWtvbSBSb290IENB
IDIwHhcNOTkwNzA5MTIxMTAwWhcNMTkwNzA5MjM1OTAwWjBxMQswCQYDVQQGEwJE
RTEcMBoGA1UEChMTRGV1dHNjaGUgVGVsZWtvbSBBRzEfMB0GA1UECxMWVC1UZWxl
U2VjIFRydXN0IENlbnRlcjEjMCEGA1UEAxMaRGV1dHNjaGUgVGVsZWtvbSBSb290
IENBIDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCrC6M14IspFLEU
ha88EOQ5bzVdSq7d6mGNlUn0b2SjGmBmpKlAIoTZ1KXleJMOaAGtuU1cOs7TuKhC
QN/Po7qCWWqSG6wcmtoIKyUn+WkjR/Hg6yx6m/UTAtB+NHzCnjwAWav12gz1Mjwr
rFDa1sPeg5TKqAyZMg4ISFZbavva4VhYAUlfckE8FQYBjl2tqriTtM2e66foai1S
NNs671x1Udrb8zH57nGYMsRUFUQM+ZtV7a3fGAigo4aKSe5TBY8ZTNXeWHmb0moc
QqvF1afPaA+W5OFhmHZhyJF81j4A4pFQh+GdCuatl9Idxjp9y7zaAzTVjlsB9WoH
txa2bkp/AgMBAAGjQjBAMB0GA1UdDgQWBBQxw3kbuvVT1xfgiXotF2wKsyudMzAP
BgNVHRMECDAGAQH/AgEFMA4GA1UdDwEB/wQEAwIBBjANBgkqhkiG9w0BAQUFAAOC
AQEAlGRZrTlk5ynrE/5aw4sTV8gEJPB0d8Bg42f76Ymmg7+Wgnxu1MM9756Abrsp
tJh6sTtU6zkXR34ajgv8HzFZMQSyzhfzLMdiNlXiItiJVbSYSKpk+tYcNthEeFpa
IzpXl/V6ME+un2pMSyuOoAPjPuCp1NJ70rOo4nI8rZ7/gFnkm0W09juwzTkZmDLl
6iFhkOQxIY40sfcvNUqFENrnijchvllj4PKFiDFT1FQUhXB59C4Gdyd1Lx+4ivn+
xbrYNuSD7Odlt79jWvNGr4GUN9RBjNYj1h7P9WgbRGOiWrqnNVmh5XAFmw4jV5mU
Cm26OWMohpLzGITY+9HPBVZkVw==
-----END CERTIFICATE-----
"
DNS_SUFF_MATCH=sample-ssid.mpipks-dresden.mpg.de

USE_CLIENT_CERT=0

#Valid methods are: "leap", "md5", "tls", "peap", "ttls", "pwd", and "fast"
EAP_METHOD=peap
#NIY
USE_EAP_PIN=0
#"md5", "mschapv2", "otp", "gtc", and "tls"
PHASE2_METHOD_EAP=mschapv2
PHASE2_CA_CERT=
PHASE2_DNS_SUFF_MATCH=
PHASE2_SUBJ_ALT_MATCH=
#NIY
PHASE2_USE_CLINET_CERT=0


#Make sure we are running in bash
if test -z "$BASH"
then
    bash $0
    exit 0
fi

if test -n "$(which zenity)"
then
    LOGIN=$(zenity --title="$SSID Login" --forms --text="Your Wifi Login" --add-entry=Username \
    --add-password=Password --separator=$'\n')
    USERN=$(printf "$LOGIN" | head -n 1)
    PASSWORD=$(printf "$LOGIN" | tail -n 1)

    #echo $USERN $PASSWORD
    if test $USE_CLIENT_CERT -eq 1
    then
        CLIENTCERT=$(zenity --title="Choose Client Certificate" --file-selection \
        --file-filter="Certificate | *.p12 *.pem *.crt *.cert *.der" --file-filter="All Files | *.*")
    fi
elif test -n "$(which kdialog)"
then
    #TODO: Implement kdialog support
    true
elif test -n "$(which xdialog)"
then
    #TODO: Implement xdialog support
    true
elif test -n "$(which dialog)"
then
    #TODO: Implement dialog support
    true
else
    echo Falling back to readline
    read -p "Username: " USERN
    read -p "Password (not echoed): " -s PASSWORD
fi


NM_VERSION=$(gdbus call --system --dest org.freedesktop.NetworkManager --object-path /org/freedesktop/NetworkManager \
--method org.freedesktop.DBus.Properties.Get "org.freedesktop.NetworkManager" "Version" | grep -Po "(?<=<').*(?='>)")

#TODO: jump to wpa_supplicant generation!
test $(echo 0.8$'\n'$NM_VERSION | sort -Vr | tail -n 1) != 0.8

if $? || ! pgrep -f NetworkManager
then
    echo "Your NM version is not supported or no NM was found" 1>&2
    read -p "Should we generate a wpa_supplicant? [Y/n] " GENWPASUPP

fi

# Get Connection Paths from DBus
if test ${NM_VERSION} = 0.8
then
    NM_SETTINGS_OBJ=/org/freedesktop/NetworkManagerSettings
    NM_SETTINGS_INTERFACE=org.freedesktop.NetworkManagerSettings
else
    NM_SETTINGS_OBJ=/org/freedesktop/NetworkManager/Settings
    NM_SETTINGS_INTERFACE=org.freedesktop.NetworkManager.Settings
fi

NM_CONNECTIONS=$(gdbus call --system  --dest org.freedesktop.NetworkManager \
    --object-path ${NM_SETTINGS_OBJ} --method ${NM_SETTINGS_INTERFACE}.ListConnections \
    | grep -Po "(?<=')[^,].*?(?=')")

# Delete existing connection
for conn in $NM_CONNECTIONS
do
    conn_info=$(gdbus call --system  --dest org.freedesktop.NetworkManager --object-path ${conn}\
     --method org.freedesktop.NetworkManager.Settings.Connection.GetSettings)
    if test "$(echo ${conn_info} | grep -Po "(?<='type': \<').*?(?='\>)")" = "802-11-wireless"
    then
        conn_ssid=$(echo ${conn_info} | grep -Po "(?<='id': \<').*?(?='\>)")
        if test ${conn_ssid} = ${SSID} || test ${conn_ssid} = ${SSID_TO_DELETE}
        then
            logger --id=$$ $(gdbus call --system  --dest org.freedesktop.NetworkManager --object-path ${conn}\
                                --method org.freedesktop.NetworkManager.Settings.Connection.Delete || true) || true
            logger --id=$$ "Connection ${conn} deleted!" || true
        fi
    fi
done

# Add new connection
#
uuid=$(cat /proc/sys/kernel/random/uuid)

gdbus call --system --dest org.freedesktop.NetworkManager --object-path ${NM_SETTINGS_OBJ} \
--method ${NM_SETTINGS_INTERFACE}.AddConnection \
    '{
        "connection":{
            "type": <"802-11-wireless">,
            "uuid": <"'$(cat /proc/sys/kernel/random/uuid)'">,
            "permissions": <["user:'${USER}'"]>,
            "id": <"'${SSID}'">
        },
        "802-11-wireless":{
            "ssid": <b"test">,
            "security": <"802-11-wireless-security">
        },
        "802-11-wireless-security":{
            "key-mgmt": <"wpa-eap">,
            "proto": <["rsn"]>,
            "pairwise": <["'${PAIRWISE}'"]>,
            "group": <["'${GROUP_CIPHER}'"]>
        },
        "802-1x": {
            "eap": <["'${EAP_METHOD}'"]>,
            "identity": <"'${USERN}'">,
            "ca-cert": <[byte '$(openssl x509 -in <(echo "$CA_CERT") -inform pem -outform der | hexdump -ve '1/1 "0x%.2x,"'| head -c-1)']>,
            '$(test ${NM_VERSION} = 0.8 && echo '"subject-match":<"'${SUBJ_ALT_MATCH}'">' || \
                                         echo '"altsubject-matches":<["'${SUBJ_ALT_MATCH}'"]>')',
            "password": <"'${PASSWORD}'">,
            "phase2-auth": <"'${PHASE2_METHOD_EAP}'">,
            "anonymous-identity": <"'${ANON_ID}'">
        },
        "ipv4": { "method": <"auto"> },
        "ipv6": { "method": <"auto"> }
    }'