echo "checking disk usage on nodes"

NODES=`kubectl get nodes --no-headers | awk '{print $1}'`  

function get_disk_usage {
  ssh -q -oServerAliveInterval=5 -oConnectTimeout=10 -oConnectionAttempts=1 -oStrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null azureuser@$1 df -$2 | grep sda
}

for n in $NODES;do
   echo "node: $n"
   get_disk_usage $n "h"
   get_disk_usage $n "i"
done

