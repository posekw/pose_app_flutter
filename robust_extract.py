import base64
import sys

def extract(filename):
    with open(filename, 'rb') as f:
        content = f.read()
    
    # Find <data> inside <key>DeveloperCertificates</key>
    start_tag = b'<key>DeveloperCertificates</key>'
    start_idx = content.find(start_tag)
    if start_idx == -1:
        print("DeveloperCertificates key not found")
        return

    array_idx = content.find(b'<array>', start_idx)
    data_start = content.find(b'<data>', array_idx) + 6
    data_end = content.find(b'</data>', data_start)
    
    cert_b64 = content[data_start:data_end].strip()
    cert_b64 = b''.join(cert_b64.split()) # clear whitespace
    
    cert_data = base64.b64decode(cert_b64)
    out_name = 'test_profile_cert.der'
    with open(out_name, 'wb') as f:
        f.write(cert_data)
    print(f"Extracted certificate to {out_name}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        extract(sys.argv[1])
    else:
        print("Usage: python robust_extract.py <profile_file>")
