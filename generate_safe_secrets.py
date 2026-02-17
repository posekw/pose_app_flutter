import base64
import os
import re

def get_clean_b64(filepath):
    with open(filepath, 'rb') as f:
        data = f.read()
        return base64.b64encode(data).decode('utf-8').replace('\n', '').replace('\r', '').strip()

# Path to the files on user machine
cert_path = 'new_dist_cert.p12'
# The user just uploaded this one, it's the latest
profile_path = '016105a0-1f0a-434c-962c-4b19048956e2'

cert_b64 = get_clean_b64(cert_path)
profile_b64 = get_clean_b64(profile_path)

with open('ULTRA_SAFE_SECRETS.txt', 'w') as f:
    f.write("=== BUILD_CERTIFICATE_BASE64 ===\n")
    f.write(cert_b64)
    f.write("\n\n=== BUILD_PROVISION_PROFILE_BASE64 ===\n")
    f.write(profile_b64)
    f.write("\n\n=== P12_PASSWORD ===\n")
    f.write("123456")

print("ULTRA_SAFE_SECRETS.txt has been created with clean, single-line strings.")
