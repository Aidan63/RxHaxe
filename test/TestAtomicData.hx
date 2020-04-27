package;

import rx.AtomicData;
import buddy.BuddySuite;

using buddy.Should;

class TestAtomicData extends BuddySuite
{
  public function new()
  {
    describe('AtomicData', {

      it('can get the value without acquiring the mutex', {
        final v = new AtomicData(7);
        v.unsafe_get().should.be(7);
      });

      it('can get the value', {
        final v = new AtomicData(7);
        v.get().should.be(7);
      });

      it('can set the value without acquiring the mutex', {
        final v = new AtomicData(7);
        v.unsafe_set(14);
        v.get().should.be(14);
      });

      it('can set the value', {
        final v = new AtomicData(7);
        v.set(14);
        v.get().should.be(14);
      });

      it('can get the current value and update it to a new value', {
        final v = new AtomicData(7);
        v.get_and_set(14).should.be(7);
        v.get().should.be(14);
      });

      it('can run a function after acquiring the data', {
        final v = new AtomicData(7);
        v.update(i -> i + 1);
        v.get().should.be(8);
      });

      it('can run a function after acquiring the data and return the value', {
        final v = new AtomicData(7);
        v.update_and_get(i -> i + 1).should.be(8);
      });

      it('will update the data only if the current value is equal to a specified value', {
        final v = new AtomicData(7);
        v.compare_and_set(7, 14);
        v.get().should.be(14);
        v.compare_and_set(7, 21);
        v.get().should.be(14);
      });

      it('will update the data only if the predicate function returns true', {
        final v = new AtomicData(7);
        v.update_if(_current -> true, _current -> _current + 1);
        v.get().should.be(8);
        v.update_if(_current -> false, _current -> _current + 1);
        v.get().should.be(8);
      });
    });
  }
}