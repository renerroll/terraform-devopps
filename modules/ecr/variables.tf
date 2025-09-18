variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten"
  type        = string
  default     = "MUTABLE"
  validation {
    condition = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image mutability must be either MUTABLE or IMMUTABLE"
  }
}

variable "force_delete" {
  type        = bool
  description = "If true, deleting the repository automatically deletes all images inside"
  default     = false
}

variable "image_retention_count" {
  description = "How many images to keep before expiring old ones"
  type        = number
  default     = 10
}

variable "scan_on_push" {
  description = "Whether to enable vulnerability scanning on image push"
  type        = bool
  default     = true
}