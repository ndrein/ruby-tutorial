# Exercise definitions: at least 1 exercise per lesson (25 lessons)
# All 4 exercise types represented across the curriculum
# multiple_choice exercises have exactly 4 options

EXERCISE_DEFINITIONS = [
  # ── Module 1: Blocks, Procs & Lambdas ──────────────────────────────

  # Lesson 1 — fill_in_blank
  {
    lesson_id: 1,
    exercise_type: "fill_in_blank",
    prompt: "Use ____ to call the block passed to a method without capturing it.",
    correct_answer: "yield",
    accepted_synonyms: [],
    options: [],
    explanation: "`yield` transfers control to the implicit block. `block_given?` tests for presence. No `&block` parameter needed.",
    position: 1
  },
  # Lesson 1 — multiple_choice
  {
    lesson_id: 1,
    exercise_type: "multiple_choice",
    prompt: "What does `block_given?` return when a method is called without a block?",
    correct_answer: "false",
    accepted_synonyms: [],
    options: ["true", "false", "nil", "raises LocalJumpError"],
    explanation: "`block_given?` returns `false` when no block is passed. Calling `yield` without a block raises `LocalJumpError`.",
    position: 2
  },

  # Lesson 2 — fill_in_blank
  {
    lesson_id: 2,
    exercise_type: "fill_in_blank",
    prompt: "Prefix a parameter with ____ to capture the block as a Proc object.",
    correct_answer: "&",
    accepted_synonyms: ["ampersand"],
    options: [],
    explanation: "`&block` in the parameter list converts the implicit block to a `Proc`. The `&` prefix can also convert a `Proc` back to a block at a call site.",
    position: 1
  },
  # Lesson 2 — spot_the_bug
  {
    lesson_id: 2,
    exercise_type: "spot_the_bug",
    prompt: "```ruby\ndef run_twice(block)\n  block.call\n  block.call\nend\nrun_twice { puts 'hi' }\n```\nWhy does this raise an error?",
    correct_answer: "The parameter should be `&block` to capture the block as a Proc",
    accepted_synonyms: ["missing & prefix", "needs &block not block"],
    options: [],
    explanation: "Without `&`, `block` is a regular parameter. The block is not passed as an argument here. Add `&block` to the parameter list.",
    position: 2
  },

  # Lesson 3 — multiple_choice
  {
    lesson_id: 3,
    exercise_type: "multiple_choice",
    prompt: "A `lambda` created with `lambda { |x| return x }` called inside a method — what does `return` do?",
    correct_answer: "Returns from the lambda only",
    accepted_synonyms: [],
    options: [
      "Returns from the lambda only",
      "Returns from the enclosing method",
      "Raises a LocalJumpError",
      "Returns nil"
    ],
    explanation: "`return` inside a `lambda` exits only the lambda. `return` inside a `proc` or `Proc.new` block exits the enclosing method.",
    position: 1
  },
  # Lesson 3 — translation
  {
    lesson_id: 3,
    exercise_type: "translation",
    prompt: "Translate this Python code to Ruby using a lambda:\n```python\nstrict = lambda x, y: x + y\n```",
    correct_answer: "strict = lambda { |x, y| x + y }",
    accepted_synonyms: ["strict = ->(x, y) { x + y }"],
    options: [],
    explanation: "Ruby lambdas enforce arity strictly like Python lambdas. The stabby lambda `->` syntax is idiomatic Ruby 1.9+.",
    position: 2
  },

  # Lesson 4 — fill_in_blank
  {
    lesson_id: 4,
    exercise_type: "fill_in_blank",
    prompt: "Ruby closures capture variables by ____ (not by value).",
    correct_answer: "reference",
    accepted_synonyms: ["reference not value", "ref"],
    options: [],
    explanation: "Block/proc/lambda closures in Ruby close over the variable binding itself, so mutations to the variable are visible inside the closure after capture.",
    position: 1
  },
  # Lesson 4 — spot_the_bug
  {
    lesson_id: 4,
    exercise_type: "spot_the_bug",
    prompt: "```ruby\nadders = []\n3.times do |i|\n  adders << proc { i }\nend\nadders.map(&:call)\n```\nA developer expected `[0, 1, 2]`. What is the actual result and why?",
    correct_answer: "[0, 1, 2]",
    accepted_synonyms: ["[0,1,2]"],
    options: [],
    explanation: "Unlike JavaScript's `var`-loop closure problem, Ruby block variables (`|i|`) are scoped per iteration. Each `proc` captures a distinct `i`. Result is `[0, 1, 2]` as expected.",
    position: 2
  },

  # Lesson 5 — translation
  {
    lesson_id: 5,
    exercise_type: "translation",
    prompt: "Translate this Python to idiomatic Ruby using `Symbol#to_proc`:\n```python\nlist(map(str.upper, [\"ruby\", \"python\", \"java\"]))\n```",
    correct_answer: "%w[ruby python java].map(&:upcase)",
    accepted_synonyms: ["[\"ruby\", \"python\", \"java\"].map(&:upcase)"],
    options: [],
    explanation: "`&:upcase` expands to `{ |s| s.upcase }`. `Symbol#to_proc` is idiomatic Ruby shorthand for single-method transformations.",
    position: 1
  },
  # Lesson 5 — multiple_choice
  {
    lesson_id: 5,
    exercise_type: "multiple_choice",
    prompt: "What does `method(:puts)` return?",
    correct_answer: "A Method object bound to self",
    accepted_synonyms: [],
    options: [
      "A Method object bound to self",
      "A Proc object",
      "A lambda",
      "A Symbol"
    ],
    explanation: "`method(:puts)` returns a `Method` object bound to the current `self`. It responds to `call`, `arity`, and can be passed with `&` as a block.",
    position: 2
  },

  # ── Module 2: Enumerable Methods ───────────────────────────────────

  # Lesson 6 — fill_in_blank
  {
    lesson_id: 6,
    exercise_type: "fill_in_blank",
    prompt: "[1,2,3,4].____{ |n| n.even? } returns [2, 4].",
    correct_answer: "select",
    accepted_synonyms: ["filter"],
    options: [],
    explanation: "`select` returns elements for which the block is truthy. Its alias `filter` is available in Ruby 2.5+. `reject` is the complement.",
    position: 1
  },
  # Lesson 6 — multiple_choice
  {
    lesson_id: 6,
    exercise_type: "multiple_choice",
    prompt: "Which method returns a new array where each element is transformed by the block?",
    correct_answer: "map",
    accepted_synonyms: [],
    options: ["map", "select", "reject", "each"],
    explanation: "`map` transforms each element and returns a new array. `each` iterates without returning a transformed array. `select`/`reject` filter without transforming.",
    position: 2
  },

  # Lesson 7 — fill_in_blank
  {
    lesson_id: 7,
    exercise_type: "fill_in_blank",
    prompt: "[1,2,3,4,5].reduce(0) { |sum, n| sum + n } returns ____.",
    correct_answer: "15",
    accepted_synonyms: [],
    options: [],
    explanation: "`reduce` folds left: ((((0+1)+2)+3)+4)+5 = 15. Without an initial value, the first element is used as the accumulator.",
    position: 1
  },
  # Lesson 7 — translation
  {
    lesson_id: 7,
    exercise_type: "translation",
    prompt: "Translate this Python to Ruby:\n```python\nfrom functools import reduce\nresult = reduce(lambda acc, n: acc * n, [1, 2, 3, 4])\n```",
    correct_answer: "[1, 2, 3, 4].reduce(:*)",
    accepted_synonyms: ["[1,2,3,4].inject(:*)", "[1, 2, 3, 4].inject(:*)"],
    options: [],
    explanation: "`reduce(:*)` uses the `*` method as the reducing operation. The symbol-argument form is equivalent to `{ |acc, n| acc * n }`.",
    position: 2
  },

  # Lesson 8 — fill_in_blank
  {
    lesson_id: 8,
    exercise_type: "fill_in_blank",
    prompt: "To count word frequencies, pass ____ as the initial object to `each_with_object`.",
    correct_answer: "Hash.new(0)",
    accepted_synonyms: ["Hash.new { |h, k| h[k] = 0 }"],
    options: [],
    explanation: "`Hash.new(0)` creates a hash with default value 0. Incrementing a missing key gives 1 without explicit initialization.",
    position: 1
  },
  # Lesson 8 — spot_the_bug
  {
    lesson_id: 8,
    exercise_type: "spot_the_bug",
    prompt: "```ruby\nresult = [1, 2, 3].each_with_object([]) do |n, acc|\n  acc + [n * 2]\nend\n```\nThe developer expected `[2, 4, 6]` but got `[]`. What is wrong?",
    correct_answer: "Should use `acc << n * 2` or `acc.push(n * 2)` instead of `acc + [n * 2]`",
    accepted_synonyms: ["acc + creates a new array instead of mutating acc", "use << not +"],
    options: [],
    explanation: "`each_with_object` ignores the block's return value; it reuses the same accumulator. `acc + [n*2]` creates a new array that is discarded. Use `acc << n * 2` to mutate in place.",
    position: 2
  },

  # Lesson 9 — translation
  {
    lesson_id: 9,
    exercise_type: "translation",
    prompt: "Translate this Python `zip` to Ruby:\n```python\ndict(zip([\"a\", \"b\", \"c\"], [1, 2, 3]))\n```",
    correct_answer: "[:a, :b, :c].zip([1, 2, 3]).to_h",
    accepted_synonyms: ["[\"a\", \"b\", \"c\"].zip([1, 2, 3]).to_h", "Hash[[:a,:b,:c].zip([1,2,3])]"],
    options: [],
    explanation: "`Array#zip` pairs elements positionally. `.to_h` converts `[[:a,1],[:b,2],[:c,3]]` to a hash. `Hash[pairs]` is an alternative.",
    position: 1
  },
  # Lesson 9 — multiple_choice
  {
    lesson_id: 9,
    exercise_type: "multiple_choice",
    prompt: "What is the difference between `group_by` and `chunk`?",
    correct_answer: "`group_by` groups all matching elements; `chunk` groups consecutive matching elements",
    accepted_synonyms: [],
    options: [
      "`group_by` groups all matching elements; `chunk` groups consecutive matching elements",
      "`chunk` groups all matching elements; `group_by` groups consecutive matching elements",
      "They are identical",
      "`chunk` requires a sorted array; `group_by` does not"
    ],
    explanation: "`group_by` scans the entire collection; `chunk` only groups consecutive elements with the same key — `[1,1,2,1,1].chunk{|n|n}` yields `[[1,[1,1]],[2,[2]],[1,[1,1]]]`.",
    position: 2
  },

  # Lesson 10 — fill_in_blank
  {
    lesson_id: 10,
    exercise_type: "fill_in_blank",
    prompt: "Chain ____ to an enumerator to defer evaluation until a terminal method is called.",
    correct_answer: "lazy",
    accepted_synonyms: [".lazy"],
    options: [],
    explanation: "`Enumerable#lazy` returns an `Enumerator::Lazy`. Subsequent `map`/`select` operations are deferred. Terminal methods like `first(n)` or `to_a` force evaluation.",
    position: 1
  },
  # Lesson 10 — spot_the_bug
  {
    lesson_id: 10,
    exercise_type: "spot_the_bug",
    prompt: "```ruby\nresult = (1..Float::INFINITY).select { |n| n.even? }.first(5)\n```\nThis code never returns. How do you fix it?",
    correct_answer: "(1..Float::INFINITY).lazy.select { |n| n.even? }.first(5)",
    accepted_synonyms: ["add .lazy before .select"],
    options: [],
    explanation: "Without `.lazy`, `select` eagerly evaluates the infinite range — it never terminates. Add `.lazy` to make the select/first chain use deferred evaluation.",
    position: 2
  },

  # ── Module 3: Object Model ─────────────────────────────────────────

  # Lesson 11 — fill_in_blank
  {
    lesson_id: 11,
    exercise_type: "fill_in_blank",
    prompt: "Use `module ____` to namespace constants and classes without creating instances.",
    correct_answer: "ModuleName",
    accepted_synonyms: ["a module name", "Geometry", "namespace"],
    options: [],
    explanation: "Ruby modules act as namespaces via `module Name; ...; end`. Constants inside are accessed as `Name::CONST`. This prevents naming collisions across libraries.",
    position: 1
  },
  # Lesson 11 — multiple_choice
  {
    lesson_id: 11,
    exercise_type: "multiple_choice",
    prompt: "After `include Printable` in class `Report`, where does `Printable` appear in `Report.ancestors`?",
    correct_answer: "Immediately after Report",
    accepted_synonyms: [],
    options: [
      "Immediately after Report",
      "Before Report",
      "At the end of the ancestors chain",
      "It does not appear in ancestors"
    ],
    explanation: "`include` inserts the module immediately after the including class in `ancestors`. `prepend` inserts before. `extend` affects the singleton class, not `ancestors`.",
    position: 2
  },

  # Lesson 12 — translation
  {
    lesson_id: 12,
    exercise_type: "translation",
    prompt: "Translate this Python mixin to Ruby using `prepend` for pre-processing:\n```python\nclass Timed:\n    def process(self, data):\n        import time; start = time.monotonic()\n        result = super().process(data)\n        print(time.monotonic() - start)\n        return result\n```",
    correct_answer: "module Timed\n  def process(data)\n    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)\n    result = super\n    puts Process.clock_gettime(Process::CLOCK_MONOTONIC) - start\n    result\n  end\nend",
    accepted_synonyms: ["module Timed with super call"],
    options: [],
    explanation: "`prepend Timed` inserts `Timed` before the class in MRO. `super` calls the original `process`. This is the idiomatic Ruby alternative to Python's cooperative MRO pattern.",
    position: 1
  },
  # Lesson 12 — multiple_choice
  {
    lesson_id: 12,
    exercise_type: "multiple_choice",
    prompt: "Which keyword adds methods to a class's *singleton class* (class-level methods)?",
    correct_answer: "extend",
    accepted_synonyms: [],
    options: ["include", "prepend", "extend", "require"],
    explanation: "`extend ModuleName` adds the module's methods as singleton (class-level) methods. `include` adds them as instance methods. `prepend` adds instance methods before the class in MRO.",
    position: 2
  },

  # Lesson 13 — spot_the_bug
  {
    lesson_id: 13,
    exercise_type: "spot_the_bug",
    prompt: "```ruby\nclass Proxy\n  def method_missing(name, *args)\n    @target.send(name, *args)\n  end\nend\n```\nWhat is missing from this implementation?",
    correct_answer: "respond_to_missing? is not defined",
    accepted_synonyms: ["missing respond_to_missing?", "no respond_to_missing?"],
    options: [],
    explanation: "Without `respond_to_missing?`, `proxy.respond_to?(:some_method)` returns `false` even if `method_missing` handles it. Always pair `method_missing` with `respond_to_missing?`.",
    position: 1
  },
  # Lesson 13 — fill_in_blank
  {
    lesson_id: 13,
    exercise_type: "fill_in_blank",
    prompt: "Always call ____ at the end of `method_missing` when the method name is not handled.",
    correct_answer: "super",
    accepted_synonyms: [],
    options: [],
    explanation: "Calling `super` in `method_missing` propagates to ancestors, eventually reaching `BasicObject#method_missing` which raises `NoMethodError` with a helpful message.",
    position: 2
  },

  # Lesson 14 — multiple_choice
  {
    lesson_id: 14,
    exercise_type: "multiple_choice",
    prompt: "How do you open the singleton class of `self` to define class methods?",
    correct_answer: "class << self",
    accepted_synonyms: [],
    options: [
      "class << self",
      "self.class do",
      "singleton_class.open",
      "def self.class_methods"
    ],
    explanation: "`class << self` opens the eigenclass (singleton class) of the current object. All `def` inside define singleton methods. This is equivalent to individual `def self.method_name` definitions.",
    position: 1
  },
  # Lesson 14 — fill_in_blank
  {
    lesson_id: 14,
    exercise_type: "fill_in_blank",
    prompt: "Call ____ on an object to get its singleton class.",
    correct_answer: "singleton_class",
    accepted_synonyms: [],
    options: [],
    explanation: "`obj.singleton_class` returns the hidden eigenclass of `obj`. Methods defined on `obj` directly (via `def obj.method_name`) appear in `obj.singleton_class.instance_methods(false)`.",
    position: 2
  },

  # Lesson 15 — translation
  {
    lesson_id: 15,
    exercise_type: "translation",
    prompt: "Translate this Python `@total_ordering` class to Ruby using `Comparable`:\n```python\nfrom functools import total_ordering\n@total_ordering\nclass Score:\n    def __init__(self, v): self.v = v\n    def __eq__(self, o): return self.v == o.v\n    def __lt__(self, o): return self.v < o.v\n```",
    correct_answer: "class Score\n  include Comparable\n  attr_reader :v\n  def initialize(v) = @v = v\n  def <=>(other) = v <=> other.v\nend",
    accepted_synonyms: ["class Score with include Comparable and <=>"],
    options: [],
    explanation: "Ruby's `Comparable` module derives `<`, `<=`, `==`, `>=`, `>`, `between?`, and `clamp` from a single `<=>` method — equivalent to Python's `total_ordering`.",
    position: 1
  },
  # Lesson 15 — multiple_choice
  {
    lesson_id: 15,
    exercise_type: "multiple_choice",
    prompt: "What does `<=>` return when the left operand is greater than the right?",
    correct_answer: "1",
    accepted_synonyms: [],
    options: ["1", "-1", "0", "true"],
    explanation: "`<=>` returns `1` (positive) when left > right, `-1` when left < right, `0` when equal, and `nil` if comparison is undefined. `Comparable` uses these semantics.",
    position: 2
  },

  # ── Module 4: Metaprogramming ──────────────────────────────────────

  # Lesson 16 — fill_in_blank
  {
    lesson_id: 16,
    exercise_type: "fill_in_blank",
    prompt: "Use ____ inside a class body to create a method whose name is determined at runtime.",
    correct_answer: "define_method",
    accepted_synonyms: [],
    options: [],
    explanation: "`define_method(:name) { |args| ... }` creates an instance method with the given name. It closes over the surrounding binding, enabling data-driven method generation.",
    position: 1
  },
  # Lesson 16 — spot_the_bug
  {
    lesson_id: 16,
    exercise_type: "spot_the_bug",
    prompt: "```ruby\nclass Flags\n  %w[active admin].each do |flag|\n    def \"\#{flag}?\" = @attrs[flag]\n  end\nend\n```\nThis raises a SyntaxError. What should be used instead?",
    correct_answer: "define_method(\"\#{flag}?\") { @attrs[flag] }",
    accepted_synonyms: ["define_method :\"\#{flag}?\""],
    options: [],
    explanation: "`def` does not support string interpolation in method names. `define_method` accepts a string or symbol and is the correct tool for dynamically-named methods.",
    position: 2
  },

  # Lesson 17 — translation
  {
    lesson_id: 17,
    exercise_type: "translation",
    prompt: "Translate this Python runtime class patching to Ruby using `class_eval`:\n```python\nclass Dog: pass\nDog.speak = lambda self: 'Woof!'\n```",
    correct_answer: "Dog.class_eval { def speak = 'Woof!' }",
    accepted_synonyms: ["Dog.class_eval { def speak; 'Woof!'; end }"],
    options: [],
    explanation: "`class_eval` evaluates the block in the class's context, injecting `speak` as an instance method. This is equivalent to reopening the class with `class Dog`.",
    position: 1
  },
  # Lesson 17 — multiple_choice
  {
    lesson_id: 17,
    exercise_type: "multiple_choice",
    prompt: "What is the difference between `class_eval` and `instance_eval` on a class object?",
    correct_answer: "`class_eval` defines instance methods; `instance_eval` defines singleton methods",
    accepted_synonyms: [],
    options: [
      "`class_eval` defines instance methods; `instance_eval` defines singleton methods",
      "`instance_eval` defines instance methods; `class_eval` defines singleton methods",
      "They are equivalent on class objects",
      "`class_eval` only accepts strings, not blocks"
    ],
    explanation: "On a class `C`: `C.class_eval { def foo; end }` → `C.new.foo` works. `C.instance_eval { def foo; end }` → `C.foo` works (singleton method). They differ in the value of `self` and `def` placement.",
    position: 2
  },

  # Lesson 18 — fill_in_blank
  {
    lesson_id: 18,
    exercise_type: "fill_in_blank",
    prompt: "`Formatter.instance_method(:format)` returns an ____ that must be bound before calling.",
    correct_answer: "UnboundMethod",
    accepted_synonyms: [],
    options: [],
    explanation: "`instance_method` returns an `UnboundMethod`. Call `.bind(obj)` to produce a `Method` bound to a specific instance, then `.call` it.",
    position: 1
  },
  # Lesson 18 — multiple_choice
  {
    lesson_id: 18,
    exercise_type: "multiple_choice",
    prompt: "What method on `Method` tells you the number of required parameters?",
    correct_answer: "arity",
    accepted_synonyms: [],
    options: ["arity", "parameters", "count", "size"],
    explanation: "`Method#arity` returns the number of required arguments (negative means optional args present). `Method#parameters` returns a detailed `[[type, name], ...]` array.",
    position: 2
  },

  # Lesson 19 — fill_in_blank
  {
    lesson_id: 19,
    exercise_type: "fill_in_blank",
    prompt: "The ____ hook is called on the module itself when it is `include`d into a class.",
    correct_answer: "included",
    accepted_synonyms: ["self.included"],
    options: [],
    explanation: "`Module#included(base)` fires with the including class as `base`. Use it to `extend` the base with class methods or set up instance variables — the `ActiveSupport::Concern` pattern.",
    position: 1
  },
  # Lesson 19 — spot_the_bug
  {
    lesson_id: 19,
    exercise_type: "spot_the_bug",
    prompt: "```ruby\nclass Plugin\n  def self.inherited(subclass)\n    plugins << subclass\n  end\nend\nclass MyPlugin < Plugin; end\nPlugin.plugins\n```\nThis raises `NoMethodError: undefined method 'plugins'`. What is missing?",
    correct_answer: "@plugins = [] and def self.plugins = @plugins on Plugin",
    accepted_synonyms: ["missing class instance variable @plugins and plugins accessor"],
    options: [],
    explanation: "`@plugins` and `def self.plugins` are not defined. The `inherited` hook references `plugins` but the storage and accessor must be declared on `Plugin`.",
    position: 2
  },

  # Lesson 20 — multiple_choice
  {
    lesson_id: 20,
    exercise_type: "multiple_choice",
    prompt: "Which method provides safe dynamic dispatch that rejects private methods?",
    correct_answer: "public_send",
    accepted_synonyms: [],
    options: ["send", "public_send", "dispatch", "call"],
    explanation: "`public_send` raises `NoMethodError` for private methods, enforcing visibility. `send` bypasses visibility — suitable only for tests or trusted internal code.",
    position: 1
  },
  # Lesson 20 — translation
  {
    lesson_id: 20,
    exercise_type: "translation",
    prompt: "Translate this Python safe attribute update to Ruby using `public_send`:\n```python\nALLOWED = {'name', 'email'}\nfor k, v in params.items():\n    if k in ALLOWED: setattr(record, k, v)\n```",
    correct_answer: "ALLOWED.each { |k| record.public_send(:\"\#{k}=\", params[k]) if params.key?(k) }",
    accepted_synonyms: ["params.slice(*ALLOWED).each { |k, v| record.public_send(:\"\#{k}=\", v) }"],
    options: [],
    explanation: "`public_send(:\"\#{k}=\", v)` calls the setter while respecting visibility. `slice` restricts keys to the allowlist before iteration.",
    position: 2
  },

  # ── Module 5: Concurrency & Performance ───────────────────────────

  # Lesson 21 — fill_in_blank
  {
    lesson_id: 21,
    exercise_type: "fill_in_blank",
    prompt: "Call ____ inside a Fiber body to suspend execution and yield a value to the caller.",
    correct_answer: "Fiber.yield",
    accepted_synonyms: [],
    options: [],
    explanation: "`Fiber.yield(value)` suspends the fiber and passes `value` back to the `fiber.resume` call. Execution resumes at the `Fiber.yield` call site on the next `fiber.resume`.",
    position: 1
  },
  # Lesson 21 — multiple_choice
  {
    lesson_id: 21,
    exercise_type: "multiple_choice",
    prompt: "What is returned by `fiber.resume` after the Fiber finishes execution?",
    correct_answer: "The last evaluated expression in the Fiber body",
    accepted_synonyms: [],
    options: [
      "The last evaluated expression in the Fiber body",
      "nil always",
      "Raises FiberError",
      "The first value passed to Fiber.yield"
    ],
    explanation: "When a Fiber runs to completion (no more `Fiber.yield`), the final `resume` returns the last expression. Subsequent `resume` calls raise `FiberError: dead fiber called`.",
    position: 2
  },

  # Lesson 22 — fill_in_blank
  {
    lesson_id: 22,
    exercise_type: "fill_in_blank",
    prompt: "Use ____ to protect shared mutable state from concurrent thread access.",
    correct_answer: "Mutex",
    accepted_synonyms: ["mutex", "Mutex.new"],
    options: [],
    explanation: "`mutex.synchronize { ... }` ensures only one thread executes the block at a time. Without synchronization, `counter += 1` is a read-modify-write race condition.",
    position: 1
  },
  # Lesson 22 — spot_the_bug
  {
    lesson_id: 22,
    exercise_type: "spot_the_bug",
    prompt: "A developer argues that Ruby threads don't need Mutex because of the GVL. What is wrong with this reasoning?",
    correct_answer: "The GVL prevents parallel Ruby bytecode but not race conditions; compound operations like += are not atomic",
    accepted_synonyms: ["GVL does not make compound ops atomic", "GVL prevents parallelism not race conditions"],
    options: [],
    explanation: "The GVL prevents two threads from running Ruby bytecode simultaneously, but `i += 1` compiles to multiple bytecode instructions (read, increment, write). Thread scheduling can preempt between instructions, causing data races.",
    position: 2
  },

  # Lesson 23 — multiple_choice
  {
    lesson_id: 23,
    exercise_type: "multiple_choice",
    prompt: "Why is `@result ||= compute` problematic when `compute` can return `false` or `nil`?",
    correct_answer: "`||=` re-evaluates compute on every call if the result is falsy",
    accepted_synonyms: [],
    options: [
      "`||=` re-evaluates compute on every call if the result is falsy",
      "It raises a TypeError for nil",
      "`||=` is not valid Ruby syntax",
      "It creates a new variable on each call"
    ],
    explanation: "`a ||= b` expands to `a || (a = b)`. If `compute` returns `false` or `nil`, `@result` stays falsy and is re-computed on every call. Use a sentinel object for falsy-valid results.",
    position: 1
  },
  # Lesson 23 — translation
  {
    lesson_id: 23,
    exercise_type: "translation",
    prompt: "Translate this Python cached_property to Ruby memoization:\n```python\nfrom functools import cached_property\nclass Repo:\n    @cached_property\n    def connection(self): return connect_db()\n```",
    correct_answer: "class Repo\n  def connection\n    @connection ||= connect_db\n  end\nend",
    accepted_synonyms: ["@connection ||= connect_db()"],
    options: [],
    explanation: "`@connection ||= connect_db` is idiomatic Ruby memoization when `connect_db` cannot return `nil`/`false`. For falsy-valid results, use the sentinel pattern.",
    position: 2
  },

  # Lesson 24 — fill_in_blank
  {
    lesson_id: 24,
    exercise_type: "fill_in_blank",
    prompt: "Call `require \"____\"` before using `ObjectSpace.memsize_of`.",
    correct_answer: "objspace",
    accepted_synonyms: [],
    options: [],
    explanation: "`memsize_of` is not available by default. `require \"objspace\"` loads the C extension exposing memory-size introspection methods on Ruby objects.",
    position: 1
  },
  # Lesson 24 — multiple_choice
  {
    lesson_id: 24,
    exercise_type: "multiple_choice",
    prompt: "What does `ObjectSpace.count_objects[:T_STRING]` report?",
    correct_answer: "The current count of live String objects in the heap",
    accepted_synonyms: [],
    options: [
      "The current count of live String objects in the heap",
      "The total memory used by String objects",
      "The number of String allocations since process start",
      "The number of frozen strings"
    ],
    explanation: "`count_objects` returns a snapshot of live objects by type tag. `:T_STRING` counts live `String` instances at that moment, not cumulative allocations.",
    position: 2
  },

  # Lesson 25 — translation
  {
    lesson_id: 25,
    exercise_type: "translation",
    prompt: "Translate this Python multiprocessing parallel sum to Ruby using Ractors:\n```python\nfrom multiprocessing import Pool\nwith Pool(2) as p:\n    total = sum(p.map(sum, [range(1,100001), range(100001,200001)]))\n```",
    correct_answer: "r1 = Ractor.new { (1..100_000).sum }\nr2 = Ractor.new { (100_001..200_000).sum }\ntotal = r1.take + r2.take",
    accepted_synonyms: ["Ractor.new with .take"],
    options: [],
    explanation: "Ruby `Ractor.new` runs the block in a parallel actor. `.take` waits for the result. Unlike Python `multiprocessing`, Ractors share the same process with isolated state.",
    position: 1
  },
  # Lesson 25 — multiple_choice
  {
    lesson_id: 25,
    exercise_type: "multiple_choice",
    prompt: "Why must objects passed between Ractors be frozen or moved?",
    correct_answer: "Ractors isolate mutable state; sharing mutable objects would reintroduce data races",
    accepted_synonyms: [],
    options: [
      "Ractors isolate mutable state; sharing mutable objects would reintroduce data races",
      "Ractors only support Integer and String",
      "Ruby's object model does not allow cross-thread object access",
      "Frozen objects use less memory"
    ],
    explanation: "Ractors achieve parallel safety by restricting shared mutable state. Objects must be frozen (immutable) for sharing, or moved (ownership transferred) to prevent concurrent mutation.",
    position: 2
  }
].freeze
