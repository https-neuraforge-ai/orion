cat > ~/start_services.sh << 'EOL'
#!/bin/bash

# Script para iniciar servicios comunes
echo "Iniciando servicios..."

# Navegar al directorio del proyecto
cd ~/orion_agi_prod

# Iniciar servicio de ORION AGI
echo "Iniciando servicio ORION AGI..."
sudo systemctl restart orion_agi
sudo systemctl status orion_agi --no-pager

# Mostrar logs del servicio
echo "Mostrando logs del servicio ORION AGI..."
journalctl -u orion_agi -f
EOL

