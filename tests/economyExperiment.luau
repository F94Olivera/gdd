--!strict
local E = require("../scripts/models/EconomyExperiment")
local S = require("../scripts/economyScenarios")
local D = require("../scripts/models/DiscoveryExperiment")
local M = require("../scripts/models/BalanceMetrics")
local function near(a: number, b: number)
	assert(math.abs(a - b) < 1e-6, tostring(a) .. " != " .. tostring(b))
end
local s = S.base()
s.horizon = 40
local r = E.run(s)
assert(r.transactions[1].id == "extractor1")
near(r.transactions[1].online, 30 + 2 / 32)
near(r.totals.accepted, 40) -- replacement never adds manual + automatic
local repeated = E.run(s)
near(repeated.totals.intel, r.totals.intel)
local absent = S.base()
absent.horizon = 3640
absent.sessionSeconds = 20
absent.sessionPeriod = 3600
local interrupted = E.run(absent)
near(interrupted.totals.accepted, r.totals.accepted)
near(interrupted.totals.processed, r.totals.processed)
near(interrupted.transactions[1].calendar, 3610 + 2 / 32)
-- A stalled starter fills bounded output; no accepted work once full.
local stalled = S.base()
stalled.horizon = 10
stalled.capacity = 1
stalled.stalls = { { start = 0, finish = 10, kind = "transport" } }
near(E.run(stalled).totals.accepted, 1)
local impossible = S.base()
impossible.horizon = 20
impossible.manualSeconds = 10
local noPurchase = E.run(impossible)
assert(#noPurchase.transactions == 0 and noPurchase.nextPurchase.id == "extractor1")
-- Promotion is a consent-scripted scenario; save/rejoin preserves cumulative
-- accepted work. Eligibility fractions aren't rounded separately at sessions/reset.
local promoted = S.base()
promoted.horizon = 1600
promoted.promote = true
local pr = E.run(promoted)
assert(pr.firstPromotion and pr.clearance == 1 and pr.totals.lost > 0)
local state = D.new(33)
local previousWhole = 0
for _, snap in pr.snapshots do
	local whole = math.floor(snap.accepted + 1e-8)
	D.advance(state, whole - previousWhole, true)
	previousWhole = whole
end
local wholeRun = D.new(33)
D.advance(wholeRun, math.floor(pr.totals.accepted + 1e-8), true)
assert(state.archives == wholeRun.archives and state.failures == wholeRun.failures)
near(pr.totals.earned + pr.totals.grants, pr.totals.spent + pr.totals.resetIntel + pr.totals.intel)
-- Full-slice temporal sensitivity, no neighboring Production fixture.
local coarse = S.base()
coarse.horizon = 1800
local fine = table.clone(coarse)
fine.h = 1 / 64
local cr, fr = E.run(coarse), E.run(fine)
assert(#cr.transactions == 12 and #fr.transactions == 12)
assert(
	math.abs(cr.totals.accepted - fr.totals.accepted) < 20,
	"purchase timing sensitivity unexpectedly large"
)
local unaccelerated = table.clone(coarse)
unaccelerated.fastForward = false
local ur = E.run(unaccelerated)
near(cr.totals.accepted, ur.totals.accepted)
near(cr.totals.processed, ur.totals.processed)
near(cr.totals.transported, ur.totals.transported)
near(cr.totals.intel, ur.totals.intel)
assert(M.whole(0.4) == 0 and M.whole(0.8) == 0 and M.whole(1.2) == 1)
local c, o, m = M.timeAt(interrupted.segments, 31)
near(c, 3611)
near(o, 31)
near(m, 30.0625)
local censored = M.quantiles({ 1, 2, math.huge, math.huge }, 4)
assert(censored["0.5"].value == 2 and censored["0.9"].value == "not reached")
assert(not pcall(E.run, { h = 0 } :: any))
print(
	"Economy: purchase affordability, substitution, sessions, stalls, impossible buy, promotion, currency and eligibility retention passed"
)
