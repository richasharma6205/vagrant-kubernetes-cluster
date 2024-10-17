# wait for node to be ready
echo "waiting for node worker-1 to be ready"
kubectl wait --for=condition=Ready node/worker-1

# create namespaces
kubectl apply -f yamls/efk/efk-namespace.yaml
kubectl apply -f yamls/dummy-backend/backend.yaml

# deploy pods in backend namespace
kubectl apply -f yamls/dummy-backend/firstapp.yaml
kubectl apply -f yamls/dummy-backend/secondapp.yaml

#deploy pods in efk namespace
## deploy elasticsearch
kubectl apply -f yamls/efk/elasticsearch/elasticsearch-configmap.yaml
kubectl apply -f yamls/efk/elasticsearch/elasticsearch.yaml

## deploy fluentd
kubectl apply -f yamls/efk/fluentd/configmap_index_perpod.yaml
# kubectl apply -f yamls/configmap_index_by_pod_pattern.yaml
# kubectl apply -f yamls/configmap_index_allpods.yaml
kubectl apply -f yamls/efk/fluentd/fluentd.yaml

## deploy kibana
kubectl apply -f yamls/efk/kibana/kibana.yaml
