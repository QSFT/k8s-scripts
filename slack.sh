SLACK_URL=$1
NAMESPACES=$2

NAME=$(sudo cat /etc/kubernetes/azure.json |
       awk '/resourceGroup/{print $2}' | 
       sed s/\",// | sed s/\"//)

echo $NAME

date

KUBE=$(kubectl get node && \
    sudo etcdctl cluster-health && \
    ./pods.sh $NAMESPACES)

STATUS=":red_circle:"
NOTIFICATION='<!channel> '

BAD=$(echo $KUBE | grep -E "NotReady|unhealthy")
if [ ${#BAD} -ne 0 ];then
  RES=$(date && echo ${NOTIFICATION}$STATUS" "*$NAME* && echo "${KUBE}")  
  curl -XPOST $SLACK_URL -d "{\"text\":\"$RES\"}";
fi
