function master_update {
    # Upgrade kubeadm
    sudo apt-mark unhold kubeadm
    sudo apt-get update && sudo apt-get install -y kubeadm=1.18.0-00
    sudo apt-mark hold kubeadm

    # Upgrade master node
    kubectl drain kmaster --ignore-daemonsets
    sudo kubeadm upgrade plan
    sudo kubeadm upgrade apply v1.18.0

    # Update Flannel
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

    # Make master node reschedulable
    kubectl uncordon kmaster

    # Upgrade kubelet and kubectl
    sudo apt-mark unhold kubelet kubectl
    sudo apt-get update && sudo apt-get install -y kubelet=1.18.0-00 kubectl=1.18.0-00
    sudo apt-mark hold kubelet kubectl
    sudo systemctl restart kubelet
}

function worker_update {
    sudo apt-mark unhold kubeadm
    sudo apt-get update && sudo apt-get install -y kubeadm=1.18.0-00
    sudo apt-mark hold kubeadm
    # Upgrade worker node
    kubectl drain kworker1 --ignore-daemonsets # On master node, or on worker node if you have proper config
    sudo kubeadm upgrade node
    # Upgrade kubelet and kubectl
    sudo apt-mark unhold kubelet kubectl
    sudo apt-get update && sudo apt-get install -y kubelet=1.18.0-00 kubectl=1.18.0-00
    sudo apt-mark hold kubelet kubectl
    sudo systemctl restart kubelet
    # Make worker node reschedulable
    kubectl uncordon kworker1 # On master node, or on worker node if you have proper config
}

function master_centos {
#https://v1-19.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
yum list --showduplicates kubeadm --disableexcludes=kubernetes
yum install -y kubeadm-1.20.4-0 --disableexcludes=kubernetes
}
