protocol TrackerRecordStoreDelegate: AnyObject {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate)
}
