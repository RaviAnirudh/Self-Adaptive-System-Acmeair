#!/bin/bash

BUILD=${1:-1}
MANIFESTS=manifests-openshift
DOCKERFILE=Dockerfile
EXTERNAL_REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
PROJECT_NAME=$(oc project -q)

if [ ${1} == "" ] || [ ${1} == 0 ] || [ ${1} == 1 ]
then
  echo "Using Docker to build/push"
  BUILD_TOOL="docker"
  BUILD=${1}
else
  echo "Using podman to build/push"
  BUILD_TOOL="podman"
  TLS_VERIFY="--tls-verify=false"
  if [[ ${2} -ne "" ]]
  then
    BUILD=${2}
  fi
fi

echo "Trying ${BUILD_TOOL} login -u $(oc whoami) -p $(oc whoami -t) ${TLS_VERIFY}  ${EXTERNAL_REGISTRY}"
${BUILD_TOOL} login -u $(oc whoami) -p $(oc whoami -t) ${TLS_VERIFY}  ${EXTERNAL_REGISTRY}

if [[ $? -ne 0 ]]
then
  echo "Login Failed"
  exit
fi
IMAGE_PREFIX_EXTERNAL=${EXTERNAL_REGISTRY}/${PROJECT_NAME}
IMAGE_PREFIX=image-registry.openshift-image-registry.svc:5000/${PROJECT_NAME}
ROUTE_HOST=acmeair-${EXTERNAL_REGISTRY}

echo "Image Prefix External=${IMAGE_PREFIX_EXTERNAL}"
echo "Image Prefix Internal=${IMAGE_PREFIX}"
echo "Route Host=${ROUTE_HOST}"


cd "$(dirname "$0")"
cd ..
kubectl delete -f ${MANIFESTS}
oc delete route acmeair-main-service

if [[ `grep -c ${IMAGE_PREFIX} ${MANIFESTS}/deploy-acmeair-mainservice-java.yaml` == 0 ]]
then
  echo "Adding ${IMAGE_PREFIX}/"
  sed -i.bak "s@acmeair-mainservice-java:latest@${IMAGE_PREFIX}/acmeair-mainservice-java:latest@" ${MANIFESTS}/deploy-acmeair-mainservice-java.yaml
fi

if [[ `grep -c ${ROUTE_HOST} ${MANIFESTS}/acmeair-mainservice-route.yaml` == 0 ]]
then
  echo "Patching Route Host: ${ROUTE_HOST}"
  sed -i.bak "s@_HOST_@${ROUTE_HOST}@" ${MANIFESTS}/acmeair-mainservice-route.yaml
fi

case "${BUILD}" in
  0)
    REPLICA_MAIN_COUNT=1
    ;;
  1)
    REPLICA_MAIN_COUNT=1
    ;;
  *)
    echo "Invalid BUILD value. No action taken."
    exit 1
    ;;
esac

sed -i.bak "s/replicas: 1/replicas: ${REPLICA_MAIN_COUNT}/" ${MANIFESTS}/deploy-acmeair-mainservice-java.yaml

kubectl apply -f ${MANIFESTS}

echo "Removing ${IMAGE_PREFIX}"
sed -i.bak "s@${IMAGE_PREFIX}/acmeair-mainservice-java:latest@acmeair-mainservice-java:latest@" ${MANIFESTS}/deploy-acmeair-mainservice-java.yaml

echo "Removing ${ROUTE_HOST}"
sed -i.bak "s@${ROUTE_HOST}@_HOST_@" ${MANIFESTS}/acmeair-mainservice-route.yaml

echo "Resetting replica count to 1"
sed -i "s/replicas: ${REPLICA_MAIN_COUNT}/replicas: 1/" ${MANIFESTS}/deploy-acmeair-mainervice-java.yaml

rm ${MANIFESTS}/acmeair-mainservice-route.yaml.bak
rm ${MANIFESTS}/deploy-acmeair-mainservice-java.yaml.bak

cd ../acmeair-authservice-java
kubectl delete -f ${MANIFESTS}

