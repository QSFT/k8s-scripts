SLACK_URL=$1
INTERVAL=$2
export TZ=Europe/Moscow

NAME=$(sudo cat /etc/kubernetes/azure.json |
       awk '/resourceGroup/{print $2}' | 
       sed s/\",// | sed s/\"//)

echo $NAME

date

KUBE=$(kubectl get node && \
    sudo etcdctl cluster-health && \
    ./nodes_disk.sh && \
    ./pods.sh)

STATUS=":red_circle:"
NOTIFICATION='<!channel> '

BAD=$(echo $KUBE | grep -E "NotReady|unhealthy")
if [ ${#BAD} -eq 0 ];then
    STATUS=":green_apple:"
    NOTIFICATION=''
    KUBE='cluster is healthy'
fi

RES=$(date && echo ${NOTIFICATION}$STATUS" "*$NAME* && echo "${KUBE}")
curl -XPOST $SLACK_URL -d "{\"text\":\"$RES\"}";

sleep $INTERVAL
