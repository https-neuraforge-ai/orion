

#!/bin/bash

# Script de reparación para ORION AGI
# Este script configura correctamente la estructura de directorios, archivos y servicios necesarios.

# Detener y eliminar el servicio actual
echo "Deteniendo y eliminando el servicio actual..."
sudo systemctl stop orion_agi 2>/dev/null
sudo systemctl disable orion_agi 2>/dev/null
sudo rm /etc/systemd/system/orion_agi.service 2>/dev/null
sudo systemctl daemon-reload

# Eliminar el entorno virtual actual
echo "Eliminando el entorno virtual actual..."
rm -rf ~/orion_agi_prod/venv

# Crear la estructura de directorios necesaria
echo "Creando la estructura de directorios..."
mkdir -p ~/orion_agi_prod/src/core
touch ~/orion_agi_prod/src/__init__.py
touch ~/orion_agi_prod/src/core/__init__.py

# Crear el archivo director_orquesta.py
echo "Creando el archivo director_orquesta.py..."
cat > ~/orion_agi_prod/src/core/director_orquesta.py << 'EOL'
class DirectorOrquesta:
    def __init__(self):
        self.resultados = {}

    def ejecutar_flujo(self, datos):
        self.resultados["nexus_mente"] = {
            "modo_contenido": "informativo",
            "canales": ["telegram"],
            "agresividad": "media"
        }
EOL

# Crear el archivo app.py
echo "Creando el archivo app.py..."
cat > ~/orion_agi_prod/app.py << 'EOL'
import sys
sys.path.append('/root/orion_agi_prod')

from src.core.director_orquesta import DirectorOrquesta
from flask import Flask, request, jsonify

app = Flask(__name__)
orquestador = DirectorOrquesta()

@app.route('/ejecutar', methods=['POST'])
def ejecutar():
    datos = request.json
    orquestador.ejecutar_flujo(datos)
    return jsonify({"status": "success", "estrategia": orquestador.resultados.get("nexus_mente")})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOL

# Crear el archivo setup.py
echo "Creando el archivo setup.py..."
cat > ~/orion_agi_prod/setup.py << 'EOL'
from setuptools import setup, find_packages

setup(
    name="orion_agi_prod",
    version="0.1",
    packages=find_packages(),
)
EOL

# Crear un nuevo entorno virtual
echo "Creando un nuevo entorno virtual..."
cd ~/orion_agi_prod
python3.8 -m venv venv

# Activar el entorno virtual e instalar las dependencias
echo "Instalando las dependencias..."
source venv/bin/activate
pip install --upgrade pip
pip install flask gunicorn
pip install -e ~/orion_agi_prod

# Crear el archivo de servicio de systemd
echo "Creando el archivo de servicio de systemd..."
sudo bash -c 'cat > /etc/systemd/system/orion_agi.service << "EOL"
[Unit]
Description=ORION AGI Service
After=network.target

[Service]
User=root
WorkingDirectory=/root/orion_agi_prod
Environment=PYTHONPATH=/root/orion_agi_prod
ExecStart=/root/orion_agi_prod/venv/bin/gunicorn --workers 4 --bind 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
EOL'

# Recargar el demonio de systemd y habilitar el servicio
echo "Recargando el demonio de systemd y habilitando el servicio..."
sudo systemctl daemon-reload
sudo systemctl enable orion_agi
sudo systemctl start orion_agi

# Verificar el estado del servicio
echo "Verificando el estado del servicio..."
sudo systemctl status orion_agi --no-pager

# Verificar que Gunicorn esté escuchando
echo "Verificando que Gunicorn esté escuchando..."
sleep 3
sudo netstat -tulnp | grep 5000

# Probar la API
echo "Probando la API..."
response=$(curl -s -X POST http://localhost:5000/ejecutar -H "Content-Type: application/json" -d '{}')
echo "Respuesta de la API:"
echo "$response"

# Verificar los logs del servicio
echo "Verificando los logs del servicio..."
sudo journalctl -u orion_agi -n 10 --no-pager
