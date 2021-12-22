# Login to OpenShift
oc login -u opentlc-mgr -p r3dh4t1!
oc project user1-project

# DataGrid
rm -f ./artifacts/*.jar
cp ../../cache/target/cache-1.0-SNAPSHOT.jar ./artifacts/
cp ../../domain/target/domain-1.0-SNAPSHOT.jar ./artifacts/

oc new-app httpd~./artifacts --name=httpd
echo "sleep 60"
sleep 60
oc start-build httpd --from-dir=./artifacts
echo "sleep 60"
sleep 60

oc apply -f create_data_grid.yaml
oc apply -f mycache.yaml
echo "sleep 60"
sleep 60
oc apply -f put_schema.yaml

# AMQ Streams
oc apply -f create_kafka_cluster.yaml
oc apply -f create_kafka_topic.yaml

# Applications
oc apply -f deploy_app.yaml 

# Enabling monitoring for user-defined projects
oc apply -f cluster-monitoring-config.yaml

# Grafana
oc apply -f create_grafana.yaml
oc apply -f service-account.yaml
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z infinispan-monitoring
export TOKEN=`oc serviceaccounts get-token infinispan-monitoring`
sed -e "s/__TOKEN__/${TOKEN}/g" grafana_datasource_template.yaml > grafana_datasource.yaml
oc apply -f grafana_datasource.yaml
oc apply -f infinispan-operator-config.yaml
oc apply -f create_grafana_dashboard.yaml

# Cryostat
oc apply -f create_cryostat.yaml

# Service Mesh
oc apply -f servicemesh_controlplane.yaml
oc apply -f servicemesh_memberroll-default.yaml
oc apply -f servicemesh-gateway.yaml
oc apply -f servicemesh_destination-rule-all.yaml

oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}'

# clean up
#oc delete is,bc,deploy,svc -l app=httpd
#oc delete infinispan example-infinispan
#oc delete cache paymentcachedefinition
#oc delete cache pointcachedefinition
#oc delete cache tokencachedefinition
#oc delete cache usercachedefinition
#oc delete cache walletcachedefinition
#oc delete batch put-schema
#oc delete kafka my-cluster
#oc delete kafkatopic point
#oc delete kafkatopic payment
#oc delete deploy payment
#oc delete deploy point
#oc delete svc payment
#oc delete svc point
#oc delete route payment
#oc delete grafana example-grafana
#oc delete sa infinispan-monitoring
#oc delete grafanadatasource grafanadatasource
#oc delete grafanadashboard simple-dashboard
#oc delete cryostat cryostat-sample