group "default" {
  targets = [
    "0_19_0",
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

variable "REGISTRY_CACHE" {
  default = "ghcr.io/n0rthernl1ghts/kopia-server-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [kopia_version, alpine_version]
  result = {
    KOPIA_VERSION = kopia_version
    ALPINE_VERSION =  notequal(alpine_version, "") ? alpine_version : "3.21"
  }
}

# Get the cache-from configuration
function "get-cache-from" {
  params = [version]
  result = [
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-tags("1.19.0", ["0.19", "latest"])
function "get-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "ghcr.io/n0rthernl1ghts/kopia-server:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "ghcr.io/n0rthernl1ghts/kopia-server:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "0_19_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("0.19.0")
  cache-to   = get-cache-to("0.19.0")
  tags       = get-tags("0.19.0", ["0", "0.19", "latest", "release"])
  args       = get-args("0.19.0", "")
}