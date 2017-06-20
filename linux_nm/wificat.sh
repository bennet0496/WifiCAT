#!/bin/bash

# Wifi Configuration Assist Tool for Linux (Python Payload)
# Copyright (C) 2017 Bennet Becker <bennet@becker-dd.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


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


#Make sure we are running in bash
if test -z "$BASH"
then
    bash $0
    exit 0
fi

if test -n "$(which zenity)"
then
    zenity --title="Wifi Configuration Assistant" --info --text="Welcome to WifiCAT. This will configure the Network $SSID automatically\n\nThe following dialogs will ask for your Credentials to install the Network."
    LOGIN=$(zenity --title="$SSID Login" --forms --text="Your Wifi Login" --add-entry=Username \
    --add-password=Password --separator=$'\n')
    USERN=$(printf "$LOGIN" | head -n 1)
    PASSWORD=$(printf "$LOGIN" | tail -n 1)

    #echo $USERN $PASSWORD
    if test ${USE_CLIENT_CERT} -eq 1
    then
        CLIENTCERT=$(zenity --title="Choose Client Certificate" --file-selection \
        --file-filter="Certificate | *.pem *.crt *.cert *.der" --file-filter="All Files | *.*")
    fi
elif test -n "$(which kdialog)"
then
    kdialog --title="Wifi Configuration Assistant" --msgbox "Welcome to WifiCAT. This will configure the Network $SSID automatically\n\nThe following dialogs will ask for your Credentials to install the Network."

    USERN=$(kdialog --title="$SSID Login" --inputbox "Your Username" ${USER})
    PASSWORD=$(kdialog --title="$SSID Login" --password "Your Password")
    if test ${USE_CLIENT_CERT} -eq 1
    then
        CLIENTCERT=$(kdialog --getopenfilename $HOME "*.pem *.crt *.cert *.der | Certificate files")
    fi
elif test -n "$(which dialog)"
then
    dialog --backtitle "WifiCAT" --title "Wifi Configuration Assistant" \
    --msgbox "Welcome to WifiCAT. This will configure the Network $SSID automatically\n\nThe following dialogs will ask for your Credentials to install the Network." 0 0
    USERN=$(dialog --backtitle "WifiCAT" --title "Login to $SSID" --inputbox "Your Username" 0 0)
    PASSWORD=$(dialog --backtitle "WifiCAT" --title "Login to $SSID" --insecure --passwordbox "Your Password" 0 0)
else
    echo Falling back to readline
    echo  -e "Welcome to WifiCAT. This will configure the Network $SSID automatically\n\nThe following dialogs will ask for your Credentials to install the Network."
    read -p "Username: " USERN
    read -p "Password (not echoed): " -s PASSWORD
fi


NM_VERSION=$(gdbus call --system --dest org.freedesktop.NetworkManager --object-path /org/freedesktop/NetworkManager \
--method org.freedesktop.DBus.Properties.Get "org.freedesktop.NetworkManager" "Version" | grep -Po "(?<=<').*(?='>)")

# Generate WPA Supplicant Config
if test $(echo 0.8$'\n'${NM_VERSION} | sort -Vr | tail -n 1) != 0.8 || ! pgrep -f NetworkManager > /dev/null
then
    if test -n "$(which zenity)"
    then
        if zenity --title="Wifi Configuration Assistant" --question \
        --text="Your NM version is not supported or no NM was found\n\nShould we generate a wpa_supplicant?"
        then
            GENWPASUPP=yes
        fi

    elif test -n "$(which kdialog)"
    then
        if kdialog --title="Wifi Configuration Assistant" \
        --yesno "Your NM version is not supported or no NM was found\n\nShould we generate a wpa_supplicant?"
        then
            GENWPASUPP=yes
        fi
    elif test -n "$(which dialog)"
    then
        if dialog --backtitle "WifiCAT" --title "Wifi Configuration Assistant" \
        --yesno "Your NM version is not supported or no NM was found\n\nShould we generate a wpa_supplicant?" 0 0
        then
            GENWPASUPP=yes
        fi
    else
        echo "Your NM version is not supported or no NM was found" 1>&2
        read -p "Should we generate a wpa_supplicant? [Y/n] " GENWPASUPP
        if test "$GENWPASUPP" != "n" && test "$GENWPASUPP" != "N"
        then
            GENWPASUPP=yes
        fi
    fi
    if test -n "$GENWPASUPP"
    then
        cat <<EOF >> $HOME/.wpa_supplicant.conf
