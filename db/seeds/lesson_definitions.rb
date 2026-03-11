# 25 lessons across 5 modules
# All content targets developers with Python/Java background.
# prerequisite_ids form a DAG within each module (no cross-module prereqs for simplicity).
# IDs are deterministic: module N uses lesson IDs (N-1)*5+1 .. N*5

LESSON_DEFINITIONS = [
  # ───────────────────────────────────────────────────────────
  # Module 1: Blocks, Procs & Lambdas  (lesson IDs 1-5)
  # ───────────────────────────────────────────────────────────
  {
    id: 1,
    module_id: 1,
    title: "Passing Blocks with yield",
    position_in_module: 1,
    estimated_minutes: 5,
    prerequisite_ids: [],
    content_body: <<~MARKDOWN,
      ## Passing Blocks with `yield`

      Ruby methods accept an implicit block argument via `yield`. Unlike Python's callable
      parameter or Java's functional interface, no explicit parameter declaration is needed.

      ```ruby
      def time_it
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        yield
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
        elapsed
      end

      elapsed = time_it { sleep(0.01) }
      puts elapsed.round(3)
      ```

      Use `block_given?` to make the block optional:

      ```ruby
      def maybe_transform(value)
        block_given? ? yield(value) : value
      end

      maybe_transform(5) { |x| x * 2 }  # => 10
      maybe_transform(5)                  # => 5
      ```

      `yield` passes values to the block as arguments and receives the block's return value.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses explicit callable parameters or decorators. The `yield` pattern maps to
      passing a callable:

      ```python
      import time

      def time_it(fn):
          start = time.monotonic()
          fn()
          return time.monotonic() - start

      elapsed = time_it(lambda: time.sleep(0.01))
      ```

      `block_given?` has no direct equivalent; Python uses default `None` parameter.
    TEXT
    java_equivalent: <<~TEXT
      Java uses functional interfaces (e.g., `Runnable`, `Supplier<T>`, `Function<T,R>`):

      ```java
      public static double timeIt(Runnable block) {
          long start = System.nanoTime();
          block.run();
          return (System.nanoTime() - start) / 1e9;
      }

      double elapsed = timeIt(() -> Thread.sleep(10));
      ```

      `block_given?` maps to checking if the functional interface parameter is non-null.
    TEXT
  },
  {
    id: 2,
    module_id: 1,
    title: "Explicit Block Parameters with &block",
    position_in_module: 2,
    estimated_minutes: 5,
    prerequisite_ids: [1],
    content_body: <<~MARKDOWN,
      ## Explicit Block Parameters with `&block`

      Capturing a block with `&block` converts it to a `Proc` object, enabling storage,
      introspection, and forwarding.

      ```ruby
      def capture_and_call(&block)
        puts block.class    # Proc
        puts block.arity
        block.call(42)
      end

      capture_and_call { |n| n * 2 }
      ```

      Forwarding a captured block to another method:

      ```ruby
      def outer(&blk)
        inner(&blk)
      end

      def inner
        yield 99
      end

      outer { |n| puts n }  # => 99
      ```

      The `&` prefix converts between blocks and Proc objects in both directions.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python passes callables explicitly. No implicit block protocol:

      ```python
      def capture_and_call(fn):
          print(type(fn))       # <class 'function'>
          print(fn.__code__.co_argcount)
          return fn(42)

      capture_and_call(lambda n: n * 2)
      ```

      Forwarding is straightforward — pass `fn` as a named argument.
    TEXT
    java_equivalent: <<~TEXT
      Java stores functional interfaces in typed variables:

      ```java
      import java.util.function.Function;

      static <T, R> R captureAndCall(Function<T, R> fn, T arg) {
          System.out.println(fn.getClass().getName());
          return fn.apply(arg);
      }

      captureAndCall(n -> n * 2, 42);
      ```

      Forwarding uses the same typed reference — no special operator needed.
    TEXT
  },
  {
    id: 3,
    module_id: 1,
    title: "Proc.new vs proc vs lambda",
    position_in_module: 3,
    estimated_minutes: 5,
    prerequisite_ids: [1, 2],
    content_body: <<~MARKDOWN,
      ## `Proc.new` vs `proc` vs `lambda`

      Ruby offers three ways to create callable objects. The critical difference is arity
      enforcement and `return` semantics.

      ```ruby
      strict = lambda { |x, y| x + y }
      loose  = proc   { |x, y| (x || 0) + (y || 0) }

      strict.call(1, 2)    # => 3
      loose.call(1)        # => 1  (y is nil, not ArgumentError)
      ```

      `return` inside a `lambda` returns from the lambda. Inside a `proc`, it returns
      from the enclosing method:

      ```ruby
      def with_lambda
        lam = lambda { return 10 }
        lam.call
        20
      end

      def with_proc
        prc = proc { return 10 }
        prc.call
        20
      end

      with_lambda  # => 20
      with_proc    # => 10
      ```

      `lambda?` distinguishes the two at runtime.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python `lambda` is expression-only; `def` creates named functions. Neither has
      `Proc`-style lenient arity — all Python callables enforce argument count:

      ```python
      import functools

      strict = lambda x, y: x + y
      strict(1, 2)   # => 3
      strict(1)      # TypeError
      ```

      `return` inside a nested function always exits that function scope — no `Proc`-style
      enclosing-method return.
    TEXT
    java_equivalent: <<~TEXT
      Java lambdas enforce arity strictly via their functional interface contract:

      ```java
      import java.util.function.BiFunction;

      BiFunction<Integer, Integer, Integer> strict = (x, y) -> x + y;
      strict.apply(1, 2); // => 3
      // strict.apply(1) — compile error: wrong number of arguments
      ```

      `return` inside a lambda exits the lambda body; it cannot propagate to the
      enclosing method (unlike Ruby `proc`).
    TEXT
  },
  {
    id: 4,
    module_id: 1,
    title: "Closures and Variable Capture",
    position_in_module: 4,
    estimated_minutes: 5,
    prerequisite_ids: [3],
    content_body: <<~MARKDOWN,
      ## Closures and Variable Capture

      Ruby blocks, procs, and lambdas close over the surrounding binding at definition
      time, capturing variables by reference (not by value).

      ```ruby
      def make_counter(start)
        count = start
        increment = lambda { count += 1; count }
        reset     = lambda { count = start }
        [increment, reset]
      end

      inc, rst = make_counter(0)
      inc.call  # => 1
      inc.call  # => 2
      rst.call
      inc.call  # => 1
      ```

      Shared mutable state via closure — both lambdas reference the same `count` variable.

      ```ruby
      adders = (1..3).map { |n| lambda { |x| x + n } }
      adders[0].call(10)  # => 11
      adders[1].call(10)  # => 12
      adders[2].call(10)  # => 13
      ```

      Unlike JavaScript's `var` loop variable issue, Ruby block variables are scoped
      per iteration.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python closures also capture by reference but require `nonlocal` to mutate:

      ```python
      def make_counter(start):
          count = [start]  # mutable container trick, or use nonlocal

          def increment():
              count[0] += 1
              return count[0]

          def reset():
              count[0] = start

          return increment, reset

      inc, rst = make_counter(0)
      inc()  # => 1
      ```

      Classic Python loop gotcha: `lambda: i` in a loop captures the loop variable
      by reference (same binding for all lambdas at loop end).
    TEXT
    java_equivalent: <<~TEXT
      Java lambdas capture "effectively final" variables — no mutation after capture:

      ```java
      import java.util.function.IntSupplier;

      static IntSupplier[] makeAdders() {
          return java.util.stream.IntStream.rangeClosed(1, 3)
              .mapToObj(n -> (IntSupplier) () -> 10 + n)
              .toArray(IntSupplier[]::new);
      }

      makeAdders()[0].getAsInt(); // => 11
      ```

      Mutable shared state requires an explicit wrapper (e.g., `AtomicInteger` or a
      single-element array) since lambdas cannot capture non-final locals.
    TEXT
  },
  {
    id: 5,
    module_id: 1,
    title: "Method Objects and Symbol#to_proc",
    position_in_module: 5,
    estimated_minutes: 5,
    prerequisite_ids: [3, 4],
    content_body: <<~MARKDOWN,
      ## Method Objects and `Symbol#to_proc`

      Ruby methods are first-class via `method(:name)`, producing a `Method` object that
      responds to `call`, `arity`, and `to_proc`.

      ```ruby
      def double(x)
        x * 2
      end

      m = method(:double)
      m.call(5)             # => 10
      [1, 2, 3].map(&m)     # => [2, 4, 6]
      ```

      `Symbol#to_proc` is syntactic sugar: `&:upcase` expands to
      `{ |obj| obj.upcase }`:

      ```ruby
      words = %w[ruby python java]
      words.map(&:upcase)     # => ["RUBY", "PYTHON", "JAVA"]
      words.select(&:frozen?) # => []
      ```

      Compose methods using `>>`/`<<` (Ruby 2.6+):

      ```ruby
      inc  = method(:succ.to_proc)
      dbl  = ->(x) { x * 2 }
      pipe = dbl >> method(:puts)
      pipe.call(3)  # prints 6
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `methodcaller` or direct function references:

      ```python
      from operator import methodcaller

      upcase = methodcaller("upper")
      words = ["ruby", "python", "java"]
      list(map(upcase, words))  # ["RUBY", "PYTHON", "JAVA"]

      # Direct method reference:
      list(map(str.upper, words))  # same result
      ```

      `functools.reduce(compose, fns)` approximates `>>` composition.
    TEXT
    java_equivalent: <<~TEXT
      Java uses method references with `::` and `Function.andThen`/`compose`:

      ```java
      import java.util.List;
      import java.util.function.Function;

      List<String> words = List.of("ruby", "python", "java");
      words.stream()
           .map(String::toUpperCase)
           .toList();  // ["RUBY", "PYTHON", "JAVA"]

      Function<Integer, Integer> dbl = x -> x * 2;
      Function<Integer, Integer> inc = x -> x + 1;
      Function<Integer, Integer> pipe = dbl.andThen(inc);
      pipe.apply(3);  // => 7
      ```
    TEXT
  },

  # ───────────────────────────────────────────────────────────
  # Module 2: Enumerable Methods  (lesson IDs 6-10)
  # ───────────────────────────────────────────────────────────
  {
    id: 6,
    module_id: 2,
    title: "map, select, and reject",
    position_in_module: 1,
    estimated_minutes: 5,
    prerequisite_ids: [],
    content_body: <<~MARKDOWN,
      ## `map`, `select`, and `reject`

      `Enumerable#map` transforms every element; `select` retains matching elements;
      `reject` discards matching elements. All return a new `Array`.

      ```ruby
      nums = [1, 2, 3, 4, 5, 6]

      doubled  = nums.map    { |n| n * 2 }      # [2, 4, 6, 8, 10, 12]
      evens    = nums.select { |n| n.even? }     # [2, 4, 6]
      odds     = nums.reject { |n| n.even? }     # [1, 3, 5]
      ```

      Chain without intermediate arrays using `lazy`:

      ```ruby
      result = (1..Float::INFINITY)
                 .lazy
                 .select { |n| n.odd? }
                 .map    { |n| n ** 2 }
                 .first(5)
      # => [1, 9, 25, 49, 81]
      ```

      `map` and `select` have destructive counterparts `map!` and `select!` that
      mutate the receiver in place.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python's built-in `map`/`filter` return lazy iterators; list comprehensions are
      often preferred:

      ```python
      nums = [1, 2, 3, 4, 5, 6]

      doubled = list(map(lambda n: n * 2, nums))
      evens   = list(filter(lambda n: n % 2 == 0, nums))
      odds    = [n for n in nums if n % 2 != 0]
      ```

      Lazy chaining uses generator expressions:
      `(n**2 for n in filter(lambda n: n % 2 != 0, range(1, 1_000_000)))`
    TEXT
    java_equivalent: <<~TEXT
      Java Streams provide `map`, `filter` (Ruby's `select`), and lazy evaluation:

      ```java
      import java.util.List;
      import java.util.stream.IntStream;

      List<Integer> nums = List.of(1, 2, 3, 4, 5, 6);

      List<Integer> doubled = nums.stream().map(n -> n * 2).toList();
      List<Integer> evens   = nums.stream().filter(n -> n % 2 == 0).toList();
      List<Integer> odds    = nums.stream().filter(n -> n % 2 != 0).toList();

      // Lazy infinite stream:
      List<Integer> first5OddSquares = IntStream.iterate(1, n -> n + 2)
          .mapToObj(n -> n * n).limit(5).toList();
      ```
    TEXT
  },
  {
    id: 7,
    module_id: 2,
    title: "reduce and inject",
    position_in_module: 2,
    estimated_minutes: 5,
    prerequisite_ids: [6],
    content_body: <<~MARKDOWN,
      ## `reduce` and `inject`

      `Enumerable#reduce` (alias `inject`) folds a collection into a single value.
      The accumulator is passed as the first block argument.

      ```ruby
      total = [1, 2, 3, 4, 5].reduce(0) { |sum, n| sum + n }
      # => 15

      product = [1, 2, 3, 4].inject(:*)
      # => 24
      ```

      Building a hash from pairs:

      ```ruby
      pairs = [[:a, 1], [:b, 2], [:c, 3]]
      pairs.reduce({}) { |h, (k, v)| h.merge(k => v) }
      # => {a: 1, b: 2, c: 3}
      ```

      Without an initial value, the first element is used as the accumulator:

      ```ruby
      [5, 3, 8, 1].reduce { |min, n| n < min ? n : min }
      # => 1  (same as .min)
      ```

      Prefer `each_with_object` when building a mutable accumulator to avoid
      repeated `merge` allocations (see next lesson).
    MARKDOWN
    python_equivalent: <<~TEXT,
      `functools.reduce` mirrors Ruby's `reduce`/`inject`:

      ```python
      from functools import reduce

      total   = reduce(lambda acc, n: acc + n, [1, 2, 3, 4, 5], 0)
      product = reduce(lambda acc, n: acc * n, [1, 2, 3, 4])

      pairs = [("a", 1), ("b", 2), ("c", 3)]
      result = reduce(lambda h, kv: {**h, kv[0]: kv[1]}, pairs, {})
      ```

      `sum()`, `min()`, `max()` are specialized built-ins preferred over `reduce`.
    TEXT
    java_equivalent: <<~TEXT
      `Stream.reduce` and `collect` serve equivalent roles:

      ```java
      import java.util.List;
      import java.util.Map;
      import java.util.stream.Collectors;

      int total = List.of(1, 2, 3, 4, 5).stream()
                      .reduce(0, Integer::sum);

      Map<String, Integer> map = List.of(
          Map.entry("a", 1), Map.entry("b", 2)
      ).stream().collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
      ```

      `Collectors.toMap` is preferred over `reduce` for building `Map` results.
    TEXT
  },
  {
    id: 8,
    module_id: 2,
    title: "each_with_object and inject with mutable state",
    position_in_module: 3,
    estimated_minutes: 5,
    prerequisite_ids: [7],
    content_body: <<~MARKDOWN,
      ## `each_with_object` and Mutable Accumulators

      `each_with_object` passes a mutable object alongside each element. Unlike `reduce`,
      the block's return value is ignored — the accumulator is returned unchanged.

      ```ruby
      words = %w[apple banana cherry apple banana apple]

      freq = words.each_with_object(Hash.new(0)) do |word, counts|
        counts[word] += 1
      end
      # => {"apple"=>3, "banana"=>2, "cherry"=>1}
      ```

      Grouping with `group_by` (specialized case):

      ```ruby
      %w[one two three four five six].group_by { |w| w.length }
      # => {3=>["one", "two", "six"], 5=>["three", "four"], 4=>["five"]}
      ```

      `tally` (Ruby 2.7+) replaces the `Hash.new(0)` pattern:

      ```ruby
      words.tally
      # => {"apple"=>3, "banana"=>2, "cherry"=>1}
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `collections.Counter` and `defaultdict`:

      ```python
      from collections import Counter, defaultdict

      words = ["apple", "banana", "cherry", "apple", "banana", "apple"]

      freq = Counter(words)
      # Counter({'apple': 3, 'banana': 2, 'cherry': 1})

      # each_with_object equivalent:
      freq2 = defaultdict(int)
      for w in words:
          freq2[w] += 1
      ```

      `itertools.groupby` exists but requires pre-sorted input unlike Ruby's `group_by`.
    TEXT
    java_equivalent: <<~TEXT
      `Collectors.groupingBy` and `Collectors.counting`:

      ```java
      import java.util.List;
      import java.util.Map;
      import java.util.stream.Collectors;

      List<String> words = List.of("apple","banana","cherry","apple","banana","apple");

      Map<String, Long> freq = words.stream()
          .collect(Collectors.groupingBy(w -> w, Collectors.counting()));
      // {apple=3, banana=2, cherry=1}

      Map<Integer, List<String>> byLength = words.stream()
          .collect(Collectors.groupingBy(String::length));
      ```
    TEXT
  },
  {
    id: 9,
    module_id: 2,
    title: "zip, flat_map, and chunk",
    position_in_module: 4,
    estimated_minutes: 5,
    prerequisite_ids: [6, 7],
    content_body: <<~MARKDOWN,
      ## `zip`, `flat_map`, and `chunk`

      `zip` combines parallel arrays element-by-element:

      ```ruby
      keys   = [:a, :b, :c]
      values = [1, 2, 3]
      pairs  = keys.zip(values)
      # => [[:a, 1], [:b, 2], [:c, 3]]
      Hash[pairs]
      # => {a: 1, b: 2, c: 3}
      ```

      `flat_map` maps then flattens one level (avoids `map.flatten(1)`):

      ```ruby
      [[1, 2], [3, 4], [5]].flat_map { |a| a.map { |n| n * 10 } }
      # => [10, 20, 30, 40, 50]
      ```

      `chunk` groups consecutive equal elements:

      ```ruby
      [1, 1, 2, 2, 3, 1, 1].chunk { |n| n }.map { |key, arr| [key, arr.length] }
      # => [[1, 2], [2, 2], [3, 1], [1, 2]]
      ```

      Compare `chunk` (consecutive) vs `group_by` (global grouping).
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python's `zip` is a built-in; `itertools` handles the rest:

      ```python
      import itertools

      keys, values = ["a", "b", "c"], [1, 2, 3]
      pairs = list(zip(keys, values))
      d = dict(pairs)

      nested = [[1, 2], [3, 4], [5]]
      flat = [n * 10 for sub in nested for n in sub]

      # chunk equivalent:
      data = [1, 1, 2, 2, 3, 1, 1]
      [(k, len(list(g))) for k, g in itertools.groupby(data)]
      # [(1, 2), (2, 2), (3, 1), (1, 2)]
      ```
    TEXT
    java_equivalent: <<~TEXT
      Java lacks a built-in `zip`; use `IntStream` indices or third-party libraries:

      ```java
      import java.util.List;
      import java.util.stream.IntStream;
      import java.util.stream.Collectors;

      List<String> keys   = List.of("a", "b", "c");
      List<Integer> values = List.of(1, 2, 3);

      var pairs = IntStream.range(0, keys.size())
          .mapToObj(i -> Map.entry(keys.get(i), values.get(i)))
          .toList();

      // flat_map:
      List<List<Integer>> nested = List.of(List.of(1,2), List.of(3,4), List.of(5));
      List<Integer> flat = nested.stream().flatMap(List::stream).toList();
      ```
    TEXT
  },
  {
    id: 10,
    module_id: 2,
    title: "Lazy Enumerators",
    position_in_module: 5,
    estimated_minutes: 5,
    prerequisite_ids: [6, 7, 8],
    content_body: <<~MARKDOWN,
      ## Lazy Enumerators

      `Enumerable#lazy` defers evaluation, enabling work on potentially infinite
      sequences without building intermediate arrays.

      ```ruby
      natural_numbers = (1..Float::INFINITY).lazy

      first_10_squares_of_evens = natural_numbers
        .select { |n| n.even? }
        .map    { |n| n ** 2 }
        .first(10)
      # => [4, 16, 36, 64, 100, 144, 196, 256, 324, 400]
      ```

      `Enumerator::Lazy` wraps any enumerator; force evaluation with `.force` or `.to_a`:

      ```ruby
      lazy_odds = Enumerator::Lazy.new(1..100) do |yielder, n|
        yielder << n if n.odd?
      end
      lazy_odds.first(3)
      # => [1, 3, 5]
      ```

      Chain lazy operations; only one pass over the data occurs at terminal evaluation.
      This is equivalent to Haskell-style lazy lists or Java Streams before `terminal ops`.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python generators are lazy by default:

      ```python
      import itertools

      def naturals():
          n = 1
          while True:
              yield n
              n += 1

      first_10 = list(itertools.islice(
          (n**2 for n in naturals() if n % 2 == 0),
          10
      ))
      # [4, 16, 36, ...]
      ```

      Generator expressions compose lazily without intermediate lists — equivalent
      to Ruby's `.lazy` chain.
    TEXT
    java_equivalent: <<~TEXT
      Java Streams are lazy until a terminal operation is called:

      ```java
      import java.util.List;
      import java.util.stream.Stream;

      List<Long> result = Stream.iterate(1L, n -> n + 1)
          .filter(n -> n % 2 == 0)
          .map(n -> n * n)
          .limit(10)
          .toList();
      // [4, 16, 36, 64, 100, 144, 196, 256, 324, 400]
      ```

      `Stream.iterate` with an unary operator is the Java equivalent of Ruby's
      infinite range `.lazy`.
    TEXT
  },

  # ───────────────────────────────────────────────────────────
  # Module 3: Object Model  (lesson IDs 11-15)
  # ───────────────────────────────────────────────────────────
  {
    id: 11,
    module_id: 3,
    title: "Modules as Namespaces and Mixins",
    position_in_module: 1,
    estimated_minutes: 5,
    prerequisite_ids: [],
    content_body: <<~MARKDOWN,
      ## Modules as Namespaces and Mixins

      Ruby modules serve two orthogonal purposes: namespacing constants/classes and
      providing mixin behavior via `include`/`extend`.

      ```ruby
      module Geometry
        PI = Math::PI

        class Circle
          def initialize(r) = @r = r
          def area = PI * @r ** 2
        end
      end

      Geometry::Circle.new(5).area.round(2)
      # => 78.54
      ```

      As a mixin, `include` inserts the module into the instance method lookup chain:

      ```ruby
      module Printable
        def print_info
          "\#{self.class.name}: \#{to_s}"
        end
      end

      class Report
        include Printable
        def to_s = "Q4 Revenue Report"
      end

      Report.new.print_info
      # => "Report: Q4 Revenue Report"
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses packages/modules for namespacing and multiple inheritance for mixins:

      ```python
      import math

      class Geometry:
          PI = math.pi

          class Circle:
              def __init__(self, r): self.r = r
              def area(self): return Geometry.PI * self.r ** 2

      Geometry.Circle(5).area()  # 78.539...

      # Mixin via multiple inheritance:
      class Printable:
          def print_info(self):
              return f"{type(self).__name__}: {self}"

      class Report(Printable):
          def __str__(self): return "Q4 Revenue Report"

      Report().print_info()
      ```
    TEXT
    java_equivalent: <<~TEXT
      Java uses packages for namespacing and interfaces (with default methods) for mixins:

      ```java
      package geometry;

      public class Circle {
          private final double radius;
          public Circle(double r) { this.radius = r; }
          public double area() { return Math.PI * radius * radius; }
      }

      // Mixin via interface with default method:
      interface Printable {
          default String printInfo() {
              return getClass().getSimpleName() + ": " + toString();
          }
      }

      class Report implements Printable {
          public String toString() { return "Q4 Revenue Report"; }
      }
      ```
    TEXT
  },
  {
    id: 12,
    module_id: 3,
    title: "include vs extend vs prepend",
    position_in_module: 2,
    estimated_minutes: 5,
    prerequisite_ids: [11],
    content_body: <<~MARKDOWN,
      ## `include` vs `extend` vs `prepend`

      Three mechanisms for mixing module methods into a class, each placing methods
      at different positions in the method lookup chain (MRO).

      ```ruby
      module Logging
        def log(msg) = puts "[LOG] \#{msg}"
      end

      class Service
        include Logging    # instance method: Service.new.log(...)
      end

      class ServiceFactory
        extend Logging     # class method: ServiceFactory.log(...)
      end
      ```

      `prepend` inserts the module *before* the class in the MRO, enabling decoration:

      ```ruby
      module Timed
        def process(data)
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          result = super
          puts "\#{Process.clock_gettime(Process::CLOCK_MONOTONIC) - start}s"
          result
        end
      end

      class Processor
        prepend Timed
        def process(data) = data.upcase
      end

      Processor.new.process("hello")
      ```

      Check ancestry: `Processor.ancestors` shows `[Timed, Processor, Object, ...]`
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python's MRO is controlled by class declaration order. No direct `prepend`:

      ```python
      import time

      class Logging:
          def log(self, msg): print(f"[LOG] {msg}")

      class Service(Logging): pass          # instance method inherited
      Service().log("ready")

      # prepend equivalent via explicit ordering:
      class Timed:
          def process(self, data):
              start = time.monotonic()
              result = super().process(data)
              print(f"{time.monotonic() - start}s")
              return result

      class Processor(Timed):
          def process(self, data): return data.upper()
      ```
    TEXT
    java_equivalent: <<~TEXT
      Java has no `prepend`; the Decorator pattern achieves runtime wrapping:

      ```java
      interface Processor {
          String process(String data);
      }

      class ConcreteProcessor implements Processor {
          public String process(String data) { return data.toUpperCase(); }
      }

      class TimedProcessor implements Processor {
          private final Processor delegate;
          TimedProcessor(Processor p) { this.delegate = p; }

          public String process(String data) {
              long start = System.nanoTime();
              String result = delegate.process(data);
              System.out.println((System.nanoTime() - start) + "ns");
              return result;
          }
      }

      new TimedProcessor(new ConcreteProcessor()).process("hello");
      ```
    TEXT
  },
  {
    id: 13,
    module_id: 3,
    title: "method_missing and respond_to_missing?",
    position_in_module: 3,
    estimated_minutes: 5,
    prerequisite_ids: [11, 12],
    content_body: <<~MARKDOWN,
      ## `method_missing` and `respond_to_missing?`

      `method_missing` intercepts calls to undefined methods, enabling dynamic dispatch
      patterns (proxy, builder DSLs, ActiveRecord-style finders).

      ```ruby
      class FlexibleRecord
        def initialize(attrs = {})
          @attrs = attrs
        end

        def method_missing(name, *args)
          key = name.to_s.delete_suffix("=").to_sym
          if name.to_s.end_with?("=")
            @attrs[key] = args.first
          elsif @attrs.key?(key)
            @attrs[key]
          else
            super
          end
        end

        def respond_to_missing?(name, include_private = false)
          key = name.to_s.delete_suffix("=").to_sym
          @attrs.key?(key) || super
        end
      end

      rec = FlexibleRecord.new(name: "Alice")
      rec.name           # => "Alice"
      rec.name = "Bob"
      rec.respond_to?(:name)  # => true
      ```

      Always override `respond_to_missing?` alongside `method_missing` to keep
      `respond_to?` and `method` reflection consistent.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `__getattr__` (called only when attribute not found) and
      `__getattribute__` (called always):

      ```python
      class FlexibleRecord:
          def __init__(self, **attrs):
              self.__dict__["_attrs"] = attrs

          def __getattr__(self, name):
              if name in self._attrs:
                  return self._attrs[name]
              raise AttributeError(name)

          def __setattr__(self, name, value):
              self._attrs[name] = value

      rec = FlexibleRecord(name="Alice")
      rec.name          # "Alice"
      rec.name = "Bob"
      hasattr(rec, "name")  # True
      ```
    TEXT
    java_equivalent: <<~TEXT
      Java has no `method_missing`; dynamic proxies via reflection achieve similar patterns:

      ```java
      import java.lang.reflect.*;
      import java.util.Map;

      Object proxy = Proxy.newProxyInstance(
          ClassLoader.getSystemClassLoader(),
          new Class[]{Map.class},
          (p, method, args) -> {
              System.out.println("Intercepted: " + method.getName());
              return null;
          }
      );
      ((Map<?, ?>) proxy).get("key"); // prints "Intercepted: get"
      ```

      In practice, Java frameworks use annotation processors or code generation
      (Lombok, MapStruct) rather than runtime `method_missing`-style dispatch.
    TEXT
  },
  {
    id: 14,
    module_id: 3,
    title: "Eigenclass and Singleton Methods",
    position_in_module: 4,
    estimated_minutes: 5,
    prerequisite_ids: [12, 13],
    content_body: <<~MARKDOWN,
      ## Eigenclass (Singleton Class) and Singleton Methods

      Every Ruby object has a hidden eigenclass (singleton class) that holds methods
      defined specifically for that object.

      ```ruby
      obj = Object.new

      def obj.greet
        "Hello from singleton"
      end

      obj.greet
      # => "Hello from singleton"
      obj.singleton_class.instance_methods(false)
      # => [:greet]
      ```

      Class methods are singleton methods on the class object:

      ```ruby
      class Config
        class << self
          def defaults
            { timeout: 30, retries: 3 }
          end

          def from_env
            { timeout: ENV.fetch("TIMEOUT", "30").to_i }
          end
        end
      end

      Config.defaults
      # => {timeout: 30, retries: 3}
      ```

      `class << self` opens the eigenclass of `self` (the class object), making all
      method definitions inside it singleton (class) methods.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `@staticmethod`/`@classmethod` decorators, not eigenclasses:

      ```python
      class Config:
          @staticmethod
          def defaults():
              return {"timeout": 30, "retries": 3}

          @classmethod
          def from_env(cls):
              import os
              return {"timeout": int(os.getenv("TIMEOUT", "30"))}

      Config.defaults()    # {"timeout": 30, "retries": 3}
      ```

      Python has no per-object method definition; methods belong to the class.
      Per-object behavior requires explicitly attaching functions to instances.
    TEXT
    java_equivalent: <<~TEXT
      Java uses `static` methods on the class; no singleton methods per instance:

      ```java
      public class Config {
          public static Map<String, Object> defaults() {
              return Map.of("timeout", 30, "retries", 3);
          }

          public static Map<String, Object> fromEnv() {
              String timeout = System.getenv("TIMEOUT");
              return Map.of("timeout", timeout != null ? Integer.parseInt(timeout) : 30);
          }
      }

      Config.defaults(); // {timeout=30, retries=3}
      ```

      Runtime per-object method dispatch requires proxies or Decorator pattern.
    TEXT
  },
  {
    id: 15,
    module_id: 3,
    title: "Object Comparison and Comparable",
    position_in_module: 5,
    estimated_minutes: 5,
    prerequisite_ids: [11, 12],
    content_body: <<~MARKDOWN,
      ## Object Comparison and `Comparable`

      Including `Comparable` and defining `<=>` (spaceship operator) gives a class
      the full suite: `<`, `<=`, `==`, `>=`, `>`, `between?`, `clamp`.

      ```ruby
      class Version
        include Comparable

        attr_reader :major, :minor, :patch

        def initialize(str)
          @major, @minor, @patch = str.split(".").map(&:to_i)
        end

        def <=>(other)
          return major <=> other.major unless major == other.major
          return minor <=> other.minor unless minor == other.minor
          patch <=> other.patch
        end

        def to_s = "\#{major}.\#{minor}.\#{patch}"
      end

      versions = %w[1.10.0 2.0.1 1.9.3].map { |v| Version.new(v) }
      versions.sort.map(&:to_s)
      # => ["1.9.3", "1.10.0", "2.0.1"]
      versions.max.to_s
      # => "2.0.1"
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `functools.total_ordering` decorator with `__eq__` and one comparison:

      ```python
      from functools import total_ordering

      @total_ordering
      class Version:
          def __init__(self, s):
              self.parts = tuple(int(x) for x in s.split("."))

          def __eq__(self, other): return self.parts == other.parts
          def __lt__(self, other): return self.parts < other.parts
          def __str__(self): return ".".join(str(p) for p in self.parts)

      versions = sorted(Version(v) for v in ["1.10.0", "2.0.1", "1.9.3"])
      [str(v) for v in versions]  # ["1.9.3", "1.10.0", "2.0.1"]
      ```
    TEXT
    java_equivalent: <<~TEXT
      Java uses `Comparable<T>` interface with `compareTo`:

      ```java
      import java.util.Arrays;

      public class Version implements Comparable<Version> {
          private final int[] parts;

          public Version(String s) {
              parts = Arrays.stream(s.split("\\.")).mapToInt(Integer::parseInt).toArray();
          }

          public int compareTo(Version o) {
              for (int i = 0; i < 3; i++) {
                  int cmp = Integer.compare(parts[i], o.parts[i]);
                  if (cmp != 0) return cmp;
              }
              return 0;
          }

          public String toString() {
              return parts[0] + "." + parts[1] + "." + parts[2];
          }
      }
      ```
    TEXT
  },

  # ───────────────────────────────────────────────────────────
  # Module 4: Metaprogramming  (lesson IDs 16-20)
  # ───────────────────────────────────────────────────────────
  {
    id: 16,
    module_id: 4,
    title: "define_method and Dynamic Method Generation",
    position_in_module: 1,
    estimated_minutes: 5,
    prerequisite_ids: [],
    content_body: <<~MARKDOWN,
      ## `define_method` and Dynamic Method Generation

      `define_method` creates instance methods at runtime, closing over the block's binding.
      It replaces repetitive method definitions driven by data.

      ```ruby
      class Threshold
        LEVELS = { low: 10, medium: 50, high: 100 }.freeze

        LEVELS.each do |name, value|
          define_method(:"\#{name}?") do |n|
            n >= value
          end
        end
      end

      t = Threshold.new
      t.low?(5)     # => false
      t.low?(15)    # => true
      t.medium?(60) # => true
      ```

      Compare the alternative — three nearly identical def blocks — which violates DRY.
      `define_method` couples the method set to the data structure automatically.

      Generate reader/writer pairs:

      ```ruby
      module AttributeAccessor
        def self.included(base)
          base.instance_variable_set(:@attributes, [])
          base.extend(ClassMethods)
        end

        module ClassMethods
          def attribute(name)
            define_method(name)       { instance_variable_get(:"\@\#{name}") }
            define_method(:"\#{name}=") { |v| instance_variable_set(:"\@\#{name}", v) }
          end
        end
      end
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `setattr` and `types.MethodType`, or decorators:

      ```python
      class Threshold:
          LEVELS = {"low": 10, "medium": 50, "high": 100}

      def make_check(value):
          def check(self, n): return n >= value
          return check

      for name, value in Threshold.LEVELS.items():
          setattr(Threshold, f"{name}_", make_check(value))

      t = Threshold()
      t.low_(5)   # False
      t.low_(15)  # True
      ```

      The factory function captures `value` correctly — avoids the closure-in-loop pitfall.
    TEXT
    java_equivalent: <<~TEXT
      Java uses annotation processors or explicit method delegation; no runtime method definition
      without bytecode manipulation:

      ```java
      import java.util.Map;
      import java.util.function.Predicate;

      public class Threshold {
          private static final Map<String, Integer> LEVELS =
              Map.of("low", 10, "medium", 50, "high", 100);

          private final Map<String, Predicate<Integer>> checks;

          public Threshold() {
              checks = new java.util.HashMap<>();
              LEVELS.forEach((name, val) -> checks.put(name, n -> n >= val));
          }

          public boolean check(String level, int n) {
              return checks.getOrDefault(level, x -> false).test(n);
          }
      }
      ```
    TEXT
  },
  {
    id: 17,
    module_id: 4,
    title: "class_eval and instance_eval",
    position_in_module: 2,
    estimated_minutes: 5,
    prerequisite_ids: [16],
    content_body: <<~MARKDOWN,
      ## `class_eval` and `instance_eval`

      `class_eval` (alias `module_eval`) evaluates a block in the context of a class,
      allowing external method injection:

      ```ruby
      class Dog; end

      Dog.class_eval do
        def speak
          "Woof!"
        end
      end

      Dog.new.speak
      # => "Woof!"
      ```

      `instance_eval` evaluates in the context of a specific object, modifying its
      eigenclass when defining methods:

      ```ruby
      config = Object.new

      config.instance_eval do
        def database_url
          "postgres://localhost/app"
        end
      end

      config.database_url
      # => "postgres://localhost/app"
      ```

      DSL builders use `instance_eval` to provide a clean configuration API:

      ```ruby
      class Router
        def initialize(&block)
          @routes = {}
          instance_eval(&block) if block_given?
        end

        def get(path, &handler)
          @routes[path] = handler
        end

        def routes = @routes
      end

      r = Router.new do
        get("/health") { "ok" }
      end
      r.routes["/health"].call
      # => "ok"
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python patches classes at runtime via direct attribute assignment or `exec`:

      ```python
      class Dog: pass

      def speak(self): return "Woof!"
      Dog.speak = speak
      Dog().speak()  # "Woof!"

      # instance_eval equivalent: direct attribute assignment
      class Config: pass
      cfg = Config()
      cfg.database_url = lambda: "postgres://localhost/app"
      cfg.database_url()  # "postgres://localhost/app"
      ```

      DSL builders often use context managers (`with`) or explicit builder objects
      rather than `instance_eval`-style block evaluation.
    TEXT
    java_equivalent: <<~TEXT
      Java has no runtime class patching without bytecode manipulation. Builder pattern
      achieves the DSL-like API:

      ```java
      import java.util.HashMap;
      import java.util.Map;
      import java.util.function.Supplier;

      public class Router {
          private final Map<String, Supplier<String>> routes = new HashMap<>();

          public Router get(String path, Supplier<String> handler) {
              routes.put(path, handler);
              return this;
          }

          public Map<String, Supplier<String>> routes() { return routes; }
      }

      Router router = new Router().get("/health", () -> "ok");
      router.routes().get("/health").get(); // "ok"
      ```
    TEXT
  },
  {
    id: 18,
    module_id: 4,
    title: "Method Objects and UnboundMethod",
    position_in_module: 3,
    estimated_minutes: 5,
    prerequisite_ids: [16, 17],
    content_body: <<~MARKDOWN,
      ## Method Objects and `UnboundMethod`

      `method(:name)` returns a bound `Method` object tied to `self`.
      `instance_method(:name)` returns an `UnboundMethod` that must be bound before calling.

      ```ruby
      class Formatter
        def format(str)
          str.strip.capitalize
        end
      end

      f = Formatter.new
      bound = f.method(:format)
      bound.call("  hello world  ")
      # => "Hello world"
      ```

      `UnboundMethod` enables sharing logic across instances:

      ```ruby
      unbound = Formatter.instance_method(:format)

      other = Formatter.new
      rebound = unbound.bind(other)
      rebound.call("  ruby  ")
      # => "Ruby"
      ```

      Use cases: method caching (avoid repeated `method(:name)` lookups in hot paths),
      delegation to specific ancestors via `unbound_method.bind(self).call`.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python has bound and unbound methods via descriptor protocol:

      ```python
      class Formatter:
          def format(self, s): return s.strip().capitalize()

      f = Formatter()
      bound = f.format           # bound method
      bound("  hello world  ")   # "Hello world"

      unbound = Formatter.format  # function (unbound)
      unbound(f, "  ruby  ")      # "Ruby"
      ```

      `inspect.signature` and `types.MethodType` expose the same metadata Ruby
      provides via `Method#arity`, `Method#source_location`.
    TEXT
    java_equivalent: <<~TEXT
      Java uses reflection's `Method` object for similar introspection:

      ```java
      import java.lang.reflect.Method;

      class Formatter {
          public String format(String s) {
              return s.strip().substring(0, 1).toUpperCase() + s.strip().substring(1);
          }
      }

      Formatter f = new Formatter();
      Method m = Formatter.class.getMethod("format", String.class);
      String result = (String) m.invoke(f, "  hello world  ");
      // "Hello world"
      ```

      Java method objects (`java.lang.reflect.Method`) are always unbound and require
      an instance argument on `invoke`.
    TEXT
  },
  {
    id: 19,
    module_id: 4,
    title: "Hook Methods: inherited, included, extended",
    position_in_module: 4,
    estimated_minutes: 5,
    prerequisite_ids: [17, 18],
    content_body: <<~MARKDOWN,
      ## Hook Methods: `inherited`, `included`, `extended`

      Ruby fires hook methods at class/module composition events, enabling registration
      and automatic setup without explicit boilerplate.

      ```ruby
      class Registry
        @subclasses = []

        def self.inherited(subclass)
          @subclasses << subclass
          super
        end

        def self.all = @subclasses
      end

      class Alpha < Registry; end
      class Beta  < Registry; end

      Registry.all
      # => [Alpha, Beta]
      ```

      `included` hook runs when a module is mixed in:

      ```ruby
      module Observable
        def self.included(base)
          base.instance_variable_set(:@callbacks, Hash.new { |h, k| h[k] = [] })
          base.extend(ClassMethods)
        end

        module ClassMethods
          def on(event, &block)
            @callbacks[event] << block
          end

          def callbacks = @callbacks
        end
      end

      class Button
        include Observable
        on(:click) { puts "clicked" }
      end

      Button.callbacks[:click].first.call
      # => clicked
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `__init_subclass__` and `__set_name__` (PEP 487) for similar hooks:

      ```python
      class Registry:
          _subclasses = []

          def __init_subclass__(cls, **kwargs):
              super().__init_subclass__(**kwargs)
              Registry._subclasses.append(cls)

      class Alpha(Registry): pass
      class Beta(Registry): pass

      Registry._subclasses  # [Alpha, Beta]
      ```

      Metaclasses (`type.__new__`) provide full control similar to Ruby's `inherited`
      and `included` hooks combined.
    TEXT
    java_equivalent: <<~TEXT
      Java lacks runtime hooks; annotation processors or service loader achieve registration:

      ```java
      import java.util.ServiceLoader;
      import java.util.List;
      import java.util.stream.StreamSupport;

      public interface Handler {}

      // In META-INF/services/Handler, list implementing classes.
      // At runtime:
      List<Handler> handlers = StreamSupport
          .stream(ServiceLoader.load(Handler.class).spliterator(), false)
          .toList();
      ```

      Spring's `ApplicationContext` and Guice's `TypeListener` approximate `inherited`
      hooks via compile-time or startup-time scanning.
    TEXT
  },
  {
    id: 20,
    module_id: 4,
    title: "eval, binding, and Safe Metaprogramming Patterns",
    position_in_module: 5,
    estimated_minutes: 5,
    prerequisite_ids: [16, 17, 18, 19],
    content_body: <<~MARKDOWN,
      ## `eval`, `binding`, and Safe Metaprogramming Patterns

      `eval` executes a string as Ruby code inside an optional `Binding`. Avoid in
      production — use `define_method`, `send`, or `public_send` instead.

      ```ruby
      x = 42
      binding_context = binding
      eval("x * 2", binding_context)
      # => 84
      ```

      Prefer `public_send` for safe dynamic dispatch — it rejects private methods:

      ```ruby
      class Calculator
        def add(a, b) = a + b
        private
        def secret = "internal"
      end

      calc = Calculator.new
      calc.public_send(:add, 3, 4)     # => 7
      calc.public_send(:secret)         # NoMethodError: private method called
      ```

      `Object#send` bypasses visibility. Use it only in tests or trusted internal code.

      Pattern: safe attribute setting from untrusted input:

      ```ruby
      ALLOWED = %i[name email].freeze

      def update_attributes(record, params)
        params.slice(*ALLOWED).each do |key, value|
          record.public_send(:"\#{key}=", value)
        end
      end
      ```
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python's `eval`/`exec` carry the same risks; `getattr`/`setattr` are the safe alternatives:

      ```python
      ALLOWED = {"name", "email"}

      def update_attributes(record, params):
          for key, value in params.items():
              if key in ALLOWED:
                  setattr(record, key, value)
              # else: silently ignore or raise

      x = 42
      eval("x * 2")  # 84 — avoid in production
      ```

      `getattr(obj, name)` raises `AttributeError` for missing attributes, not a security
      boundary (unlike Ruby's `public_send` vs `send`).
    TEXT
    java_equivalent: <<~TEXT
      Java uses reflection `Method.invoke` for dynamic dispatch, with visibility checks:

      ```java
      import java.lang.reflect.Method;
      import java.util.Set;
      import java.util.Map;

      Set<String> ALLOWED = Set.of("name", "email");

      void updateAttributes(Object record, Map<String, String> params) throws Exception {
          for (var entry : params.entrySet()) {
              if (!ALLOWED.contains(entry.getKey())) continue;
              String setter = "set" + entry.getKey().substring(0, 1).toUpperCase()
                            + entry.getKey().substring(1);
              Method m = record.getClass().getMethod(setter, String.class);
              m.invoke(record, entry.getValue());
          }
      }
      ```

      `setAccessible(true)` bypasses Java visibility — equivalent to Ruby's `send`.
      Avoid in security-sensitive paths.
    TEXT
  },

  # ───────────────────────────────────────────────────────────
  # Module 5: Concurrency & Performance  (lesson IDs 21-25)
  # ───────────────────────────────────────────────────────────
  {
    id: 21,
    module_id: 5,
    title: "Fiber and Cooperative Concurrency",
    position_in_module: 1,
    estimated_minutes: 5,
    prerequisite_ids: [],
    content_body: <<~MARKDOWN,
      ## Fiber and Cooperative Concurrency

      A `Fiber` is a coroutine — a manually scheduled unit of execution that suspends
      at `Fiber.yield` and resumes at `fiber.resume`.

      ```ruby
      counter = Fiber.new do
        i = 0
        loop do
          Fiber.yield i
          i += 1
        end
      end

      5.times.map { counter.resume }
      # => [0, 1, 2, 3, 4]
      ```

      Fibers enable pull-based pipelines without threads:

      ```ruby
      producer = Fiber.new do
        [10, 20, 30].each { |n| Fiber.yield n }
        nil
      end

      results = []
      loop do
        val = producer.resume
        break if val.nil?
        results << val * 2
      end
      results
      # => [20, 40, 60]
      ```

      Ruby 3.0+ adds `Fiber::Scheduler` for non-blocking I/O — Fibers are the foundation
      of `async` gems and the Falcon web server.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python generators (`yield`) are equivalent to Fibers:

      ```python
      def counter():
          i = 0
          while True:
              yield i
              i += 1

      gen = counter()
      [next(gen) for _ in range(5)]  # [0, 1, 2, 3, 4]
      ```

      `asyncio` uses coroutines (`async def`) built on generators for non-blocking I/O.
      Python 3.11+ adds `asyncio.TaskGroup` mirroring Ruby's `Fiber::Scheduler` capabilities.
    TEXT
    java_equivalent: <<~TEXT
      Java 21 virtual threads (Project Loom) provide similar cooperative semantics:

      ```java
      import java.util.concurrent.*;
      import java.util.concurrent.atomic.AtomicInteger;

      AtomicInteger counter = new AtomicInteger();

      // Virtual thread as coroutine equivalent:
      try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
          for (int i = 0; i < 5; i++) {
              final int idx = i;
              executor.submit(() -> System.out.println(counter.getAndIncrement()));
          }
      }
      ```

      Java lacks built-in coroutine yield semantics; third-party libraries like
      `Quasar` or Kotlin coroutines provide the closest equivalent.
    TEXT
  },
  {
    id: 22,
    module_id: 5,
    title: "Thread Basics and the GVL",
    position_in_module: 2,
    estimated_minutes: 5,
    prerequisite_ids: [21],
    content_body: <<~MARKDOWN,
      ## Thread Basics and the GVL

      MRI Ruby's Global VM Lock (GVL, formerly GIL) prevents true parallel execution of
      Ruby bytecode — only one thread runs Ruby code at a time. I/O-bound tasks still
      benefit from threading.

      ```ruby
      require "benchmark"

      def io_bound_task
        sleep(0.1)
      end

      Benchmark.bm do |b|
        b.report("sequential") do
          10.times { io_bound_task }
        end

        b.report("threaded") do
          threads = 10.times.map { Thread.new { io_bound_task } }
          threads.each(&:join)
        end
      end
      ```

      Thread-safe data sharing with `Mutex`:

      ```ruby
      counter = 0
      mutex   = Mutex.new
      threads = 10.times.map do
        Thread.new { mutex.synchronize { counter += 1 } }
      end
      threads.each(&:join)
      counter
      # => 10
      ```

      JRuby and TruffleRuby remove the GVL for CPU-bound parallelism.
    MARKDOWN
    python_equivalent: <<~TEXT,
      CPython has an equivalent GIL. `threading` for I/O, `multiprocessing` for CPU:

      ```python
      import threading, time

      counter = 0
      lock = threading.Lock()

      def increment():
          global counter
          with lock:
              counter += 1

      threads = [threading.Thread(target=increment) for _ in range(10)]
      for t in threads: t.start()
      for t in threads: t.join()
      # counter == 10
      ```

      Python 3.13 introduces a per-interpreter GIL, enabling true parallelism in
      subinterpreters — similar to JRuby's no-GVL design.
    TEXT
    java_equivalent: <<~TEXT
      Java has no GVL — threads run truly in parallel. Use `synchronized` or
      `java.util.concurrent` for thread safety:

      ```java
      import java.util.concurrent.atomic.AtomicInteger;
      import java.util.concurrent.*;

      AtomicInteger counter = new AtomicInteger(0);

      ExecutorService pool = Executors.newFixedThreadPool(10);
      List<Future<?>> futures = new ArrayList<>();
      for (int i = 0; i < 10; i++) {
          futures.add(pool.submit(counter::incrementAndGet));
      }
      futures.forEach(f -> { try { f.get(); } catch (Exception e) {} });
      pool.shutdown();
      // counter.get() == 10
      ```
    TEXT
  },
  {
    id: 23,
    module_id: 5,
    title: "Memoization Patterns",
    position_in_module: 3,
    estimated_minutes: 5,
    prerequisite_ids: [21, 22],
    content_body: <<~MARKDOWN,
      ## Memoization Patterns

      The `||=` idiom memoizes the result of an expensive computation in an instance
      variable. Beware of falsy-value traps.

      ```ruby
      class ReportBuilder
        def dataset
          @dataset ||= load_from_database
        end

        private

        def load_from_database
          puts "Loading..."
          [1, 2, 3]
        end
      end

      r = ReportBuilder.new
      r.dataset  # prints "Loading..."
      r.dataset  # silent — memoized
      ```

      For results that can be `nil` or `false`, use explicit sentinel:

      ```ruby
      UNSET = Object.new

      class Resolver
        def initialize
          @cached = UNSET
        end

        def result
          @cached = fetch! if @cached.equal?(UNSET)
          @cached
        end

        private

        def fetch!
          nil
        end
      end
      ```

      Thread-safe memoization requires `Mutex#synchronize` around assignment.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `functools.lru_cache` or `functools.cached_property`:

      ```python
      from functools import cached_property

      class ReportBuilder:
          @cached_property
          def dataset(self):
              print("Loading...")
              return [1, 2, 3]

      r = ReportBuilder()
      r.dataset  # prints "Loading..."
      r.dataset  # silent
      ```

      `cached_property` handles `None` returns correctly — no falsy-value trap.
      Thread safety requires `threading.RLock` wrapping in concurrent contexts.
    TEXT
    java_equivalent: <<~TEXT
      Java uses `lazy initialization` with `volatile` or `AtomicReference`:

      ```java
      import java.util.concurrent.atomic.AtomicReference;
      import java.util.List;

      public class ReportBuilder {
          private final AtomicReference<List<Integer>> cache = new AtomicReference<>();

          public List<Integer> getDataset() {
              return cache.updateAndGet(existing -> {
                  if (existing != null) return existing;
                  System.out.println("Loading...");
                  return List.of(1, 2, 3);
              });
          }
      }
      ```

      `AtomicReference.updateAndGet` ensures thread-safe single-initialization semantics.
    TEXT
  },
  {
    id: 24,
    module_id: 5,
    title: "ObjectSpace and Memory Profiling",
    position_in_module: 4,
    estimated_minutes: 5,
    prerequisite_ids: [22, 23],
    content_body: <<~MARKDOWN,
      ## ObjectSpace and Memory Profiling

      `ObjectSpace` provides a window into the Ruby VM's object heap at runtime.
      Use it for diagnostics, not production logic.

      ```ruby
      require "objspace"

      ObjectSpace.count_objects
      # {:TOTAL=>..., :FREE=>..., :T_OBJECT=>..., :T_STRING=>..., ...}

      str = "hello world"
      ObjectSpace.memsize_of(str)
      # => 40 (platform-dependent)
      ```

      Track allocations for a specific code path:

      ```ruby
      before = ObjectSpace.count_objects[:T_STRING]
      result = 100.times.map { |i| "item_\#{i}" }
      after  = ObjectSpace.count_objects[:T_STRING]
      puts "New strings: \#{after - before}"
      ```

      `ObjectSpace.each_object(String)` enumerates all live string objects — useful for
      detecting leaked large strings or unexpected retention.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `sys` and `gc` for object introspection:

      ```python
      import sys, gc

      s = "hello world"
      sys.getsizeof(s)   # 60 (platform-dependent)

      gc.collect()
      # Count live objects by type:
      strings = [o for o in gc.get_objects() if isinstance(o, str)]
      len(strings)
      ```

      `tracemalloc` provides allocation tracing analogous to `ObjectSpace` allocation tracking.
    TEXT
    java_equivalent: <<~TEXT
      Java uses JVM profiling tools (JVisualVM, Java Flight Recorder) rather than
      programmatic ObjectSpace-style APIs:

      ```java
      import java.lang.management.ManagementFactory;
      import java.lang.management.MemoryMXBean;

      MemoryMXBean memBean = ManagementFactory.getMemoryMXBean();
      long heapUsed = memBean.getHeapMemoryUsage().getUsed();
      System.out.println("Heap used: " + heapUsed + " bytes");

      // Force GC for baseline:
      System.gc();
      long afterGC = memBean.getHeapMemoryUsage().getUsed();
      ```

      `jcmd <pid> GC.heap_info` and heap dumps (jmap) provide finer-grained analysis.
    TEXT
  },
  {
    id: 25,
    module_id: 5,
    title: "Ractors and Parallel Execution",
    position_in_module: 5,
    estimated_minutes: 5,
    prerequisite_ids: [22, 23, 24],
    content_body: <<~MARKDOWN,
      ## Ractors and Parallel Execution

      `Ractor` (Ruby 3.0+) provides actor-model parallelism without the GVL, enabling
      true CPU-bound parallel execution on MRI.

      ```ruby
      r1 = Ractor.new { (1..100_000).sum }
      r2 = Ractor.new { (100_001..200_000).sum }

      total = r1.take + r2.take
      # => 20_000_100_000
      ```

      Ractors communicate via message passing. Objects must be shareable (frozen or
      `Ractor::MovedObject`):

      ```ruby
      pipe = Ractor.new do
        loop do
          msg = Ractor.receive
          Ractor.yield msg.upcase
        end
      end

      pipe.send("hello")
      pipe.take
      # => "HELLO"
      ```

      Mutable objects must be moved (ownership transferred) or deep-copied.
      `Ractor.make_shareable(obj)` deep-freezes for safe sharing.
    MARKDOWN
    python_equivalent: <<~TEXT,
      Python uses `multiprocessing` to bypass the GIL for CPU-bound work:

      ```python
      from multiprocessing import Pool

      def partial_sum(range_args):
          start, end = range_args
          return sum(range(start, end + 1))

      with Pool(2) as pool:
          results = pool.map(partial_sum, [(1, 100_000), (100_001, 200_000)])
      total = sum(results)
      # 20_000_100_000
      ```

      `multiprocessing` uses process isolation (no shared memory by default) —
      heavier than Ractor but fully parallel. Python 3.13 subinterpreters provide
      a lighter alternative.
    TEXT
    java_equivalent: <<~TEXT
      Java uses `ForkJoinPool` and parallel streams for CPU-bound work:

      ```java
      import java.util.stream.LongStream;

      long total = LongStream.rangeClosed(1, 200_000)
          .parallel()
          .sum();
      // 20_000_100_000

      // Actor model via Akka or Virtual Threads message-passing:
      import java.util.concurrent.*;

      BlockingQueue<String> queue = new LinkedBlockingQueue<>();
      Thread.ofVirtual().start(() -> {
          try { System.out.println(queue.take().toUpperCase()); }
          catch (InterruptedException e) { Thread.currentThread().interrupt(); }
      });
      queue.put("hello");
      ```
    TEXT
  }
].freeze
