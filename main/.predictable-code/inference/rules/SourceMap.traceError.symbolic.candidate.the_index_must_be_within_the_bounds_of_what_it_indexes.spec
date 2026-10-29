rule "sourceMap_traceError_requires_the_index_must_be_within_the_bounds_of_what_it_indexes"
  tier: pure
  effect: pure
  given:
  when: call precondition "The index must be within the bounds of what it indexes."
  then:
    throw "The index must be within the bounds of what it indexes."
  contracts:
    pre: call requires "The index must be within the bounds of what it indexes."
  examples: