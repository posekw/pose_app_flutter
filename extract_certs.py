import base64
from xml.etree import ElementTree as ET
import os

def extract_certs_from_profile(profile_path):
    with open(profile_path, 'rb') as f:
        data = f.read()
    start = data.find(b'<plist')
    end = data.find(b'</plist>') + 8
    if start == -1 or end == -1:
        return []
    plist_str = data[start:end]
    root = ET.fromstring(plist_str)
    
    certs_data = []
    find_key = False
    
    # Simple walk of the dict
    it = iter(root.find('dict'))
    for child in it:
        if child.tag == 'key' and child.text == 'DeveloperCertificates':
            array = next(it)
            if array.tag == 'array':
                for cert_node in array.findall('data'):
                    certs_data.append(cert_node.text.strip())
            break
    return certs_data

profile_path = r'f:\Docler\pose_app_flutter\c109c555-0d56-4315-8670-9d18314776b5'
certs = extract_certs_from_profile(profile_path)
print(f'Found {len(certs)} certificates in provisioning profile.')

for i, cert_b64 in enumerate(certs):
    filename = f'out_cert_{i}.der'
    with open(filename, 'wb') as f:
        f.write(base64.b64decode(cert_b64))
    print(f'Saved certificate {i} to {filename}')
