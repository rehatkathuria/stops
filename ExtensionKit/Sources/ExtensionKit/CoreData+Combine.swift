import Combine
import CoreData

public final class FetchedResultsPublisher<ResultType>: Publisher where ResultType: NSFetchRequestResult {
	let request: NSFetchRequest<ResultType>
	let context: NSManagedObjectContext

	public init(
		request: NSFetchRequest<ResultType>,
		context: NSManagedObjectContext
	) {
		self.request = request
		self.context = context
	}

	// MARK: - Publisher

	public typealias Output = [ResultType]
	public typealias Failure = NSError

	public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
		subscriber.receive(subscription: FetchedResultsSubscription(
			subscriber: subscriber,
			request: request,
			context: context
		))
	}
}

private final class FetchedResultsSubscription
<SubscriberType, ResultType>
: NSObject, Subscription, NSFetchedResultsControllerDelegate
where
SubscriberType: Subscriber,
SubscriberType.Input == [ResultType],
SubscriberType.Failure == NSError,
ResultType: NSFetchRequestResult {

	init(
		subscriber: SubscriberType,
		request: NSFetchRequest<ResultType>,
		context: NSManagedObjectContext
	) {
		self.subscriber = subscriber
		self.request = request
		self.context = context
	}

	private(set) var subscriber: SubscriberType?
	private(set) var request: NSFetchRequest<ResultType>?
	private(set) var context: NSManagedObjectContext?
	private(set) var controller: NSFetchedResultsController<ResultType>?

	// MARK: - Subscription

	func request(_ demand: Subscribers.Demand) {
		guard
			demand > 0,
			let subscriber = subscriber,
			let request = request,
			let context = context
		else { return }

		controller = NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		controller?.delegate = self

		do {
			try controller?.performFetch()
			if let fetchedObjects = controller?.fetchedObjects {
				_ = subscriber.receive(fetchedObjects)
			}
		} catch {
			subscriber.receive(completion: .failure(error as NSError))
		}
	}

	// MARK: - Cancellable

	func cancel() {
		subscriber = nil
		controller = nil
		request = nil
		context = nil
	}

	// MARK: - NSFetchedResultsControllerDelegate

	func controllerDidChangeContent(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>
	) {
		guard
			let subscriber = subscriber,
			controller == self.controller,
			let fetchedObjects = self.controller?.fetchedObjects
		else { return }

		_ = subscriber.receive(fetchedObjects)
	}
}
