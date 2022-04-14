locals {
  path_module = var.path_module != "unset" ? var.path_module : path.module
}

variable "path_module" {
  default = "unset"
}

variable "naming_suffix" {
  default = "apps-test-dq"
}


variable "namespace" {
  default = "test"
}

variable "int_tab_monitor_name" {
  default = "int-tab-monitor"
}

variable "int_tab_monitor_lambda_run" {
  default = "1380"
}

variable "int_tab_input_bucket" {
  default = "s3-dq-data-archive-bucket"
}

variable "output_path_int_tab" {
  default = "tableau-int/green/"
}

variable "ext_tab_monitor_name" {
  default = "ext-tab-monitor"
}

variable "ext_tab_monitor_lambda_run" {
  default = "900"
}

variable "ext_tab_input_bucket" {
  default = "s3-dq-data-archive-bucket"
}

variable "output_path_ext_tab" {
  default = "tableau-ext/green/"
}

variable "kms_key_s3" {
  description = "The ARN of the KMS key that is used to encrypt S3 buckets"
  default     = "arn:aws:kms:eu-west-2:797728447925:key/ad7169c4-6d6a-4d21-84ee-a3b54f4bef87"
}
