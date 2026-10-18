--!strict
local D = require("../scripts/models/DiscoveryExperiment")
local seed = 1
for _, expected in { 16807, 282475249, 1622650073, 984943658, 1144108930 } do
	seed = D.uniform(seed)
	assert(seed == expected, "Park-Miller reference vector")
end
local s = D.new(42)
s.nextNatural = 900000
s.failures = 199999
assert(#D.advance(s, 1, true) == 1 and s.failures == 0 and s.archives == 1)
assert(#D.advance(s, 199999, true) == 0)
assert(#D.advance(s, 1, true) == 1 and s.failures == 0)
local a, b = D.new(71), D.new(71)
D.advance(a, 150000, true)
D.advance(a, 850000, true)
D.advance(b, 1000000, true)
assert(a.archives == b.archives and a.failures == b.failures and a.rng == b.rng)
local natural, forced = D.new(19), D.new(19)
D.advance(natural, 1000000, false)
D.advance(forced, 1000000, true)
assert(
	natural.nextNatural == forced.nextNatural and natural.rng == forced.rng,
	"paired stream shifted"
)
assert(not pcall(D.advance, b, 0.1, true))
print(
	"Discovery experiment: PRNG vector, H boundary, reset, chunk/reconnect retention and paired stream passed"
)
