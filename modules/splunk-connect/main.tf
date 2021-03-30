provider "helm" {
  kubernetes {
    host                   = var.host
    token                  = var.token
    cluster_ca_certificate = var.cluster_ca_certificate
  }
}
resource "helm_release" "splunk-connect" {
  name  = "kafka"
  chart = "${path.module}/../../splunk_streaming_chart"

  set {
    name  = "streaminglite.servers"
    #value = module.mod_eventstream_topic.kafka_brokers_sasl //when event_stream_topic module is used to get sasl broker values
    value = var.event_stream_brokers_sasl
  }

  set {
    name  = "ibmcloud.apikey"
    value = var.ibmcloud_api_key
  }
}
resource "null_resource" "kafka_port_forward" {
    depends_on = [helm_release.splunk-connect]
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
      kubectl port-forward service/kafka-splunk-streaming-lite-connect  8083 &
    EOT
    environment = {
      API_KEY = self.triggers.API_KEY
      REGION=self.triggers.REGION
      RESOURCE_GROUP=self.triggers.RESOURCE_GROUP
      CLUSTER_ID=self.triggers.CLUSTER_ID
    }
    }
}
resource "time_sleep" "wait_30_seconds" {
  depends_on = [helm_release.splunk-connect]
  create_duration = "30s"
  triggers = {
    connector = var.splunk_connector_name
  }
}
provider "kafka-connect" {
  url = "http://localhost:8083"
}

resource "kafka-connect_connector" "kafka-connect-sink" {
  depends_on = [helm_release.splunk-connect,time_sleep.wait_30_seconds]
  name = var.splunk_connector_name
  config = {
    "name"            = var.splunk_connector_name
    "connector.class"= "com.splunk.kafka.connect.SplunkSinkConnector"
    "tasks.max"= "3"
    "splunk.indexes"= var.splunk_index
    "topics" = var.event_stream_topic
    "splunk.hec.uri"= var.splunk_hec_uri
    "splunk.hec.token"=var.splunk_hec_token
    } 
}