if [[ `grep -c ${IMAGE_PREFIX} ${MANIFESTS}/deploy-acmeair-authservice-java.yaml` == 0 ]]
then
  echo "Adding ${IMAGE_PREFIX}/"
  sed -i.bak "s@acmeair-authservice-java:latest@${IMAGE_PREFIX}/acmeair-authservice-java:latest@" ${MANIFESTS}/deploy-acmeair-authservice-java.yaml
fi

if [[ `grep -c ${ROUTE_HOST} ${MANIFESTS}/acmeair-authservice-route.yaml` == 0 ]]
then
  echo "Patching Route Host: ${ROUTE_HOST}"
  sed -i.bak "s@_HOST_@${ROUTE_HOST}@" ${MANIFESTS}/acmeair-authservice-route.yaml
fi

case "${BUILD}" in
  0)
    REPLICA_AUTH_COUNT=1
    ;;
  1)
    REPLICA_AUTH_COUNT=1
    ;;
  *)
    echo "Invalid BUILD value. No action taken."
    exit 1
    ;;
esac

sed -i.bak "s/replicas: 1/replicas: ${REPLICA_AUTH_COUNT}/" ${MANIFESTS}/deploy-acmeair-authservice-java.yaml

kubectl apply -f ${MANIFESTS}

echo "Removing ${IMAGE_PREFIX}"
sed -i.bak "s@${IMAGE_PREFIX}/acmeair-authservice-java:latest@acmeair-authservice-java:latest@" ${MANIFESTS}/deploy-acmeair-authservice-java.yaml

echo "Removing ${ROUTE_HOST}"
sed -i.bak "s@${ROUTE_HOST}@_HOST_@" ${MANIFESTS}/acmeair-authservice-route.yaml

echo "Resetting replica count to 1"
sed -i "s/replicas: ${REPLICA_AUTH_COUNT}/replicas: 1/" ${MANIFESTS}/deploy-acmeair-authservice-java.yaml

rm ${MANIFESTS}/acmeair-authservice-route.yaml.bak
rm ${MANIFESTS}/deploy-acmeair-authservice-java.yaml.bak

cd ../acmeair-bookingservice-java
kubectl delete -f ${MANIFESTS}

if [[ `grep -c ${IMAGE_PREFIX} ${MANIFESTS}/deploy-acmeair-bookingservice-java.yaml` == 0 ]]
then
  echo "Adding ${IMAGE_PREFIX}/"
  sed -i.bak "s@acmeair-bookingservice-java:latest@${IMAGE_PREFIX}/acmeair-bookingservice-java:latest@" ${MANIFESTS}/deploy-acmeair-bookingservice-java.yaml
fi

if [[ `grep -c ${ROUTE_HOST} ${MANIFESTS}/acmeair-bookingservice-route.yaml` == 0 ]]
then
  echo "Patching Route Host: ${ROUTE_HOST}"
fi

case "${BUILD}" in
  0)
    REPLICA_B_COUNT=2
    ;;
  1)
    REPLICA_B_COUNT=1
    ;;
  *)
    echo "Invalid BUILD value. No action taken."
    exit 1
    ;;
esac

sed -i.bak "s/replicas: 1/replicas: ${REPLICA_B_COUNT}/" ${MANIFESTS}/deploy-acmeair-bookingservice-java.yaml

kubectl apply -f ${MANIFESTS}

echo "Removing ${IMAGE_PREFIX}"
sed -i.bak "s@${IMAGE_PREFIX}/acmeair-bookingservice-java:latest@acmeair-bookingservice-java:latest@" ${MANIFESTS}/deploy-acmeair-bookingservice-java.yaml

echo "Removing ${ROUTE_HOST}"
sed -i.bak "s@${ROUTE_HOST}@_HOST_@" ${MANIFESTS}/acmeair-bookingservice-route.yaml

echo "Resetting replica count to 1"
sed -i "s/replicas: ${REPLICA_B_COUNT}/replicas: 1/" ${MANIFESTS}/deploy-acmeair-bookingservice-java.yaml

rm ${MANIFESTS}/acmeair-bookingservice-route.yaml.bak
rm ${MANIFESTS}/deploy-acmeair-bookingservice-java.yaml.bak


cd ../acmeair-customerservice-java
kubectl delete -f ${MANIFESTS}

