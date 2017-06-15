from lxml import etree
import uuid
#from M2Crypto import BIO, Rand, SMIME
import OpenSSL



def create_xml(json_data):
    tree = etree.parse("default.xml")
    root = tree.getroot()

    cert_uuid = uuid.uuid4()
    payload_id = uuid.uuid4()

    eap_types = root[0][1][0][5][1]
    outer_id = root[0][1][0][5][5]
    trusted_names = root[0][1][0][5][9]
    ssid = root[0][1][0][25]

    certificate = root[0][1][1][3]
    certificate_cn = root[0][1][1][7]
    # [ i[1] for i in OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, open("ca.pem").read()).get_subject().get_components() if i[0] == b'CN' ]


    description = root[0][3]
    display_name = root[0][5]
    identifier = root[0][7]
    org = root[0][9]


    # Certificate UUID
    root[0][1][0][5][7][0].text = str(cert_uuid)
    root[0][1][1][9].text = "com.apple.security.root.{0}".format(cert_uuid)
    root[0][1][1][13].text = str(cert_uuid)
    # Payload UUID
    root[0][1][0][17].text = "com.apple.wifi.managed.{0}".format(payload_id)
    root[0][1][0][19].text = str(payload_id)
    # Payload UUID General
    root[0][15].text = str(uuid.uuid4())

    # print(etree.tostring(certificate_cn))
    # print(etree.tostring(certificate))
    # print(etree.tostring(ssid))
    # print(etree.tostring(trusted_names))
    # print(etree.tostring(eap_types))
    # print(etree.tostring(outer_id))
    print(etree.tostring(tree, pretty_print=True).decode())

def sign_file(filename, keyfile, certfile, chainfile):
    pass
    # openssl smime -sign -signer ~/cert/2_bbecker@example.com.crt -inkey ~/cert/bbeckerATpksDOTmpgDOTde.key -certfile ~/cert/1_Intermediate.crt -nodetach -outform der -in sample-ssid_wifi_profile.mobileconfig -out sample-ssid_wifi_profile_signed.mobileconfig

