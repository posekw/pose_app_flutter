import base64
import os

def get_clean_b64(filepath):
    with open(filepath, 'rb') as f:
        data = f.read()
        return base64.b64encode(data).decode('utf-8')

# Current project files
cert_path = 'new_dist_cert.p12'
profile_path = 'ad5e3001-6637-4d84-9971-445e1539f8eb'

cert_b64 = get_clean_b64(cert_path)
profile_b64 = get_clean_b64(profile_path)

output_file = 'FINAL_MATCHED_SECRETS.txt'

with open(output_file, 'w', encoding='utf-8') as f:
    f.write("=== STEP 1: DELETE OLD SECRETS IN GITHUB ===\n")
    f.write("Go to Settings > Secrets and variables > Actions and DELETE the old secrets first.\n\n")
    
    f.write("=== STEP 2: ADD NEW BUILD_CERTIFICATE_BASE64 ===\n")
    f.write(cert_b64)
    f.write("\n\n")
    
    f.write("=== STEP 3: ADD NEW BUILD_PROVISION_PROFILE_BASE64 ===\n")
    f.write(profile_b64)
    f.write("\n\n")
    
    f.write("=== STEP 4: ENSURE P12_PASSWORD IS CORRECT ===\n")
    f.write("123456\n")

print(f"Success! Matched secrets generated in {output_file}")
