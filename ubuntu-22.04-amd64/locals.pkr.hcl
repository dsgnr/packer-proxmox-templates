locals {
  # "timestamp" template function replacement
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  use_iso_file = var.iso_file != null ? true : false

  cloud_init_storage_pool = coalesce(var.cloud_init_storage_pool, var.disk_storage_pool)
}
