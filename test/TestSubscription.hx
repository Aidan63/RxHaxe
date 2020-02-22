
import buddy.BuddySuite;
import rx.Subscription;
import rx.disposables.Boolean;
import rx.disposables.Composite;
import rx.disposables.SingleAssignment;
import rx.disposables.MultipleAssignment;
import hx.concurrent.thread.ThreadPool;

using buddy.Should;

class TestSubscription extends BuddySuite
{
    public function new()
    {
        describe('subscriptions', {
            it('will only unsubscribe once', {
                var counter     = 0;
                var unsubscribe = Subscription.create(() -> counter = incr(counter));

                unsubscribe.unsubscribe();
                unsubscribe.unsubscribe();

                counter.should.be(1);
            });

            it('can track if a subscription has been unsubscribed', {
                var counter     = 0;
                var unsubscribe = Boolean.create(() -> counter = incr(counter));

                unsubscribe.is_unsubscribed().should.be(false);
                unsubscribe.unsubscribe();
                unsubscribe.is_unsubscribed().should.be(true);
                unsubscribe.unsubscribe();
                unsubscribe.is_unsubscribed().should.be(true);
                counter.should.be(1);
            });

            it('will unsubscribe from all children in a composite subscription', {
                var counter   = 0;
                var composite = Composite.create([]);

                composite.add(Subscription.create(() -> counter = incr(counter)));
                composite.add(Subscription.create(() -> counter = incr(counter)));
                composite.unsubscribe();

                counter.should.be(2);
            });

            it('can unsubscribe from all threaded child subscriptions in a composite subscription', {
                var counter   = 0;
                var maxTasks  = 10;
                var composite = Composite.create([]);
                var executor  = new ThreadPool(2);

                for (_ in 0...maxTasks)
                {
                    executor.submit(_ctx -> {
                        composite.add(Subscription.create(() -> counter = incr(counter)));
                    });
                }

                composite.unsubscribe();

                if (executor.awaitCompletion(1000))
                {
                    counter.should.be(maxTasks);
                }
                else
                {
                    fail('threadpool took too long to complete its tasks');
                }
            });

            it('can remove subscriptions from a composite subscription', {
                final composite = Composite.create();
                final sub1 = Subscription.empty();
                final sub2 = Subscription.empty();

                composite.add(sub1);
                composite.add(sub2);
                composite.remove(sub1);

                sub1.is_unsubscribed().should.be(true);
                sub2.is_unsubscribed().should.be(false);
            });

            it('can clear all child subscriptions from a composite subscription', {
                final composite = Composite.create();
                final sub1 = Subscription.empty();
                final sub2 = Subscription.empty();
                final sub3 = Subscription.empty();

                composite.add(sub1);
                composite.add(sub2);
                composite.clear();

                sub1.is_unsubscribed().should.be(true);
                sub2.is_unsubscribed().should.be(true);
                composite.is_unsubscribed().should.be(false);

                composite.add(sub3);
                composite.unsubscribe();

                sub3.is_unsubscribed().should.be(true);
                composite.is_unsubscribed().should.be(true);
            });

            it('will not unsubscribe composite subscriptions if they have already been unsubscribed', {
                var counter   = 0;
                var composite = Composite.create();

                composite.add(Subscription.create(() -> counter = incr(counter)));
                composite.unsubscribe();
                composite.unsubscribe();
                composite.unsubscribe();

                counter.should.be(1);
            });

            it('will not unsubscribe composite subscriptions if they have already been unsubscribed even when called from another thread', {
                var counter   = 0;
                var maxTasks  = 10;
                var composite = Composite.create([ Subscription.create(() -> counter = incr(counter)) ]);
                var executor  = new ThreadPool(2);

                for (_ in 0...maxTasks)
                {
                    executor.submit(_ctx -> {
                        composite.unsubscribe();
                    });
                }

                if (executor.awaitCompletion(1000))
                {
                    counter.should.be(1);
                }
                else
                {
                    fail('threadpool took too long to complete its tasks');
                }
            });

            it('will remember the previous unsubscribed state when assigning new subscriptions to a multi assignment object', {
                final multiple = MultipleAssignment.create(Subscription.empty());

                var unsubscribed1 = false;
                var subscription1 = Subscription.create(() -> unsubscribed1 = true);

                multiple.set(subscription1);
                multiple.is_unsubscribed().should.be(false);

                var unsubscribed2 = false;
                var subscription2 = Subscription.create(() -> unsubscribed2 = true);
                
                multiple.set(subscription2);
                multiple.is_unsubscribed().should.be(false);
                unsubscribed1.should.be(false);

                multiple.unsubscribe();
                multiple.is_unsubscribed().should.be(true);
                unsubscribed2.should.be(true);

                var unsubscribed3 = false;
                var subscription3 = Subscription.create(() -> unsubscribed3 = true);

                multiple.set(subscription3);
                multiple.is_unsubscribed().should.be(true);
                unsubscribed3.should.be(true);
            });

            it('will throw an exception when trying to re-assign a single subscription', {
                final single = SingleAssignment.create();

                var unsubscribed1 = false;
                var subscription1 = Subscription.create(() -> unsubscribed1 = true);

                single.set(subscription1);
                single.is_unsubscribed().should.be(false);

                var unsubscribed2 = false;
                var subscription2 = Subscription.create(() -> unsubscribed2 = true);

                single.set.bind(subscription2).should.throwValue('SingleAssignment');

                unsubscribed2.should.be(false);
                subscription2.is_unsubscribed().should.be(false);
            });
        });
    }

    function incr(i) return i++;
}