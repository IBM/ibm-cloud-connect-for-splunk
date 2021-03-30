provider "kubernetes" {
  host                   = var.host
  token                  = var.token
  cluster_ca_certificate = var.cluster_ca_certificate
}
resource "kubernetes_deployment" "splunk_deployment" {
  count=0 // increment to 1 if you want to deploy splunk
  metadata {
    name = "splunk"
    labels = {
      app  = "splunk-app"
      tier = "splunk"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "splunk-app"
        tier = "splunk"
      }
    }
    template {
      metadata {
        labels = {
          app   = "splunk-app"
          tier  = "splunk"
          track = "stable"
        }
      }
      spec {
        container {
          image             = "splunk/splunk:latest"
          name              = "splunk-client"
          image_pull_policy = "Always"
          env {
            name  = "SPLUNK_START_ARGS"
            value = "--accept-license --answer-yes"
          }
          env {
            name  = "SPLUNK_USER"
            value = "root"
          }
          env {
            name  = "SPLUNK_PASSWORD"
            value = "changeme"
          }
          env {
            name  = "SPLUNK_FORWARD_SERVER"
            value = "splunk-receiver:9997"
          }
          port {
            name           = "http"
            container_port = 8000
          }
          port {
            name           = "http-hec"
            container_port = 8088
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "splunk_service" {
    count=0 // increment to 1 if you want to deploy splunk
  depends_on =[kubernetes_deployment.splunk_deployment]
  metadata {
    name = "splunk-service"
    labels = {
      app = "splunk"
    }
  }
  spec {
    selector = {
      app = "splunk-app"
    }
    port {
      name     = "http"
      port     = 8000
      protocol = "TCP"
    }
    port {
      name     = "http-hec"
      port     = 8088
      protocol = "TCP"
    }
  }
}

resource "null_resource" "splunk_port_forward" {
    # depends_on = [kubernetes_service.splunk_service] // enable depends on if splunk is deployed using terraform
     triggers = {
        API_KEY = var.ibmcloud_api_key
        REGION=var.event_stream_region
        RESOURCE_GROUP=var.event_stream_resource_group
        CLUSTER_ID=var.cluster_name
    }
    provisioner "local-exec" {
        command = <<-EOT
      ibmcloud config --check-version=false
      ibmcloud login -r $REGION -g $RESOURCE_GROUP --apikey $API_KEY
      ibmcloud ks cluster config --cluster $CLUSTER_ID
      kubectl port-forward service/splunk-service 8000 &
    EOT
    environment = {
      API_KEY = self.triggers.API_KEY
      REGION=self.triggers.REGION
      RESOURCE_GROUP=self.triggers.RESOURCE_GROUP
      CLUSTER_ID=self.triggers.CLUSTER_ID
    }
    }
}