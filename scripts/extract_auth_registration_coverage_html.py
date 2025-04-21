#!/usr/bin/env python3
"""
Script: extract_auth_registration_coverage_html.py
Extrae las filas de cobertura de registro y autenticación del HTML global y genera un nuevo HTML solo con esos módulos.
"""
import sys
import os
from bs4 import BeautifulSoup

MODULE_KEYWORDS = [
    'Authentication Feature/UserLoginUseCaseTests.swift',
    'Registration Feature/UserRegistrationUseCaseTests.swift',
    'Security Feature/Keychain/SystemKeychainTests.swift',
    'Security Feature/SecureStorageTests.swift',
    'Security Feature/Keychain/SystemKeychain.swift',
    'Security Feature/SecureStorage.swift',
]

def extract_and_write_html(src_html, dst_html, keywords):
    with open(src_html, 'r') as f:
        soup = BeautifulSoup(f, 'html.parser')
    table = soup.find('table')
    if not table:
        print('No se encontró la tabla de cobertura en el HTML.')
        return False
    rows = table.find_all('tr')
    header = rows[0]
    filtered = [header]
    for row in rows[1:]:
        cells = row.find_all('td')
        if cells and any(kw in cells[0].text for kw in keywords):
            filtered.append(row)
    # Borra las filas anteriores y añade solo las relevantes
    table.clear()
    for row in filtered:
        table.append(row)
    # Cambia el título para reflejar el filtrado
    if soup.title:
        soup.title.string = 'Coverage Report: Auth & Registration Only'
    h1 = soup.find(['h1','h2'])
    if h1:
        h1.string = 'Coverage Report: Auth & Registration Only'
    # Escribe el HTML filtrado
    os.makedirs(os.path.dirname(dst_html), exist_ok=True)
    with open(dst_html, 'w') as f:
        f.write(str(soup))
    print(f'HTML filtrado generado en: {dst_html}')
    return True

def main():
    if len(sys.argv) < 3:
        print('Uso: python extract_auth_registration_coverage_html.py <src_html> <dst_html>')
        sys.exit(1)
    src_html = sys.argv[1]
    dst_html = sys.argv[2]
    extract_and_write_html(src_html, dst_html, MODULE_KEYWORDS)

if __name__ == '__main__':
    main()
