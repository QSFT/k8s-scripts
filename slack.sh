SLACK_URL=$1
NAMESPACES=$2

NAME=$(sudo cat /etc/kubernetes/azure.json |
       awk '/resourceGroup/{print $2}' | 
       sed s/\",// | sed s/\"//)

echo $NAME

date

KUBE=$(kubectl get node && \
       sudo etcdctl cluster-health && \
       ./nodes_disk.sh)

PODS=$(./pods.sh $NAMESPACES)

STATUS=":red_circle:"
NOTIFICATION='<!channel> '

BAD=$(echo $PODS | grep -E "NotReady|unhealthy")
if [ ${#BAD} -eq 0 ];then
    STATUS=":green_apple:"
    NOTIFICATION=''
fi

KUBE="$KUBE\n$PODS"
BAD=$(echo $KUBE | grep -E "NotReady|unhealthy")
if [ ${#BAD} -eq 0 ];then
    KUBE='cluster is healthy'
fi


rm -f /tmp/slackmsg
RES="{\"text\":\"$(date && echo ${NOTIFICATION}$STATUS" "*$NAME* && echo "${KUBE}")\"}"
echo $RES > /tmp/slackmsg
curl -XPOST $SLACK_URL -d "@/tmp/slackmsg";
