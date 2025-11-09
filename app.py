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
