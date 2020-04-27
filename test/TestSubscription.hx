import buddy.BuddySuite;
import rx.Subscription;
import rx.disposables.Binary;
import rx.disposables.Boolean;
import rx.disposables.Composite;
import rx.disposables.MultipleAssignment;

using buddy.Should;

class TestSubscription extends BuddySuite {
	public function new() {
		describe('subscriptions', {
			it('will only unsubscribe once', {
				var counter = 0;
				var unsubscribe = Subscription.create(() -> counter++);

				unsubscribe.unsubscribe();
				unsubscribe.unsubscribe();

				counter.should.be(1);
			});

			it('can track if a subscription has been unsubscribed', {
				var counter = 0;
				var unsubscribe = new Boolean(() -> counter++);

				unsubscribe.isUnsubscribed().should.be(false);
				unsubscribe.unsubscribe();
				unsubscribe.isUnsubscribed().should.be(true);
				unsubscribe.unsubscribe();
				unsubscribe.isUnsubscribed().should.be(true);
				counter.should.be(1);
			});

			it('will unsubscribe from all children in a composite subscription', {
				var counter = 0;
				var composite = new Composite();

				composite.add(Subscription.create(() -> counter++));
				composite.add(Subscription.create(() -> counter++));
				composite.unsubscribe();

				counter.should.be(2);
			});

#if (target.threaded)
			it('can unsubscribe from all threaded child subscriptions in a composite subscription', {
				var counter = 0;
				var maxTasks = 10;
				var composite = new Composite();
				var executor = new hx.concurrent.thread.ThreadPool(2);

				for (_ in 0...maxTasks) {
					executor.submit(_ctx -> {
						composite.add(Subscription.create(() -> counter++));
					});
				}

				composite.unsubscribe();

				if (executor.awaitCompletion(1000)) {
					counter.should.be(maxTasks);
				} else {
					fail('threadpool took too long to complete its tasks');
				}
			});
#end

			it('can remove subscriptions from a composite subscription', {
				final composite = new Composite();
				final sub1 = Subscription.empty();
				final sub2 = Subscription.empty();

				composite.add(sub1);
				composite.add(sub2);
				composite.remove(sub1);

				sub1.isUnsubscribed().should.be(true);
				sub2.isUnsubscribed().should.be(false);
			});

			it('can clear all child subscriptions from a composite subscription', {
				final composite = new Composite();
				final sub1 = Subscription.empty();
				final sub2 = Subscription.empty();
				final sub3 = Subscription.empty();

				composite.add(sub1);
				composite.add(sub2);
				composite.clear();

				sub1.isUnsubscribed().should.be(true);
				sub2.isUnsubscribed().should.be(true);
				composite.isUnsubscribed().should.be(false);

				composite.add(sub3);
				composite.unsubscribe();

				sub3.isUnsubscribed().should.be(true);
				composite.isUnsubscribed().should.be(true);
			});

			it('will not unsubscribe composite subscriptions if they have already been unsubscribed', {
				var counter = 0;
				var composite = new Composite();

				composite.add(Subscription.create(() -> counter++));
				composite.unsubscribe();
				composite.unsubscribe();
				composite.unsubscribe();

				counter.should.be(1);
			});

#if (target.threaded)
			it('will not unsubscribe composite subscriptions if they have already been unsubscribed even when called from another thread', {
				var counter = 0;
				var maxTasks = 10;
				var composite = new Composite([ Subscription.create(() -> counter++) ]);
				var executor = new hx.concurrent.thread.ThreadPool(2);

				for (_ in 0...maxTasks) {
					executor.submit(_ctx -> {
						composite.unsubscribe();
					});
				}

				if (executor.awaitCompletion(1000)) {
					counter.should.be(1);
				} else {
					fail('threadpool took too long to complete its tasks');
				}
			});
#end

			it('will remember the previous unsubscribed state when assigning new subscriptions to a multi assignment object', {
				final multiple = new MultipleAssignment(Subscription.empty());

				var unsubscribed1 = false;
				var subscription1 = Subscription.create(() -> unsubscribed1 = true);

				multiple.set(subscription1);
				multiple.isUnsubscribed().should.be(false);

				var unsubscribed2 = false;
				var subscription2 = Subscription.create(() -> unsubscribed2 = true);

				multiple.set(subscription2);
				multiple.isUnsubscribed().should.be(false);
				unsubscribed1.should.be(false);

				multiple.unsubscribe();
				multiple.isUnsubscribed().should.be(true);
				unsubscribed2.should.be(true);

				var unsubscribed3 = false;
				var subscription3 = Subscription.create(() -> unsubscribed3 = true);

				multiple.set(subscription3);
				multiple.isUnsubscribed().should.be(true);
				unsubscribed3.should.be(true);
			});
		});
	}
}
