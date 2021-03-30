terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
    }
    kafka-connect = {
      source = "Mongey/kafka-connect"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}