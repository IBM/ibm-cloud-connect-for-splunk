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
