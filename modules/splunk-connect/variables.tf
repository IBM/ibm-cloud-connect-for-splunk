variable "event_stream_region" {
  description = "Region of the source Event Stream instance (us-south, eu-de, etc.)"
}
variable "event_stream_resource_group" {
  description = "Resource group name of the source Event Stream instance"
}
variable "cluster_name" {
  description = "Name of source Event Stream instance to connect to"
}
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
}
variable "host" {
  description = "Cluster config host"
}
variable "token" {
  description = "Cluster config token"
}
variable "cluster_ca_certificate" {
  description = "Cluster config ca_certificate"
}
variable "splunk_index" {
  description = "A repository for Splunk data"
}
variable "event_stream_topic" {
  description = "Name of the event stream instance topic"
}
variable "splunk_hec_uri" {
  description = "URL for the Splunk - HTTP Event Collector"
}
variable "splunk_hec_token" {
  description = "Auth token for the Splunk - HTTP Event Collector"
}
variable "splunk_connector_name" {
  description = "name for the splunk connector"
}
variable "event_stream_brokers_sasl" {
  description = "kafka broker sasl of event stream topic " 
}