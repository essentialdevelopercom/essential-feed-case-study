#!/usr/bin/env python3
"""
Script: extract_auth_registration_coverage.py
Extrae las filas de cobertura de registro y autenticación del HTML de cobertura global y genera un resumen en Markdown.
"""
import sys
from bs4 import BeautifulSoup

# Archivos/módulos a buscar (ajusta según tus necesidades)
MODULE_KEYWORDS = [
    'Authentication Feature/UserLoginUseCaseTests.swift',
    'Registration Feature/UserRegistrationUseCaseTests.swift',
    'Security Feature/Keychain/SystemKeychainTests.swift',
    'Security Feature/SecureStorageTests.swift',
    'Security Feature/Keychain/SystemKeychain.swift',
    'Security Feature/SecureStorage.swift',
]

def extract_rows(html_path, keywords):
    with open(html_path, 'r') as f:
        soup = BeautifulSoup(f, 'html.parser')
    table = soup.find('table')
    if not table:
        print('No se encontró la tabla de cobertura en el HTML.')
        return []
    rows = table.find_all('tr')
    header = rows[0]
    filtered = [header]
    for row in rows[1:]:
        cells = row.find_all('td')
        if cells and any(kw in cells[0].text for kw in keywords):
            filtered.append(row)
    return filtered

def to_markdown(rows):
    md = []
    for row in rows:
        cols = [c.get_text(strip=True) for c in row.find_all(['th', 'td'])]
        md.append('| ' + ' | '.join(cols) + ' |')
    return '\n'.join(md)

def main():
    if len(sys.argv) < 2:
        print('Uso: python extract_auth_registration_coverage.py <ruta_al_index.html>')
        sys.exit(1)
    html_path = sys.argv[1]
    rows = extract_rows(html_path, MODULE_KEYWORDS)
    if not rows:
        print('No se encontraron módulos de registro/autenticación en el HTML.')
        sys.exit(1)
    print('# Cobertura de Registro y Autenticación\n')
    print(to_markdown(rows))

if __name__ == '__main__':
    main()
