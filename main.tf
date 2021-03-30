
data "ibm_resource_group" "resource_group" {
  name = var.event_stream_resource_group
}

module "classic_kubernetes_single_zone_cluster" {
  source                = "git::https://github.com/kavya498/terraform-ibm-cluster.git//modules/classic-kubernetes-single-zone"
  count                 = (var.create_cluster == true ? 1 : 0)
  cluster_name          = var.cluster_name
  worker_zone           = "dal13"
  hardware              = "shared"
  resource_group_id     = data.ibm_resource_group.resource_group.id
  worker_nodes_per_zone = 1
  worker_pool_flavor    = "b3c.16x64"
  public_vlan           = "3043770"
  private_vlan          = "private_vlan"
  tags                  = ["kafka", "splunk"]
}
data "ibm_container_cluster" "cluster" {
  name              = (var.create_cluster == true ? module.classic_kubernetes_single_zone_cluster[0].container_cluster_id : var.cluster_name)
  resource_group_id = data.ibm_resource_group.resource_group.id
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id =data.ibm_container_cluster.cluster.id
  config_dir      = "./"
}

data "ibm_resource_instance" "es_instance" {
  name              = var.event_stream_name
  resource_group_id = data.ibm_resource_group.resource_group.id
}
data "ibm_event_streams_topic" "es_topic" {
  resource_instance_id = data.ibm_resource_instance.es_instance.id
  name                 = var.event_stream_topic
}
module "splunk" {
  source = "./modules/splunk"
  host                   = data.ibm_container_cluster_config.cluster_config.host
  token                  = data.ibm_container_cluster_config.cluster_config.token
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
  ibmcloud_api_key=var.ibmcloud_api_key
  event_stream_region=var.event_stream_region
  event_stream_resource_group=var.event_stream_resource_group
  cluster_name=var.cluster_name
}
module "splunk-connect" {
  source = "./modules/splunk-connect"
  host                   = data.ibm_container_cluster_config.cluster_config.host
  token                  = data.ibm_container_cluster_config.cluster_config.token
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_config.ca_certificate
  ibmcloud_api_key=var.ibmcloud_api_key
  event_stream_region=var.event_stream_region
  event_stream_resource_group=var.event_stream_resource_group
  cluster_name=var.cluster_name
  splunk_index= var.splunk_index
  event_stream_topic = var.event_stream_topic
  splunk_hec_uri= var.splunk_hec_uri
  splunk_hec_token=var.splunk_hec_token
  splunk_connector_name = var.splunk_connector_name
  event_stream_brokers_sasl = join("\\,",data.ibm_event_streams_topic.es_topic.kafka_brokers_sasl)
}
