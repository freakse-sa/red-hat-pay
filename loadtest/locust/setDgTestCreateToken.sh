set -e

scriptDir=`dirname ${BASH_SOURCE[0]}`

bash ${scriptDir}/seed.sh ${scriptDir}/MultiUserTaskSet.py http://`oc get route payment -n red-hat-pay --template={{.spec.host}}`

