# set JAVA_HOME for Maven
export JAVA_HOME=/usr/lib/jvm/`rpm -q java-11-openjdk-devel | sed s/devel-//g`
# Build the application
mvn clean package

# Login OpenShift Internal Registry
REGISTRY_URL=$(oc get route default-route -n openshift-image-registry --template={{.spec.host}})
podman login -u $(oc whoami) -p $(oc whoami -t) ${REGISTRY_URL} --tls-verify=false

# Building Application Images
cd payment/
podman build -f src/main/docker/Dockerfile.jvm -t quarkus/payment-jvm .
podman image tag quarkus/payment-jvm:latest ${REGISTRY_URL}/${RED_HAT_PAY_PROJECT}/payment-jvm:latest
podman push ${REGISTRY_URL}/${RED_HAT_PAY_PROJECT}/payment-jvm:latest --tls-verify=false
cd ../point/
podman build -f src/main/docker/Dockerfile.jvm -t quarkus/point-jvm .
podman image tag quarkus/point-jvm:latest ${REGISTRY_URL}/${RED_HAT_PAY_PROJECT}/point-jvm:latest
podman push ${REGISTRY_URL}/${RED_HAT_PAY_PROJECT}/point-jvm:latest
cd ..
