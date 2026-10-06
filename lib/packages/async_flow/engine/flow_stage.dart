enum FlowStage {
  IDLE,
  WAITING, // polling / recall
  SUCCESS, // Generic success (alternative to APPROVED)
  FAILED,
  TIMEOUT,
  REQUESTING, // Making API request
  UPLOADING, // Uploading data
  DOWNLOADING, // Downloading data
  NETWORK_ERROR, // Network/connectivity issues
}
