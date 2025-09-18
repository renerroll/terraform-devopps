resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  replace          = true
  force_update     = true
  chart      = "argo-cd"
  version    = var.chart_version
  depends_on       = [kubernetes_namespace.argo_cd]
  create_namespace = false
  values = [
    file("${path.module}/values.yaml")
  ]

}

locals {
  argocd_values = templatefile("${path.module}/charts/values.yaml", {
    github_repo_url = var.github_repo_url
    github_user     = var.github_user
    github_pat    = var.github_pat
    github_branch   = var.github_branch
  })
}

resource "helm_release" "argo_apps" {
  name       = "${var.name}-apps"
  chart      = "${path.module}/charts"
  namespace  = var.namespace
  create_namespace = false
  values           = [local.argocd_values]
  depends_on = [helm_release.argo_cd]
}

