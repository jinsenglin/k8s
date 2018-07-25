provider "kubernetes" {
    config_path = "/etc/kubernetes/admin.conf"
}
resource "kubernetes_namespace" "tf_ns" {
  metadata {
    name = "tf"
  }
}
