
function etcd_install() {
mkdir /tmp/etcd && cd /tmp/etcd

yum -y install wget curl

curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | cut -d '"' -f 4 \
  | wget -qi -

tar xvf *.tar*
cd etcd-*/
sudo mv etcd* /usr/local/bin/
cd ~
rm -rf /tmp/etcd
mkdir /tmp/etcd_backup.db
}

function etcd_save() {
etcdctl snapshot save /home/vagrant/etcd_backup.db --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key

}