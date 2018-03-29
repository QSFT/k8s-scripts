SLACK_URL=$1
INTERVAL=$2
export TZ=Europe/Moscow

NAME=$(sudo cat /etc/kubernetes/azure.json |
       awk '/resourceGroup/{print $2}' | 
       sed s/\",// | sed s/\"//)

echo $NAME

while true; do 

date

KUBE=$(kubectl get node && \
    sudo etcdctl cluster-health && \
    sh ./nodes_disk.sh && \
    sh ./pods.sh)

echo "parse status result"

STATUS=":red_circle:"
NOTIFICATION='<!channel> '

BAD=$(echo $KUBE | grep -E "NotReady|unhealthy")
if [ ${#BAD} -eq 0 ];then
    STATUS=":green_apple:"
    NOTIFICATION=''
    KUBE=''
fi

RES=$(date && echo ${NOTIFICATION}$STATUS" "*$NAME* && echo "${KUBE}")
echo "send status: $RES"
curl -XPOST $SLACK_URL -d "{\"text\":\"$RES\"}";

sleep $INTERVAL

done
