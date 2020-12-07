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
# Delete OCP4 Sensor
#

if [ "$1" == "prep" ]
then


 pei "cd $m/manuela-gitops/deployment/execenv-linedataserver"

 pei "rm manuela-stormshift-machine-sensor-application.yaml"

 pei "git add ."
 pei "git commit -m \"undeploy manuela-stormshift-machine-sensor-application\""
 pei "git push"



fi


if [ "$1" == "run" ]
then

  # Application Templating Concept
  pe "cd $m/manuela-gitops/config/templates"
  pe "ls -d1 manu*"

  pe "ls -1 manuela/"
  pe "ls -1 manuela/machine-sensor/"

  pe "more manuela/machine-sensor/kustomization.yaml"

  # Let go to the deployments ... and create a link to the instance
  pe "cd $m/manuela-gitops/deployment/execenv-linedataserver"
  pe "ln -s ../../config/instances/manuela-stormshift/manuela-stormshift-machine-sensor-application.yaml"

  pei "git add ."
  pei "git commit -m \"deploy manuela-stormshift-machine-sensor-application\""
  pei "git push"
fi


# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
