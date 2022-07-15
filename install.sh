#!/bin/bash

##############################################################################
# -- FUNCTIONS --
info() {
    printf "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
    printf "\nINFO: $@\n"
    printf "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
}
deploy_operator() # (subscription yaml file, operator name, namespace)
{
    oc apply -f $1 -n $3
    LOOP="TRUE"
    echo "waiting for operator to be in Succeeded state"
    while [ $LOOP == "TRUE" ]
    do
        # get the csv name
        RESOURCE=$(oc get subscription $2 -n $3 -o template --template '{{.status.currentCSV}}')
        # get the status of csv 
        RESP=$(oc get csv $RESOURCE -n $3  --no-headers 2>/dev/null)
        RC=$(echo $?)
        STATUS=""
        if [ "$RC" -eq 0 ]
        then
            STATUS=$(oc get csv $RESOURCE -n $3 -o template --template '{{.status.phase}}')
            RC=$(echo $?)
        fi
        # Check the CSV state
        if [ "$RC" -eq 0 ] && [ "$STATUS" == "Succeeded" ]
        then
            echo "$2 operator deployed!"
            LOOP="FALSE" 
        fi 
    done
}
#-----------------------------------------------------------------------------

##############################################################################
# -- ENVIRONMENT --
NS_CMP=workshop-components
NS_DEV=app-dev
NS_TEST=app-test
NS_PROD=app-prod
GITEA_HOSTNAME=
ARGO_URL=
ARGO_PASS=
#-----------------------------------------------------------------------------

##############################################################################
# -- EXECUTION --
#-----------------------------------------------------------------------------

info "Starting installation"

info "Creating namespaces"
oc new-project $NS_CMP
oc new-project $NS_DEV
oc new-project $NS_TEST
oc new-project $NS_PROD

info "Deploying and configuring GITEA"
oc apply -f workshop-environment/gitea/gitea_deployment.yaml -n $NS_CMP
GITEA_HOSTNAME=$(oc get route gitea -o template --template='{{.spec.host}}' -n $NS_CMP)
sed "s/@HOSTNAME/$GITEA_HOSTNAME/g" workshop-environment/gitea/gitea_configuration.yaml | oc create -f - -n $NS_CMP
oc rollout status deployment/gitea -n $NS_CMP
sed "s/@HOSTNAME/$GITEA_HOSTNAME/g" workshop-environment/gitea/setup_job.yaml | oc apply -f - --wait -n $NS_CMP
oc wait --for=condition=complete job/configure-gitea --timeout=60s -n $NS_CMP

info "Deploying and configuring OpenShift pipelines"
deploy_operator workshop-environment/tekton/operator_sub.yaml openshift-pipelines-operator-rh openshift-operators
sleep 30
oc policy add-role-to-user edit system:serviceaccount:$NS_CMP:pipeline -n $NS_DEV
oc policy add-role-to-user edit system:serviceaccount:$NS_CMP:pipeline -n $NS_TEST
oc policy add-role-to-user edit system:serviceaccount:$NS_CMP:pipeline -n $NS_PROD


##############################################################################
# -- INSTALATION INFO --
#-----------------------------------------------------------------------------
printf "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "\nINSTALATIO COMPLETED!!\n"
printf "\n"
printf "OPENSHIFT NAMESPACES: \n"
printf "  - workshop components: $NS_CMP\n"
printf "  - dev: $NS_DEV\n"
printf "  - test: $NS_TEST\n"
printf "  - production: $NS_PROD\n"
printf "\n"
printf "GITEA: \n"
printf "  - url: http://$GITEA_HOSTNAME\n"
printf "  - user: gitea\n"
printf "  - password: openshift\n"
printf "\n"
printf "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"


