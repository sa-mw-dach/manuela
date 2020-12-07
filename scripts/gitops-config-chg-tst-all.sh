#!/usr/bin/env bash

########################
# include the magic
########################
#. ../demo-magic.sh
. ~/Projects/cli-demo/demo-magic/demo-magic.sh

########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

# text color
DEMO_CMD_COLOR=$BLACK

m="~/Projects/manuela"


if [ -z "$1" ]
then
 echo "Use ..."
 echo " $0 prep"  
 echo " $0 run"  
 echo " $0 clean"  
 exit
fi

# hide the evidence
clear


#
# Set temp to false
#

if [ "$1" == "prep" ]
then

  pei "cd $m/manuela-gitops/config/instances/manuela-stormshift/machine-sensor"
  pei "sed -i \"s|SENSOR_TEMPERATURE_ENABLED.*|SENSOR_TEMPERATURE_ENABLED=false|\" machine-sensor-2-configmap.properties"
  pei "git add ."
  pei "git commit -m \"Set SENSOR_TEMPERATURE_ENABLED=false\""
  pei "git push"

fi


if [ "$1" == "run" ]
then

  # Set temp to true
  pe "cd $m/manuela-gitops/config/instances/manuela-stormshift/machine-sensor"
  pe "ls -1"
  pe "vi machine-sensor-2-configmap.properties"


  pei "git add ."
  pei "git commit -m \"Set SENSOR_TEMPERATURE_ENABLED=true\""
  pei "git push"

fi


# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
