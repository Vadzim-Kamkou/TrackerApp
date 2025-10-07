enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case trackerCategoryNotFound
    case categoryAlreadyExists
    case trackerNotFound
}
