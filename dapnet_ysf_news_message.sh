#!/bin/bash
#
# V1.2 DAPNET_Scripts dans la rubric
#
USER=f1XXX
USER_PASSWORD=XXXXXXXXXXXXXXXXXXXXXXX
URL=http://www.hampager.de:8080
RUBRIC=ysf-news
GROUP=ysf-france
TEXT="$1"

# Fonctions
display_usage() {
        echo "This script must be run with super-user privileges."
        echo -e "\nUsage:\n./dapnet_ysf_news_message.sh \"Mon message\"\n"
        }

# Display Utilisation du script
if [  $# -le 0 ]
 then
        display_usage
        exit 1
fi

curl -H "Content-Type: application/json" -X POST -u $USER:$USER_PASSWORD -d "{ \"rubricName\": \"$RUBRIC\", \"text\": \"$TEXT\" }" $URL/news 2>&1 >/dev/null

exit 0
