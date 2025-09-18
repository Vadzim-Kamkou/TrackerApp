protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate)
}