network={
    ssid="${SSID}"
    scan_ssid=1
    key_mgmt=WPA-EAP
    pairwise=CCMP TKIP
    group=CCMP TKIP
    identity="${USERN}"
    password="${PASSWORD}"
    $( test -n "$ANON_ID"               && echo anonymous_identity=\"${ANON_ID}\" )
    $( test -n "$SUBJ_ALT_MATCH"        && echo altsubject_matches=\"${SUBJ_ALT_MATCH}\" )
    $( test -n "$CA_CERT"               && echo ca_cert=\"$HOME/.cat_installer/${SSID}.ca.pem\" )
    $( test -n "$CLIENTCERT"            && echo client_cert=\"${CLIENTCERT}\" )
    $( test -n "$DNS_SUFF_MATCH"        && echo domain_suffix_match=\"${DNS_SUFF_MATCH}\" )
    $( test -n "$EAP_METHOD"            && echo eap=$(echo ${EAP_METHOD} | tr '[a-z]' '[A-Z]') )
    $( test -n "$PHASE2_METHOD_EAP"     && echo phase2=\"autheap=$(echo ${PHASE2_METHOD_EAP} | tr '[a-z]' '[A-Z]')\" )
}
EOF
    fi
    exit 0
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
for conn in ${NM_CONNECTIONS}
do
    conn_info=$(gdbus call --system  --dest org.freedesktop.NetworkManager --object-path ${conn}\
     --method org.freedesktop.NetworkManager.Settings.Connection.GetSettings)
    if test "$(echo ${conn_info} | grep -Po "(?<='type': \<').*?(?='\>)")" = "802-11-wireless"
    then
        conn_ssid=$(echo ${conn_info} | grep -Po "(?<='id': \<').*?(?='\>)")
        if test "${conn_ssid}" = "${SSID}" || test "${conn_ssid}" = "${SSID_TO_DELETE}"
        then
            logger --id=$$ $(gdbus call --system  --dest org.freedesktop.NetworkManager --object-path ${conn}\
                                --method org.freedesktop.NetworkManager.Settings.Connection.Delete || true) || true
            logger --id=$$ "Connection ${conn} deleted!" || true
        fi
    fi
done

# Add new connection
uuid=$(cat /proc/sys/kernel/random/uuid)

#BUG: ca-cert not shown in nm-applet
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


for active_conn in $(gdbus call --system --dest org.freedesktop.NetworkManager --object-path \
                    /org/freedesktop/NetworkManager --method org.freedesktop.DBus.Properties.Get \
                    "org.freedesktop.NetworkManager" "ActiveConnections" | grep -Po "(?<=')[^,].*?(?=')")
do
    conn_type=$(gdbus call --system  --dest org.freedesktop.NetworkManager --object-path ${active_conn} \
                --method org.freedesktop.DBus.Properties.Get "org.freedesktop.NetworkManager.Connection.Active" "Type" \
                | grep -Po "(?<=\<').*?(?='>)")
    conn_id=$(gdbus call --system  --dest org.freedesktop.NetworkManager --object-path ${active_conn} \
                --method org.freedesktop.DBus.Properties.Get "org.freedesktop.NetworkManager.Connection.Active" "Id" \
                | grep -Po "(?<=\<').*?(?='>)")
    conn_dev=$(gdbus call --system  --dest org.freedesktop.NetworkManager --object-path ${active_conn} \
                --method org.freedesktop.DBus.Properties.Get "org.freedesktop.NetworkManager.Connection.Active" "Devices" \
                | grep -Po "(?<=').*?(?=')" | head -n 1)
    if test ${conn_type} = 802-11-wireless && test ${conn_id} = ${SSID_TO_DELETE}
    then
        gdbus call --system --dest org.freedesktop.NetworkManager --object-path \
        /org/freedesktop/NetworkManager --method org.freedesktop.NetworkManager.DeactivateConnection ${active_conn} \
        > /dev/null
        #TODO: Reconnect to configured network
        #SUB TODO: Search AP to connect to
        # gdbus call --system  --dest org.freedesktop.NetworkManager --object-path /org/freedesktop/NetworkManager/Devices/0 --method org.freedesktop.NetworkManager.Device.Wireless.GetAccessPoints
        # echo -e $(gdbus call --system --dest org.freedesktop.NetworkManager --object-path /org/freedesktop/NetworkManager/AccessPoint/1904 --method org.freedesktop.DBus.Properties.Get "org.freedesktop.NetworkManager.AccessPoint" "Ssid" | grep -Po '(?<=\[byte).*(?=\]>)' | sed 's/0x/\\x/g' | tr -d ', ')
        break
    fi
done
