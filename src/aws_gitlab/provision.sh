VM_PUBLIC_IP=$1

cd /home/ubuntu/gitlab

echo "export AZ_SERVICE_PRINCIPAL_CLIENT_ID=$2" >> /etc/profile
echo "export AZ_SERVICE_PRINCIPAL_CLIENT_SECRET=$3" >> /etc/profile
echo "export AZ_TENANT_ID=$4" >> /etc/profile

source /etc/profile

sudo -E docker-compose up -d
echo "Gitlab URL: http://$VM_PUBLIC_IP"