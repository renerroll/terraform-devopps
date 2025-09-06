variable "repository_name" {
  type        = string
  description = "Name of the ECR repository (must be unique per AWS account and region)."
}

variable "scan_on_push" {
  type        = bool
  description = "Whether to enable image vulnerability scanning on push."
  default     = true
}

variable "image_tag_mutability" {
  type        = string
  description = "Defines whether tags can be overwritten (MUTABLE) or locked (IMMUTABLE)."
  default     = "MUTABLE"
}

variable "force_delete" {
  type        = bool
  description = "If true, deleting the repo will also remove all contained images."
  default     = true
}

variable "repository_policy" {
  type        = string
  description = "Optional JSON-formatted access policy for the repository."
  default     = null
}
