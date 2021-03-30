variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
}
variable "create_cluster" {
  description = "Assign true if you want to create a cluster"
  default     = false
}

#### Event streams variables ####
variable "event_stream_region" {
  description = "Region of the source Event Stream instance (us-south, eu-de, etc.)"
  default = "us-south"
}
variable "event_stream_resource_group" {
  description = "Resource group name of the source Event Stream instance"
  default = "Default"
}
variable "cluster_name" {
  description = "Name of source Event Stream instance to connect to"
}
variable "event_stream_topic" {
  description = "Name of the event stream instance topic"
}

variable "event_stream_name" {
  description = "Name of the event stream instance topic"
}
#### Splunk variables ####
variable "splunk_index" {
  description = "A repository for Splunk data"
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
