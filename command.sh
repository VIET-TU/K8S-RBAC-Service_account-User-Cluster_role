# get service account
k get sa

kubectl get role

 k get rolebinding

## Bên trong pod
k exec -it pod/tools
root@tools:/#export SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount/
root@tools:/# export TOKEN=$(cat ${SERVICEACCOUNT}/token)
root@tools:/# export CACERT=${SERVICEACCOUNT}/ca.crt
root@tools:/# curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET https://kubernetes.default.svc/api/v1/namespaces/default/pods

# không có quyền trên namespace kube-system
root@tools:/# curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET https://kubernetes.default.svc/api/v1/namespaces/kube-system/pods
# {
#   "kind": "Status",
#   "apiVersion": "v1",
#   "metadata": {},
#   "status": "Failure",
#   "message": "pods is forbidden: User \"system:serviceaccount:default:viettu\" cannot list resource \"pods\" in API group \"\" in the namespace \"kube-system\"",
#   "reason": "Forbidden",
#   "details": {
#     "kind": "pods"
#   },
#   "code": 403
# }root@tools:/#

############################
 k config view

 ## Tạo key
  openssl genrsa -out developer-be.key 2048

  # Tạo csr 
   openssl req -new -key developer-be.key -out developer-be.csr -subj "/CN=developer-be/O=staging"
# Tiếp tho tạo crt

 openssl x509 -req -in developer-be.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out developer-be.crt -days 365

 # Xet user
 k config set-credentials developer-be --client-certificate=developer-be.crt --client-key=developer-be.key

 # kiem tra
 k config view

#  root@k8s-master-1:/200lab/k8s/developer-be# k config view
# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority-data: DATA+OMITTED
#     server: https://127.0.0.1:6443
#   name: cluster.local
# - cluster:
#     certificate-authority-data: DATA+OMITTED
#     server: https://api.viettu.id.vn
#     tls-server-name: api.internal.viettu.id.vn
#   name: viettu.id.vn
# contexts:
# - context:
#     cluster: cluster.local
#     namespace: default
#     user: kubernetes-admin
#   name: kubernetes-admin@cluster.local
# - context:
#     cluster: viettu.id.vn
#     user: viettu.id.vn
#   name: viettu.id.vn
# current-context: kubernetes-admin@cluster.local
# kind: Config
# preferences: {}
# users:
# - name: developer-be
#   user:
#     client-certificate: /200lab/k8s/developer-be/developer-be.crt
#     client-key: /200lab/k8s/developer-be/developer-be.key
# - name: kubernetes-admin
#   user:
#     client-certificate-data: DATA+OMITTED
#     client-key-data: DATA+OMITTED
# - name: viettu.id.vn
#   user:
#     client-certificate-data: DATA+OMITTED
#     client-key-data: DATA+OMITTED
# root@k8s-master-1:/200lab/k8s/developer-be#


## Tạo context context
kubectl config set-context developer-be-context --cluster=cluster.local --user=developer-be

k config view

# root@k8s-master-1:/200lab/k8s/developer-be# k config view
# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority-data: DATA+OMITTED
#     server: https://127.0.0.1:6443
#   name: cluster.local
# - cluster:
#     certificate-authority-data: DATA+OMITTED
#     server: https://api.viettu.id.vn
#     tls-server-name: api.internal.viettu.id.vn
#   name: viettu.id.vn
# contexts:
# - context:
#     cluster: cluster.local
#     user: developer-be
#   name: developer-be-context
# - context:
#     cluster: cluster.local
#     namespace: default
#     user: kubernetes-admin
#   name: kubernetes-admin@cluster.local
# - context:
#     cluster: viettu.id.vn
#     user: viettu.id.vn
#   name: viettu.id.vn
# current-context: kubernetes-admin@cluster.local
# kind: Config
# preferences: {}
# users:
# - name: developer-be
#   user:
#     client-certificate: /200lab/k8s/developer-be/developer-be.crt
#     client-key: /200lab/k8s/developer-be/developer-be.key
# - name: kubernetes-admin
#   user:
#     client-certificate-data: DATA+OMITTED
#     client-key-data: DATA+OMITTED
# - name: viettu.id.vn
#   user:
#     client-certificate-data: DATA+OMITTED
#     client-key-data: DATA+OMITTED
# root@k8s-master-1:/200lab/k8s/developer-be#

## Set context
k config use-context developer-be-context

## khong co quyen de xet pod
# root@k8s-master-1:/200lab/k8s/developer-be# k get pods
# Error from server (Forbidden): pods is forbidden: User "developer-be" cannot list resource "pods" in API group "" in the namespace "default"


## Tạo role sử file 2.role-user.yaml

###*****Cluster Role******************

CLUSTER ROLE KHÔNG PHÂN BIỆT NAMESPACE, SẼ TOÀN QUYỀN TRUY CẬP VÀO CLUSTER BẾT KỂ NS NÀO THÌ CŨNG TRUY CẬP ĐƯỢC HẾT

 k config use-context kubernetes-admin@cluster.local

# tao cluster role
 k apply -f 2.cluster-role.yaml

 k get clusterrole
 k get clusterrolebinding

  k config use-context developer-be-context


   - --tls-cert-file=/etc/kubernetes/ssl/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/ssl/apiserver.key
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key