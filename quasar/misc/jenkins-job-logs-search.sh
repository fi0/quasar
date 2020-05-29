#!/bin/bash

# Usage
#
# ./jenkins-job-logs-search.sh 44026 44027 "event1\|event2"
#
# 1st argument: First job run to start the search at.
# 2nd argument: Last job run to end the search at.
# 3rd argument: case insensitive regex pattern. See: https://linuxize.com/post/regular-expressions-in-grep/

# Colors
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LG='\033[0;37m' # Light Grey

# Credentials
username=<jenkinsUsername>
# https://www.jenkins.io/images/post-images/2018-07-02-new-api-token-system/legacy_removal.gif
password=<jenkinsToken>

# setup

# Edit to point to QA or Prod instance
host=jenkins.d12g.co
# Copy/paste just as it appears in the browser's URL
jobName=CIO%20Consumer
start=$1
end=$2
searchPattern=$3

# Tests if using correct credentials
isAuthorized() {
    response=$(curl --silent -u $username:$password https://$host/job/$jobName/$start/consoleText)
    # TODO: Check for 404 and 500
    if [[ $response == *"Error 401"* ]]; then
        echo -e "${RED}Invalid password/token for user $1${NC}"
        echo "Goodbye."
        # http://www.tldp.org/LDP/abs/html/exitcodes.html
        exit 126
    fi
}

# Main

# Check if credentials are valid
isAuthorized

echo "----------------------------------------"
echo -e "Jenkins job name: ${CYAN}$jobName${NC}"
echo -e "Search grep pattern: ${CYAN}$searchPattern${NC}"
echo -e "Searching console logs for runs starting at ${CYAN}#$start${NC} and ending at ${CYAN}#$end${NC}"
echo "----------------------------------------"

for ((i=$start;i<=$end;i++)); do
    echo -e "${LG}Searching job #$i console log ${NC}"
    match=$(curl --silent -u $username:$password https://$host/job/$jobName/$i/consoleText | grep -i $searchPattern)

    if [[ ! -z $match ]]; then
        echo -e "${GREEN}Found it in console log for run${NC} ${CYAN}#$i${GREEN}:${NC}"
        echo -e "$match"
        exit 0
    fi
done

echo "Not Found."
