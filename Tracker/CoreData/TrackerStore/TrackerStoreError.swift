enum TrackerStoreError: Error {
    case decodingErrorInvalidColor
    case decodingErrorInvalidId
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidName
    case decodingErrorInvalidSchedule
    case trackerNotFound
}
