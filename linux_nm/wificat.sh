#!/bin/bash -x

SSID=sample-ssid
ANON_ID=anonymous
SUBJ_ALT_MATCH=
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

USE_CLIENT_CERT=1

#Valid methods are: "leap", "md5", "tls", "peap", "ttls", "pwd", and "fast"
EAP_METHOD=peap
#NIY
USE_EAP_PIN=0
#"pap", "chap", "mschap", "mschapv2", "gtc", "otp", "md5", and "tls"
PHASE2_METHOD_NONEAP=
#"md5", "mschapv2", "otp", "gtc", and "tls"
PHASE2_METHOD_EAP=mschapv2
PHASE2_CA_CERT=
PHASE2_DNS_SUFF_MATCH=
PHASE2_SUBJ_ALT_MATCH=
#NIY
PHASE2_USE_CLINET_CERT=0


if test -n "$(which zenity)"
then
    LOGIN=$(zenity --title="$SSID Login" --forms --text="Your Wifi Login" --add-entry=Username --add-password=Password --separator=°)
    if test $USE_CLIENT_CERT -eq 1
    then
        CLIENTCERT=$(zenity --title="Choose Client Certificate" --file-selection --file-filter="Certificate | *.p12 *.pem *.crt *.cert *.der" --file-filter="All Files | *.*")
    fi
else
    echo Falling back to readline
    echo "Username: "
    read -n USERN
    echo "Password (not echoed): "
    read -s PASSWORD
    LOGIN=${USERN}°${PASSWORD}
fi

if test -n "$(which nmcli)"
then
    nmcli con add type wifi con-name $SSID ifname wlp4s0 ssid $SSID
    mkdir -p $HOME/.cat_installer
    cat <<EOF > $HOME/.cat_installer/${SSID}.ca.pem
$CA_CERT
EOF
    nmcli c modify $SSID 802-11-wireless-security.key-mgmt wpa-eap $(
        echo 802-1x.identity $(echo $LOGIN | awk -F° '{ print $1}')
        echo 802-1x.password $(echo $LOGIN | awk -F° '{ print $2}')
        test -n "$ANON_ID"               && echo 802-1x.anonymous-identity $ANON_ID
        test -n "$SUBJ_ALT_MATCH"        && echo 802-1x.altsubject-matches $SUBJ_ALT_MATCH
        test -n "$CA_CERT"               && echo 802-1x.ca-cert $HOME/.cat_installer/${SSID}.ca.pem
        test -n "$CLIENTCERT"            && echo 802-1x.client-cert $CLIENTCERT
        test -n "$DNS_SUFF_MATCH"        && echo 802-1x.domain-suffix-match $DNS_SUFF_MATCH
        test -n "$EAP_METHOD"            && echo 802-1x.eap $EAP_METHOD
        test -n "$PHASE2_METHOD_NONEAP"  && echo 802-1x.phase2-auth $PHASE2_METHOD_NONEAP
        test -n "$PHASE2_METHOD_EAP"     && echo 802-1x.phase2-autheap $PHASE2_METHOD_EAP
        test -n "$PHASE2_CA_CERT"        && echo 802-1x.phase2-ca-cert $HOME/.cat_installer/${SSID}.ca2.pem
        test -n "$PHASE2_DNS_SUFF_MATCH" && echo 802-1x.phase2-domain-suffix-match $PHASE2_DNS_SUFF_MATCH
        test -n "$PHASE2_SUBJ_ALT_MATCH" && echo 802-1x.phase2-altsubject-matches $PHASE2_SUBJ_ALT_MATCH
    )
else
    cat <<EOF >> $HOME/.wpa_supplicant.conf
network={
    ssid="$SSID"
    scan_ssid=1
    key_mgmt=WPA-EAP
    pairwise=CCMP TKIP
    group=CCMP TKIP
    $( echo identity=\"$(echo $LOGIN | awk -F° '{ print $1}')\" )
    $( echo password=\"$(echo $LOGIN | awk -F° '{ print $2}')\" )
    $( test -n "$ANON_ID"               && echo anonymous_identity=\"$ANON_ID\" )
    $( test -n "$SUBJ_ALT_MATCH"        && echo altsubject_matches=\"$SUBJ_ALT_MATCH\" )
    $( test -n "$CA_CERT"               && echo ca_cert=\"$HOME/.cat_installer/${SSID}.ca.pem\" )
    $( test -n "$CLIENTCERT"            && echo client_cert=\"$CLIENTCERT\" )
    $( test -n "$DNS_SUFF_MATCH"        && echo domain_suffix_match=\"$DNS_SUFF_MATCH\" )
    $( test -n "$EAP_METHOD"            && echo eap=$(echo $EAP_METHOD | tr '[a-z]' '[A-Z]') )
    $( test -n "$PHASE2_METHOD_NONEAP"  && echo phase2=\"auth=$(echo $PHASE2_METHOD_NONEAP | tr '[a-z]' '[A-Z]')\" )
    $( test -n "$PHASE2_METHOD_EAP"     && echo phase2=\"autheap=$(echo $PHASE2_METHOD_EAP | tr '[a-z]' '[A-Z]')\" )
    $( test -n "$PHASE2_CA_CERT"        && echo ca_cert2=\"$HOME/.cat_installer/${SSID}.ca2.pem\" )
    $( test -n "$PHASE2_DNS_SUFF_MATCH" && echo domain_suffix_match2=\"$PHASE2_DNS_SUFF_MATCH\" )
    $( test -n "$PHASE2_SUBJ_ALT_MATCH" && echo altsubject_matches2=\"$PHASE2_SUBJ_ALT_MATCH\" )
}
EOF
echo Config append to ~/.wpa_supplicant.conf
echo Press any key to continue
read
fi


exit 0
