variable "bucketName" {
  description = "bucketname"
}

variable "commonTags" {
  type        = "map"
  description = "map of common tags to be applied"
}

variable "envName" {
  description = "describe environement eg.dev/prod etc.."
}