if [[ `grep -c ${IMAGE_PREFIX}/a ${MANIFESTS}/deploy-acmeair-customerservice-java.yaml` == 0 ]]
then
  echo "Adding ${IMAGE_PREFIX}/"
  sed -i.bak "s@acmeair-customerservice-java:latest@${IMAGE_PREFIX}/acmeair-customerservice-java:latest@" ${MANIFESTS}/deploy-acmeair-customerservice-java.yaml

fi

if [[ `grep -c ${ROUTE_HOST} ${MANIFESTS}/acmeair-customerservice-route.yaml` == 0 ]]
then
  echo "Patching Route Host: ${ROUTE_HOST}"
fi

case "${BUILD}" in
  0)
    REPLICA_C_COUNT=2
    ;;
  1)
    REPLICA_C_COUNT=1
    ;;
  *)
    echo "Invalid BUILD value. No action taken."
    exit 1
    ;;
esac

sed -i.bak "s/replicas: 1/replicas: ${REPLICA_C_COUNT}/" ${MANIFESTS}/deploy-acmeair-customerservice-java.yaml

kubectl apply -f ${MANIFESTS}

echo "Removing ${IMAGE_PREFIX}"
sed -i.bak "s@${IMAGE_PREFIX}/acmeair-customerservice-java:latest@acmeair-customerservice-java:latest@" ${MANIFESTS}/deploy-acmeair-customerservice-java.yaml


echo "Removing ${ROUTE_HOST}"
sed -i.bak "s@${ROUTE_HOST}@_HOST_@" ${MANIFESTS}/acmeair-customerservice-route.yaml

echo "Resetting replica count to 1"
sed -i "s/replicas: ${REPLICA_C_COUNT}/replicas: 1/" ${MANIFESTS}/deploy-acmeair-customerservice-java.yaml


rm ${MANIFESTS}/acmeair-customerservice-route.yaml.bak
rm ${MANIFESTS}/deploy-acmeair-customerservice-java.yaml.bak

cd ../acmeair-flightservice-java
kubectl delete -f ${MANIFESTS}

if [[ `grep -c ${IMAGE_PREFIX}/a ${MANIFESTS}/deploy-acmeair-flightservice-java.yaml` == 0 ]]
then
  echo "Adding ${IMAGE_PREFIX}/"
  sed -i.bak "s@acmeair-flightservice-java:latest@${IMAGE_PREFIX}/acmeair-flightservice-java:latest@" ${MANIFESTS}/deploy-acmeair-flightservice-java.yaml
  
fi

if [[ `grep -c ${ROUTE_HOST} ${MANIFESTS}/acmeair-flightservice-route.yaml` == 0 ]]
then
  echo "Patching Route Host: ${ROUTE_HOST}"
  sed -i.bak "s@_HOST_@${ROUTE_HOST}@" ${MANIFESTS}/acmeair-flightservice-route.yaml
fi

case "${BUILD}" in
  0)
    REPLICA_F_COUNT=2
    ;;
  1)
    REPLICA_F_COUNT=1
    ;;
  *)
    echo "Invalid BUILD value. No action taken."
    exit 1
    ;;
esac

sed -i.bak "s/replicas: 1/replicas: ${REPLICA_F_COUNT}/" ${MANIFESTS}/deploy-acmeair-flightservice-java.yaml

kubectl apply -f ${MANIFESTS}

echo "Removing ${IMAGE_PREFIX}"
sed -i.bak "s@${IMAGE_PREFIX}/acmeair-flightservice-java:latest@acmeair-flightservice-java:latest@" ${MANIFESTS}/deploy-acmeair-flightservice-java.yaml


echo "Removing ${ROUTE_HOST}"

echo "Resetting replica count to 1"
sed -i "s/replicas: ${REPLICA_F_COUNT}/replicas: 1/" ${MANIFESTS}/deploy-acmeair-flightservice-java.yaml

rm ${MANIFESTS}/acmeair-flightservice-route.yaml.bak
rm ${MANIFESTS}/deploy-acmeair-flightservice-java.yaml.bak

echo "acmeair available @ http://${ROUTE_HOST}/acmeair"
