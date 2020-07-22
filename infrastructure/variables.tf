variable "resource-group-name" {
  description = "The resource group to house all the Azure resources."
  type        = string
  default     = "aks-oidc-proxy"
}

variable "region" {
  description = "The cloud location where resources will be placed."
  type        = string
  default     = "East US"
}

variable "dns-zone-name" {
  description = "The name of the DNS Zone that will hold records for the various services that will be deployed."
  type        = string
}

variable "aks-cluster-name" {
  description = "The name of the Kubernetes cluster."
  type        = string
}
